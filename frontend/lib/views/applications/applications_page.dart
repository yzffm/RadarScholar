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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lamaran'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey.shade900,
        elevation: 0.5,
      ),
      body: SafeArea(
        child: Padding(
          padding: Spacing.pagePadding(MediaQuery.of(context).size.width),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pelacakan Lamaran',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.brandPrimary,
                ),
              ),
              const SizedBox(height: Spacing.xs),
              Text(
                'Pantau status aplikasi, berkas persyaratan, dan tenggat waktu pendaftaran.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
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

    if (state is ApplicationsLoading || state is ApplicationsInitial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is ApplicationsError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(state.message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const EmptyState(
              icon: Icons.checklist_rtl_rounded,
              title: 'Belum Ada Lamaran',
              message:
                  'Mulailah melacak lamaran beasiswa Anda untuk mengatur tugas dan jadwal.',
            ),
            const SizedBox(height: Spacing.md),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Cari Beasiswa'),
            ),
          ],
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
    return Card(
      margin: const EdgeInsets.only(bottom: Spacing.md),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      elevation: 2,
      child: InkWell(
        onTap: () {
          // Go to detail (will implement in next step)
          context.push('/applications/${app.id}');
        },
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: const EdgeInsets.all(Spacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      app.scholarship.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildStatusBadge(app.status),
                ],
              ),
              if (app.scholarship.source != null) ...[
                const SizedBox(height: Spacing.xs),
                Text(
                  app.scholarship.source!.providerName,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ],
              const SizedBox(height: Spacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.checklist_rtl,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${app.tasksCompleted}/${app.tasksTotal} Tugas',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.event, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        app.targetDeadline != null
                            ? '${app.targetDeadline!.day}/${app.targetDeadline!.month}/${app.targetDeadline!.year}'
                            : 'Belum diatur',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: Spacing.sm),
              LinearProgressIndicator(
                value: app.progress,
                backgroundColor: Colors.grey.shade200,
                color: app.progress == 1.0
                    ? Colors.green
                    : AppTheme.brandPrimary,
                minHeight: 6,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(ApplicationStatus status) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case ApplicationStatus.planned:
        bgColor = Colors.blue.shade50;
        textColor = Colors.blue.shade700;
        label = 'Direncanakan';
        break;
      case ApplicationStatus.inProgress:
        bgColor = Colors.orange.shade50;
        textColor = Colors.orange.shade700;
        label = 'Sedang Diproses';
        break;
      case ApplicationStatus.submitted:
        bgColor = Colors.purple.shade50;
        textColor = Colors.purple.shade700;
        label = 'Terkirim';
        break;
      case ApplicationStatus.accepted:
        bgColor = Colors.green.shade50;
        textColor = Colors.green.shade700;
        label = 'Diterima';
        break;
      case ApplicationStatus.rejected:
        bgColor = Colors.red.shade50;
        textColor = Colors.red.shade700;
        label = 'Ditolak';
        break;
      case ApplicationStatus.withdrawn:
        bgColor = Colors.grey.shade200;
        textColor = Colors.grey.shade700;
        label = 'Ditarik';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
