import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../controllers/admin_controller.dart';
import '../../models/scholarship.dart';
import '../../models/admin.dart';

class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard & Source Monitoring'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Sources'),
              Tab(text: 'Crawl History'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _SourcesTab(),
            _CrawlHistoryTab(),
          ],
        ),
      ),
    );
  }
}

class _SourcesTab extends ConsumerWidget {
  const _SourcesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sourcesState = ref.watch(adminSourcesControllerProvider);

    return sourcesState.when(
      data: (sources) {
        if (sources.isEmpty) {
          return const Center(child: Text('No sources available.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: sources.length,
          itemBuilder: (context, index) {
            final source = sources[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12.0),
              child: ListTile(
                title: Text(source.providerName),
                subtitle: Text(source.sourceUrl),
                trailing: Switch(
                  value: source.active,
                  onChanged: (val) async {
                    try {
                      await ref.read(adminSourcesControllerProvider.notifier).toggleSource(source.id);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Source ${source.providerName} is now ${val ? 'Active' : 'Inactive'}')),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to toggle source: $e'), backgroundColor: Colors.red),
                        );
                      }
                    }
                  },
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error loading sources: $e')),
    );
  }
}

class _CrawlHistoryTab extends ConsumerWidget {
  const _CrawlHistoryTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyState = ref.watch(adminCrawlRunsProvider);

    return historyState.when(
      data: (response) {
        final runs = response.items;
        if (runs.isEmpty) {
          return const Center(child: Text('No crawl history available.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: runs.length,
          itemBuilder: (context, index) {
            final run = runs[index];
            final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');
            final Color statusColor = run.status == 'SUCCESS' 
                ? Colors.green 
                : (run.status == 'PARTIAL_SUCCESS' ? Colors.orange : Colors.red);

            return Card(
              margin: const EdgeInsets.only(bottom: 12.0),
              child: ExpansionTile(
                title: Text('Run on ${formatter.format(run.startedAt.toLocal())}'),
                subtitle: Text(
                  'Status: ${run.status} | '
                  'Attempted: ${run.sourcesAttempted} | '
                  'Created: ${run.scholarshipsCreated}',
                ),
                leading: Icon(Icons.circle, color: statusColor, size: 16),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Succeeded Sources: ${run.sourcesSucceeded}'),
                        Text('Failed Sources: ${run.sourcesFailed}'),
                        const SizedBox(height: 8),
                        Text('Scholarships Created: ${run.scholarshipsCreated}'),
                        Text('Scholarships Updated: ${run.scholarshipsUpdated}'),
                        Text('Scholarships Skipped: ${run.scholarshipsSkipped}'),
                        if (run.errors.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          const Text('Errors:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                          ...run.errors.map((e) => Text('- $e', style: const TextStyle(color: Colors.red))),
                        ]
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error loading crawl history: $e')),
    );
  }
}
