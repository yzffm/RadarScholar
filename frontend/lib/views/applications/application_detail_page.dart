import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../controllers/application_controller.dart';
import '../../repositories/application_repository.dart';
import '../../core/theme.dart';
import '../../models/application.dart';

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
                      SnackBar(content: Text('Gagal menambahkan tugas: $e')),
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Lamaran'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey.shade900,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
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
                        backgroundColor: Colors.red,
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
                      child: const Text(
                        'Hapus',
                        style: TextStyle(color: Colors.white),
                      ),
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
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              const Text('Gagal memuat detail aplikasi'),
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
    );
  }

  Widget _buildDetail(Application application) {
    return SingleChildScrollView(
      padding: Spacing.pagePadding(MediaQuery.of(context).size.width),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header info
          Text(
            application.scholarship.title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          if (application.scholarship.source != null) ...[
            const SizedBox(height: Spacing.xs),
            Text(
              application.scholarship.source!.providerName,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],

          const SizedBox(height: Spacing.lg),

          // Status Card
          Card(
            elevation: 0,
            color: Colors.grey.shade50,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: ListTile(
              title: const Text(
                'Status Lamaran',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              subtitle: Text(
                _getStatusLabel(application.status),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              trailing: const Icon(
                Icons.edit,
                size: 20,
                color: AppTheme.brandPrimary,
              ),
              onTap: () => _updateStatus(application.id, application.status),
            ),
          ),

          const SizedBox(height: Spacing.xl),

          // Tasks section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daftar Tugas',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Tambah'),
                onPressed: () => _showAddTaskDialog(context, application.id),
              ),
            ],
          ),

          const SizedBox(height: Spacing.sm),

          LinearProgressIndicator(
            value: application.progress,
            backgroundColor: Colors.grey.shade200,
            color: application.progress == 1.0
                ? Colors.green
                : AppTheme.brandPrimary,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),

          const SizedBox(height: Spacing.xs),
          Text(
            '${application.tasksCompleted} dari ${application.tasksTotal} tugas selesai',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),

          const SizedBox(height: Spacing.md),

          if (application.tasks.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text(
                  'Belum ada tugas.',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: application.tasks.length,
              itemBuilder: (context, index) {
                final task = application.tasks[index];
                return CheckboxListTile(
                  title: Text(
                    task.title,
                    style: TextStyle(
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                      color: task.isCompleted ? Colors.grey : Colors.black87,
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
                      ref.invalidate(applicationDetailProvider(application.id));
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
                    icon: const Icon(Icons.close, size: 20, color: Colors.grey),
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
                  contentPadding: EdgeInsets.zero,
                );
              },
            ),
        ],
      ),
    );
  }
}
