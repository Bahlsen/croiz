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
  });
  final String id;
  final String title;
  final String path;
  final String subtitle;
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

/// Parse AssetManifest.json content into a list of asset paths under assets/data/*.json
List<String> parseAssetManifest(String manifestContent) {
  final manifest = jsonDecode(manifestContent) as Map<String, dynamic>;
  return manifest.keys
      .where((k) => k.startsWith('assets/data/') && k.endsWith('.json'))
      .where((k) => !k.endsWith('puzzles.json'))
      .toList();
}

/// FutureProvider that enumerates puzzle JSONs and extracts basic metadata (id/title/path).
final puzzlesProvider = FutureProvider<List<PuzzleDescriptor>>((ref) async {
  final manifestContent = await rootBundle.loadString('AssetManifest.json');
  final keys = parseAssetManifest(manifestContent);

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
      out.add(
        PuzzleDescriptor(
          id: token,
          title: title,
          path: path,
          subtitle: subtitle,
        ),
      );
    } on Object catch (_) {
      final name = path.split('/').last;
      out.add(PuzzleDescriptor(id: token, title: name, path: path));
    }
  }

  out.sort((a, b) => a.title.compareTo(b.title));
  return out;
});
