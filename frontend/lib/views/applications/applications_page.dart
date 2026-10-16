import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../controllers/application_controller.dart';
import '../../core/theme.dart';
import '../../models/application.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_state.dart';

class ApplicationsPage extends ConsumerStatefulWidget {
  const ApplicationsPage({super.key});

  @override
  ConsumerState<ApplicationsPage> createState() => _ApplicationsPageState();
}

class _ApplicationsPageState extends ConsumerState<ApplicationsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(applicationsControllerProvider.notifier).fetchApplications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final primaryColor = AppTheme.primaryOf(context);
    final textPrimary = AppTheme.textPrimaryOf(context);
    final textMuted = AppTheme.textMutedOf(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1080),
            child: Padding(
              padding: Spacing.pagePadding(screenWidth),
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
                      'APPLICATION WORKSPACE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                        color: primaryColor,
                      ),
                    ),
                  ),
                  Text(
                    'Pelacakan Lamaran',
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
                    'Pantau status aplikasi, kelengkapan berkas persyaratan, dan tenggat waktu pendaftaran.',
                    style: TextStyle(
                      fontSize: 13.5,
                      color: textMuted,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: Spacing.lg),
                  Expanded(child: _buildContent()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final state = ref.watch(applicationsControllerProvider);

    if (state is ApplicationsLoading || state is ApplicationsInitial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is ApplicationsError) {
      return ErrorState(
        message: state.message,
        onRetry: () => ref
            .read(applicationsControllerProvider.notifier)
            .fetchApplications(),
      );
    }

    if (state is ApplicationsEmpty) {
      return EmptyState(
        icon: Icons.checklist_rtl_rounded,
        title: 'Belum Ada Lamaran',
        message:
            'Mulailah melacak lamaran beasiswa Anda untuk mengatur checklist tugas, dokumen, dan jadwal pendaftaran.',
        actionLabel: 'Cari Beasiswa',
        onAction: () => context.go('/discovery'),
      );
    }

    if (state is ApplicationsSuccess) {
      return RefreshIndicator(
        onRefresh: () => ref
            .read(applicationsControllerProvider.notifier)
            .fetchApplications(),
        child: ListView.builder(
          padding: const EdgeInsets.only(bottom: Spacing.xl),
          itemCount: state.applications.length,
          itemBuilder: (context, index) {
            final application = state.applications[index];
            return _ApplicationCard(application: application);
          },
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

class _ApplicationCard extends StatefulWidget {
  final Application application;

  const _ApplicationCard({required this.application});

  @override
  State<_ApplicationCard> createState() => _ApplicationCardState();
}

class _ApplicationCardState extends State<_ApplicationCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final app = widget.application;
    final isDark = AppTheme.isDark(context);
    final primaryColor = AppTheme.primaryOf(context);
    final cardBg = _isHovered
        ? AppTheme.cardHoverColorOf(context)
        : AppTheme.cardColorOf(context);
    final borderColor = _isHovered
        ? primaryColor.withValues(alpha: isDark ? 0.45 : 0.35)
        : AppTheme.borderColorOf(context);
    final textPrimary = AppTheme.textPrimaryOf(context);
    final textMuted = AppTheme.textMutedOf(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        margin: const EdgeInsets.only(bottom: Spacing.md),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: borderColor),
          boxShadow: AppTheme.cardShadowOf(context, isHovered: _isHovered),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: InkWell(
            onTap: () {
              context.push('/applications/${app.id}');
            },
            borderRadius: BorderRadius.circular(AppRadius.lg),
            hoverColor: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(
                            alpha: isDark ? 0.16 : 0.1,
                          ),
                          borderRadius: BorderRadius.circular(11),
                          border: Border.all(
                            color: primaryColor.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Icon(
                          Icons.assignment_turned_in_rounded,
                          size: 20,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (app.scholarship.source != null)
                              Text(
                                app.scholarship.source!.providerName,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: primaryColor,
                                ),
                              ),
                            const SizedBox(height: 3),
                            Text(
                              app.scholarship.title,
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16.5,
                                color: textPrimary,
                                letterSpacing: -0.3,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildStatusBadge(context, app.status),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceElevatedOf(context),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          border: Border.all(
                            color: AppTheme.borderColorOf(context),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.checklist_rtl_rounded,
                              size: 14,
                              color: primaryColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${app.tasksCompleted}/${app.tasksTotal} Tugas',
                              style: TextStyle(
                                color: AppTheme.textSecondaryOf(context),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.event_outlined,
                            size: 15,
                            color: textMuted,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            app.targetDeadline != null
                                ? '${app.targetDeadline!.day}/${app.targetDeadline!.month}/${app.targetDeadline!.year}'
                                : 'Tenggat belum diatur',
                            style: TextStyle(
                              color: textMuted,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    child: LinearProgressIndicator(
                      value: app.progress,
                      backgroundColor: AppTheme.surfaceElevatedOf(context),
                      color: app.progress == 1.0
                          ? AppTheme.statusSuccess
                          : primaryColor,
                      minHeight: 6,
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

  Widget _buildStatusBadge(BuildContext context, ApplicationStatus status) {
    final isDark = AppTheme.isDark(context);
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case ApplicationStatus.planned:
        bgColor = isDark
            ? const Color(0xFF0C4A6E).withValues(alpha: 0.45)
            : const Color(0xFFE0F2FE);
        textColor = isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7);
        label = 'Direncanakan';
        break;
      case ApplicationStatus.inProgress:
        bgColor = isDark
            ? const Color(0xFF78350F).withValues(alpha: 0.45)
            : const Color(0xFFFEF3C7);
        textColor = isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309);
        label = 'Sedang Diproses';
        break;
      case ApplicationStatus.submitted:
        bgColor = isDark
            ? const Color(0xFF581C87).withValues(alpha: 0.45)
            : const Color(0xFFF3E8FF);
        textColor = isDark ? const Color(0xFFC084FC) : const Color(0xFF7E22CE);
        label = 'Terkirim';
        break;
      case ApplicationStatus.accepted:
        bgColor = isDark
            ? const Color(0xFF064E3B).withValues(alpha: 0.45)
            : const Color(0xFFDCFCE7);
        textColor = isDark ? const Color(0xFF34D399) : const Color(0xFF15803D);
        label = 'Diterima';
        break;
      case ApplicationStatus.rejected:
        bgColor = isDark
            ? const Color(0xFF7F1D1D).withValues(alpha: 0.45)
            : const Color(0xFFFEE2E2);
        textColor = isDark ? const Color(0xFFF87171) : const Color(0xFFB91C1C);
        label = 'Ditolak';
        break;
      case ApplicationStatus.withdrawn:
        bgColor = isDark
            ? const Color(0xFF334155).withValues(alpha: 0.5)
            : const Color(0xFFF1F5F9);
        textColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569);
        label = 'Ditarik';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: textColor.withValues(alpha: 0.35), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}
