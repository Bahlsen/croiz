import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
final puzzlesProvider = FutureProvider<List<PuzzleDescriptor>>((ref) async {
  final indexContent = await rootBundle.loadString('assets/data/puzzles.json');
  final parsed = jsonDecode(indexContent);
  if (parsed is! List) {
    throw Exception('assets/data/puzzles.json must contain a JSON array of asset paths');
  }
  final keys = parsed.whereType<String>().toList();

  final out = <PuzzleDescriptor>[];
  for (final path in keys) {
    final token = puzzleTokenFromAssetPath(path);
    try {
      final data =
          jsonDecode(await rootBundle.loadString(path)) as Map<String, dynamic>;
      // IMPORTANT: do NOT use JSON `id` for routing.
      // Many puzzle JSONs use a human-readable title in `id`, which does not
      // match the asset filename. Routing must use the filename token.
      final title = puzzleTitleFromJson(data, fallback: token);
      final subtitle = (data['subtitle'] ?? '').toString();
      // Derive origin and year from the asset path: assets/data/<origin>/<year>/file.json
      final parts = path.split('/');
      var origin = 'unknown';
      var year = '';
      if (parts.length >= 3) {
        origin = parts[2];
      }
      if (parts.length >= 4) {
        year = parts[3];
      }
      out.add(
        PuzzleDescriptor(
          id: token,
          title: title,
          path: path,
          subtitle: subtitle,
          origin: origin,
          year: year,
        ),
      );
    } on Object catch (_) {
      final name = path.split('/').last;
      final parts = path.split('/');
      var origin = 'unknown';
      var year = '';
      if (parts.length >= 3) {
        origin = parts[2];
      }
      if (parts.length >= 4) {
        year = parts[3];
      }
      out.add(PuzzleDescriptor(
        id: token,
        title: name,
        path: path,
        origin: origin,
        year: year,
      ));
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
});
