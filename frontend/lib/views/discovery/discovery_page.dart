import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/scholarship_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../core/theme.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/scholarship_card.dart';
import 'package:go_router/go_router.dart';

class DiscoveryPage extends ConsumerStatefulWidget {
  const DiscoveryPage({super.key});

  @override
  ConsumerState<DiscoveryPage> createState() => _DiscoveryPageState();
}

class _DiscoveryPageState extends ConsumerState<DiscoveryPage> {
  final _searchController = TextEditingController();
  String _currentStatus = 'Semua'; // 'Semua', 'Aktif', 'Tidak Aktif'

  @override
  void initState() {
    super.initState();
    // Fetch initially
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(scholarshipControllerProvider.notifier)
          .fetchScholarships(refresh: true);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchSubmit(String value) {
    ref.read(scholarshipControllerProvider.notifier).search(value);
  }

  void _onFilterSelected(String status) {
    setState(() {
      _currentStatus = status;
    });

    String? apiStatus;
    if (status == 'Aktif') apiStatus = 'active';
    if (status == 'Tidak Aktif') apiStatus = 'inactive';

    ref.read(scholarshipControllerProvider.notifier).setStatusFilter(apiStatus);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(scholarshipControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: Spacing.pagePadding(MediaQuery.of(context).size.width),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Eksplorasi Beasiswa',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.brandPrimary,
                ),
              ),
              const SizedBox(height: Spacing.xs),
              Text(
                'Jelajahi peluang beasiswa dari sumber resmi yang terverifikasi.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
              ),
              const SizedBox(height: Spacing.lg),

              // Search bar
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search_rounded, color: Colors.grey.shade600),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onSubmitted: _onSearchSubmit,
                        decoration: InputDecoration(
                          hintText: 'Cari beasiswa atau penyedia...',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchSubmit('');
                        },
                      ),
                  ],
                ),
              ),
              const SizedBox(height: Spacing.md),

              // Filter chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('Semua'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Aktif'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Tidak Aktif'),
                  ],
                ),
              ),
              const SizedBox(height: Spacing.md),

              if (ref.watch(isAuthenticatedProvider)) ...[
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: Spacing.md),
                  child: ElevatedButton.icon(
                    onPressed: () => context.push('/recommendations'),
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('Lihat Rekomendasi Cerdas'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.brandPrimary.withValues(
                        alpha: 0.1,
                      ),
                      foregroundColor: AppTheme.brandPrimary,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],

              // Main content area
              Expanded(child: _buildContent(state)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _currentStatus == label;
    return FilterChip(
      selected: isSelected,
      label: Text(label),
      onSelected: (_) => _onFilterSelected(label),
      selectedColor: AppTheme.brandPrimary.withValues(alpha: 0.12),
      checkmarkColor: AppTheme.brandPrimary,
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.brandPrimary : Colors.grey.shade700,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        fontSize: 13,
      ),
    );
  }

  Widget _buildContent(ScholarshipDiscoveryState state) {
    if (state is ScholarshipDiscoveryLoading ||
        state is ScholarshipDiscoveryInitial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is ScholarshipDiscoveryError) {
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
                  .read(scholarshipControllerProvider.notifier)
                  .fetchScholarships(refresh: true),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (state is ScholarshipDiscoveryEmpty) {
      return Center(
        child: EmptyState(
          icon: Icons.search_off_rounded,
          title: state.isSearch
              ? 'Tidak menemukan beasiswa'
              : 'Belum ada beasiswa',
          message: state.isSearch
              ? 'Tidak ada beasiswa yang sesuai dengan pencarian atau filter Anda.'
              : 'Belum ada beasiswa yang tersedia saat ini.',
        ),
      );
    }

    if (state is ScholarshipDiscoverySuccess) {
      return RefreshIndicator(
        onRefresh: () => ref
            .read(scholarshipControllerProvider.notifier)
            .fetchScholarships(refresh: true),
        child: ListView.builder(
          itemCount: state.scholarships.length + (state.hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == state.scholarships.length) {
              // Reached the end, trigger load more
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ref
                    .read(scholarshipControllerProvider.notifier)
                    .fetchScholarships();
              });
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            return ScholarshipCard(scholarship: state.scholarships[index]);
          },
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
