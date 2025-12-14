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
/// Lightweight index provider: only reads the master index and returns minimal
/// descriptors (title is initially the token). This avoids loading thousands
/// of individual puzzle JSONs at app startup.
final puzzlesProvider = FutureProvider<List<PuzzleDescriptor>>((ref) async {
  // Prefer a precomputed metadata index if present (fast for web builds).
  try {
    final indexContent = await rootBundle.loadString('assets/data/puzzles_index.json');
    final parsed = jsonDecode(indexContent);
    if (parsed is List) {
      final out = <PuzzleDescriptor>[];
      for (final e in parsed) {
        if (e is Map<String, dynamic>) {
          out.add(PuzzleDescriptor(
            id: e['id']?.toString() ?? '',
            title: e['title']?.toString() ?? '',
            path: e['path']?.toString() ?? '',
            subtitle: e['subtitle']?.toString() ?? '',
            origin: e['origin']?.toString() ?? 'unknown',
            year: e['year']?.toString() ?? '',
          ));
        }
      }
      out.sort((a, b) {
        final o = a.origin.compareTo(b.origin);
        if (o != 0) return o;
        final y = a.year.compareTo(b.year);
        if (y != 0) return y;
        return a.title.compareTo(b.title);
      });
      return out;
    }
  } catch (_) {
    // ignore and fallback to live index
  }

  // Fallback: read master list and create lightweight descriptors (no full JSON load)
  final indexContent = await rootBundle.loadString('assets/data/puzzles.json');
  final parsed = jsonDecode(indexContent);
  if (parsed is! List) {
    throw Exception('assets/data/puzzles.json must contain a JSON array of asset paths');
  }
  final keys = parsed.whereType<String>().toList();

  final out = <PuzzleDescriptor>[];
  for (final path in keys) {
    final token = puzzleTokenFromAssetPath(path);
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
      title: token,
      path: path,
      origin: origin,
      year: year,
    ));
  }
  out.sort((a, b) {
    final o = a.origin.compareTo(b.origin);
    if (o != 0) return o;
    final y = a.year.compareTo(b.year);
    if (y != 0) return y;
    return a.title.compareTo(b.title);
  });
  return out;
});

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
    if (parts.length >= 3) origin = parts[2];
    if (parts.length >= 4) year = parts[3];
    return PuzzleDescriptor(
      id: token,
      title: title,
      path: path,
      subtitle: subtitle,
      origin: origin,
      year: year,
    );
  } catch (_) {
    // On error return a minimal descriptor preserving token/path.
    final parts = path.split('/');
    var origin = 'unknown';
    var year = '';
    if (parts.length >= 3) origin = parts[2];
    if (parts.length >= 4) year = parts[3];
    return PuzzleDescriptor(
      id: token,
      title: token,
      path: path,
      origin: origin,
      year: year,
    );
  }
});
