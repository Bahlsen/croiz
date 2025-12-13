import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A simple descriptor for a puzzle packaged in assets.
class PuzzleDescriptor {
  PuzzleDescriptor({required this.id, required this.title, required this.path, this.subtitle = ''});
  final String id;
  final String title;
  final String path;
  final String subtitle;
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
    try {
      final data = jsonDecode(await rootBundle.loadString(path)) as Map<String, dynamic>;
      final id = (data['id'] ?? path.split('/').last.split('.').first).toString();
      final title = (data['title'] ?? data['meta']?['title'] ?? id).toString();
      final subtitle = (data['subtitle'] ?? '').toString();
      out.add(PuzzleDescriptor(id: id, title: title, path: path, subtitle: subtitle));
    } on Object catch (_) {
      final name = path.split('/').last;
      final id = name.split('.').first;
      out.add(PuzzleDescriptor(id: id, title: name, path: path));
    }
  }

  out.sort((a, b) => a.title.compareTo(b.title));
  return out;
});
