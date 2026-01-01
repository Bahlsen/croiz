import 'package:croiz/core/config/app_difficulty.dart';
import 'package:croiz/core/config/app_languages.dart';
import 'package:croiz/core/exceptions/user_friendly_exception.dart';
import 'package:croiz/features/generation/services/generation_orchestrator.dart';
import 'package:croiz/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class GenerationDialog extends ConsumerStatefulWidget {
  const GenerationDialog({super.key});

  @override
  ConsumerState<GenerationDialog> createState() => _GenerationDialogState();
}

class _GenerationDialogState extends ConsumerState<GenerationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _topicController = TextEditingController();
  String _language = 'en'; // Default to English
  double _difficulty = 3;
  int _size = 15;
  bool _isLoading = false;
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

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final orchestrator = ref.read(puzzleGenerationOrchestratorProvider);

      // Handle special case: Russian -> Ukrainian
      final targetLang = _language == 'ru' ? 'uk' : _language;

      final puzzleId = await orchestrator.generateAndSave(
        topic: _topicController.text,
        language: targetLang,
        difficulty: _difficulty.round(),
        size: _size,
      );

      if (mounted) {
        Navigator.of(context).pop(); // Close dialog

        // Show success snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)?.successMessage ??
                  'Puzzle generated successfully!',
            ),
            action: SnackBarAction(
              label: AppLocalizations.of(context)?.playButton ?? 'PLAY',
              onPressed: () {
                // Navigate to game
                context.push('/game/$puzzleId');
              },
            ),
          ),
        );
      }
    } on UserFriendlyException catch (e) {
      // Display user-friendly message
      if (mounted) {
        setState(() {
          _error = e.userMessage;
        });
      }
    } on Exception {
      // Fallback for any unexpected errors
      if (mounted) {
        setState(() {
          _error = 'An unexpected error occurred. Please try again.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Dialog(
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
                    return l10n?.errorTopicMissing ?? 'Please enter a topic';
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
                items: AppLanguages.supported.entries
                    .map(
                      (e) => DropdownMenuItem(
                        value: e.key,
                        child: Text('${e.value.flag} ${e.value.name}'),
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
                Flexible(
                  child: SingleChildScrollView(
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              SizedBox(
                height: 48,
                child: FilledButton(
                  onPressed: _isLoading ? null : _generate,
                  child: _isLoading
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
    );
  }
}
