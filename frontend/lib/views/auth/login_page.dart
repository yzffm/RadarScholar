import 'dart:async';

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
  final _carouselController = PageController();
  Timer? _carouselTimer;
  int _carouselIndex = 0;

  static const _carouselSlides = [
    (
      title: 'Cari dengan arah yang jelas.',
      body:
          'Temukan peluang resmi yang lebih dekat dengan profil akademik dan tujuanmu.',
      icon: Icons.explore_rounded,
    ),
    (
      title: 'Pahami sebelum memutuskan.',
      body:
          'Bandingkan kriteria, benefit, deadline, dan status verifikasi dalam satu tempat.',
      icon: Icons.fact_check_rounded,
    ),
    (
      title: 'Siapkan aplikasi dengan percaya diri.',
      body:
          'Lacak progres dan gunakan AI sebagai pendamping, bukan pengganti keputusanmu.',
      icon: Icons.track_changes_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _carouselTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || !_carouselController.hasClients) return;
      final next = (_carouselIndex + 1) % _carouselSlides.length;
      _carouselController.animateToPage(
        next,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _carouselTimer?.cancel();
    _carouselController.dispose();
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
            content: const Text('Berhasil masuk ke RadarScholar.'),
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
          content: const Text('Login Google berhasil.'),
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

                SizedBox(
                  height: 300,
                  child: PageView.builder(
                    controller: _carouselController,
                    itemCount: _carouselSlides.length,
                    onPageChanged: (index) =>
                        setState(() => _carouselIndex = index),
                    itemBuilder: (context, index) {
                      final slide = _carouselSlides[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            slide.icon,
                            color: AppTheme.brandSecondary,
                            size: 42,
                          ),
                          const SizedBox(height: Spacing.lg),
                          Text(
                            slide.title,
                            style: Theme.of(context).textTheme.displaySmall
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  height: 1.15,
                                ),
                          ),
                          const SizedBox(height: Spacing.md),
                          Text(
                            slide.body,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.82),
                                  height: 1.55,
                                ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Row(
                  children: List.generate(
                    _carouselSlides.length,
                    (index) => GestureDetector(
                      onTap: () => _carouselController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 260),
                        curve: Curves.easeOut,
                      ),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        margin: const EdgeInsets.only(right: 8),
                        width: index == _carouselIndex ? 28 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: index == _carouselIndex
                              ? AppTheme.brandSecondary
                              : Colors.white.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
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
    final colors = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        side: BorderSide(color: colors.outlineVariant, width: 1),
      ),
      color: colors.surface,
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
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: Spacing.xs),
              Text(
                'Masuk ke akun Anda untuk mengakses rekomendasi beasiswa.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
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
                    backgroundColor: colors.surface,
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
                          color: colors.onSurface,
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
                  color: colors.onSurface,
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
                  fillColor: colors.surfaceContainerHighest,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: BorderSide(color: colors.outlineVariant),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: BorderSide(color: colors.outlineVariant),
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
                  fillColor: colors.surfaceContainerHighest,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: BorderSide(color: colors.outlineVariant),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: BorderSide(color: colors.outlineVariant),
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
                    onPressed: () => context.push('/forgot-password'),
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
}
