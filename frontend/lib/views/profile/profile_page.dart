import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../controllers/profile_controller.dart';
import '../../models/user_profile.dart';
import '../../widgets/error_state.dart';

/// User Profile Page — Modern SaaS Academic Identity Workspace.
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
    return text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  Future<void> _confirmEditProfile() async {
    final shouldContinue = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit profil?'),
        content: const Text(
          'Perubahan profil dapat memengaruhi hasil pencocokan beasiswa Anda.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Lanjutkan'),
          ),
        ],
      ),
    );

    if (shouldContinue == true && mounted) {
      setState(() => _isEditing = true);
    }
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

    final success = await ref
        .read(profileControllerProvider.notifier)
        .saveProfile(data);

    if (success && mounted) {
      setState(() => _isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppTheme.brandPrimary,
          content: Text('Profil berhasil disimpan.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileControllerProvider);
    final borderColor = AppTheme.borderColorOf(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil & Akademik'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: borderColor),
        ),
        actions: [
          if (state is ProfileLoaded && !_isEditing)
            IconButton(
              icon: const Icon(Icons.edit_rounded, size: 19),
              tooltip: 'Edit Profil',
              onPressed: _confirmEditProfile,
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(child: _buildBody(state)),
    );
  }

  Widget _buildBody(ProfileState state) {
    if (state is ProfileLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is ProfileError) {
      return ErrorState(
        message: state.message,
        onRetry: () =>
            ref.read(profileControllerProvider.notifier).fetchProfile(),
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
    final primaryColor = AppTheme.primaryOf(context);
    final textPrimary = AppTheme.textPrimaryOf(context);
    final textMuted = AppTheme.textMutedOf(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      padding: Spacing.pagePadding(screenWidth),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 920),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Profile Hero Card
              Container(
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.only(bottom: Spacing.lg),
                decoration: BoxDecoration(
                  color: AppTheme.cardColorOf(context),
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border.all(color: AppTheme.borderColorOf(context)),
                  boxShadow: AppTheme.cardShadowOf(context),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            gradient: AppTheme.accentGradient,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: AppTheme.glowShadowOf(
                              primaryColor,
                              intensity: 0.25,
                            ),
                          ),
                          child: const Icon(
                            Icons.school_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                profile.university ??
                                    'Perguruan Tinggi Belum Diisi',
                                style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                  color: textPrimary,
                                  letterSpacing: -0.4,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                [
                                  if (profile.faculty != null &&
                                      profile.faculty!.isNotEmpty)
                                    profile.faculty,
                                  if (profile.major != null &&
                                      profile.major!.isNotEmpty)
                                    profile.major,
                                  if (profile.degreeLevel != null)
                                    profile.degreeLevel!.value,
                                ].join(' • '),
                                style: TextStyle(
                                  fontSize: 13.5,
                                  color: textMuted,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        FilledButton.icon(
                          onPressed: _confirmEditProfile,
                          icon: const Icon(Icons.edit_rounded, size: 15),
                          label: const Text('Edit'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      height: 1,
                      color: AppTheme.borderColorOf(context),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricTile(
                            'JENJANG',
                            profile.degreeLevel?.value ?? '-',
                            Icons.workspace_premium_outlined,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildMetricTile(
                            'SEMESTER',
                            profile.semester?.toString() ?? '-',
                            Icons.timelapse_rounded,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildMetricTile(
                            'IPK / GPA',
                            profile.gpa?.toStringAsFixed(2) ?? '-',
                            Icons.insights_rounded,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

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
              const SizedBox(height: Spacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricTile(String label, String value, IconData icon) {
    final primaryColor = AppTheme.primaryOf(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevatedOf(context),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppTheme.borderColorOf(context)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: primaryColor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: AppTheme.textMutedOf(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimaryOf(context),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final primaryColor = AppTheme.primaryOf(context);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColorOf(context),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppTheme.borderColorOf(context)),
        boxShadow: AppTheme.cardShadowOf(context),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, color: primaryColor, size: 18),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimaryOf(context),
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 1,
            color: AppTheme.borderColorOf(context).withValues(alpha: 0.65),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDisplayField(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppTheme.textMutedOf(context),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimaryOf(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisplayList(String label, List<String> items) {
    if (items.isEmpty) return const SizedBox.shrink();
    final primaryColor = AppTheme.primaryOf(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppTheme.textMutedOf(context),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items.map((item) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(
                    color: primaryColor.withValues(alpha: 0.25),
                  ),
                ),
                child: Text(
                  item,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    final primaryColor = AppTheme.primaryOf(context);
    final textPrimary = AppTheme.textPrimaryOf(context);
    final textMuted = AppTheme.textMutedOf(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return SingleChildScrollView(
      padding: Spacing.pagePadding(screenWidth),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 880),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(
                      color: primaryColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Lengkapi profil Anda agar RadarScholar dapat memberikan rekomendasi beasiswa yang paling akurat secara real-time.',
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 13.5,
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Spacing.lg),

                // Data Akademik Card
                _buildSectionCard(
                  title: 'Data Akademik',
                  icon: Icons.school_rounded,
                  children: [
                    TextFormField(
                      controller: _univController,
                      decoration: const InputDecoration(
                        labelText: 'Universitas',
                      ),
                    ),
                    const SizedBox(height: Spacing.md),
                    if (isMobile) ...[
                      TextFormField(
                        controller: _facultyController,
                        decoration: const InputDecoration(
                          labelText: 'Fakultas',
                        ),
                      ),
                      const SizedBox(height: Spacing.md),
                      TextFormField(
                        controller: _majorController,
                        decoration: const InputDecoration(
                          labelText: 'Program Studi (Jurusan)',
                        ),
                      ),
                    ] else
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _facultyController,
                              decoration: const InputDecoration(
                                labelText: 'Fakultas',
                              ),
                            ),
                          ),
                          const SizedBox(width: Spacing.md),
                          Expanded(
                            child: TextFormField(
                              controller: _majorController,
                              decoration: const InputDecoration(
                                labelText: 'Program Studi (Jurusan)',
                              ),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: Spacing.md),
                    if (isMobile) ...[
                      DropdownButtonFormField<DegreeLevel>(
                        initialValue: _selectedDegree,
                        decoration: const InputDecoration(labelText: 'Jenjang'),
                        items: DegreeLevel.values.map((e) {
                          return DropdownMenuItem(
                            value: e,
                            child: Text(e.value),
                          );
                        }).toList(),
                        onChanged: (val) =>
                            setState(() => _selectedDegree = val),
                      ),
                      const SizedBox(height: Spacing.md),
                      TextFormField(
                        controller: _semesterController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Semester (Cth: 5)',
                        ),
                        validator: _validateSemester,
                      ),
                      const SizedBox(height: Spacing.md),
                      TextFormField(
                        controller: _gpaController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'IPK (Cth: 3.75)',
                        ),
                        validator: _validateGpa,
                      ),
                    ] else
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<DegreeLevel>(
                              initialValue: _selectedDegree,
                              decoration: const InputDecoration(
                                labelText: 'Jenjang',
                              ),
                              items: DegreeLevel.values.map((e) {
                                return DropdownMenuItem(
                                  value: e,
                                  child: Text(e.value),
                                );
                              }).toList(),
                              onChanged: (val) =>
                                  setState(() => _selectedDegree = val),
                            ),
                          ),
                          const SizedBox(width: Spacing.md),
                          Expanded(
                            child: TextFormField(
                              controller: _semesterController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Semester (Cth: 5)',
                              ),
                              validator: _validateSemester,
                            ),
                          ),
                          const SizedBox(width: Spacing.md),
                          Expanded(
                            child: TextFormField(
                              controller: _gpaController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: const InputDecoration(
                                labelText: 'IPK (Cth: 3.75)',
                              ),
                              validator: _validateGpa,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),

                const SizedBox(height: Spacing.lg),

                // Pengalaman & Kemampuan Card
                _buildSectionCard(
                  title: 'Pengalaman & Kemampuan',
                  icon: Icons.work_history_rounded,
                  children: [
                    Text(
                      'Pisahkan setiap entri dengan tanda koma (,)',
                      style: TextStyle(color: textMuted, fontSize: 12.5),
                    ),
                    const SizedBox(height: Spacing.md),
                    TextFormField(
                      controller: _skillsController,
                      decoration: const InputDecoration(
                        labelText: 'Keahlian / Skills',
                        hintText: 'Python, Public Speaking, Design',
                      ),
                    ),
                    const SizedBox(height: Spacing.md),
                    TextFormField(
                      controller: _orgsController,
                      decoration: const InputDecoration(
                        labelText: 'Organisasi',
                        hintText: 'BEM UI, HMIF ITB',
                      ),
                    ),
                    const SizedBox(height: Spacing.md),
                    TextFormField(
                      controller: _achievementsController,
                      decoration: const InputDecoration(
                        labelText: 'Pencapaian / Prestasi',
                        hintText: 'Juara 1 Hackathon Nasional',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: Spacing.lg),

                // Minat & Tujuan Card
                _buildSectionCard(
                  title: 'Minat & Tujuan',
                  icon: Icons.explore_rounded,
                  children: [
                    TextFormField(
                      controller: _careerController,
                      decoration: const InputDecoration(
                        labelText: 'Minat Karir (Pisahkan koma)',
                        hintText: 'Data Scientist, Software Engineer',
                      ),
                    ),
                    const SizedBox(height: Spacing.md),
                    TextFormField(
                      controller: _goalsController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Tujuan Masa Depan',
                        hintText:
                            'Ceritakan singkat tentang tujuan karir Anda...',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: Spacing.xl),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (ref.read(profileControllerProvider) is ProfileLoaded)
                      OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _isEditing = false;
                            _initialized = false;
                          });
                        },
                        child: const Text('Batal'),
                      ),
                    const SizedBox(width: 12),
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

  String? _validateSemester(String? val) {
    if (val != null && val.isNotEmpty) {
      final n = int.tryParse(val);
      if (n == null || n < 1 || n > 14) {
        return 'Semester 1 - 14';
      }
    }
    return null;
  }

  String? _validateGpa(String? val) {
    if (val != null && val.isNotEmpty) {
      final n = double.tryParse(val);
      if (n == null || n < 0 || n > 4) {
        return 'IPK 0.0 - 4.0';
      }
    }
    return null;
  }
}
