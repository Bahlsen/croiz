import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:croiz/features/puzzles/puzzles_provider.dart';

/// Displays all packaged puzzles and navigates with a short `id` token.
class PuzzlesListPage extends ConsumerWidget {
  const PuzzlesListPage({Key? key}) : super(key: key);

  Widget _buildList(BuildContext context, List<PuzzleDescriptor> items) =>
      ListView.separated(
        itemCount: items.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final p = items[index];
          return ListTile(
            title: Text(p.title),
            subtitle: p.subtitle.isNotEmpty ? Text(p.subtitle) : null,
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              final id = Uri.encodeComponent(p.id);
              context.go('/crossword?id=$id');
            },
          );
        },
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(puzzlesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Puzzles')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Could not load puzzles: $e')),
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('No puzzles found'));
          }
          return _buildList(context, items);
        },
      ),
    );
  }
}
