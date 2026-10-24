import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/responsive.dart';
import '../../core/theme.dart';
import '../../controllers/navigation_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/app_logo.dart';

/// RadarScholar Responsive Application Shell — Modern SaaS Workspace.
///
/// Implements CPMK 2 (Responsive UI across Desktop, Tablet, and Mobile viewports)
/// and encapsulates the persistent navigation structure using GoRouter ShellRoute.
class AppShell extends ConsumerWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  int _calculateSelectedIndex(
    BuildContext context,
    List<NavigationDestinationItem> destinations,
  ) {
    try {
      final String location = GoRouterState.of(context).uri.path;
      for (int i = 0; i < destinations.length; i++) {
        if (location.startsWith(destinations[i].path)) {
          return i;
        }
      }
    } catch (_) {
      // Graceful fallback when pumped outside GoRouter in tests
    }
    return 0;
  }

  void _onDestinationSelected(
    BuildContext context,
    WidgetRef ref,
    int index,
    List<NavigationDestinationItem> destinations,
  ) {
    ref.read(navigationIndexProvider.notifier).state = index;
    try {
      context.go(destinations[index].path);
    } catch (_) {
      // Graceful fallback when pumped outside GoRouter in tests
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final destinations = ref.watch(navigationDestinationsProvider);
    final selectedIndex = _calculateSelectedIndex(context, destinations);
    final screenWidth = MediaQuery.of(context).size.width;
    final deviceType = Responsive.getDeviceType(screenWidth);

    if (deviceType == DeviceType.mobile) {
      return _buildMobileShell(context, ref, selectedIndex, destinations);
    } else if (deviceType == DeviceType.tablet) {
      return _buildTabletShell(context, ref, selectedIndex, destinations);
    } else {
      return _buildDesktopShell(context, ref, selectedIndex, destinations);
    }
  }

  // ─── Mobile Shell (< 600px) ──────────────────────────────────────────
  Widget _buildMobileShell(
    BuildContext context,
    WidgetRef ref,
    int selectedIndex,
    List<NavigationDestinationItem> destinations,
  ) {
    final themeMode = ref.watch(themeModeProvider);
    final primaryColor = AppTheme.primaryOf(context);
    final borderColor = AppTheme.borderColorOf(context);
    final surfaceColor = AppTheme.surfaceOf(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: surfaceColor,
        titleSpacing: 16,
        title: AppLogo(
          mode: AppLogoMode.full,
          height: 30,
          onTap: () => context.go('/'),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: borderColor),
        ),
        actions: [
          IconButton(
            tooltip: 'About Creator',
            icon: const Icon(Icons.badge_outlined, size: 20),
            onPressed: () {
              try {
                context.go('/about');
              } catch (_) {}
            },
          ),
          _ThemeToggleButton(themeMode: themeMode, ref: ref),
          const SizedBox(width: 4),
          if (ref.watch(isAuthenticatedProvider))
            IconButton(
              tooltip: 'Keluar',
              icon: const Icon(Icons.logout_rounded, size: 20),
              onPressed: () =>
                  ref.read(authControllerProvider.notifier).signOut(),
            )
          else
            IconButton(
              tooltip: 'Masuk ke Akun',
              icon: const Icon(Icons.account_circle_outlined, size: 22),
              onPressed: () => context.go('/login'),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: surfaceColor,
          border: Border(top: BorderSide(color: borderColor, width: 1)),
        ),
        child: NavigationBar(
          backgroundColor: surfaceColor,
          selectedIndex: selectedIndex,
          onDestinationSelected: (index) =>
              _onDestinationSelected(context, ref, index, destinations),
          destinations: destinations.map((d) {
            return NavigationDestination(
              icon: Icon(d.icon, size: 21),
              selectedIcon: Icon(d.selectedIcon, color: primaryColor, size: 21),
              label: d.label,
            );
          }).toList(),
        ),
      ),
    );
  }

  // ─── Tablet Shell (600px – 1024px) ───────────────────────────────────
  Widget _buildTabletShell(
    BuildContext context,
    WidgetRef ref,
    int selectedIndex,
    List<NavigationDestinationItem> destinations,
  ) {
    final primaryColor = AppTheme.primaryOf(context);
    final themeMode = ref.watch(themeModeProvider);
    final borderColor = AppTheme.borderColorOf(context);
    final surfaceColor = AppTheme.surfaceOf(context);

    return Scaffold(
      body: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: surfaceColor,
              border: Border(right: BorderSide(color: borderColor, width: 1)),
            ),
            child: NavigationRail(
              backgroundColor: surfaceColor,
              selectedIndex: selectedIndex,
              onDestinationSelected: (index) =>
                  _onDestinationSelected(context, ref, index, destinations),
              labelType: NavigationRailLabelType.all,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: AppLogo.icon(height: 38, onTap: () => context.go('/')),
              ),
              trailing: Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'About Creator',
                          icon: const Icon(Icons.badge_outlined),
                          onPressed: () {
                            try {
                              context.go('/about');
                            } catch (_) {}
                          },
                        ),
                        const SizedBox(height: 4),
                        _ThemeToggleButton(themeMode: themeMode, ref: ref),
                        const SizedBox(height: 8),
                        ref.watch(isAuthenticatedProvider)
                            ? IconButton(
                                tooltip: 'Keluar',
                                icon: const Icon(Icons.logout_rounded),
                                onPressed: () => ref
                                    .read(authControllerProvider.notifier)
                                    .signOut(),
                              )
                            : IconButton(
                                tooltip: 'Masuk ke Akun',
                                icon: const Icon(Icons.login_rounded),
                                onPressed: () => context.go('/login'),
                              ),
                      ],
                    ),
                  ),
                ),
              ),
              destinations: destinations.map((d) {
                return NavigationRailDestination(
                  icon: Icon(d.icon),
                  selectedIcon: Icon(d.selectedIcon, color: primaryColor),
                  label: Text(d.label),
                );
              }).toList(),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }

  // ─── Desktop Shell (>= 1024px) ───────────────────────────────────────
  Widget _buildDesktopShell(
    BuildContext context,
    WidgetRef ref,
    int selectedIndex,
    List<NavigationDestinationItem> destinations,
  ) {
    final isDark = AppTheme.isDark(context);
    final primaryColor = AppTheme.primaryOf(context);
    final surfaceColor = AppTheme.surfaceOf(context);
    final borderColor = AppTheme.borderColorOf(context);
    final textPrimary = AppTheme.textPrimaryOf(context);
    final textMuted = AppTheme.textMutedOf(context);
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      body: Row(
        children: [
          // Persistent Modern SaaS Sidebar
          Container(
            width: 268,
            decoration: BoxDecoration(
              color: surfaceColor,
              border: Border(right: BorderSide(color: borderColor, width: 1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Brand Header + Theme Toggle
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 14, 18),
                  child: Row(
                    children: [
                      Expanded(
                        child: AppLogo(
                          mode: AppLogoMode.full,
                          height: 34,
                          onTap: () => context.go('/'),
                        ),
                      ),
                      _ThemeToggleButton(themeMode: themeMode, ref: ref),
                    ],
                  ),
                ),
                Container(height: 1, color: borderColor),
                const SizedBox(height: 16),

                // Section Label
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 0, 16, 8),
                  child: Text(
                    'NAVIGASI UTAMA',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                      color: textMuted.withValues(alpha: 0.75),
                    ),
                  ),
                ),

                // Navigation Items (ListView.builder preserved for tests & scalability)
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: destinations.length,
                    itemBuilder: (context, index) {
                      final item = destinations[index];
                      final isSelected = index == selectedIndex;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (index == 3) ...[
                            const SizedBox(height: 14),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(10, 4, 10, 8),
                              child: Text(
                                'INTELLIGENCE & AKUN',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.1,
                                  color: textMuted.withValues(alpha: 0.75),
                                ),
                              ),
                            ),
                          ],
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: _SidebarNavItem(
                              item: item,
                              isSelected: isSelected,
                              isDark: isDark,
                              primaryColor: primaryColor,
                              textPrimary: textPrimary,
                              textMuted: textMuted,
                              onTap: () => _onDestinationSelected(
                                context,
                                ref,
                                index,
                                destinations,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                // About Creator Link
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    onTap: () {
                      try {
                        context.go('/about');
                      } catch (_) {}
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.brandPrimary.withValues(
                              alpha: isDark ? 0.18 : 0.08,
                            ),
                            AppTheme.brandAccent.withValues(
                              alpha: isDark ? 0.10 : 0.04,
                            ),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(
                          color: primaryColor.withValues(alpha: 0.28),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.badge_outlined,
                            size: 18,
                            color: primaryColor,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'About Creator',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: textPrimary,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_outward_rounded,
                            size: 14,
                            color: primaryColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Bottom Account / Workspace Card
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                  child: _AccountDockCard(
                    isDark: isDark,
                    primaryColor: primaryColor,
                    borderColor: borderColor,
                    textPrimary: textPrimary,
                    textMuted: textMuted,
                  ),
                ),
              ],
            ),
          ),

          // Main Content Area
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _ThemeToggleButton extends StatelessWidget {
  final ThemeMode themeMode;
  final WidgetRef ref;

  const _ThemeToggleButton({required this.themeMode, required this.ref});

  @override
  Widget build(BuildContext context) {
    final isDark = themeMode == ThemeMode.dark;
    final borderColor = AppTheme.borderColorOf(context);
    final textMuted = AppTheme.textMutedOf(context);

    return Tooltip(
      message: isDark ? 'Beralih ke Mode Terang' : 'Beralih ke Mode Gelap',
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        onTap: () {
          ref.read(themeModeProvider.notifier).state = isDark
              ? ThemeMode.light
              : ThemeMode.dark;
        },
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppTheme.surfaceElevatedOf(context).withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(color: borderColor),
          ),
          child: Icon(
            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            size: 17,
            color: isDark ? AppTheme.brandSecondary : textMuted,
          ),
        ),
      ),
    );
  }
}

class _SidebarNavItem extends StatefulWidget {
  final NavigationDestinationItem item;
  final bool isSelected;
  final bool isDark;
  final Color primaryColor;
  final Color textPrimary;
  final Color textMuted;
  final VoidCallback onTap;

  const _SidebarNavItem({
    required this.item,
    required this.isSelected,
    required this.isDark,
    required this.primaryColor,
    required this.textPrimary,
    required this.textMuted,
    required this.onTap,
  });

  @override
  State<_SidebarNavItem> createState() => _SidebarNavItemState();
}

class _SidebarNavItemState extends State<_SidebarNavItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.isSelected;
    final primary = widget.primaryColor;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? primary.withValues(alpha: widget.isDark ? 0.14 : 0.09)
                  : _isHovered
                  ? AppTheme.surfaceElevatedOf(context).withValues(alpha: 0.65)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: isSelected
                    ? primary.withValues(alpha: widget.isDark ? 0.3 : 0.22)
                    : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  width: 3,
                  height: isSelected ? 18 : 0,
                  margin: EdgeInsets.only(right: isSelected ? 10 : 0),
                  decoration: BoxDecoration(
                    color: primary,
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: primary.withValues(alpha: 0.55),
                              blurRadius: 6,
                            ),
                          ]
                        : null,
                  ),
                ),
                Icon(
                  isSelected ? widget.item.selectedIcon : widget.item.icon,
                  size: 19,
                  color: isSelected
                      ? primary
                      : _isHovered
                      ? widget.textPrimary
                      : widget.textMuted,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.item.label,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      letterSpacing: -0.1,
                      color: isSelected
                          ? (widget.isDark ? Colors.white : primary)
                          : _isHovered
                          ? widget.textPrimary
                          : widget.textMuted,
                    ),
                  ),
                ),
                if (widget.item.label == 'Asisten AI')
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      gradient: AppTheme.accentGradient,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Text(
                      'AI',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AccountDockCard extends ConsumerWidget {
  final bool isDark;
  final Color primaryColor;
  final Color borderColor;
  final Color textPrimary;
  final Color textMuted;

  const _AccountDockCard({
    required this.isDark,
    required this.primaryColor,
    required this.borderColor,
    required this.textPrimary,
    required this.textMuted,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final isAuth = ref.watch(isAuthenticatedProvider);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardColorOf(context),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: borderColor),
        boxShadow: AppTheme.cardShadowOf(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Stack(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: AppTheme.accentGradient,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withValues(alpha: 0.25),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  Positioned(
                    right: -1,
                    bottom: -1,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: isAuth
                            ? AppTheme.statusSuccess
                            : AppTheme.brandSecondary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.cardColorOf(context),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user != null
                          ? (user.userMetadata?['display_name'] ?? 'Pengguna')
                          : 'RadarScholar',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: textPrimary,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 1),
                    Text(
                      user != null ? (user.email ?? '') : 'Mode Eksplorasi',
                      style: TextStyle(fontSize: 11, color: textMuted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: isAuth
                ? OutlinedButton.icon(
                    onPressed: () =>
                        ref.read(authControllerProvider.notifier).signOut(),
                    icon: const Icon(Icons.logout_rounded, size: 14),
                    label: const Text(
                      'Keluar',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      foregroundColor: AppTheme.statusDanger,
                      backgroundColor: AppTheme.statusDanger.withValues(
                        alpha: 0.06,
                      ),
                      side: BorderSide(
                        color: AppTheme.statusDanger.withValues(alpha: 0.25),
                      ),
                    ),
                  )
                : OutlinedButton.icon(
                    onPressed: () => context.go('/login'),
                    icon: const Icon(Icons.login_rounded, size: 14),
                    label: const Text(
                      'Masuk ke Akun',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      foregroundColor: primaryColor,
                      backgroundColor: primaryColor.withValues(alpha: 0.06),
                      side: BorderSide(
                        color: primaryColor.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
