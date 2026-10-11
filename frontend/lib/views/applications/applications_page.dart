import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../controllers/application_controller.dart';
import '../../core/theme.dart';
import '../../models/application.dart';
import '../../widgets/empty_state.dart';

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
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: Spacing.pagePadding(MediaQuery.of(context).size.width),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pelacakan Lamaran',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: colors.onSurface,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: Spacing.xs),
              Text(
                'Pantau status aplikasi, kelengkapan berkas persyaratan, dan tenggat waktu pendaftaran.',
                style: TextStyle(
                  fontSize: 14,
                  color: colors.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: Spacing.xl),
              Expanded(child: _buildContent()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final state = ref.watch(applicationsControllerProvider);
    final colors = Theme.of(context).colorScheme;

    if (state is ApplicationsLoading || state is ApplicationsInitial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is ApplicationsError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, color: colors.error, size: 48),
            const SizedBox(height: 16),
            Text(
              state.message,
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => ref
                  .read(applicationsControllerProvider.notifier)
                  .fetchApplications(),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (state is ApplicationsEmpty) {
      return Center(
        child: EmptyState(
          icon: Icons.checklist_rtl_rounded,
          title: 'Belum Ada Lamaran',
          message:
              'Mulailah melacak lamaran beasiswa Anda untuk mengatur checklist tugas, dokumen, dan jadwal pendaftaran.',
          actionLabel: 'Cari Beasiswa',
          onAction: () => context.go('/discovery'),
        ),
      );
    }

    if (state is ApplicationsSuccess) {
      return RefreshIndicator(
        onRefresh: () => ref
            .read(applicationsControllerProvider.notifier)
            .fetchApplications(),
        child: ListView.builder(
          itemCount: state.applications.length,
          itemBuilder: (context, index) {
            final application = state.applications[index];
            return _buildApplicationCard(application);
          },
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildApplicationCard(Application app) {
    final colors = Theme.of(context).colorScheme;
    final primaryColor = AppTheme.primaryOf(context);
    final cardBg = AppTheme.cardColorOf(context);
    final borderColor = AppTheme.borderColorOf(context);

    return Container(
      margin: const EdgeInsets.only(bottom: Spacing.md),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: AppTheme.isDark(context) ? 0.2 : 0.04,
            ),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: InkWell(
          onTap: () {
            context.push('/applications/${app.id}');
          },
          borderRadius: BorderRadius.circular(AppRadius.lg),
          hoverColor: primaryColor.withValues(alpha: 0.04),
          child: Padding(
            padding: const EdgeInsets.all(Spacing.md + 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (app.scholarship.source != null)
                            Text(
                              app.scholarship.source!.providerName,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: primaryColor,
                              ),
                            ),
                          const SizedBox(height: 3),
                          Text(
                            app.scholarship.title,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: colors.onSurface,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildStatusBadge(app.status),
                  ],
                ),
                const SizedBox(height: Spacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.checklist_rtl_rounded,
                          size: 16,
                          color: colors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${app.tasksCompleted}/${app.tasksTotal} Tugas',
                          style: TextStyle(
                            color: colors.onSurfaceVariant,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.event_outlined,
                          size: 16,
                          color: colors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          app.targetDeadline != null
                              ? '${app.targetDeadline!.day}/${app.targetDeadline!.month}/${app.targetDeadline!.year}'
                              : 'Tenggat belum diatur',
                          style: TextStyle(
                            color: colors.onSurfaceVariant,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.sm + 2),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: app.progress,
                    backgroundColor: colors.surfaceContainerHighest,
                    color: app.progress == 1.0
                        ? const Color(0xFF10B981)
                        : primaryColor,
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(ApplicationStatus status) {
    final isDark = AppTheme.isDark(context);
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case ApplicationStatus.planned:
        bgColor = isDark
            ? const Color(0xFF0C4A6E).withValues(alpha: 0.4)
            : const Color(0xFFE0F2FE);
        textColor = isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7);
        label = 'Direncanakan';
        break;
      case ApplicationStatus.inProgress:
        bgColor = isDark
            ? const Color(0xFF78350F).withValues(alpha: 0.4)
            : const Color(0xFFFEF3C7);
        textColor = isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309);
        label = 'Sedang Diproses';
        break;
      case ApplicationStatus.submitted:
        bgColor = isDark
            ? const Color(0xFF581C87).withValues(alpha: 0.4)
            : const Color(0xFFF3E8FF);
        textColor = isDark ? const Color(0xFFC084FC) : const Color(0xFF7E22CE);
        label = 'Terkirim';
        break;
      case ApplicationStatus.accepted:
        bgColor = isDark
            ? const Color(0xFF064E3B).withValues(alpha: 0.4)
            : const Color(0xFFDCFCE7);
        textColor = isDark ? const Color(0xFF34D399) : const Color(0xFF15803D);
        label = 'Diterima';
        break;
      case ApplicationStatus.rejected:
        bgColor = isDark
            ? const Color(0xFF7F1D1D).withValues(alpha: 0.4)
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
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: textColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
