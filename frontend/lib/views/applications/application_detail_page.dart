import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../controllers/application_controller.dart';
import '../../repositories/application_repository.dart';
import '../../core/theme.dart';
import '../../models/application.dart';
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
          ElevatedButton(
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
                  // Invalidate provider to fetch updated application details
                  ref.invalidate(applicationDetailProvider(applicationId));
                  // Refresh application list too
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
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: ApplicationStatus.values.map((status) {
            final isSelected = status == currentStatus;
            return ListTile(
              title: Text(_getStatusLabel(status)),
              trailing: isSelected
                  ? const Icon(Icons.check, color: AppTheme.brandPrimary)
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
                        const SnackBar(content: Text('Gagal mengubah status')),
                      );
                    }
                  }
                }
              },
            );
          }).toList(),
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

    final primary = AppTheme.primaryOf(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Lamaran'),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: Color(0xFFEF4444),
            ),
            tooltip: 'Hapus Pelacakan',
            onPressed: () {
              // Confirm delete
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
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
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
                            context.pop(); // Go back
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
        ],
      ),
      body: applicationAsyncValue.when(
        data: (application) => _buildDetail(application),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Color(0xFFEF4444),
                size: 48,
              ),
              const SizedBox(height: 16),
              const Text('Gagal memuat detail aplikasi'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.invalidate(
                  applicationDetailProvider(widget.applicationId),
                ),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) =>
                ApplicationAssistantSheet(applicationId: widget.applicationId),
          );
        },
        backgroundColor: primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.auto_awesome),
        label: const Text(
          'Asisten AI',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildDetail(Application application) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = AppTheme.isDark(context);
    final primary = AppTheme.primaryOf(context);
    final cardColor = AppTheme.cardColorOf(context);
    final borderColor = AppTheme.borderColorOf(context);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 860),
        child: SingleChildScrollView(
          padding: Spacing.pagePadding(MediaQuery.of(context).size.width),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header info
              Text(
                application.scholarship.title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              if (application.scholarship.source != null) ...[
                const SizedBox(height: Spacing.xs),
                Text(
                  application.scholarship.source!.providerName,
                  style: TextStyle(color: primary, fontWeight: FontWeight.w600),
                ),
              ],

              const SizedBox(height: Spacing.lg),

              // Status Card
              Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: borderColor),
                ),
                child: ListTile(
                  title: Text(
                    'Status Lamaran',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: colors.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      _getStatusLabel(application.status),
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: colors.onSurface,
                      ),
                    ),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.edit_outlined, size: 18, color: primary),
                  ),
                  onTap: () =>
                      _updateStatus(application.id, application.status),
                ),
              ),

              const SizedBox(height: Spacing.xl),

              // Tasks section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Daftar Tugas & Checklist',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                  TextButton.icon(
                    icon: Icon(Icons.add_rounded, size: 18, color: primary),
                    label: Text(
                      'Tambah Tugas',
                      style: TextStyle(
                        color: primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () =>
                        _showAddTaskDialog(context, application.id),
                  ),
                ],
              ),

              const SizedBox(height: Spacing.sm),

              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: application.progress,
                  backgroundColor: isDark
                      ? const Color(0xFF1E293B)
                      : Colors.grey.shade200,
                  color: application.progress == 1.0
                      ? const Color(0xFF10B981)
                      : primary,
                  minHeight: 8,
                ),
              ),

              const SizedBox(height: Spacing.xs),
              Text(
                '${application.tasksCompleted} dari ${application.tasksTotal} tugas selesai (${(application.progress * 100).toInt()}%)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: colors.onSurface.withValues(alpha: 0.65),
                ),
              ),

              const SizedBox(height: Spacing.md),

              if (application.tasks.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 36,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.checklist_rtl_rounded,
                        size: 40,
                        color: colors.onSurface.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Belum ada checklist tugas',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: colors.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tambahkan berkas atau syarat yang perlu Anda siapkan.',
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: borderColor),
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
                            color: task.isCompleted
                                ? colors.onSurface.withValues(alpha: 0.45)
                                : colors.onSurface,
                            fontWeight: task.isCompleted
                                ? FontWeight.normal
                                : FontWeight.w500,
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
                            color: colors.onSurface.withValues(alpha: 0.4),
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
                          horizontal: 12,
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
