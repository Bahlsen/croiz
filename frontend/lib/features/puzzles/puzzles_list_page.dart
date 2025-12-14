import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:croiz/features/puzzles/puzzles_provider.dart';
import 'package:croiz/features/game/game_providers.dart';

/// Displays all packaged puzzles and navigates with a short `id` token.
class PuzzlesListPage extends ConsumerWidget {
  const PuzzlesListPage({Key? key}) : super(key: key);

  Widget _buildList(
    BuildContext context,
    WidgetRef ref,
    List<PuzzleDescriptor> items,
  ) => ListView.separated(
    itemCount: 1,
    separatorBuilder: (_, __) => const Divider(height: 1),
    itemBuilder: (context, index) {
      // Group by origin then by year
      final groups = <String, Map<String, List<PuzzleDescriptor>>>{};
      for (final p in items) {
        final byOrigin = groups.putIfAbsent(p.origin, () => {});
        final y = p.year.isNotEmpty ? p.year : 'unknown';
        byOrigin.putIfAbsent(y, () => <PuzzleDescriptor>[]).add(p);
      }

      final originKeys = List.of(groups.keys)..sort();

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: originKeys.length,
        itemBuilder: (context, oi) {
          final origin = originKeys[oi];
          final yearsMap = groups[origin]!;
          final yearKeys = List.of(yearsMap.keys)..sort();
          return ExpansionTile(
            title: Text(origin),
            initiallyExpanded: true,
            children: yearKeys.map((year) {
              final list = List.of(yearsMap[year]!)..sort((a, b) => a.title.compareTo(b.title));
              return ExpansionTile(
                initiallyExpanded: true,
                title: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(year, style: Theme.of(context).textTheme.bodySmall),
                ),
                children: [
                  SizedBox(
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: list.length,
                      itemBuilder: (context, i) {
                        final p = list[i];
                        final token = p.path.split('/').last.replaceAll('.json', '');
                        if (p.title != token) {
                          // Caller provided a title (e.g. tests). Show it immediately.
                          return ListTile(
                            title: Text(p.title),
                            subtitle: p.subtitle.isNotEmpty ? Text(p.subtitle) : null,
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              ref.read(selectedPuzzleIdProvider.notifier).value = p.id;
                              final id = Uri.encodeComponent(p.id);
                              context.go('/crossword?id=$id');
                            },
                          );
                        }

                        final meta = ref.watch(puzzleMetadataProvider(p.path));
                        return meta.when(
                          loading: () => ListTile(
                            title: Text(p.title),
                            subtitle: const Text('Loading...'),
                            trailing: const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
                          ),
                          error: (_, __) => ListTile(
                            title: Text(p.title),
                            subtitle: const Text('Error loading metadata'),
                            trailing: const Icon(Icons.error, color: Colors.red),
                            onTap: () {},
                          ),
                          data: (full) => ListTile(
                            title: Text(full.title),
                            subtitle: full.subtitle.isNotEmpty ? Text(full.subtitle) : null,
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              ref.read(selectedPuzzleIdProvider.notifier).value = full.id;
                              final id = Uri.encodeComponent(full.id);
                              context.go('/crossword?id=$id');
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            }).toList(),
          );
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
          return _buildList(context, ref, items);
        },
      ),
    );
  }
}
