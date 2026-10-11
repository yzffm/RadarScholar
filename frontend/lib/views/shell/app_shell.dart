import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/responsive.dart';
import '../../core/theme.dart';
import '../../controllers/navigation_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/app_logo.dart';

/// RadarScholar Responsive Application Shell.
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

    return Scaffold(
      appBar: AppBar(
        title: AppLogo(
          mode: AppLogoMode.full,
          height: 30,
          onTap: () => context.go('/'),
        ),
        actions: [
          IconButton(
            tooltip: themeMode == ThemeMode.dark ? 'Mode Terang' : 'Mode Gelap',
            icon: Icon(
              themeMode == ThemeMode.dark
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
              size: 20,
            ),
            onPressed: () {
              ref
                  .read(themeModeProvider.notifier)
                  .state = themeMode == ThemeMode.dark
                  ? ThemeMode.light
                  : ThemeMode.dark;
            },
          ),
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
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) =>
            _onDestinationSelected(context, ref, index, destinations),
        destinations: destinations.map((d) {
          return NavigationDestination(
            icon: Icon(d.icon),
            selectedIcon: Icon(
              d.selectedIcon,
              color: primaryColor,
            ),
            label: d.label,
          );
        }).toList(),
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

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
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
                        tooltip: themeMode == ThemeMode.dark
                            ? 'Mode Terang'
                            : 'Mode Gelap',
                        icon: Icon(
                          themeMode == ThemeMode.dark
                              ? Icons.light_mode_rounded
                              : Icons.dark_mode_rounded,
                        ),
                        onPressed: () {
                          ref
                              .read(themeModeProvider.notifier)
                              .state = themeMode == ThemeMode.dark
                              ? ThemeMode.light
                              : ThemeMode.dark;
                        },
                      ),
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
                selectedIcon: Icon(
                  d.selectedIcon,
                  color: primaryColor,
                ),
                label: Text(d.label),
              );
            }).toList(),
          ),
          const VerticalDivider(thickness: 1, width: 1),
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
    final colors = Theme.of(context).colorScheme;
    final primaryColor = AppTheme.primaryOf(context);
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      body: Row(
        children: [
          // Persistent Modern Sidebar
          Container(
            width: 260,
            decoration: BoxDecoration(
              color: colors.surface,
              border: Border(
                right: BorderSide(color: colors.outlineVariant, width: 1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo Header with Theme Switcher
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 20, 14, 18),
                  child: Row(
                    children: [
                      Expanded(
                        child: AppLogo(
                          mode: AppLogoMode.full,
                          height: 34,
                          onTap: () => context.go('/'),
                        ),
                      ),
                      IconButton(
                        tooltip: themeMode == ThemeMode.dark
                            ? 'Mode Terang'
                            : 'Mode Gelap',
                        icon: Icon(
                          themeMode == ThemeMode.dark
                              ? Icons.light_mode_outlined
                              : Icons.dark_mode_outlined,
                          size: 18,
                          color: colors.onSurfaceVariant,
                        ),
                        onPressed: () {
                          ref
                              .read(themeModeProvider.notifier)
                              .state = themeMode == ThemeMode.dark
                              ? ThemeMode.light
                              : ThemeMode.dark;
                        },
                      ),
                    ],
                  ),
                ),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: colors.outlineVariant.withValues(alpha: 0.6),
                ),
                const SizedBox(height: 14),

                // Navigation Items
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    itemCount: destinations.length,
                    itemBuilder: (context, index) {
                      final item = destinations[index];
                      final isSelected = index == selectedIndex;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: InkWell(
                          onTap: () => _onDestinationSelected(
                            context,
                            ref,
                            index,
                            destinations,
                          ),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? primaryColor.withValues(alpha: 0.12)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              border: Border.all(
                                color: isSelected
                                    ? primaryColor.withValues(alpha: 0.25)
                                    : Colors.transparent,
                              ),
                            ),
                            child: Row(
                              children: [
                                if (isSelected)
                                  Container(
                                    width: 3,
                                    height: 16,
                                    margin: const EdgeInsets.only(right: 10),
                                    decoration: BoxDecoration(
                                      color: primaryColor,
                                      borderRadius: BorderRadius.circular(2),
                                      boxShadow: [
                                        BoxShadow(
                                          color: primaryColor.withValues(
                                            alpha: 0.5,
                                          ),
                                          blurRadius: 6,
                                        ),
                                      ],
                                    ),
                                  ),
                                Icon(
                                  isSelected ? item.selectedIcon : item.icon,
                                  size: 20,
                                  color: isSelected
                                      ? primaryColor
                                      : colors.onSurfaceVariant,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    item.label,
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? (AppTheme.isDark(context)
                                                ? Colors.white
                                                : primaryColor)
                                          : colors.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                                if (item.label == 'Asisten AI')
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: AppTheme.accentGradient,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      'AI',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Bottom Account / Login Card
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHighest.withValues(
                        alpha: 0.5,
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: colors.outlineVariant.withValues(alpha: 0.7),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                gradient: AppTheme.accentGradient,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryColor.withValues(alpha: 0.25),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.person_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Consumer(
                                builder: (context, ref, child) {
                                  final user = ref.watch(currentUserProvider);
                                  if (user != null) {
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          user.userMetadata?['display_name'] ??
                                              'Pengguna',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12.5,
                                            color: colors.onSurface,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          user.email ?? '',
                                          style: TextStyle(
                                            fontSize: 10.5,
                                            color: colors.onSurfaceVariant,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    );
                                  }
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'RadarScholar',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12.5,
                                          color: colors.onSurface,
                                        ),
                                      ),
                                      Text(
                                        'Mode Eksplorasi',
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          color: colors.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: Consumer(
                            builder: (context, ref, child) {
                              final isAuth = ref.watch(isAuthenticatedProvider);
                              if (isAuth) {
                                return OutlinedButton.icon(
                                  onPressed: () => ref
                                      .read(authControllerProvider.notifier)
                                      .signOut(),
                                  icon: const Icon(
                                    Icons.logout_rounded,
                                    size: 14,
                                  ),
                                  label: const Text(
                                    'Keluar',
                                    style: TextStyle(fontSize: 11.5),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 6,
                                    ),
                                    foregroundColor: const Color(0xFFF87171),
                                    side: BorderSide(
                                      color: const Color(
                                        0xFFF87171,
                                      ).withValues(alpha: 0.3),
                                    ),
                                  ),
                                );
                              }
                              return OutlinedButton.icon(
                                onPressed: () => context.go('/login'),
                                icon: const Icon(Icons.login_rounded, size: 14),
                                label: const Text(
                                  'Masuk ke Akun',
                                  style: TextStyle(fontSize: 11.5),
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 6,
                                  ),
                                  foregroundColor: primaryColor,
                                  side: BorderSide(
                                    color: primaryColor.withValues(alpha: 0.4),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Main Content
          Expanded(child: child),
        ],
      ),
    );
  }
}
