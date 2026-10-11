import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'profile_controller.dart';

/// Navigation destination model representing an item in the AppShell.
class NavigationDestinationItem {
  final String label;
  final String path;
  final IconData icon;
  final IconData selectedIcon;

  const NavigationDestinationItem({
    required this.label,
    required this.path,
    required this.icon,
    required this.selectedIcon,
  });
}

/// The 5 core navigation destinations of RadarScholar as defined in Technical Docs §11.
final navigationDestinationsProvider =
    Provider<List<NavigationDestinationItem>>((ref) {
      final items = [
        const NavigationDestinationItem(
          label: 'Eksplorasi',
          path: '/discovery',
          icon: Icons.explore_outlined,
          selectedIcon: Icons.explore,
        ),
        const NavigationDestinationItem(
          label: 'Tersimpan',
          path: '/saved',
          icon: Icons.bookmark_border,
          selectedIcon: Icons.bookmark,
        ),
        const NavigationDestinationItem(
          label: 'Pelacakan',
          path: '/applications',
          icon: Icons.assignment_outlined,
          selectedIcon: Icons.assignment,
        ),
        const NavigationDestinationItem(
          label: 'Asisten AI',
          path: '/assistant',
          icon: Icons.auto_awesome_outlined,
          selectedIcon: Icons.auto_awesome,
        ),
        const NavigationDestinationItem(
          label: 'Profil',
          path: '/profile',
          icon: Icons.person_outline,
          selectedIcon: Icons.person,
        ),
      ];

      final profileState = ref.watch(profileControllerProvider);
      if (profileState is ProfileLoaded && profileState.profile.isAdmin) {
        items.add(
          const NavigationDestinationItem(
            label: 'Admin',
            path: '/admin',
            icon: Icons.dashboard_outlined,
            selectedIcon: Icons.dashboard,
          ),
        );
      }

      return items;
    });

/// Riverpod state provider tracking the current selected navigation index in the shell.
final navigationIndexProvider = StateProvider<int>((ref) => 0);
