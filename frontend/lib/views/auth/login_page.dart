import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/responsive.dart';
import '../../core/theme.dart';
import '../../controllers/login_controller.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/auth_showcase_panel.dart';

/// RadarScholar Login Page.
///
/// Delivers a responsive, Modern Intelligence SaaS authentication screen (CPMK 2)
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
        // Left Column: Interactive Product Mockup Showcase
        const Expanded(
          flex: 5,
          child: AuthShowcasePanel(mode: AuthShowcaseMode.login),
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
                height: 44,
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
    final cardBg = AppTheme.cardColorOf(context);
    final elevatedBg = AppTheme.surfaceElevatedOf(context);
    final borderSubtle = AppTheme.borderSubtleOf(context);
    final borderStrong = AppTheme.borderStrongOf(context);
    final textPrimary = AppTheme.textPrimaryOf(context);
    final textSecondary = AppTheme.textSecondaryOf(context);
    final textMuted = AppTheme.textMutedOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: borderSubtle, width: 1),
        boxShadow: AppTheme.cardShadowOf(context),
      ),
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
                        color: textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Kembali ke Beranda',
                        style: TextStyle(
                          fontSize: 13,
                          color: textSecondary,
                          fontWeight: FontWeight.w600,
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
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: Spacing.xs),
              Text(
                'Masuk ke akun Anda untuk mengakses rekomendasi beasiswa.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: textSecondary),
              ),
              const SizedBox(height: Spacing.xl),

              // ─── SPECIAL GOOGLE LOGIN BUTTON ───────────────────────
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: state.isLoading ? null : _handleGoogleLogin,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: borderStrong, width: 1.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    backgroundColor: elevatedBg,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: const BoxDecoration(shape: BoxShape.circle),
                        child: const Center(
                          child: Text(
                            'G',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFEA4335),
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
                          color: textPrimary,
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
                  Expanded(child: Divider(color: borderSubtle)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'atau masuk dengan email',
                      style: TextStyle(fontSize: 12, color: textMuted),
                    ),
                  ),
                  Expanded(child: Divider(color: borderSubtle)),
                ],
              ),

              const SizedBox(height: Spacing.lg),

              // Error Message display
              if (state.errorMessage != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.brandDanger.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: AppTheme.brandDanger.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: AppTheme.brandDanger,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          state.errorMessage!,
                          style: const TextStyle(
                            color: AppTheme.brandDanger,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
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
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: Spacing.xs),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                enabled: !state.isLoading,
                style: TextStyle(color: textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'nama@universitas.ac.id',
                  hintStyle: TextStyle(color: textMuted, fontSize: 14),
                  prefixIcon: Icon(
                    Icons.mail_outline_rounded,
                    size: 20,
                    color: textSecondary,
                  ),
                  filled: true,
                  fillColor: elevatedBg,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: BorderSide(color: borderStrong),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: BorderSide(color: borderStrong),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: BorderSide(
                      color: isDark
                          ? AppTheme.brandAccent
                          : AppTheme.brandPrimary,
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
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: Spacing.xs),
              TextFormField(
                controller: _passwordController,
                obscureText: !state.isPasswordVisible,
                enabled: !state.isLoading,
                style: TextStyle(color: textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Minimal 6 karakter',
                  hintStyle: TextStyle(color: textMuted, fontSize: 14),
                  prefixIcon: Icon(
                    Icons.lock_outline_rounded,
                    size: 20,
                    color: textSecondary,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      state.isPasswordVisible
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 20,
                      color: textSecondary,
                    ),
                    onPressed: () => controller.togglePasswordVisibility(),
                  ),
                  filled: true,
                  fillColor: elevatedBg,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: BorderSide(color: borderStrong),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: BorderSide(color: borderStrong),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: BorderSide(
                      color: isDark
                          ? AppTheme.brandAccent
                          : AppTheme.brandPrimary,
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
                        style: TextStyle(fontSize: 13, color: textSecondary),
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
                    child: Text(
                      'Lupa kata sandi?',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? AppTheme.brandAccent
                            : AppTheme.brandPrimary,
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
                    foregroundColor: Colors.white,
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
                            fontWeight: FontWeight.w700,
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
                      style: TextStyle(fontSize: 13, color: textSecondary),
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
                      child: Text(
                        'Daftar Sekarang',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppTheme.brandAccent
                              : AppTheme.brandPrimary,
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
