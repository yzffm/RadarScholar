import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/empty_state.dart';

class ApplicationsPage extends StatelessWidget {
  const ApplicationsPage({super.key});

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
                'Pelacakan Lamaran',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.brandPrimary,
                    ),
              ),
              const SizedBox(height: Spacing.xs),
              Text(
                'Pantau status aplikasi, berkas persyaratan, dan tenggat waktu pendaftaran.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
              const SizedBox(height: Spacing.xl),
              const Expanded(
                child: Center(
                  child: EmptyState(
                    icon: Icons.checklist_rtl_rounded,
                    title: 'Manajemen Aplikasi & Berkas',
                    message:
                        'Manajemen tahapan seleksi, checklist berkas pendaftaran, dan pengingat deadline resmi akan diimplementasikan pada Milestone 6 (M6).',
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
