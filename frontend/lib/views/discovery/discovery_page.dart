import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../controllers/scholarship_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../core/theme.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_state.dart';
import '../../widgets/scholarship_card.dart';

class DiscoveryPage extends ConsumerStatefulWidget {
  const DiscoveryPage({super.key});

  @override
  ConsumerState<DiscoveryPage> createState() => _DiscoveryPageState();
}

class _DiscoveryPageState extends ConsumerState<DiscoveryPage> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  String _currentStatus = 'Semua'; // 'Semua', 'Aktif', 'Tidak Aktif'
  bool _isSearchFocused = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _searchFocusNode.addListener(_onFocusChanged);
    // Fetch initially
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(scholarshipControllerProvider.notifier)
          .fetchScholarships(refresh: true);
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchFocusNode.removeListener(_onFocusChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {});
  }

  void _onFocusChanged() {
    setState(() {
      _isSearchFocused = _searchFocusNode.hasFocus;
    });
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
    final isDark = AppTheme.isDark(context);
    final primaryColor = AppTheme.primaryOf(context);
    final textPrimary = AppTheme.textPrimaryOf(context);
    final textMuted = AppTheme.textMutedOf(context);
    final borderColor = AppTheme.borderColorOf(context);
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
                  // Top Header with Eyebrow & Live Counter
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
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
                                borderRadius: BorderRadius.circular(
                                  AppRadius.xs,
                                ),
                                border: Border.all(
                                  color: primaryColor.withValues(alpha: 0.25),
                                ),
                              ),
                              child: Text(
                                'SCHOLARSHIP RADAR',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.1,
                                  color: primaryColor,
                                ),
                              ),
                            ),
                            Text(
                              'Eksplorasi Beasiswa',
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
                              'Jelajahi peluang beasiswa dari sumber resmi yang terverifikasi secara berkala.',
                              style: TextStyle(
                                fontSize: 13.5,
                                color: textMuted,
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (state is ScholarshipDiscoverySuccess &&
                          screenWidth >= 600)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.cardColorOf(context),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(color: borderColor),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(
                                  color: AppTheme.statusSuccess,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${state.scholarships.length} Program Ditampilkan',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textSecondaryOf(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: Spacing.lg),

                  // Command-Bar Search & Filter Toolbar
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    decoration: BoxDecoration(
                      color: AppTheme.cardColorOf(context),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: _isSearchFocused ? primaryColor : borderColor,
                        width: _isSearchFocused ? 1.5 : 1,
                      ),
                      boxShadow: _isSearchFocused
                          ? AppTheme.glowShadowOf(
                              primaryColor,
                              intensity: isDark ? 0.18 : 0.1,
                            )
                          : AppTheme.cardShadowOf(context),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 3,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search_rounded,
                          color: _isSearchFocused ? primaryColor : textMuted,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            focusNode: _searchFocusNode,
                            onSubmitted: _onSearchSubmit,
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              hintText:
                                  'Cari nama beasiswa, instansi, atau penyedia...',
                              hintStyle: TextStyle(
                                color: textMuted.withValues(alpha: 0.8),
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              filled: false,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                        if (_searchController.text.isNotEmpty)
                          IconButton(
                            icon: Icon(
                              Icons.clear_rounded,
                              size: 18,
                              color: textMuted,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              _onSearchSubmit('');
                            },
                          )
                        else if (screenWidth >= 600)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceElevatedOf(context),
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: borderColor),
                            ),
                            child: Text(
                              'ENTER',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: textMuted,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Segmented Filter Chips Bar
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('Semua', Icons.grid_view_rounded),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          'Aktif',
                          Icons.check_circle_outline_rounded,
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip('Tidak Aktif', Icons.history_rounded),
                      ],
                    ),
                  ),
                  const SizedBox(height: Spacing.md),

                  // AI Smart Recommendation Banner (if authenticated)
                  if (ref.watch(isAuthenticatedProvider)) ...[
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: Spacing.md),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        gradient: isDark
                            ? const LinearGradient(
                                colors: [
                                  Color(0xFF111C38),
                                  Color(0xFF172554),
                                  Color(0xFF1E3A8A),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : const LinearGradient(
                                colors: [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(
                          color: primaryColor.withValues(alpha: 0.35),
                        ),
                        boxShadow: AppTheme.cardShadowOf(context),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              gradient: AppTheme.accentGradient,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.auto_awesome_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Rekomendasi Cerdas AI',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: textPrimary,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Cek kecocokan profil akademik Anda dengan beasiswa yang tersedia.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? const Color(0xFFCBD5E1)
                                        : textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          FilledButton.icon(
                            onPressed: () => context.push('/recommendations'),
                            icon: const Icon(
                              Icons.arrow_forward_rounded,
                              size: 14,
                            ),
                            label: const Text(
                              'Buka Matcher',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppTheme.brandPrimary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Main Scholarship List Content (ListView.builder preserved for CPMK 6)
                  Expanded(child: _buildContent(state)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon) {
    final isSelected = _currentStatus == label;
    final isDark = AppTheme.isDark(context);
    final primaryColor = AppTheme.primaryOf(context);
    final textMuted = AppTheme.textMutedOf(context);
    final borderColor = AppTheme.borderColorOf(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onFilterSelected(label),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? primaryColor.withValues(alpha: isDark ? 0.16 : 0.1)
                : AppTheme.cardColorOf(context),
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(
              color: isSelected
                  ? primaryColor.withValues(alpha: isDark ? 0.5 : 0.4)
                  : borderColor,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 15,
                color: isSelected ? primaryColor : textMuted,
              ),
              const SizedBox(width: 7),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? (isDark ? Colors.white : primaryColor)
                      : textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(ScholarshipDiscoveryState state) {
    if (state is ScholarshipDiscoveryLoading ||
        state is ScholarshipDiscoveryInitial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is ScholarshipDiscoveryError) {
      return ErrorState(
        message: state.message,
        onRetry: () => ref
            .read(scholarshipControllerProvider.notifier)
            .fetchScholarships(refresh: true),
      );
    }

    if (state is ScholarshipDiscoveryEmpty) {
      return EmptyState(
        icon: Icons.search_off_rounded,
        title: state.isSearch
            ? 'Tidak menemukan beasiswa'
            : 'Belum ada beasiswa',
        message: state.isSearch
            ? 'Tidak ada beasiswa yang sesuai dengan pencarian atau filter Anda.'
            : 'Belum ada beasiswa yang tersedia saat ini.',
      );
    }

    if (state is ScholarshipDiscoverySuccess) {
      return RefreshIndicator(
        onRefresh: () => ref
            .read(scholarshipControllerProvider.notifier)
            .fetchScholarships(refresh: true),
        child: ListView.builder(
          padding: const EdgeInsets.only(bottom: Spacing.xl),
          itemCount: state.scholarships.length + (state.hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == state.scholarships.length) {
              final controller = ref.read(
                scholarshipControllerProvider.notifier,
              );
              if (!controller.isFetching) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) controller.fetchScholarships();
                });
              }
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
