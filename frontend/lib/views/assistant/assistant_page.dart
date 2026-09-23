import 'package:flutter/material.dart';
import '../../core/theme.dart';

class AssistantPage extends StatelessWidget {
  const AssistantPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: Spacing.pagePadding(MediaQuery.of(context).size.width),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Asisten AI RadarScholar',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.brandPrimary,
                ),
              ),
              const SizedBox(height: Spacing.xs),
              Text(
                'Pendampingan cerdas untuk persiapan berkas dan wawancara beasiswa.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
              ),
              const SizedBox(height: Spacing.xl),
              // Feature overview cards
              _buildFeatureCard(
                context,
                icon: Icons.description_outlined,
                title: 'Review CV & Portofolio Beasiswa',
                description:
                    'Analisis kesesuaian profil dan rekomendasi penekanan pencapaian akademik/organisasi secara objektif.',
                milestoneBadge: 'Milestone 9',
              ),
              const SizedBox(height: Spacing.md),
              _buildFeatureCard(
                context,
                icon: Icons.edit_note_rounded,
                title: 'Pendamping Motivasi & Esai',
                description:
                    'Bantuan penulisan esai terstruktur tanpa fabrikasi fakta data pribadi sesuai kode etik RadarScholar.',
                milestoneBadge: 'Milestone 9',
              ),
              const SizedBox(height: Spacing.md),
              _buildFeatureCard(
                context,
                icon: Icons.record_voice_over_outlined,
                title: 'Simulasi Wawancara Interaktif',
                description:
                    'Latihan tanya jawab berbasis persyaratan dan profil beasiswa yang Anda tuju.',
                milestoneBadge: 'Milestone 9',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required String milestoneBadge,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.brandPrimary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(icon, color: AppTheme.brandPrimary, size: 28),
            ),
            const SizedBox(width: Spacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.brandSecondary.withValues(
                            alpha: 0.15,
                          ),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Text(
                          milestoneBadge,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.amber.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
