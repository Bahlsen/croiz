import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:croiz/features/puzzles/puzzles_provider.dart';
import 'package:croiz/features/game/game_providers.dart';

/// Displays all packaged puzzles and navigates with a short `id` token.
class PuzzlesListPage extends ConsumerWidget {
  const PuzzlesListPage({Key? key}) : super(key: key);

  Widget _buildList(BuildContext context, WidgetRef ref) {
    final legacyAsync = ref.watch(puzzlesProvider);
    if (legacyAsync is AsyncData<List<PuzzleDescriptor>>) {
      // Tests may override the legacy provider; prefer it when already available.
      return _buildFromItems(context, ref, legacyAsync.value);
    }

    final originsAsync = ref.watch(puzzleOriginsProvider);
    return originsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Could not load origins: $e')),
      data: (origins) {
        final originKeys = List.of(origins)..sort();
        return ListView.separated(
          itemCount: originKeys.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, oi) {
            final origin = originKeys[oi];
            return ExpansionTile(
              title: Text(origin),
              children: [
                // Load the per-origin index lazily when this tile expands.
                Consumer(
                  builder: (context, ref2, _) {
                    final idx = ref2.watch(originIndexProvider(origin));
                    return idx.when(
                      loading: () => const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (e, st) => Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text('Error loading $origin: $e'),
                      ),
                      data: (items) {
                        // Group by year inside this origin
                        final years = <String, List<PuzzleDescriptor>>{};
                        for (final p in items) {
                          final y = p.year.isNotEmpty ? p.year : 'unknown';
                          years.putIfAbsent(y, () => []).add(p);
                        }
                        final yearKeys = years.keys.toList()..sort();
                        return Column(
                          children: yearKeys.map((year) {
                            final list = years[year]!
                              ..sort((a, b) => a.title.compareTo(b.title));
                            return ExpansionTile(
                              title: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                child: Text(
                                  year,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                              initiallyExpanded: false,
                              children: list.map((p) {
                                final token = p.path
                                    .split('/')
                                    .last
                                    .replaceAll('.json', '');
                                if (p.title != token) {
                                  return ListTile(
                                    title: Text(p.title),
                                    subtitle: p.subtitle.isNotEmpty
                                        ? Text(p.subtitle)
                                        : null,
                                    trailing: const Icon(Icons.chevron_right),
                                    onTap: () {
                                      ref
                                          .read(
                                            selectedPuzzleIdProvider.notifier,
                                          )
                                          .value = p
                                          .id;
                                      final id = Uri.encodeComponent(p.id);
                                      context.go('/crossword?id=$id');
                                    },
                                  );
                                }
                                final meta = ref.watch(
                                  puzzleMetadataProvider(p.path),
                                );
                                return meta.when(
                                  loading: () => ListTile(
                                    title: Text(p.title),
                                    subtitle: const Text('Loading...'),
                                    trailing: const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    onTap: () {
                                      ref
                                              .read(
                                                selectedPuzzleIdProvider
                                                    .notifier,
                                              )
                                              .value =
                                          token;
                                      final id = Uri.encodeComponent(token);
                                      context.go('/crossword?id=$id');
                                    },
                                  ),
                                  error: (_, __) => ListTile(
                                    title: Text(p.title),
                                    subtitle: const Text(
                                      'Error loading metadata',
                                    ),
                                    trailing: const Icon(
                                      Icons.error,
                                      color: Colors.red,
                                    ),
                                    onTap: () {
                                      ref
                                              .read(
                                                selectedPuzzleIdProvider
                                                    .notifier,
                                              )
                                              .value =
                                          token;
                                      final id = Uri.encodeComponent(token);
                                      context.go('/crossword?id=$id');
                                    },
                                  ),
                                  data: (full) => ListTile(
                                    title: Text(full.title),
                                    subtitle: full.subtitle.isNotEmpty
                                        ? Text(full.subtitle)
                                        : null,
                                    trailing: const Icon(Icons.chevron_right),
                                    onTap: () {
                                      ref
                                          .read(
                                            selectedPuzzleIdProvider.notifier,
                                          )
                                          .value = full
                                          .id;
                                      final id = Uri.encodeComponent(full.id);
                                      context.go('/crossword?id=$id');
                                    },
                                  ),
                                );
                              }).toList(),
                            );
                          }).toList(),
                        );
                      },
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildFromItems(
    BuildContext context,
    WidgetRef ref,
    List<PuzzleDescriptor> items,
  ) {
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
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: originKeys.length,
      itemBuilder: (context, oi) {
        final origin = originKeys[oi];
        final yearsMap = groups[origin]!;
        final yearKeys = List.of(yearsMap.keys)..sort();
        return ExpansionTile(
          title: Text(origin),
          initiallyExpanded: false,
          children: yearKeys.map((year) {
            final list = List.of(yearsMap[year]!)
              ..sort((a, b) => a.title.compareTo(b.title));
            return ExpansionTile(
              initiallyExpanded: false,
              title: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
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
                      final token = p.path
                          .split('/')
                          .last
                          .replaceAll('.json', '');
                      if (p.title != token) {
                        return ListTile(
                          title: Text(p.title),
                          subtitle: p.subtitle.isNotEmpty
                              ? Text(p.subtitle)
                              : null,
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            ref.read(selectedPuzzleIdProvider.notifier).value =
                                p.id;
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
                          trailing: const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          onTap: () {
                            ref.read(selectedPuzzleIdProvider.notifier).value =
                                token;
                            final id = Uri.encodeComponent(token);
                            context.go('/crossword?id=$id');
                          },
                        ),
                        error: (_, __) => ListTile(
                          title: Text(p.title),
                          subtitle: const Text('Error loading metadata'),
                          trailing: const Icon(Icons.error, color: Colors.red),
                          onTap: () {
                            ref.read(selectedPuzzleIdProvider.notifier).value =
                                token;
                            final id = Uri.encodeComponent(token);
                            context.go('/crossword?id=$id');
                          },
                        ),
                        data: (full) => ListTile(
                          title: Text(full.title),
                          subtitle: full.subtitle.isNotEmpty
                              ? Text(full.subtitle)
                              : null,
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            ref.read(selectedPuzzleIdProvider.notifier).value =
                                full.id;
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
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(title: const Text('Puzzles')),
    body: _buildList(context, ref),
  );
}
