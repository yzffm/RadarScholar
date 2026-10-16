import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../controllers/ai_assistant_controller.dart';
import '../../models/ai_assistant.dart';
import '../../core/theme.dart';

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
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final textPrimary = AppTheme.textPrimaryOf(context);
    final textMuted = AppTheme.textMutedOf(context);
    final borderColor = AppTheme.borderColorOf(context);
    final primary = AppTheme.primaryOf(context);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: bottomInset,
          left: Spacing.lg,
          right: Spacing.lg,
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
                    color: borderColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          gradient: AppTheme.accentGradient,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: const Icon(
                          Icons.auto_awesome_rounded,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Asisten AI',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: textMuted),
                    onPressed: () => context.pop(),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Bantuan AI untuk mempersiapkan aplikasi beasiswa ini.',
                style: TextStyle(color: textMuted, fontSize: 13.5),
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
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                ),

              if (_selectedMode == AssistantTaskType.interview)
                Container(
                  padding: const EdgeInsets.all(Spacing.md),
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: primary.withValues(alpha: 0.28)),
                  ),
                  child: Text(
                    'Mode ini akan membangkitkan simulasi pertanyaan wawancara berdasarkan gabungan profil Anda dan detail beasiswa.',
                    style: TextStyle(
                      color: AppTheme.textSecondaryOf(context),
                      fontSize: 13,
                      height: 1.45,
                    ),
                  ),
                ),

              const SizedBox(height: Spacing.md),

              // Action Button / Result Display
              aiState.when(
                data: (response) {
                  final cardColor = AppTheme.surfaceElevatedOf(context);

                  if (response == null) {
                    return FilledButton.icon(
                      icon: const Icon(Icons.auto_awesome_rounded, size: 17),
                      label: const Text('Minta Bantuan AI'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.brandPrimary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                      onPressed: _generateFeedback,
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Hasil Analisis AI',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15.5,
                              color: textPrimary,
                            ),
                          ),
                          TextButton.icon(
                            icon: Icon(
                              Icons.refresh_rounded,
                              size: 16,
                              color: primary,
                            ),
                            label: Text(
                              'Buat Ulang',
                              style: TextStyle(color: primary),
                            ),
                            onPressed: () {
                              ref
                                  .read(aiAssistantControllerProvider.notifier)
                                  .reset();
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: Spacing.xs),
                      Container(
                        padding: const EdgeInsets.all(Spacing.md),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          border: Border.all(color: borderColor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              response.feedback,
                              style: TextStyle(
                                fontSize: 13.5,
                                color: textPrimary,
                                height: 1.6,
                              ),
                            ),
                            if (response.actionableTips.isNotEmpty) ...[
                              const SizedBox(height: Spacing.md),
                              Divider(color: borderColor),
                              const SizedBox(height: Spacing.sm),
                              Text(
                                'Langkah yang Bisa Dilakukan:',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: textPrimary,
                                ),
                              ),
                              const SizedBox(height: Spacing.sm),
                              ...response.actionableTips.map(
                                (tip) => Padding(
                                  padding: const EdgeInsets.only(bottom: 6.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.check_circle_outline_rounded,
                                        size: 16,
                                        color: primary,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          tip,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: AppTheme.textSecondaryOf(
                                              context,
                                            ),
                                            height: 1.45,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ],
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
                    color: AppTheme.statusDanger.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: AppTheme.statusDanger.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: AppTheme.statusDanger,
                      ),
                      const SizedBox(height: Spacing.sm),
                      Text(
                        'Asisten AI belum dapat memproses permintaan ini. Periksa profil, aplikasi, dan koneksi lalu coba lagi.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: textPrimary, fontSize: 13),
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
