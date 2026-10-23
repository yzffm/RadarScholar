import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme.dart';
import 'app_logo.dart';

enum AuthShowcaseMode { login, register }

/// Modern Framed Showcase Card with Interactive 3-Slide Photo Carousel & Bottom Hook Overlay
/// for the left section of [LoginPage] and [RegisterPage].
///
/// Uses the three curated student photography assets:
/// - `assets/images/login and register 1.jpg`
/// - `assets/images/login and register 2.jpg`
/// - `assets/images/login and register 3.jpg`
///
/// Each slide pairs the visual with a persuasive, professional hook headline,
/// supporting copy, and key platform advantages inside a smooth bottom gradient overlay.
class AuthShowcasePanel extends StatefulWidget {
  final AuthShowcaseMode mode;

  const AuthShowcasePanel({super.key, required this.mode});

  @override
  State<AuthShowcasePanel> createState() => _AuthShowcasePanelState();
}

class _AuthShowcasePanelState extends State<AuthShowcasePanel> {
  late int _currentSlideIndex;
  Timer? _carouselTimer;

  static const List<_AuthShowcaseSlide> _slides = [
    _AuthShowcaseSlide(
      indexLabel: '01',
      imagePath: 'assets/images/login and register 1.jpg',
      imageAlignment: Alignment(0.0, -0.25),
      badge: 'EKSPLORASI & RENCANA BEASISWA',
      topTrustTitle: 'Sumber Resmi Terkurasi',
      topTrustSubtitle: 'Atribusi Tautan Asli & Tanggal Verifikasi',
      headline:
          'Jangan Biarkan Peluang Beasiswa Impianmu Terlewat Begitu Saja.',
      subtitle:
          'Telusuri beasiswa aktif dari portal resmi terkurasi, pahami setiap syarat dengan jernih, dan susun strategi pendaftaranmu sejak hari pertama.',
      highlights: [
        'Atribusi Portal Resmi',
        'Pantau Tenggat Waktu',
        'Data Terverifikasi',
      ],
      accentColor: AppTheme.brandAccent,
    ),
    _AuthShowcaseSlide(
      indexLabel: '02',
      imagePath: 'assets/images/login and register 2.jpg',
      imageAlignment: Alignment(0.0, -0.35),
      badge: 'KEPASTIAN KRITERIA & KECOCOKAN',
      topTrustTitle: 'Evaluasi Syarat Objektif',
      topTrustSubtitle: 'IPK • Jenjang • Semester • Batas Usia',
      headline:
          'Fokus pada Beasiswa yang Benar-Benar Sesuai dengan Profil Akademikmu.',
      subtitle:
          'Evaluasi kelayakan akademik secara deterministik dan transparan—tanpa tebakan atau skor persentase kecocokan yang menyesatkan.',
      highlights: [
        'Pencocokan Objektif',
        'Relevansi Transparan',
        'Tanpa Skor Palsu',
      ],
      accentColor: AppTheme.brandTertiary,
    ),
    _AuthShowcaseSlide(
      indexLabel: '03',
      imagePath: 'assets/images/login and register 3.jpg',
      imageAlignment: Alignment(0.0, -0.30),
      badge: 'PERSIAPAN DOKUMEN & ESAI TERARAH',
      topTrustTitle: 'Pendampingan AI Berintegritas',
      topTrustSubtitle: 'Checklist Berkas • Review CV & Esai Jujur',
      headline:
          'Siapkan Berkas & Esai Terbaikmu dengan Pendampingan yang Jujur.',
      subtitle:
          'Kelola daftar periksa dokumen pendaftaran dan perbaiki struktur CV maupun esai bersama asisten AI yang menjaga keaslian cerita prestasimu.',
      highlights: [
        'Checklist Terstruktur',
        'AI Tanpa Fabrikasi',
        'Siap Daftar Tepat Waktu',
      ],
      accentColor: Color(0xFF818CF8),
    ),
  ];

  bool get _isFlutterTest {
    if (kIsWeb) return false;
    final bindingType = WidgetsBinding.instance.runtimeType.toString();
    return bindingType.contains('TestWidgetsFlutterBinding') ||
        bindingType.contains('AutomatedTestWidgetsFlutterBinding');
  }

  @override
  void initState() {
    super.initState();
    // Start on slide 0 for Login, slide 1 for Register so both feel tailored,
    // while allowing full interactive cycling through all 3 slides.
    _currentSlideIndex = widget.mode == AuthShowcaseMode.login ? 0 : 1;

    if (!_isFlutterTest) {
      _startAutoSlideTimer();
    }
  }

  void _startAutoSlideTimer() {
    _carouselTimer?.cancel();
    _carouselTimer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (!mounted) return;
      setState(() {
        _currentSlideIndex = (_currentSlideIndex + 1) % _slides.length;
      });
    });
  }

  void _selectSlide(int index) {
    setState(() {
      _currentSlideIndex = index % _slides.length;
    });
    if (!_isFlutterTest) {
      _startAutoSlideTimer();
    }
  }

  void _nextSlide() => _selectSlide(_currentSlideIndex + 1);

  void _prevSlide() =>
      _selectSlide((_currentSlideIndex - 1 + _slides.length) % _slides.length);

  @override
  void dispose() {
    _carouselTimer?.cancel();
    super.dispose();
  }

  void _navigateSafely(BuildContext context, String route) {
    try {
      context.go(route);
    } catch (_) {
      // No GoRouter ancestor in isolated widget test
    }
  }

  @override
  Widget build(BuildContext context) {
    final slide = _slides[_currentSlideIndex];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderSubtle = AppTheme.borderSubtleOf(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 8, 24),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0B111E),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.12) : borderSubtle,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.40 : 0.12),
              blurRadius: 32,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(27),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ─── 1. Full-Bleed Curated Photo Asset (Crossfade Carousel) ───
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 520),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: SizedBox.expand(
                  key: ValueKey<String>(slide.imagePath),
                  child: Image.asset(
                    slide.imagePath,
                    fit: BoxFit.cover,
                    alignment: slide.imageAlignment,
                    errorBuilder: (_, _, _) => Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF1E3A8A), Color(0xFF0F172A)],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // ─── 2. Subtle Top Scrim & Bottom Deep Editorial Gradient Overlay ───
              IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.0, 0.22, 0.44, 0.70, 1.0],
                      colors: [
                        const Color(0xFF090D16).withValues(alpha: 0.42),
                        Colors.transparent,
                        const Color(0xFF090D16).withValues(alpha: 0.25),
                        const Color(0xFF090D16).withValues(alpha: 0.86),
                        const Color(0xFF090D16).withValues(alpha: 0.97),
                      ],
                    ),
                  ),
                ),
              ),

              // ─── 3. Top Header Bar (Brand Logo + Floating Verification Badge) ───
              Positioned(
                top: 24,
                left: 24,
                right: 24,
                child: Row(
                  children: [
                    // Frosted Brand Pill
                    GestureDetector(
                      onTap: () => _navigateSafely(context, '/'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF0B111E,
                          ).withValues(alpha: 0.84),
                          borderRadius: BorderRadius.circular(AppRadius.xxl),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.16),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AppLogo.icon(height: 26),
                            const SizedBox(width: 10),
                            const Text(
                              'RadarScholar',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Contextual Floating Verification Pill
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF0B111E,
                          ).withValues(alpha: 0.84),
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          border: Border.all(
                            color: slide.accentColor.withValues(alpha: 0.45),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.verified_rounded,
                              size: 16,
                              color: slide.accentColor,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    slide.topTrustTitle,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    slide.topTrustSubtitle,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.68,
                                      ),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ─── 4. Bottom Hook Copywriting & Interactive Controls Overlay ───
              Positioned(
                left: 28,
                right: 28,
                bottom: 26,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Slide Badge Pill
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Container(
                        key: ValueKey<String>(slide.badge),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: slide.accentColor.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(AppRadius.xxl),
                          border: Border.all(
                            color: slide.accentColor.withValues(alpha: 0.45),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: slide.accentColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              slide.badge,
                              style: TextStyle(
                                color: slide.accentColor,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.7,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Persuasive Hook Headline
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 320),
                      child: Text(
                        slide.headline,
                        key: ValueKey<String>(slide.headline),
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 25,
                              height: 1.24,
                              letterSpacing: -0.5,
                            ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Persuasive Hook Subtitle
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 320),
                      child: Text(
                        slide.subtitle,
                        key: ValueKey<String>(slide.subtitle),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.82),
                          fontSize: 13.5,
                          height: 1.55,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Key Advantage Pills
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: slide.highlights.map((item) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 11,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.14),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                size: 14,
                                color: slide.accentColor,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                item,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 22),
                    Divider(
                      color: Colors.white.withValues(alpha: 0.12),
                      height: 1,
                    ),
                    const SizedBox(height: 16),

                    // Carousel Footer: Slide Selector Indicators + Navigation Arrows
                    Row(
                      children: [
                        // Interactive slide progress bars
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(_slides.length, (index) {
                            final isSelected = index == _currentSlideIndex;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: InkWell(
                                key: ValueKey<String>(
                                  'auth_slide_indicator_$index',
                                ),
                                onTap: () => _selectSlide(index),
                                borderRadius: BorderRadius.circular(
                                  AppRadius.xxl,
                                ),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 240),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.white.withValues(alpha: 0.18)
                                        : Colors.white.withValues(alpha: 0.06),
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.xxl,
                                    ),
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.white.withValues(alpha: 0.45)
                                          : Colors.white.withValues(
                                              alpha: 0.12,
                                            ),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        _slides[index].indexLabel,
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.white.withValues(
                                                  alpha: 0.55,
                                                ),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      if (isSelected) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          width: 18,
                                          height: 3,
                                          decoration: BoxDecoration(
                                            color: slide.accentColor,
                                            borderRadius: BorderRadius.circular(
                                              2,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                        const Spacer(),
                        // Previous / Next Slide Controls
                        _buildNavArrowButton(
                          key: const ValueKey<String>('auth_slide_prev'),
                          icon: Icons.chevron_left_rounded,
                          tooltip: 'Slide Sebelumnya',
                          onTap: _prevSlide,
                        ),
                        const SizedBox(width: 8),
                        _buildNavArrowButton(
                          key: const ValueKey<String>('auth_slide_next'),
                          icon: Icons.chevron_right_rounded,
                          tooltip: 'Slide Berikutnya',
                          onTap: _nextSlide,
                        ),
                      ],
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

  Widget _buildNavArrowButton({
    required Key key,
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        key: key,
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

class _AuthShowcaseSlide {
  final String indexLabel;
  final String imagePath;
  final Alignment imageAlignment;
  final String badge;
  final String topTrustTitle;
  final String topTrustSubtitle;
  final String headline;
  final String subtitle;
  final List<String> highlights;
  final Color accentColor;

  const _AuthShowcaseSlide({
    required this.indexLabel,
    required this.imagePath,
    required this.imageAlignment,
    required this.badge,
    required this.topTrustTitle,
    required this.topTrustSubtitle,
    required this.headline,
    required this.subtitle,
    required this.highlights,
    required this.accentColor,
  });
}
