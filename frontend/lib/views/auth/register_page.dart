import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/responsive.dart';
import '../../core/theme.dart';
import '../../controllers/register_controller.dart';
import '../../widgets/app_logo.dart';

/// RadarScholar Registration Page.
///
/// Premium split-screen design matching the Login page style (CPMK 2).
/// Connected to [RegisterController] via Riverpod (CPMK 4).
class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (_formKey.currentState?.validate() ?? false) {
      final success =
          await ref.read(registerControllerProvider.notifier).submitRegister();
      if (success && mounted) {
        final state = ref.read(registerControllerProvider);
        if (state.needsEmailConfirmation) {
          _showEmailConfirmationDialog();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppTheme.brandPrimary,
              content: const Text('Pendaftaran berhasil! Selamat datang.'),
            ),
          );
          context.go('/discovery');
        }
      }
    }
  }

  void _showEmailConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: const Row(
          children: [
            Icon(Icons.mail_outline_rounded,
                color: AppTheme.brandPrimary, size: 28),
            SizedBox(width: 12),
            Text('Verifikasi Email'),
          ],
        ),
        content: const Text(
          'Kami telah mengirimkan link konfirmasi ke email Anda. '
          'Silakan periksa inbox (dan folder spam) untuk mengaktifkan akun.',
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.go('/login');
            },
            child: const Text('Ke Halaman Login'),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final state = ref.watch(registerControllerProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = Responsive.isDesktop(screenWidth);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: isDesktop
            ? _buildDesktopLayout(context, state)
            : _buildMobileTabletLayout(context, state),
      ),
    );
  }

  // ─── Desktop Split Screen ────────────────────────────────────────────
  Widget _buildDesktopLayout(BuildContext context, RegisterFormState state) {
    return Row(
      children: [
        // Left Column: Brand Hero
        Expanded(
          flex: 5,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 48),
            decoration: const BoxDecoration(
              gradient: AppTheme.heroGradient,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    AppLogo.icon(height: 48),
                    const SizedBox(width: 14),
                    Text(
                      'RadarScholar',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppRadius.xxl),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.school_rounded,
                              color: AppTheme.brandSecondary, size: 16),
                          SizedBox(width: 6),
                          Text(
                            'Mulai Perjalanan Beasiswamu',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: Spacing.xl),
                    Text(
                      'Daftar dan Temukan\nBeasiswa yang Tepat.',
                      style:
                          Theme.of(context).textTheme.displaySmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                    ),
                    const SizedBox(height: Spacing.md),
                    Text(
                      'Buat profil akademikmu, dan biarkan RadarScholar '
                      'mencocokanmu dengan beasiswa dari sumber terkurasi resmi.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withValues(alpha: 0.85),
                            height: 1.6,
                          ),
                    ),
                    const SizedBox(height: Spacing.xxl),
                    _buildPillarItem(
                      icon: Icons.verified_user_outlined,
                      title: 'Profil Sekali, Cocokkan Berkali-kali',
                      subtitle:
                          'Lengkapi profil akademik dan sistem otomatis mencarikan yang relevan.',
                    ),
                    const SizedBox(height: Spacing.md),
                    _buildPillarItem(
                      icon: Icons.notifications_active_outlined,
                      title: 'Pantau Deadline Secara Otomatis',
                      subtitle:
                          'Tidak lagi terlewat — semua deadline penting di satu tempat.',
                    ),
                    const SizedBox(height: Spacing.md),
                    _buildPillarItem(
                      icon: Icons.security_outlined,
                      title: 'Data Aman & Privasi Terjaga',
                      subtitle:
                          'Informasi pribadimu tidak akan dibagikan tanpa izin.',
                    ),
                  ],
                ),
                Text(
                  'RadarScholar © 2026 • Proyek Pengembangan Perangkat Lunak Mahasiswa',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Right Column: Register Form
        Expanded(
          flex: 4,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: _buildFormCard(context, state),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Mobile / Tablet Layout ──────────────────────────────────────────
  Widget _buildMobileTabletLayout(
      BuildContext context, RegisterFormState state) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(Spacing.lg),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppLogo(
                mode: AppLogoMode.full,
                height: 48,
                onTap: () => context.go('/'),
              ),
              const SizedBox(height: Spacing.xl),
              _buildFormCard(context, state),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Form Card ───────────────────────────────────────────────────────
  Widget _buildFormCard(BuildContext context, RegisterFormState state) {
    final controller = ref.read(registerControllerProvider.notifier);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(Spacing.xl),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Back Button
              InkWell(
                onTap: () => context.go('/'),
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_back_rounded,
                          size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 6),
                      Text(
                        'Kembali ke Beranda',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: Spacing.md),

              // Title & Subtitle
              Text(
                'Buat Akun Baru',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade900,
                    ),
              ),
              const SizedBox(height: Spacing.xs),
              Text(
                'Daftar untuk mulai menjelajahi beasiswa yang sesuai profilmu.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
              const SizedBox(height: Spacing.xl),

              // Error Message
              if (state.errorMessage != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline_rounded,
                          color: Colors.red.shade700, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          state.errorMessage!,
                          style: TextStyle(
                              color: Colors.red.shade800, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Spacing.md),
              ],

              // Display Name
              _buildFieldLabel('Nama Lengkap'),
              const SizedBox(height: Spacing.xs),
              TextFormField(
                controller: _nameController,
                enabled: !state.isLoading,
                decoration: _inputDecoration(
                  hint: 'Nama lengkap Anda',
                  icon: Icons.person_outline_rounded,
                ),
                onChanged: (val) => controller.updateDisplayName(val),
                validator: (val) => controller.validateDisplayName(val),
              ),
              const SizedBox(height: Spacing.md),

              // Email
              _buildFieldLabel('Alamat Email'),
              const SizedBox(height: Spacing.xs),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                enabled: !state.isLoading,
                decoration: _inputDecoration(
                  hint: 'nama@universitas.ac.id',
                  icon: Icons.mail_outline_rounded,
                ),
                onChanged: (val) => controller.updateEmail(val),
                validator: (val) => controller.validateEmail(val),
              ),
              const SizedBox(height: Spacing.md),

              // Password
              _buildFieldLabel('Kata Sandi'),
              const SizedBox(height: Spacing.xs),
              TextFormField(
                controller: _passwordController,
                obscureText: !state.isPasswordVisible,
                enabled: !state.isLoading,
                decoration: _inputDecoration(
                  hint: 'Minimal 6 karakter',
                  icon: Icons.lock_outline_rounded,
                  suffixIcon: IconButton(
                    icon: Icon(
                      state.isPasswordVisible
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 20,
                      color: Colors.grey.shade600,
                    ),
                    onPressed: () => controller.togglePasswordVisibility(),
                  ),
                ),
                onChanged: (val) => controller.updatePassword(val),
                validator: (val) => controller.validatePassword(val),
              ),
              const SizedBox(height: Spacing.md),

              // Confirm Password
              _buildFieldLabel('Konfirmasi Kata Sandi'),
              const SizedBox(height: Spacing.xs),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: !state.isConfirmPasswordVisible,
                enabled: !state.isLoading,
                decoration: _inputDecoration(
                  hint: 'Ulangi kata sandi',
                  icon: Icons.lock_outline_rounded,
                  suffixIcon: IconButton(
                    icon: Icon(
                      state.isConfirmPasswordVisible
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 20,
                      color: Colors.grey.shade600,
                    ),
                    onPressed: () =>
                        controller.toggleConfirmPasswordVisibility(),
                  ),
                ),
                onChanged: (val) => controller.updateConfirmPassword(val),
                validator: (val) => controller.validateConfirmPassword(val),
              ),
              const SizedBox(height: Spacing.lg),

              // Register Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: state.isLoading ? null : _handleRegister,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.brandPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                  child: state.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Daftar Sekarang',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: Spacing.lg),

              // Login Link
              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'Sudah memiliki akun? ',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () => context.go('/login'),
                      child: const Text(
                        'Masuk di sini',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.brandPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.grey.shade800,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      prefixIcon: Icon(icon, size: 20),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide:
            const BorderSide(color: AppTheme.brandPrimary, width: 1.5),
      ),
    );
  }

  Widget _buildPillarItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
