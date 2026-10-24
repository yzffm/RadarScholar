import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../controllers/ai_assistant_controller.dart';
import '../../controllers/application_controller.dart';
import '../../core/theme.dart';
import '../../models/ai_assistant.dart';
import '../../models/application.dart';

/// Interactive AI Copilot Workspace for scholarship preparation.
///
/// Fully functional workspace supporting:
/// - Selecting a tracked application context
/// - 4 AI assistant modes (Review CV, Motivation Letter, Feedback Esai, Latihan Wawancara)
/// - Direct draft input and real-time grounded AI evaluation
/// - Rich display of actionable recommendations and zero-fabrication trust cues.
class AssistantPage extends ConsumerStatefulWidget {
  const AssistantPage({super.key});

  @override
  ConsumerState<AssistantPage> createState() => _AssistantPageState();
}

class _AssistantPageState extends ConsumerState<AssistantPage> {
  String? _selectedApplicationId;
  AssistantTaskType _selectedMode = AssistantTaskType.cv;
  final TextEditingController _draftController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(applicationsControllerProvider.notifier).fetchApplications();
    });
  }

  @override
  void dispose() {
    _draftController.dispose();
    super.dispose();
  }

  String _getModeTitle(AssistantTaskType mode) {
    switch (mode) {
      case AssistantTaskType.cv:
        return 'Review CV';
      case AssistantTaskType.motivationLetter:
        return 'Motivation Letter';
      case AssistantTaskType.essay:
        return 'Feedback Esai';
      case AssistantTaskType.interview:
        return 'Latihan Wawancara';
    }
  }

  String _getModeDescription(AssistantTaskType mode) {
    switch (mode) {
      case AssistantTaskType.cv:
        return 'Soroti pengalaman yang relevan dengan persyaratan beasiswa tanpa mengarang fakta.';
      case AssistantTaskType.motivationLetter:
        return 'Susun struktur dan perkuat alasan yang berasal dari pengalaman nyata Anda.';
      case AssistantTaskType.essay:
        return 'Periksa alur, kejelasan narasi, dan keterkaitan draft dengan nilai beasiswa.';
      case AssistantTaskType.interview:
        return 'Dapatkan simulasi pertanyaan wawancara kontekstual dan panduan menjawab STAR.';
    }
  }

  String _getInputHint(AssistantTaskType mode) {
    switch (mode) {
      case AssistantTaskType.cv:
        return 'Tempelkan ringkasan pengalaman, riwayat organisasi, atau poin CV Anda di sini...';
      case AssistantTaskType.motivationLetter:
        return 'Tuliskan draf surat motivasi atau alasan Anda mendaftar beasiswa ini di sini...';
      case AssistantTaskType.essay:
        return 'Tempelkan draf esai Anda untuk diperiksa struktur dan kekuatannya di sini...';
      case AssistantTaskType.interview:
        return '(Opsional) Masukkan fokus minat atau pertanyaan yang paling Anda khawatirkan...';
    }
  }

  void _runAssistant(String applicationId) {
    final draft = _draftController.text.trim();
    final request = AssistantRequest(
      taskType: _selectedMode,
      draftText: draft.isNotEmpty ? draft : null,
    );
    ref
        .read(aiAssistantControllerProvider.notifier)
        .getAssistantFeedback(applicationId, request);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final primaryColor = AppTheme.primaryOf(context);
    final textPrimary = AppTheme.textPrimaryOf(context);
    final textMuted = AppTheme.textMutedOf(context);
    final screenWidth = MediaQuery.of(context).size.width;

    final appState = ref.watch(applicationsControllerProvider);
    final aiState = ref.watch(aiAssistantControllerProvider);

    List<Application> applications = [];
    if (appState is ApplicationsSuccess) {
      applications = appState.applications;
      if (_selectedApplicationId == null && applications.isNotEmpty) {
        _selectedApplicationId = applications.first.id;
      }
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1080),
            child: SingleChildScrollView(
              padding: Spacing.pagePadding(screenWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Workspace Header
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: primaryColor.withValues(
                                  alpha: isDark ? 0.14 : 0.08,
                                ),
                                borderRadius: BorderRadius.circular(AppRadius.xs),
                                border: Border.all(
                                  color: primaryColor.withValues(alpha: 0.25),
                                ),
                              ),
                              child: Text(
                                'AI COPILOT WORKSPACE',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.1,
                                  color: primaryColor,
                                ),
                              ),
                            ),
                            Text(
                              'Ruang Persiapan',
                              style: TextStyle(
                                fontSize: screenWidth < 600 ? 24 : 28,
                                fontWeight: FontWeight.w800,
                                color: textPrimary,
                                letterSpacing: -0.6,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Gunakan AI sebagai pendamping terpercaya untuk menyiapkan berkas aplikasi berdasarkan profil dan beasiswa yang kamu lacak.',
                              style: TextStyle(
                                fontSize: 13.5,
                                color: textMuted,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (screenWidth >= 640)
                        OutlinedButton.icon(
                          onPressed: () => context.go('/applications'),
                          icon: const Icon(Icons.track_changes_rounded, size: 16),
                          label: const Text(
                            'Buka Application Tracker',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: primaryColor,
                            side: BorderSide(
                              color: primaryColor.withValues(alpha: 0.35),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: Spacing.xl),

                  // Applications Context Selection
                  if (appState is ApplicationsLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (applications.isEmpty)
                    _buildEmptyApplicationNotice(context)
                  else ...[
                    _buildApplicationSelector(context, applications),
                    const SizedBox(height: Spacing.lg),
                    _buildModeSelector(context),
                    const SizedBox(height: Spacing.lg),
                    _buildDraftInputWorkspace(context, aiState),
                    if (aiState.hasValue && aiState.value != null) ...[
                      const SizedBox(height: Spacing.xl),
                      _buildAiFeedbackResult(context, aiState.value!),
                    ],
                  ],

                  const SizedBox(height: Spacing.xl),
                  _buildTrustNote(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyApplicationNotice(BuildContext context) {
    final primaryColor = AppTheme.primaryOf(context);
    final textPrimary = AppTheme.textPrimaryOf(context);
    final textMuted = AppTheme.textMutedOf(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Spacing.xl),
      decoration: BoxDecoration(
        color: AppTheme.cardColorOf(context),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppTheme.borderColorOf(context)),
        boxShadow: AppTheme.cardShadowOf(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: primaryColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pilih Beasiswa untuk Memulai Bantuan AI',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Asisten AI RadarScholar membutuhkan konteks beasiswa nyata agar evaluasi berkas Anda 100% tepat sasaran dan objektif.',
                      style: TextStyle(fontSize: 13, color: textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.lg),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                onPressed: () => context.go('/discovery'),
                icon: const Icon(Icons.explore_rounded, size: 16),
                label: const Text(
                  'Cari Beasiswa di Discovery',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => context.go('/applications'),
                icon: const Icon(Icons.track_changes_rounded, size: 16),
                label: const Text(
                  'Buka Application Tracker',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: textPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationSelector(
    BuildContext context,
    List<Application> applications,
  ) {
    final textPrimary = AppTheme.textPrimaryOf(context);
    final textMuted = AppTheme.textMutedOf(context);
    final borderColor = AppTheme.borderColorOf(context);

    final selectedApp = applications.firstWhere(
      (a) => a.id == _selectedApplicationId,
      orElse: () => applications.first,
    );

    return Container(
      padding: const EdgeInsets.all(Spacing.md + 4),
      decoration: BoxDecoration(
        color: AppTheme.cardColorOf(context),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: borderColor),
        boxShadow: AppTheme.cardShadowOf(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.assignment_turned_in_rounded,
                size: 16,
                color: AppTheme.brandPrimary,
              ),
              const SizedBox(width: 8),
              Text(
                'TARGET BEASISWA AKTIF',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.brandPrimary,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            initialValue: _selectedApplicationId ?? selectedApp.id,
            isExpanded: true,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: BorderSide(color: borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: BorderSide(color: borderColor),
              ),
            ),
            dropdownColor: AppTheme.cardColorOf(context),
            items:
                applications.map((app) {
                  return DropdownMenuItem<String>(
                    value: app.id,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            app.scholarship.title,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 13.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          app.scholarship.source?.providerName ?? 'Official',
                          style: TextStyle(fontSize: 11.5, color: textMuted),
                        ),
                      ],
                    ),
                  );
                }).toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() => _selectedApplicationId = val);
                ref.read(aiAssistantControllerProvider.notifier).reset();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildModeSelector(BuildContext context) {
    final modes = [
      (
        AssistantTaskType.cv,
        Icons.description_outlined,
        'Review CV',
        const Color(0xFF38BDF8),
      ),
      (
        AssistantTaskType.motivationLetter,
        Icons.edit_note_rounded,
        'Motivation Letter',
        const Color(0xFF818CF8),
      ),
      (
        AssistantTaskType.essay,
        Icons.article_outlined,
        'Feedback Esai',
        const Color(0xFFA78BFA),
      ),
      (
        AssistantTaskType.interview,
        Icons.record_voice_over_outlined,
        'Latihan Wawancara',
        AppTheme.brandSecondary,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossCount = constraints.maxWidth >= 720 ? 4 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 110,
          ),
          itemCount: modes.length,
          itemBuilder: (context, index) {
            final m = modes[index];
            final isSelected = _selectedMode == m.$1;
            final isDark = AppTheme.isDark(context);

            return InkWell(
              onTap: () {
                setState(() => _selectedMode = m.$1);
                ref.read(aiAssistantControllerProvider.notifier).reset();
              },
              borderRadius: BorderRadius.circular(AppRadius.lg),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? m.$4.withValues(alpha: isDark ? 0.20 : 0.12)
                          : AppTheme.cardColorOf(context),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(
                    color:
                        isSelected
                            ? m.$4
                            : AppTheme.borderColorOf(context),
                    width: isSelected ? 1.8 : 1.0,
                  ),
                  boxShadow:
                      isSelected
                          ? [
                            BoxShadow(
                              color: m.$4.withValues(alpha: 0.22),
                              blurRadius: 10,
                            ),
                          ]
                          : AppTheme.cardShadowOf(context),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Icon(m.$2, color: isSelected ? m.$4 : m.$4.withValues(alpha: 0.7), size: 20),
                        const Spacer(),
                        if (isSelected)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(color: m.$4, shape: BoxShape.circle),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      m.$3,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: isSelected ? (isDark ? Colors.white : m.$4) : AppTheme.textPrimaryOf(context),
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _selectedMode == m.$1 ? 'Sedang aktif' : 'Pilih mode',
                      style: TextStyle(
                        fontSize: 11,
                        color: isSelected ? m.$4 : AppTheme.textMutedOf(context),
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDraftInputWorkspace(
    BuildContext context,
    AsyncValue<AssistantResponse?> aiState,
  ) {
    final textPrimary = AppTheme.textPrimaryOf(context);
    final textMuted = AppTheme.textMutedOf(context);
    final borderColor = AppTheme.borderColorOf(context);
    final primaryColor = AppTheme.primaryOf(context);
    final isLoading = aiState.isLoading;

    return Container(
      padding: const EdgeInsets.all(Spacing.xl),
      decoration: BoxDecoration(
        color: AppTheme.cardColorOf(context),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: borderColor),
        boxShadow: AppTheme.cardShadowOf(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getModeTitle(_selectedMode),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _getModeDescription(_selectedMode),
                      style: TextStyle(fontSize: 13, color: textMuted, height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),

          // Input Text Box
          TextField(
            controller: _draftController,
            maxLines: 8,
            minLines: 5,
            enabled: !isLoading,
            style: TextStyle(fontSize: 14, color: textPrimary, height: 1.5),
            decoration: InputDecoration(
              hintText: _getInputHint(_selectedMode),
              hintStyle: TextStyle(fontSize: 13.5, color: textMuted),
              filled: true,
              fillColor: AppTheme.surfaceElevatedOf(context).withValues(alpha: 0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: BorderSide(color: borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: BorderSide(color: borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: BorderSide(color: primaryColor, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: Spacing.md),

          // Action Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_draftController.text.isNotEmpty)
                TextButton(
                  onPressed: isLoading ? null : () => setState(() => _draftController.clear()),
                  child: Text(
                    'Bersihkan Teks',
                    style: TextStyle(color: textMuted, fontSize: 12.5),
                  ),
                )
              else
                const SizedBox(),
              FilledButton.icon(
                onPressed:
                    isLoading || _selectedApplicationId == null
                        ? null
                        : () => _runAssistant(_selectedApplicationId!),
                icon:
                    isLoading
                        ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : const Icon(Icons.auto_awesome_rounded, size: 17),
                label: Text(
                  isLoading ? 'Menganalisis Draf...' : 'Minta Analisis AI',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.brandPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
              ),
            ],
          ),

          if (aiState.hasError) ...[
            const SizedBox(height: Spacing.md),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.statusDanger.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppTheme.statusDanger.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, color: AppTheme.statusDanger, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Gagal menganalisis dokumen: ${aiState.error}',
                      style: const TextStyle(color: AppTheme.statusDanger, fontSize: 12.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAiFeedbackResult(
    BuildContext context,
    AssistantResponse response,
  ) {
    final textPrimary = AppTheme.textPrimaryOf(context);
    final textMuted = AppTheme.textMutedOf(context);
    final borderColor = AppTheme.borderColorOf(context);
    final primaryColor = AppTheme.primaryOf(context);

    return Container(
      padding: const EdgeInsets.all(Spacing.xl),
      decoration: BoxDecoration(
        color: AppTheme.cardColorOf(context),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: primaryColor.withValues(alpha: 0.45)),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.14),
            blurRadius: 24,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: primaryColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Hasil Evaluasi & Rekomendasi Berkas',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.statusSuccess.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: Border.all(color: AppTheme.statusSuccess.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_rounded, color: AppTheme.statusSuccess, size: 12),
                    SizedBox(width: 5),
                    Text(
                      'Grounded',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.statusSuccess,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.lg),

          // Main feedback body
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceElevatedOf(context).withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: borderColor),
            ),
            child: SelectableText(
              response.feedback,
              style: TextStyle(
                fontSize: 13.5,
                color: textPrimary,
                height: 1.6,
              ),
            ),
          ),

          // Actionable Tips
          if (response.actionableTips.isNotEmpty) ...[
            const SizedBox(height: Spacing.lg),
            Text(
              'Rekomendasi Tindakan:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            ...response.actionableTips.map((tip) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 3),
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: AppTheme.brandSecondary.withValues(alpha: 0.16),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: AppTheme.brandSecondary,
                        size: 11,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        tip,
                        style: TextStyle(
                          fontSize: 13,
                          color: textMuted,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildTrustNote(BuildContext context) {
    final primaryColor = AppTheme.primaryOf(context);
    final textMuted = AppTheme.textMutedOf(context);

    return Container(
      padding: const EdgeInsets.all(Spacing.md + 2),
      decoration: BoxDecoration(
        color: AppTheme.cardColorOf(context),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: primaryColor.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.verified_user_outlined,
              color: primaryColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'RadarScholar tidak mengarang prestasi, pengalaman, atau persyaratan. Seluruh analisis AI grounded pada data nyata profil dan dokumen beasiswa.',
              style: TextStyle(color: textMuted, fontSize: 12.5, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
