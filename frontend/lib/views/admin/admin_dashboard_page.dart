import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../controllers/admin_controller.dart';
import '../../core/theme.dart';

class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final borderColor = AppTheme.borderColorOf(context);
    final primaryColor = AppTheme.primaryOf(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard & Source Monitoring'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(49),
            child: Column(
              children: [
                TabBar(
                  indicatorColor: primaryColor,
                  labelColor: primaryColor,
                  unselectedLabelColor: AppTheme.textMutedOf(context),
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                  ),
                  tabs: const [
                    Tab(text: 'Sources'),
                    Tab(text: 'Crawl History'),
                  ],
                ),
                Container(height: 1, color: borderColor),
              ],
            ),
          ),
        ),
        body: const TabBarView(children: [_SourcesTab(), _CrawlHistoryTab()]),
      ),
    );
  }
}

class _SourcesTab extends ConsumerWidget {
  const _SourcesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sourcesState = ref.watch(adminSourcesControllerProvider);
    final primaryColor = AppTheme.primaryOf(context);
    final cardBg = AppTheme.cardColorOf(context);
    final borderColor = AppTheme.borderColorOf(context);

    return sourcesState.when(
      data: (sources) {
        if (sources.isEmpty) {
          return const Center(child: Text('No sources available.'));
        }

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 960),
            child: ListView.builder(
              padding: const EdgeInsets.all(20.0),
              itemCount: sources.length,
              itemBuilder: (context, index) {
                final source = sources[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12.0),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: borderColor),
                    boxShadow: AppTheme.cardShadowOf(context),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    title: Text(
                      source.providerName,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimaryOf(context),
                      ),
                    ),
                    subtitle: Text(
                      source.sourceUrl,
                      style: TextStyle(
                        color: AppTheme.textMutedOf(context),
                        fontSize: 12.5,
                      ),
                    ),
                    trailing: Switch(
                      value: source.active,
                      activeThumbColor: primaryColor,
                      onChanged: (val) async {
                        try {
                          await ref
                              .read(adminSourcesControllerProvider.notifier)
                              .toggleSource(source.id);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Source ${source.providerName} is now ${val ? 'Active' : 'Inactive'}',
                                ),
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to toggle source: $e'),
                                backgroundColor: AppTheme.statusDanger,
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ),
                );
              },
            ),
          ),
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
    final cardBg = AppTheme.cardColorOf(context);
    final borderColor = AppTheme.borderColorOf(context);

    return historyState.when(
      data: (response) {
        final runs = response.items;
        if (runs.isEmpty) {
          return const Center(child: Text('No crawl history available.'));
        }

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 960),
            child: ListView.builder(
              padding: const EdgeInsets.all(20.0),
              itemCount: runs.length,
              itemBuilder: (context, index) {
                final run = runs[index];
                final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');
                final Color statusColor = run.status == 'SUCCESS'
                    ? AppTheme.statusSuccess
                    : (run.status == 'PARTIAL_SUCCESS'
                          ? AppTheme.brandSecondary
                          : AppTheme.statusDanger);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12.0),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: borderColor),
                    boxShadow: AppTheme.cardShadowOf(context),
                  ),
                  child: ExpansionTile(
                    title: Text(
                      'Run on ${formatter.format(run.startedAt.toLocal())}',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimaryOf(context),
                      ),
                    ),
                    subtitle: Text(
                      'Status: ${run.status} | '
                      'Attempted: ${run.sourcesAttempted} | '
                      'Created: ${run.scholarshipsCreated}',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: AppTheme.textMutedOf(context),
                      ),
                    ),
                    leading: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: statusColor.withValues(alpha: 0.4),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Succeeded Sources: ${run.sourcesSucceeded}'),
                            Text('Failed Sources: ${run.sourcesFailed}'),
                            const SizedBox(height: 8),
                            Text(
                              'Scholarships Created: ${run.scholarshipsCreated}',
                            ),
                            Text(
                              'Scholarships Updated: ${run.scholarshipsUpdated}',
                            ),
                            Text(
                              'Scholarships Skipped: ${run.scholarshipsSkipped}',
                            ),
                            if (run.errors.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              const Text(
                                'Errors:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.statusDanger,
                                ),
                              ),
                              ...run.errors.map(
                                (e) => Text(
                                  '- $e',
                                  style: const TextStyle(
                                    color: AppTheme.statusDanger,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error loading crawl history: $e')),
    );
  }
}
