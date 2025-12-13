import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:go_router/go_router.dart';

class PuzzlesListPage extends StatelessWidget {
  const PuzzlesListPage({Key? key, this.puzzles}) : super(key: key);

  /// If [puzzles] is provided, it will be used directly (useful for tests).
  final List<Map<String, String>>? puzzles;

  Future<List<Map<String, String>>> _loadFromAssets() async =>
      (jsonDecode(await rootBundle.loadString('assets/data/puzzles.json'))
              as List<dynamic>)
          .map((e) => Map<String, String>.from(e as Map<String, dynamic>))
          .toList();

  Widget _buildList(BuildContext context, List<Map<String, String>> items) =>
      ListView.separated(
        itemCount: items.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final p = items[index];
          return ListTile(
            title: Text(p['title'] ?? ''),
            subtitle: Text(p['subtitle'] ?? ''),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              final id = p['id'];
              if (id != null) {
                context.go('/crossword?id=$id');
              }
            },
          );
        },
      );

  @override
  Widget build(BuildContext context) {
    if (puzzles != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Puzzles')),
        body: _buildList(context, puzzles!),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Puzzles')),
      body: FutureBuilder<List<Map<String, String>>>(
        future: _loadFromAssets(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Could not load puzzles: ${snapshot.error}'),
            );
          }
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return const Center(child: Text('No puzzles found'));
          }
          return _buildList(context, items);
        },
      ),
    );
  }
}
