import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/empty_state.dart';

class DiscoveryPage extends StatelessWidget {
  const DiscoveryPage({super.key});

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
                'Eksplorasi Beasiswa',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.brandPrimary,
                    ),
              ),
              const SizedBox(height: Spacing.xs),
              Text(
                'Jelajahi peluang beasiswa dari sumber resmi yang terverifikasi.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
              const SizedBox(height: Spacing.lg),
              // Search & Filter bar placeholder
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search_rounded, color: Colors.grey.shade600),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        enabled: false,
                        decoration: InputDecoration(
                          hintText: 'Cari berdasarkan nama beasiswa, institusi, atau bidang...',
                          hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.tune_rounded),
                      onPressed: () {},
                      tooltip: 'Filter',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Spacing.md),
              // Filter chips preview
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip(context, 'Semua Beasiswa', true),
                    const SizedBox(width: 8),
                    _buildFilterChip(context, 'Jenjang S1', false),
                    const SizedBox(width: 8),
                    _buildFilterChip(context, 'Bantuan UKT', false),
                    const SizedBox(width: 8),
                    _buildFilterChip(context, 'Prestasi', false),
                    const SizedBox(width: 8),
                    _buildFilterChip(context, 'Deadline Terdekat', false),
                  ],
                ),
              ),
              const SizedBox(height: Spacing.xl),
              // Empty State ready for M4 (Scholarship Discovery)
              Expanded(
                child: Center(
                  child: EmptyState(
                    icon: Icons.manage_search_rounded,
                    title: 'Pusat Eksplorasi Beasiswa',
                    message:
                        'Katalog beasiswa terverifikasi, penyaringan multi-kriteria, dan engine pencocokan profil deterministik akan aktif pada Milestone 4 (M4).',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, bool isSelected) {
    return FilterChip(
      selected: isSelected,
      label: Text(label),
      onSelected: (_) {},
      selectedColor: AppTheme.brandPrimary.withValues(alpha: 0.12),
      checkmarkColor: AppTheme.brandPrimary,
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.brandPrimary : Colors.grey.shade700,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        fontSize: 13,
      ),
    );
  }
}
