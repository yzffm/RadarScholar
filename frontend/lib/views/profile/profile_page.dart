import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../controllers/profile_controller.dart';
import '../../models/user_profile.dart';

/// User Profile Page.
///
/// Handles CRUD operations for the user's profile (Academic, Experience, Interests).
/// Connects to [ProfileController] via Riverpod (CPMK 4).
class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _formKey = GlobalKey<FormState>();

  // Academic Controllers
  final _univController = TextEditingController();
  final _facultyController = TextEditingController();
  final _majorController = TextEditingController();
  final _semesterController = TextEditingController();
  final _gpaController = TextEditingController();
  DegreeLevel? _selectedDegree;

  // Experience & Interests (simplified as comma-separated for MVP)
  final _skillsController = TextEditingController();
  final _orgsController = TextEditingController();
  final _achievementsController = TextEditingController();
  final _careerController = TextEditingController();
  final _goalsController = TextEditingController();

  bool _isEditing = false;
  bool _initialized = false;

  @override
  void dispose() {
    _univController.dispose();
    _facultyController.dispose();
    _majorController.dispose();
    _semesterController.dispose();
    _gpaController.dispose();
    _skillsController.dispose();
    _orgsController.dispose();
    _achievementsController.dispose();
    _careerController.dispose();
    _goalsController.dispose();
    super.dispose();
  }

  void _populateForm(UserProfile profile) {
    if (_initialized) return;

    _univController.text = profile.university ?? '';
    _facultyController.text = profile.faculty ?? '';
    _majorController.text = profile.major ?? '';
    _selectedDegree = profile.degreeLevel;
    _semesterController.text = profile.semester?.toString() ?? '';
    _gpaController.text = profile.gpa?.toString() ?? '';

    _skillsController.text = profile.skills.join(', ');
    _orgsController.text = profile.organizations.join(', ');
    _achievementsController.text = profile.achievements.join(', ');
    _careerController.text = profile.careerInterests.join(', ');
    _goalsController.text = profile.goals ?? '';

    _initialized = true;
  }

  List<String> _splitComma(String text) {
    if (text.trim().isEmpty) return [];
    return text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final data = <String, dynamic>{
      'university': _univController.text.trim(),
      'faculty': _facultyController.text.trim(),
      'major': _majorController.text.trim(),
      'degree_level': _selectedDegree?.value,
      'semester': int.tryParse(_semesterController.text.trim()),
      'gpa': double.tryParse(_gpaController.text.trim()),
      'skills': _splitComma(_skillsController.text),
      'organizations': _splitComma(_orgsController.text),
      'achievements': _splitComma(_achievementsController.text),
      'career_interests': _splitComma(_careerController.text),
      'goals': _goalsController.text.trim(),
    };

    final success = await ref.read(profileControllerProvider.notifier).saveProfile(data);

    if (success && mounted) {
      setState(() => _isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppTheme.brandPrimary,
          content: const Text('Profil berhasil disimpan.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil & Akademik'),
        actions: [
          if (state is ProfileLoaded && !_isEditing)
            IconButton(
              icon: const Icon(Icons.edit_rounded),
              tooltip: 'Edit Profil',
              onPressed: () => setState(() => _isEditing = true),
            ),
        ],
      ),
      body: SafeArea(
        child: _buildBody(state),
      ),
    );
  }

  Widget _buildBody(ProfileState state) {
    if (state is ProfileLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is ProfileError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(state.message, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => ref.read(profileControllerProvider.notifier).fetchProfile(),
              child: const Text('Coba Lagi'),
            )
          ],
        ),
      );
    }

    if (state is ProfileNotFound) {
      _isEditing = true;
      return _buildForm();
    }

    if (state is ProfileLoaded) {
      if (!_isEditing) {
        _initialized = false; // reset so we repopulate on next edit
        return _buildReadOnlyProfile(state.profile);
      }
      _populateForm(state.profile);
      return _buildForm();
    }

    return const Center(child: Text('Memuat...'));
  }

  Widget _buildReadOnlyProfile(UserProfile profile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(Spacing.lg),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionCard(
                title: 'Data Akademik',
                icon: Icons.school_rounded,
                children: [
                  _buildDisplayField('Universitas', profile.university),
                  _buildDisplayField('Fakultas', profile.faculty),
                  _buildDisplayField('Program Studi', profile.major),
                  _buildDisplayField('Jenjang', profile.degreeLevel?.value),
                  _buildDisplayField('Semester', profile.semester?.toString()),
                  _buildDisplayField('IPK', profile.gpa?.toString()),
                ],
              ),
              const SizedBox(height: Spacing.lg),
              _buildSectionCard(
                title: 'Pengalaman & Kemampuan',
                icon: Icons.work_history_rounded,
                children: [
                  _buildDisplayList('Organisasi', profile.organizations),
                  _buildDisplayList('Pencapaian', profile.achievements),
                  _buildDisplayList('Keahlian (Skills)', profile.skills),
                ],
              ),
              const SizedBox(height: Spacing.lg),
              _buildSectionCard(
                title: 'Minat & Tujuan',
                icon: Icons.explore_rounded,
                children: [
                  _buildDisplayList('Minat Karir', profile.careerInterests),
                  _buildDisplayField('Tujuan (Goals)', profile.goals),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppTheme.brandPrimary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const Divider(height: 32),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDisplayField(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildDisplayList(String label, List<String> items) {
    if (items.isEmpty) return const SizedBox.shrink();
    return _buildDisplayField(label, items.join(' • '));
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(Spacing.lg),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.brandPrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline_rounded, color: AppTheme.brandPrimary),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Lengkapi profil Anda agar RadarScholar dapat memberikan rekomendasi beasiswa yang paling akurat.',
                          style: TextStyle(color: AppTheme.brandPrimary),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Spacing.xl),

                // Data Akademik
                Text('Data Akademik', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: Spacing.md),
                TextFormField(
                  controller: _univController,
                  decoration: const InputDecoration(labelText: 'Universitas', border: OutlineInputBorder()),
                ),
                const SizedBox(height: Spacing.md),
                Row(
                  children: [
                    Expanded(child: TextFormField(
                      controller: _facultyController,
                      decoration: const InputDecoration(labelText: 'Fakultas', border: OutlineInputBorder()),
                    )),
                    const SizedBox(width: Spacing.md),
                    Expanded(child: TextFormField(
                      controller: _majorController,
                      decoration: const InputDecoration(labelText: 'Program Studi (Jurusan)', border: OutlineInputBorder()),
                    )),
                  ],
                ),
                const SizedBox(height: Spacing.md),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<DegreeLevel>(
                        value: _selectedDegree,
                        decoration: const InputDecoration(labelText: 'Jenjang', border: OutlineInputBorder()),
                        items: DegreeLevel.values.map((e) {
                          return DropdownMenuItem(value: e, child: Text(e.value));
                        }).toList(),
                        onChanged: (val) => setState(() => _selectedDegree = val),
                      ),
                    ),
                    const SizedBox(width: Spacing.md),
                    Expanded(
                      child: TextFormField(
                        controller: _semesterController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Semester (Cth: 5)', border: OutlineInputBorder()),
                        validator: (val) {
                          if (val != null && val.isNotEmpty) {
                            final n = int.tryParse(val);
                            if (n == null || n < 1 || n > 14) return 'Semester 1 - 14';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: Spacing.md),
                    Expanded(
                      child: TextFormField(
                        controller: _gpaController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(labelText: 'IPK (Cth: 3.75)', border: OutlineInputBorder()),
                        validator: (val) {
                          if (val != null && val.isNotEmpty) {
                            final n = double.tryParse(val);
                            if (n == null || n < 0 || n > 4) return 'IPK 0.0 - 4.0';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: Spacing.xxl),
                // Pengalaman
                Text('Pengalaman & Kemampuan', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: Spacing.xs),
                Text('Pisahkan dengan koma (,)', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                const SizedBox(height: Spacing.md),
                TextFormField(
                  controller: _skillsController,
                  decoration: const InputDecoration(labelText: 'Keahlian / Skills', hintText: 'Python, Public Speaking, Design', border: OutlineInputBorder()),
                ),
                const SizedBox(height: Spacing.md),
                TextFormField(
                  controller: _orgsController,
                  decoration: const InputDecoration(labelText: 'Organisasi', hintText: 'BEM UI, HMIF ITB', border: OutlineInputBorder()),
                ),
                const SizedBox(height: Spacing.md),
                TextFormField(
                  controller: _achievementsController,
                  decoration: const InputDecoration(labelText: 'Pencapaian / Prestasi', hintText: 'Juara 1 Hackathon Nasional', border: OutlineInputBorder()),
                ),

                const SizedBox(height: Spacing.xxl),
                // Minat
                Text('Minat & Tujuan', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: Spacing.md),
                TextFormField(
                  controller: _careerController,
                  decoration: const InputDecoration(labelText: 'Minat Karir (Pisahkan koma)', hintText: 'Data Scientist, Software Engineer', border: OutlineInputBorder()),
                ),
                const SizedBox(height: Spacing.md),
                TextFormField(
                  controller: _goalsController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Tujuan Masa Depan', hintText: 'Ceritakan singkat tentang tujuan karir Anda...', border: OutlineInputBorder()),
                ),

                const SizedBox(height: Spacing.xxl),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (ref.read(profileControllerProvider) is ProfileLoaded)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isEditing = false;
                            _initialized = false;
                          });
                        },
                        child: const Text('Batal'),
                      ),
                    const SizedBox(width: 16),
                    FilledButton.icon(
                      onPressed: _saveProfile,
                      icon: const Icon(Icons.save_rounded, size: 18),
                      label: const Text('Simpan Profil'),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.xxl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
