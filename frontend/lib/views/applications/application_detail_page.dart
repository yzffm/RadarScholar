import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../controllers/application_controller.dart';
import '../../repositories/application_repository.dart';
import '../../core/theme.dart';
import '../../models/application.dart';
import '../../widgets/error_state.dart';
import 'application_assistant_page.dart';

class ApplicationDetailPage extends ConsumerStatefulWidget {
  final String applicationId;

  const ApplicationDetailPage({super.key, required this.applicationId});

  @override
  ConsumerState<ApplicationDetailPage> createState() =>
      _ApplicationDetailPageState();
}

class _ApplicationDetailPageState extends ConsumerState<ApplicationDetailPage> {
  final _taskController = TextEditingController();

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  void _showAddTaskDialog(BuildContext context, String applicationId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Tugas Baru'),
        content: TextField(
          controller: _taskController,
          decoration: const InputDecoration(
            hintText: 'Contoh: Lengkapi Transkrip Nilai',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () async {
              final title = _taskController.text.trim();
              if (title.isNotEmpty) {
                Navigator.pop(context);
                final repo = ref.read(applicationRepositoryProvider);
                try {
                  await repo.addTask(
                    applicationId: applicationId,
                    title: title,
                  );
                  ref.invalidate(applicationDetailProvider(applicationId));
                  ref
                      .read(applicationsControllerProvider.notifier)
                      .fetchApplications();
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Gagal menambahkan tugas')),
                    );
                  }
                }
                _taskController.clear();
              }
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }

  void _updateStatus(String applicationId, ApplicationStatus currentStatus) {
    final primary = AppTheme.primaryOf(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardColorOf(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: ApplicationStatus.values.map((status) {
              final isSelected = status == currentStatus;
              return ListTile(
                title: Text(
                  _getStatusLabel(status),
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? primary
                        : AppTheme.textPrimaryOf(context),
                  ),
                ),
                trailing: isSelected
                    ? Icon(Icons.check_circle_rounded, color: primary)
                    : null,
                onTap: () async {
                  Navigator.pop(context);
                  if (status != currentStatus) {
                    final repo = ref.read(applicationRepositoryProvider);
                    try {
                      await repo.updateApplication(
                        applicationId: applicationId,
                        status: status,
                      );
                      ref.invalidate(applicationDetailProvider(applicationId));
                      ref
                          .read(applicationsControllerProvider.notifier)
                          .fetchApplications();
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Gagal mengubah status'),
                          ),
                        );
                      }
                    }
                  }
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  String _getStatusLabel(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.planned:
        return 'Direncanakan';
      case ApplicationStatus.inProgress:
        return 'Sedang Diproses';
      case ApplicationStatus.submitted:
        return 'Terkirim';
      case ApplicationStatus.accepted:
        return 'Diterima';
      case ApplicationStatus.rejected:
        return 'Ditolak';
      case ApplicationStatus.withdrawn:
        return 'Ditarik';
    }
  }

  @override
  Widget build(BuildContext context) {
    final applicationAsyncValue = ref.watch(
      applicationDetailProvider(widget.applicationId),
    );
    final borderColor = AppTheme.borderColorOf(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Lamaran'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: borderColor),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: AppTheme.statusDanger,
              size: 20,
            ),
            tooltip: 'Hapus Pelacakan',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Hapus Pelacakan?'),
                  content: const Text(
                    'Data pelacakan dan semua tugas akan dihapus. Lanjutkan?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal'),
                    ),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.statusDanger,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        Navigator.pop(context);
                        try {
                          await ref
                              .read(applicationRepositoryProvider)
                              .deleteApplication(widget.applicationId);
                          ref
                              .read(applicationsControllerProvider.notifier)
                              .fetchApplications();
                          if (context.mounted) {
                            context.pop();
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Gagal menghapus')),
                            );
                          }
                        }
                      },
                      child: const Text('Hapus'),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: applicationAsyncValue.when(
        data: (application) => _buildDetail(application),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => ErrorState(
          message: 'Gagal memuat detail aplikasi',
          onRetry: () =>
              ref.invalidate(applicationDetailProvider(widget.applicationId)),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: AppTheme.cardColorOf(context),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppRadius.xl),
              ),
            ),
            builder: (context) =>
                ApplicationAssistantSheet(applicationId: widget.applicationId),
          );
        },
        backgroundColor: AppTheme.brandPrimary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.auto_awesome_rounded, size: 18),
        label: const Text(
          'Asisten AI',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildDetail(Application application) {
    final primary = AppTheme.primaryOf(context);
    final cardColor = AppTheme.cardColorOf(context);
    final borderColor = AppTheme.borderColorOf(context);
    final textPrimary = AppTheme.textPrimaryOf(context);
    final textMuted = AppTheme.textMutedOf(context);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 920),
        child: SingleChildScrollView(
          padding: Spacing.pagePadding(MediaQuery.of(context).size.width),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border.all(color: borderColor),
                  boxShadow: AppTheme.cardShadowOf(context),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (application.scholarship.source != null) ...[
                      Text(
                        application.scholarship.source!.providerName,
                        style: TextStyle(
                          color: primary,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    Text(
                      application.scholarship.title,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(height: 1, color: borderColor),
                    const SizedBox(height: 16),
                    InkWell(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      onTap: () =>
                          _updateStatus(application.id, application.status),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceElevatedOf(context),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(color: borderColor),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'STATUS LAMARAN',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.8,
                                      color: textMuted,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    _getStatusLabel(application.status),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15.5,
                                      color: textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(9),
                              ),
                              child: Icon(
                                Icons.edit_outlined,
                                size: 17,
                                color: primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: Spacing.xl),

              // Tasks section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Daftar Tugas & Checklist',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  FilledButton.tonalIcon(
                    icon: Icon(Icons.add_rounded, size: 17, color: primary),
                    label: Text(
                      'Tambah Tugas',
                      style: TextStyle(
                        color: primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: primary.withValues(alpha: 0.12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                    ),
                    onPressed: () =>
                        _showAddTaskDialog(context, application.id),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.full),
                child: LinearProgressIndicator(
                  value: application.progress,
                  backgroundColor: AppTheme.surfaceElevatedOf(context),
                  color: application.progress == 1.0
                      ? AppTheme.statusSuccess
                      : primary,
                  minHeight: 8,
                ),
              ),

              const SizedBox(height: 6),
              Text(
                '${application.tasksCompleted} dari ${application.tasksTotal} tugas selesai (${(application.progress * 100).toInt()}%)',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: textMuted,
                ),
              ),

              const SizedBox(height: Spacing.md),

              if (application.tasks.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 40,
                    horizontal: 20,
                  ),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.checklist_rtl_rounded,
                        size: 38,
                        color: textMuted.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Belum ada checklist tugas',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tambahkan berkas atau syarat yang perlu Anda siapkan.',
                        style: TextStyle(fontSize: 12.5, color: textMuted),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: borderColor),
                    boxShadow: AppTheme.cardShadowOf(context),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: application.tasks.length,
                    separatorBuilder: (context, index) =>
                        Divider(height: 1, color: borderColor),
                    itemBuilder: (context, index) {
                      final task = application.tasks[index];
                      return CheckboxListTile(
                        activeColor: primary,
                        title: Text(
                          task.title,
                          style: TextStyle(
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            color: task.isCompleted ? textMuted : textPrimary,
                            fontWeight: task.isCompleted
                                ? FontWeight.w400
                                : FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        value: task.isCompleted,
                        onChanged: (val) async {
                          if (val == null) return;
                          try {
                            await ref
                                .read(applicationRepositoryProvider)
                                .updateTask(
                                  applicationId: application.id,
                                  taskId: task.id,
                                  isCompleted: val,
                                );
                            ref.invalidate(
                              applicationDetailProvider(application.id),
                            );
                            ref
                                .read(applicationsControllerProvider.notifier)
                                .fetchApplications();
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Gagal mengupdate tugas'),
                                ),
                              );
                            }
                          }
                        },
                        secondary: IconButton(
                          icon: Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: textMuted,
                          ),
                          onPressed: () async {
                            try {
                              await ref
                                  .read(applicationRepositoryProvider)
                                  .deleteTask(
                                    applicationId: application.id,
                                    taskId: task.id,
                                  );
                              ref.invalidate(
                                applicationDetailProvider(application.id),
                              );
                              ref
                                  .read(applicationsControllerProvider.notifier)
                                  .fetchApplications();
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Gagal menghapus tugas'),
                                  ),
                                );
                              }
                            }
                          },
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 2,
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: Spacing.xxxl),
            ],
          ),
        ),
      ),
    );
  }
}
