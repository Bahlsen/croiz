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
/// Strict behaviour: requires `assets/data/puzzles_index.json` to exist and contain
/// a JSON object with an "items" array. Each item must have an "origin" field.
/// Provider that returns the list of available origins (for lazy-loading).
final puzzleOriginsProvider = FutureProvider<List<String>>((ref) async {
  final rawIndex = await rootBundle.loadString(
    'assets/data/puzzles_index.json',
  );
  final parsedIndex = jsonDecode(rawIndex);

  if (parsedIndex is! Map<String, dynamic>) {
    throw StateError('Invalid puzzles_index.json: expected JSON object.');
  }

  final items = parsedIndex['items'];
  if (items is! List || items.isEmpty) {
    throw StateError(
      'Invalid puzzles_index.json: "items" array is missing or empty.',
    );
  }

  final origins = <String>{};
  for (final e in items) {
    if (e is Map<String, dynamic>) {
      final origin = e['origin']?.toString();
      if (origin != null && origin.isNotEmpty) {
        origins.add(origin);
      }
    }
  }

  if (origins.isEmpty) {
    throw StateError(
      'Invalid puzzles_index.json: no valid origins found in items.',
    );
  }

  return origins.toList()..sort();
});

/// Provider to load puzzles for a single origin from the main index.
final originIndexProvider =
    FutureProvider.family<List<PuzzleDescriptor>, String>((ref, origin) async {
      final rawIndex = await rootBundle.loadString(
        'assets/data/puzzles_index.json',
      );
      final parsedIndex = jsonDecode(rawIndex);

      if (parsedIndex is! Map<String, dynamic>) {
        throw StateError('Invalid puzzles_index.json: expected JSON object.');
      }

      final items = parsedIndex['items'];
      if (items is! List) {
        throw StateError(
          'Invalid puzzles_index.json: "items" array is missing.',
        );
      }

      final out = <PuzzleDescriptor>[];
      for (final e in items) {
        if (e is Map<String, dynamic>) {
          final itemOrigin = e['origin']?.toString() ?? '';
          if (itemOrigin == origin) {
            final rawPath = e['path']?.toString() ?? '';
            out.add(
              PuzzleDescriptor(
                id: e['id']?.toString() ?? '',
                title: e['title']?.toString() ?? '',
                path: _normalizeIndexedPath(rawPath),
                subtitle: e['subtitle']?.toString() ?? '',
                origin: itemOrigin,
                year: e['year']?.toString() ?? '',
              ),
            );
          }
        }
      }

      out.sort(_sortByYearDescThenTitle);
      return out;
    });

int _sortByYearDescThenTitle(PuzzleDescriptor a, PuzzleDescriptor b) {
  final ai = int.tryParse(a.year) ?? -9999;
  final bi = int.tryParse(b.year) ?? -9999;
  final yc = bi.compareTo(ai);
  if (yc != 0) {
    return yc;
  }
  return a.title.compareTo(b.title);
}

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

  // Expect merged index format: object { items: [ ... ] }
  var entries = <dynamic>[];
  if (parsed is Map<String, dynamic>) {
    final items = parsed['items'];
    if (items is List) {
      entries = items;
    }
  }
  if (entries.isEmpty) {
    throw StateError(
      'Invalid puzzles_index.json: expected merged object with "items" list.',
    );
  }

  for (final e in entries) {
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
  out.sort((a, b) {
    final o = a.origin.compareTo(b.origin);
    if (o != 0) {
      return o;
    }
    final ai = int.tryParse(a.year) ?? -9999;
    final bi = int.tryParse(b.year) ?? -9999;
    final y = bi.compareTo(ai);
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
  } on Object catch (err) {
    // Strict behavior: propagate error so UI can show an explicit failure.
    throw StateError('Failed to load puzzle metadata for "$path": $err');
  }
});
