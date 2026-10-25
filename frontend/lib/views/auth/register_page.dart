import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/responsive.dart';
import '../../core/theme.dart';
import '../../controllers/register_controller.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/auth_showcase_panel.dart';
import '../../widgets/google_auth_button.dart';

/// RadarScholar Registration Page.
///
/// Modern Intelligence SaaS split-screen design matching the Login page style (CPMK 2).
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
      final success = await ref
          .read(registerControllerProvider.notifier)
          .submitRegister();
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

  void _handleGoogleRegister() {
    // Redirects the browser to Google; the account is created on first
    // sign-in and the router then sends the user to /discovery.
    ref.read(registerControllerProvider.notifier).registerWithGoogle();
  }

  void _showEmailConfirmationDialog() {
    final cardBg = AppTheme.cardColorOf(context);
    final borderSubtle = AppTheme.borderSubtleOf(context);
    final textPrimary = AppTheme.textPrimaryOf(context);
    final textSecondary = AppTheme.textSecondaryOf(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(color: borderSubtle),
        ),
        title: Row(
          children: [
            const Icon(
              Icons.mail_outline_rounded,
              color: AppTheme.brandAccent,
              size: 26,
            ),
            const SizedBox(width: 12),
            Text(
              'Verifikasi Email',
              style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: Text(
          'Kami telah mengirimkan link konfirmasi ke email Anda. '
          'Silakan periksa inbox (dan folder spam) untuk mengaktifkan akun.',
          style: TextStyle(color: textSecondary),
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
        // Left Column: Interactive Product Mockup Showcase
        const Expanded(
          flex: 5,
          child: AuthShowcasePanel(mode: AuthShowcaseMode.register),
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
    BuildContext context,
    RegisterFormState state,
  ) {
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

  // ─── Form Card ───────────────────────────────────────────────────────
  Widget _buildFormCard(BuildContext context, RegisterFormState state) {
    final controller = ref.read(registerControllerProvider.notifier);
    final cardBg = AppTheme.cardColorOf(context);
    final borderSubtle = AppTheme.borderSubtleOf(context);
    final textPrimary = AppTheme.textPrimaryOf(context);
    final textSecondary = AppTheme.textSecondaryOf(context);
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
              // Back link
              InkWell(
                onTap: () => context.go('/login'),
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
                        'Kembali ke Login',
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

              Text(
                'Buat Akun Baru',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: Spacing.xs),
              Text(
                'Isi data di bawah untuk mendaftar ke RadarScholar.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: textSecondary),
              ),
              const SizedBox(height: Spacing.lg),

              // Google sign-up
              GoogleAuthButton(
                label: 'Daftar dengan Google',
                onPressed: state.isLoading ? null : _handleGoogleRegister,
              ),
              const SizedBox(height: Spacing.lg),
              Row(
                children: [
                  Expanded(child: Divider(color: borderSubtle)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'atau daftar dengan email',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textMutedOf(context),
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: borderSubtle)),
                ],
              ),
              const SizedBox(height: Spacing.lg),

              // Error Banner
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

              // Display Name
              _buildFieldLabel(context, 'Nama Lengkap'),
              const SizedBox(height: Spacing.xs),
              TextFormField(
                controller: _nameController,
                enabled: !state.isLoading,
                style: TextStyle(color: textPrimary, fontSize: 14),
                decoration: _inputDecoration(
                  context: context,
                  hint: 'Nama lengkap Anda',
                  icon: Icons.person_outline_rounded,
                ),
                onChanged: (val) => controller.updateDisplayName(val),
                validator: (val) => controller.validateDisplayName(val),
              ),
              const SizedBox(height: Spacing.md),

              // Email
              _buildFieldLabel(context, 'Alamat Email'),
              const SizedBox(height: Spacing.xs),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                enabled: !state.isLoading,
                style: TextStyle(color: textPrimary, fontSize: 14),
                decoration: _inputDecoration(
                  context: context,
                  hint: 'nama@universitas.ac.id',
                  icon: Icons.mail_outline_rounded,
                ),
                onChanged: (val) => controller.updateEmail(val),
                validator: (val) => controller.validateEmail(val),
              ),
              const SizedBox(height: Spacing.md),

              // Password
              _buildFieldLabel(context, 'Kata Sandi'),
              const SizedBox(height: Spacing.xs),
              TextFormField(
                controller: _passwordController,
                obscureText: !state.isPasswordVisible,
                enabled: !state.isLoading,
                style: TextStyle(color: textPrimary, fontSize: 14),
                decoration: _inputDecoration(
                  context: context,
                  hint: 'Minimal 6 karakter',
                  icon: Icons.lock_outline_rounded,
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
                ),
                onChanged: (val) => controller.updatePassword(val),
                validator: (val) => controller.validatePassword(val),
              ),
              const SizedBox(height: Spacing.md),

              // Confirm Password
              _buildFieldLabel(context, 'Konfirmasi Kata Sandi'),
              const SizedBox(height: Spacing.xs),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: !state.isConfirmPasswordVisible,
                enabled: !state.isLoading,
                style: TextStyle(color: textPrimary, fontSize: 14),
                decoration: _inputDecoration(
                  context: context,
                  hint: 'Ulangi kata sandi',
                  icon: Icons.lock_outline_rounded,
                  suffixIcon: IconButton(
                    icon: Icon(
                      state.isConfirmPasswordVisible
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 20,
                      color: textSecondary,
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
                          'Daftar Sekarang',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
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
                      style: TextStyle(fontSize: 13, color: textSecondary),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () => context.go('/login'),
                      child: Text(
                        'Masuk di sini',
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

  Widget _buildFieldLabel(BuildContext context, String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppTheme.textPrimaryOf(context),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required BuildContext context,
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    final elevatedBg = AppTheme.surfaceElevatedOf(context);
    final borderStrong = AppTheme.borderStrongOf(context);
    final textSecondary = AppTheme.textSecondaryOf(context);
    final textMuted = AppTheme.textMutedOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: textMuted, fontSize: 14),
      prefixIcon: Icon(icon, size: 20, color: textSecondary),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: elevatedBg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
          color: isDark ? AppTheme.brandAccent : AppTheme.brandPrimary,
          width: 1.5,
        ),
      ),
    );
  }
}
