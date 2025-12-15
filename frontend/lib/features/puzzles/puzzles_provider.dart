import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

/// A simple descriptor for a puzzle packaged in assets.
class PuzzleDescriptor {
  PuzzleDescriptor({
    required this.id,
    required this.title,
    required this.path,
    this.subtitle = '',
    this.origin = 'unknown',
    this.year = '',
  });
  final String id;
  final String title;
  final String path;
  final String subtitle;
  final String origin;
  final String year;
}

/// Extract a stable short token from an asset path.
///
/// Example: `assets/data/nyt2005-01-01.json` -> `nyt2005-01-01`.
///
/// IMPORTANT: this is the token used for routing and for resolving an asset
/// via `assetPathForPuzzleId()`.
String puzzleTokenFromAssetPath(String assetPath) {
  final file = assetPath.split('/').last;
  if (file.toLowerCase().endsWith('.json')) {
    return file.substring(0, file.length - '.json'.length);
  }
  return file;
}

String _normalizeIndexedPath(String assetPath) {
  // Strict behaviour: indexed paths MUST be relative to `assets/data/`.
  // Do not perform any legacy fallback or normalization here. If the
  // generator produced a path with a leading `assets/` or `data/`, fail
  // loudly so the index generation can be corrected.
  if (assetPath.startsWith('assets/') || assetPath.startsWith('data/')) {
    throw StateError(
      'Indexed path must be relative to assets/data/: $assetPath',
    );
  }
  return assetPath;
}

/// Extract a display title from puzzle JSON.
///
/// Prefers `title`, then `metadata.title`, then `meta.title`, else `fallback`.
String puzzleTitleFromJson(
  Map<String, dynamic> data, {
  required String fallback,
}) {
  final direct = data['title'];
  if (direct is String && direct.trim().isNotEmpty) {
    return direct.trim();
  }

  // Canonical schema uses `metadata`.
  final metadata = data['metadata'];
  if (metadata is Map<String, dynamic>) {
    final metaTitle = metadata['title'];
    if (metaTitle is String && metaTitle.trim().isNotEmpty) {
      return metaTitle.trim();
    }
  }

  // Backward-compat for earlier experiments that used `meta`.
  final meta = data['meta'];
  if (meta is Map<String, dynamic>) {
    final metaTitle = meta['title'];
    if (metaTitle is String && metaTitle.trim().isNotEmpty) {
      return metaTitle.trim();
    }
  }

  return fallback;
}

/// FutureProvider that enumerates puzzle JSONs and extracts basic metadata (id/title/path).
///
/// Strict behaviour: requires `assets/data/puzzles.json` to exist and contain
/// a JSON array of asset paths. No fallback to `AssetManifest.json`.
/// Lightweight index provider: only reads the master index and returns minimal
/// descriptors (title is initially the token). This avoids loading thousands
/// of individual puzzle JSONs at app startup.
/// Provider that returns the list of available origins (for lazy-loading).
final puzzleOriginsProvider = FutureProvider<List<String>>((ref) async {
  // Strict: require precomputed origins summary; no fallback.
  final raw = await rootBundle.loadString(
    'assets/data/puzzles_index_origins.json',
  );
  final parsed = jsonDecode(raw);
  if (parsed is List) {
    final out = <String>[];
    for (final e in parsed) {
      if (e is Map<String, dynamic>) {
        final origin = e['origin']?.toString();
        if (origin != null) {
          out.add(origin);
        }
      } else if (e is String) {
        out.add(e);
      }
    }
    out.sort();
    return out;
  }
  throw StateError('Invalid origins summary format.');
});

/// Provider to load the compact index for a single origin lazily.
final originIndexProvider =
    FutureProvider.family<List<PuzzleDescriptor>, String>((ref, origin) async {
      // Strict: require per-origin compact index; no fallback.
      final originPath = 'assets/data/puzzles_index_by_origin/$origin.json';
      final raw = await rootBundle.loadString(originPath);
      final parsed = jsonDecode(raw);
      if (parsed is List) {
        final out = <PuzzleDescriptor>[];
        for (final e in parsed) {
          if (e is Map<String, dynamic>) {
            final rawPath = e['path']?.toString() ?? '';
            out.add(
              PuzzleDescriptor(
                id: e['id']?.toString() ?? '',
                title: e['title']?.toString() ?? '',
                path: _normalizeIndexedPath(rawPath),
                subtitle: e['subtitle']?.toString() ?? '',
                origin: e['origin']?.toString() ?? origin,
                year: e['year']?.toString() ?? '',
              ),
            );
          }
        }
        out.sort((a, b) => a.title.compareTo(b.title));
        return out;
      }
      throw StateError('Invalid origin index format for $origin.');
    });

// Fallback parsing removed: origin indexes must be provided via
// assets/data/puzzles_index_by_origin/<origin>.json.

/// Backwards-compatible provider returning all puzzles (parses off UI thread).
final puzzlesProvider = FutureProvider<List<PuzzleDescriptor>>((ref) async {
  final raw = await rootBundle.loadString('assets/data/puzzles_index.json');
  final list = await compute(_parseAllFromIndex, raw);
  return list;
});

List<PuzzleDescriptor> _parseAllFromIndex(String raw) {
  final parsed = jsonDecode(raw);
  final out = <PuzzleDescriptor>[];
  if (parsed is List) {
    for (final e in parsed) {
      if (e is Map<String, dynamic>) {
        final rawPath = e['path']?.toString() ?? '';
        out.add(
          PuzzleDescriptor(
            id: e['id']?.toString() ?? '',
            title: e['title']?.toString() ?? '',
            path: _normalizeIndexedPath(rawPath),
            subtitle: e['subtitle']?.toString() ?? '',
            origin: e['origin']?.toString() ?? '',
            year: e['year']?.toString() ?? '',
          ),
        );
      }
    }
  }
  out.sort((a, b) {
    final o = a.origin.compareTo(b.origin);
    if (o != 0) {
      return o;
    }
    final y = a.year.compareTo(b.year);
    if (y != 0) {
      return y;
    }
    return a.title.compareTo(b.title);
  });
  return out;
}

/// Loads full metadata for a single puzzle asset path on demand.
final puzzleMetadataProvider = FutureProvider.family<PuzzleDescriptor, String>((
  ref,
  path,
) async {
  // `path` here is the normalized indexed path (no leading `assets/`).
  final token = puzzleTokenFromAssetPath(path);
  try {
    // `path` is relative to `assets/data/` (e.g. "crosswordsclub/2001/cc-1162.json").
    final data =
        jsonDecode(await rootBundle.loadString('assets/data/$path'))
            as Map<String, dynamic>;
    final title = puzzleTitleFromJson(data, fallback: token);
    final subtitle = (data['subtitle'] ?? '').toString();
    final parts = path.split('/');
    var origin = 'unknown';
    var year = '';
    if (parts.isNotEmpty) {
      origin = parts[0];
    }
    if (parts.length >= 2) {
      year = parts[1];
    }
    return PuzzleDescriptor(
      id: token,
      title: title,
      path: path,
      subtitle: subtitle,
      origin: origin,
      year: year,
    );
  } on Object catch (_) {
    // On error return a minimal descriptor preserving token/path.
    final parts = path.split('/');
    var origin = 'unknown';
    var year = '';
    if (parts.isNotEmpty) {
      origin = parts[0];
    }
    if (parts.length >= 2) {
      year = parts[1];
    }
    return PuzzleDescriptor(
      id: token,
      title: token,
      path: path,
      origin: origin,
      year: year,
    );
  }
});
