import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Navigation destination model representing an item in the AppShell.
class NavigationDestinationItem {
  final String label;
  final String path;
  final int iconCodePoint;
  final int selectedIconCodePoint;

  const NavigationDestinationItem({
    required this.label,
    required this.path,
    required this.iconCodePoint,
    required this.selectedIconCodePoint,
  });
}

/// The 5 core navigation destinations of RadarScholar as defined in Technical Docs §11.
final navigationDestinationsProvider =
    Provider<List<NavigationDestinationItem>>((ref) {
      return const [
        NavigationDestinationItem(
          label: 'Eksplorasi',
          path: '/discovery',
          iconCodePoint: 0xe59a, // search / explore
          selectedIconCodePoint: 0xe59a,
        ),
        NavigationDestinationItem(
          label: 'Tersimpan',
          path: '/saved',
          iconCodePoint: 0xe0e7, // bookmark_border
          selectedIconCodePoint: 0xe0e6, // bookmark
        ),
        NavigationDestinationItem(
          label: 'Pelacakan',
          path: '/applications',
          iconCodePoint: 0xe15f, // assignment_outlined
          selectedIconCodePoint: 0xe15e, // assignment
        ),
        NavigationDestinationItem(
          label: 'Asisten AI',
          path: '/assistant',
          iconCodePoint: 0xe0b4, // auto_awesome_outlined
          selectedIconCodePoint: 0xe0b3, // auto_awesome
        ),
        NavigationDestinationItem(
          label: 'Profil',
          path: '/profile',
          iconCodePoint: 0xe491, // person_outline
          selectedIconCodePoint: 0xe490, // person
        ),
      ];
    });

/// Riverpod state provider tracking the current selected navigation index in the shell.
final navigationIndexProvider = StateProvider<int>((ref) => 0);
