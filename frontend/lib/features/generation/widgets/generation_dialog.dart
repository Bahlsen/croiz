import 'dart:async';
import 'package:croiz/core/config/app_difficulty.dart';
import 'package:croiz/core/config/app_languages.dart';
import 'package:croiz/features/generation/logic/generation_controller.dart';
import 'package:croiz/features/puzzles/pending_puzzles_provider.dart';
import 'package:croiz/services/providers.dart';
import 'package:croiz/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GenerationDialog extends ConsumerStatefulWidget {
  const GenerationDialog({super.key});

  @override
  ConsumerState<GenerationDialog> createState() => _GenerationDialogState();
}

class _GenerationDialogState extends ConsumerState<GenerationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _topicController = TextEditingController();
  String _language = 'en';

  @override
  void initState() {
    super.initState();
    // Default to current app locale if supported for generation, otherwise default to English
    final appLanguage = ref.read(localeProvider).languageCode;
    _language =
        AppLanguages.puzzleSupported.contains(appLanguage) ? appLanguage : 'en';
  }

  double _difficulty = 3;
  int _size = 15;
  String? _error;

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final pending = ref.read(pendingPuzzlesProvider);
    if (pending.isNotEmpty) {
      setState(() {
        _error = 'A generation is already in progress. Please wait.';
      });
      return;
    }

    // Start generation in background
    unawaited(
      ref
          .read(generationControllerProvider.notifier)
          .generateInBackgroundTask(
            topic: _topicController.text,
            language: _language,
            difficulty: _difficulty.round(),
            size: _size,
          ),
    );

    // Close immediately
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n?.generatorTitle ?? 'Puzzle Generator',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _topicController,
                    decoration: InputDecoration(
                      labelText: l10n?.topicLabel ?? 'Topic',
                      hintText: l10n?.topicHint,
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n?.errorTopicMissing ??
                            'Please enter a topic';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    key: ValueKey(_language),
                    initialValue: _language,
                    decoration: InputDecoration(
                      labelText: l10n?.languageLabel ?? 'Language',
                      border: const OutlineInputBorder(),
                    ),
                    items:
                        AppLanguages.puzzleSupported
                            .map(
                              (code) => DropdownMenuItem(
                                value: code,
                                child: Text(
                                  '${AppLanguages.getFlag(code)} ${AppLanguages.getName(code)}',
                                ),
                              ),
                            )
                            .toList(),
                    onChanged: (v) => setState(() => _language = v!),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    key: ValueKey(_size),
                    initialValue: _size,
                    decoration: InputDecoration(
                      labelText: l10n?.sizeLabel ?? 'Grid Size',
                      border: const OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: 10,
                        child: Text('10x10 (${l10n?.quick ?? 'Quick'})'),
                      ),
                      const DropdownMenuItem(value: 12, child: Text('12x12')),
                      DropdownMenuItem(
                        value: 15,
                        child: Text('15x15 (${l10n?.standard ?? 'Standard'})'),
                      ),
                      const DropdownMenuItem(
                        value: 20,
                        child: Text('20x20 (Large)'),
                      ),
                      const DropdownMenuItem(
                        value: 25,
                        child: Text('25x25 (Extra Large)'),
                      ),
                    ],
                    onChanged: (v) => setState(() => _size = v!),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${l10n?.difficultyLabel ?? 'Difficulty'} : ${_difficulty.round()} (${AppDifficulty.getLabel(_difficulty.round())})',
                  ),
                  Slider(
                    value: _difficulty,
                    min: AppDifficulty.minLevel.toDouble(),
                    max: AppDifficulty.maxLevel.toDouble(),
                    divisions: AppDifficulty.maxLevel - AppDifficulty.minLevel,
                    label: AppDifficulty.getLabel(_difficulty.round()),
                    onChanged: (v) => setState(() => _difficulty = v),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 48,
                    child: FilledButton(
                      onPressed:
                          ref.watch(pendingPuzzlesProvider).isNotEmpty
                              ? null
                              : _generate,
                      child:
                          ref.watch(pendingPuzzlesProvider).isNotEmpty
                              ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : Text(l10n?.generateButton ?? 'GENERATE'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
