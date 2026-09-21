import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/empty_state.dart';

class SavedPage extends StatelessWidget {
  const SavedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: Spacing.pagePadding(MediaQuery.of(context).size.width),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Beasiswa Tersimpan',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.brandPrimary,
                    ),
              ),
              const SizedBox(height: Spacing.xs),
              Text(
                'Daftar pantauan beasiswa yang menarik minat Anda.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
              const SizedBox(height: Spacing.xl),
              const Expanded(
                child: Center(
                  child: EmptyState(
                    icon: Icons.bookmark_border_rounded,
                    title: 'Belum Ada Beasiswa Tersimpan',
                    message:
                        'Fitur watchlist dan pelacakan tenggat waktu beasiswa yang disimpan akan diimplementasikan pada Milestone 6 (M6).',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
