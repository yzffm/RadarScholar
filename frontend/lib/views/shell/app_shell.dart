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

  const AppShell({
    super.key,
    required this.child,
  });

  int _calculateSelectedIndex(BuildContext context, List<NavigationDestinationItem> destinations) {
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
    return Scaffold(
      appBar: AppBar(
        title: AppLogo(
          mode: AppLogoMode.full,
          height: 32,
          onTap: () => context.go('/'),
        ),
        actions: [
          if (ref.watch(isAuthenticatedProvider))
            IconButton(
              tooltip: 'Keluar',
              icon: const Icon(Icons.logout_rounded),
              onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
            )
          else
            IconButton(
              tooltip: 'Masuk ke Akun',
              icon: const Icon(Icons.account_circle_outlined),
              onPressed: () => context.go('/login'),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) => _onDestinationSelected(context, ref, index, destinations),
        destinations: destinations.map((d) {
          return NavigationDestination(
            icon: Icon(IconData(d.iconCodePoint, fontFamily: 'MaterialIcons')),
            selectedIcon: Icon(
              IconData(d.selectedIconCodePoint, fontFamily: 'MaterialIcons'),
              color: AppTheme.brandPrimary,
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
              child: AppLogo.icon(
                height: 40,
                onTap: () => context.go('/'),
              ),
            ),
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: ref.watch(isAuthenticatedProvider)
                      ? IconButton(
                          tooltip: 'Keluar',
                          icon: const Icon(Icons.logout_rounded),
                          onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
                        )
                      : IconButton(
                          tooltip: 'Masuk ke Akun',
                          icon: const Icon(Icons.login_rounded),
                          onPressed: () => context.go('/login'),
                        ),
                ),
              ),
            ),
            destinations: destinations.map((d) {
              return NavigationRailDestination(
                icon: Icon(IconData(d.iconCodePoint, fontFamily: 'MaterialIcons')),
                selectedIcon: Icon(
                  IconData(d.selectedIconCodePoint, fontFamily: 'MaterialIcons'),
                  color: AppTheme.brandPrimary,
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
    return Scaffold(
      body: Row(
        children: [
          // Persistent Sidebar
          Container(
            width: 260,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                right: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                  child: AppLogo(
                    mode: AppLogoMode.full,
                    height: 38,
                    onTap: () => context.go('/'),
                  ),
                ),
                const Divider(height: 1, thickness: 1),
                const SizedBox(height: 16),

                // Navigation Items
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: destinations.length,
                    itemBuilder: (context, index) {
                      final item = destinations[index];
                      final isSelected = index == selectedIndex;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: InkWell(
                          onTap: () => _onDestinationSelected(context, ref, index, destinations),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.brandPrimary.withValues(alpha: 0.1)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  IconData(
                                    isSelected
                                        ? item.selectedIconCodePoint
                                        : item.iconCodePoint,
                                    fontFamily: 'MaterialIcons',
                                  ),
                                  size: 22,
                                  color: isSelected
                                      ? AppTheme.brandPrimary
                                      : Colors.grey.shade700,
                                ),
                                const SizedBox(width: 14),
                                Text(
                                  item.label,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                    color: isSelected
                                        ? AppTheme.brandPrimary
                                        : Colors.grey.shade800,
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

                // Bottom Account / Login Prompt
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.brandPrimary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: AppTheme.brandPrimary.withValues(alpha: 0.15),
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
                                color: AppTheme.brandPrimary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.person_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Consumer(
                                builder: (context, ref, child) {
                                  final user = ref.watch(currentUserProvider);
                                  if (user != null) {
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          user.userMetadata?['display_name'] ?? 'Pengguna',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            color: Colors.grey.shade900,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          user.email ?? '',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey.shade600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    );
                                  }
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'RadarScholar',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: Colors.grey.shade900,
                                        ),
                                      ),
                                      Text(
                                        'M2 — Terautentikasi',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey.shade600,
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
                                  onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
                                  icon: const Icon(Icons.logout_rounded, size: 16),
                                  label: const Text('Keluar', style: TextStyle(fontSize: 12)),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    foregroundColor: Colors.red.shade700,
                                    side: BorderSide(color: Colors.red.shade200),
                                  ),
                                );
                              }
                              return OutlinedButton.icon(
                                onPressed: () => context.go('/login'),
                                icon: const Icon(Icons.login_rounded, size: 16),
                                label: const Text('Masuk ke Akun', style: TextStyle(fontSize: 12)),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  foregroundColor: AppTheme.brandPrimary,
                                  side: const BorderSide(color: AppTheme.brandPrimary),
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
