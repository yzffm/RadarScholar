import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/ai_assistant_controller.dart';
import '../../models/ai_assistant.dart';
import '../../core/theme.dart';
import 'package:go_router/go_router.dart';

class ApplicationAssistantSheet extends ConsumerStatefulWidget {
  final String applicationId;

  const ApplicationAssistantSheet({super.key, required this.applicationId});

  @override
  ConsumerState<ApplicationAssistantSheet> createState() =>
      _ApplicationAssistantSheetState();
}

class _ApplicationAssistantSheetState
    extends ConsumerState<ApplicationAssistantSheet> {
  AssistantTaskType _selectedMode = AssistantTaskType.cv;
  final TextEditingController _draftController = TextEditingController();

  @override
  void dispose() {
    _draftController.dispose();
    super.dispose();
  }

  String _getModeLabel(AssistantTaskType mode) {
    switch (mode) {
      case AssistantTaskType.cv:
        return 'CV';
      case AssistantTaskType.motivationLetter:
        return 'Motivation Letter';
      case AssistantTaskType.essay:
        return 'Esai';
      case AssistantTaskType.interview:
        return 'Wawancara';
    }
  }

  void _generateFeedback() {
    final draft = _draftController.text.trim();
    final request = AssistantRequest(
      taskType: _selectedMode,
      draftText: draft.isNotEmpty ? draft : null,
    );
    ref
        .read(aiAssistantControllerProvider.notifier)
        .getAssistantFeedback(widget.applicationId, request);
  }

  @override
  Widget build(BuildContext context) {
    final aiState = ref.watch(aiAssistantControllerProvider);
    // Determine bottom padding for keyboard
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: bottomInset,
          left: Spacing.md,
          right: Spacing.md,
          top: Spacing.md,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle for bottom sheet
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: Spacing.md),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Asisten AI',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => context.pop(),
                  ),
                ],
              ),
              const Text(
                'Bantuan AI untuk mempersiapkan aplikasi beasiswa ini.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: Spacing.md),

              // Mode Selection
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: AssistantTaskType.values.map((mode) {
                    final isSelected = _selectedMode == mode;
                    return Padding(
                      padding: const EdgeInsets.only(right: Spacing.sm),
                      child: ChoiceChip(
                        label: Text(_getModeLabel(mode)),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedMode = mode;
                            });
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: Spacing.md),

              // Draft Input
              if (_selectedMode != AssistantTaskType.interview)
                TextField(
                  controller: _draftController,
                  maxLines: 5,
                  minLines: 3,
                  maxLength: 20000,
                  decoration: InputDecoration(
                    hintText: 'Tempel draft di sini (opsional)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Spacing.sm),
                    ),
                  ),
                ),

              if (_selectedMode == AssistantTaskType.interview)
                Container(
                  padding: const EdgeInsets.all(Spacing.md),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(Spacing.sm),
                  ),
                  child: Text(
                    'Mode ini akan membangkitkan simulasi pertanyaan wawancara berdasarkan gabungan profil Anda dan detail beasiswa.',
                    style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer),
                  ),
                ),

              const SizedBox(height: Spacing.md),

              // Action Button / Result Display
              aiState.when(
                data: (response) {
                  if (response == null) {
                    return ElevatedButton.icon(
                      icon: const Icon(Icons.auto_awesome),
                      label: const Text('Minta Bantuan AI'),
                      onPressed: _generateFeedback,
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Hasil Analisis AI',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextButton.icon(
                            icon: const Icon(Icons.refresh, size: 16),
                            label: const Text('Buat Ulang'),
                            onPressed: () {
                              ref
                                  .read(aiAssistantControllerProvider.notifier)
                                  .reset();
                            },
                          ),
                        ],
                      ),
                      Card(
                        elevation: 0,
                        margin: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(Spacing.sm),
                          side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(Spacing.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(response.feedback),
                              if (response.actionableTips.isNotEmpty) ...[
                                const SizedBox(height: Spacing.md),
                                const Text(
                                  'Langkah yang Bisa Dilakukan:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: Spacing.sm),
                                ...response.actionableTips.map(
                                  (tip) => Padding(
                                    padding: const EdgeInsets.only(bottom: 4.0),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text('• '),
                                        Expanded(child: Text(tip)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: Spacing.lg),
                    ],
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.all(Spacing.md),
                  child: Center(
                    child: Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: Spacing.md),
                        Text('AI sedang menyusun saran untuk Anda...'),
                      ],
                    ),
                  ),
                ),
                error: (err, stack) => Container(
                  padding: const EdgeInsets.all(Spacing.md),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(Spacing.sm),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.error_outline, color: Theme.of(context).colorScheme.onErrorContainer),
                      const SizedBox(height: Spacing.sm),
                      Text(
                        err.toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
                      ),
                      TextButton(
                        onPressed: _generateFeedback,
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: Spacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
