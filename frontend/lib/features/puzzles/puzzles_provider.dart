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
  // Prefer a precomputed origins summary if present.
  try {
    final raw = await rootBundle.loadString('assets/data/puzzles_index_origins.json');
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
  } on Object catch (_) {
    // ignore and fallback
  }

  // Fallback: parse master index but do the heavy JSON decode off the UI thread.
  final raw = await rootBundle.loadString('assets/data/puzzles_index.json');
  final parsed = await compute(_parseOriginsFromIndex, raw);
  parsed.sort();
  return parsed;
});

List<String> _parseOriginsFromIndex(String raw) {
  final parsed = jsonDecode(raw);
  final set = <String>{};
  if (parsed is List) {
    for (final e in parsed) {
      if (e is Map<String, dynamic>) {
        final o = e['origin']?.toString() ?? 'unknown';
        set.add(o);
      }
    }
  }
  return set.toList();
}

/// Provider to load the compact index for a single origin lazily.
final originIndexProvider = FutureProvider.family<List<PuzzleDescriptor>, String>((ref, origin) async {
  // Try per-origin file first.
  final originPath = 'assets/data/puzzles_index_by_origin/$origin.json';
  try {
    final raw = await rootBundle.loadString(originPath);
    final parsed = jsonDecode(raw);
    if (parsed is List) {
      final out = <PuzzleDescriptor>[];
      for (final e in parsed) {
        if (e is Map<String, dynamic>) {
          out.add(PuzzleDescriptor(
            id: e['id']?.toString() ?? '',
            title: e['title']?.toString() ?? '',
            path: e['path']?.toString() ?? '',
            subtitle: e['subtitle']?.toString() ?? '',
            origin: e['origin']?.toString() ?? origin,
            year: e['year']?.toString() ?? '',
          ));
        }
      }
      out.sort((a, b) => a.title.compareTo(b.title));
      return out;
    }
  } on Object catch (_) {
    // ignore and fallback
  }

  // Fallback: filter master index (parse off UI thread)
  final raw = await rootBundle.loadString('assets/data/puzzles_index.json');
  final list = await compute(_parseOriginListFromIndex, {'raw': raw, 'origin': origin});
  return list;
});

List<PuzzleDescriptor> _parseOriginListFromIndex(Map<String, String> args) {
  final raw = args['raw']!;
  final origin = args['origin']!;
  final parsed = jsonDecode(raw);
  final out = <PuzzleDescriptor>[];
  if (parsed is List) {
    for (final e in parsed) {
      if (e is Map<String, dynamic>) {
        final o = e['origin']?.toString() ?? 'unknown';
        if (o == origin) {
          out.add(PuzzleDescriptor(
            id: e['id']?.toString() ?? '',
            title: e['title']?.toString() ?? '',
            path: e['path']?.toString() ?? '',
            subtitle: e['subtitle']?.toString() ?? '',
            origin: o,
            year: e['year']?.toString() ?? '',
          ));
        }
      }
    }
  }
  out.sort((a, b) => a.title.compareTo(b.title));
  return out;
}

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
        out.add(PuzzleDescriptor(
          id: e['id']?.toString() ?? '',
          title: e['title']?.toString() ?? '',
          path: e['path']?.toString() ?? '',
          subtitle: e['subtitle']?.toString() ?? '',
          origin: e['origin']?.toString() ?? '',
          year: e['year']?.toString() ?? '',
        ));
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
final puzzleMetadataProvider = FutureProvider.family<PuzzleDescriptor, String>((ref, path) async {
  final token = puzzleTokenFromAssetPath(path);
  try {
    final data = jsonDecode(await rootBundle.loadString(path)) as Map<String, dynamic>;
    final title = puzzleTitleFromJson(data, fallback: token);
    final subtitle = (data['subtitle'] ?? '').toString();
    final parts = path.split('/');
    var origin = 'unknown';
    var year = '';
    if (parts.length >= 3) {
      origin = parts[2];
    }
    if (parts.length >= 4) {
      year = parts[3];
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
    if (parts.length >= 3) {
      origin = parts[2];
    }
    if (parts.length >= 4) {
      year = parts[3];
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
