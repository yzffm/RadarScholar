import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/responsive.dart';
import '../../core/theme.dart';
import '../../controllers/login_controller.dart';
import '../../widgets/app_logo.dart';

/// RadarScholar Login Page.
///
/// Delivers a responsive, Material 3 authentication screen (CPMK 2)
/// connected to [LoginController] via Riverpod (CPMK 4).
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleEmailLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      final success = await ref
          .read(loginControllerProvider.notifier)
          .submitLogin();
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppTheme.brandPrimary,
            content: const Text(
              'Berhasil Masuk! (M1 UI Preview — Integrasi Supabase Auth penuh di M2)',
            ),
            action: SnackBarAction(
              label: 'Ke Eksplorasi',
              textColor: AppTheme.brandSecondary,
              onPressed: () => context.go('/discovery'),
            ),
          ),
        );
        context.go('/discovery');
      }
    }
  }

  void _handleGoogleLogin() async {
    final success = await ref
        .read(loginControllerProvider.notifier)
        .loginWithGoogle();
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppTheme.brandPrimary,
          content: const Text(
            'Login Google berhasil disimulasikan! (M1 UI Preview)',
          ),
          action: SnackBarAction(
            label: 'Ke Eksplorasi',
            textColor: AppTheme.brandSecondary,
            onPressed: () => context.go('/discovery'),
          ),
        ),
      );
      context.go('/discovery');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginControllerProvider);
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

  // ─── Desktop Split Screen (>= 1024px) ────────────────────────────────
  Widget _buildDesktopLayout(BuildContext context, LoginFormState state) {
    return Row(
      children: [
        // Left Column: Brand Hero Showcase
        Expanded(
          flex: 5,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 48),
            decoration: const BoxDecoration(gradient: AppTheme.heroGradient),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top Brand Bar
                Row(
                  children: [
                    AppLogo.icon(height: 48),
                    const SizedBox(width: 14),
                    Text(
                      'RadarScholar',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                    ),
                  ],
                ),

                // Middle Pitch
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppRadius.xxl),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified_rounded,
                            color: AppTheme.brandSecondary,
                            size: 16,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Platform Intelijen Beasiswa Mahasiswa',
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
                      'Temukan Beasiswa yang\nSesuai Profil Akademikmu.',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: Spacing.md),
                    Text(
                      'Sistem pencocokan deterministik tanpa tebak-tebakan. Pantau deadline resmi dan persiapkan dokumen aplikasi dengan pendampingan AI cerdas.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: Spacing.xxl),
                    // Value points
                    _buildPillarItem(
                      icon: Icons.shield_outlined,
                      title: '100% Sumber Terkurasi & Resmi',
                      subtitle:
                          'Bebas hoaks dengan atribusi tautan asli penyedia beasiswa.',
                    ),
                    const SizedBox(height: Spacing.md),
                    _buildPillarItem(
                      icon: Icons.rule_folder_outlined,
                      title: 'Evaluasi Objektif & Kualitatif',
                      subtitle:
                          'Penjelasan relevansi transparan berdasarkan kriteria terverifikasi.',
                    ),
                    const SizedBox(height: Spacing.md),
                    _buildPillarItem(
                      icon: Icons.auto_awesome_rounded,
                      title: 'Asisten Dokumen & Wawancara AI',
                      subtitle:
                          'Bantuan penulisan esai dan motivasi tanpa memalsukan fakta.',
                    ),
                  ],
                ),

                // Bottom academic note
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

        // Right Column: Login Card Form
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

  // ─── Mobile / Tablet Layout (< 1024px) ──────────────────────────────
  Widget _buildMobileTabletLayout(BuildContext context, LoginFormState state) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(Spacing.lg),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Logo
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

  // ─── Form Card (Shared) ──────────────────────────────────────────────
  Widget _buildFormCard(BuildContext context, LoginFormState state) {
    final controller = ref.read(loginControllerProvider.notifier);

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
                      Icon(
                        Icons.arrow_back_rounded,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
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
                'Selamat Datang Kembali',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade900,
                ),
              ),
              const SizedBox(height: Spacing.xs),
              Text(
                'Masuk ke akun Anda untuk mengakses rekomendasi beasiswa.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
              ),
              const SizedBox(height: Spacing.xl),

              // ─── SPECIAL GOOGLE LOGIN BUTTON ───────────────────────
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: state.isLoading ? null : _handleGoogleLogin,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade300, width: 1.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    backgroundColor: Colors.white,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Google Logo G representation
                      Container(
                        width: 22,
                        height: 22,
                        decoration: const BoxDecoration(shape: BoxShape.circle),
                        child: Center(
                          child: Text(
                            'G',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Colors.red.shade600,
                              fontFamily: 'Roboto',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Masuk dengan Google',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: Spacing.lg),

              // Divider "atau masuk dengan email"
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'atau masuk dengan email',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                ],
              ),

              const SizedBox(height: Spacing.lg),

              // Error Message display
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
                      Icon(
                        Icons.error_outline_rounded,
                        color: Colors.red.shade700,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          state.errorMessage!,
                          style: TextStyle(
                            color: Colors.red.shade800,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Spacing.md),
              ],

              // Email Field
              Text(
                'Alamat Email',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: Spacing.xs),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                enabled: !state.isLoading,
                decoration: InputDecoration(
                  hintText: 'nama@universitas.ac.id',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(Icons.mail_outline_rounded, size: 20),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
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
                    borderSide: const BorderSide(
                      color: AppTheme.brandPrimary,
                      width: 1.5,
                    ),
                  ),
                ),
                onChanged: (val) => controller.updateEmail(val),
                validator: (val) => controller.validateEmail(val),
              ),

              const SizedBox(height: Spacing.md),

              // Password Field
              Text(
                'Kata Sandi',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: Spacing.xs),
              TextFormField(
                controller: _passwordController,
                obscureText: !state.isPasswordVisible,
                enabled: !state.isLoading,
                decoration: InputDecoration(
                  hintText: 'Minimal 6 karakter',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
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
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
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
                    borderSide: const BorderSide(
                      color: AppTheme.brandPrimary,
                      width: 1.5,
                    ),
                  ),
                ),
                onChanged: (val) => controller.updatePassword(val),
                validator: (val) => controller.validatePassword(val),
              ),

              const SizedBox(height: Spacing.sm),

              // Remember Me & Forgot Password
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                runSpacing: 4,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: state.rememberMe,
                          activeColor: AppTheme.brandPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          onChanged: (val) {
                            if (val != null) controller.toggleRememberMe(val);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Ingat saya',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Fitur pemulihan kata sandi akan aktif pada M2.',
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      'Lupa kata sandi?',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.brandPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: Spacing.lg),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: state.isLoading ? null : _handleEmailLogin,
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
                          'Masuk ke Akun',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: Spacing.lg),

              // Register Prompt
              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'Belum memiliki akun? ',
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
                      onPressed: () {
                        context.go('/register');
                      },
                      child: const Text(
                        'Daftar Sekarang',
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
