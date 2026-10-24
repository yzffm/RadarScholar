import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/theme.dart';

/// An interactive 3D Name Card / ID Badge with physical volume (thickness),
/// rotatable in 360 degrees in real time via mouse drag (pan) gestures,
/// or animated with a smooth 180° flip.
///
/// Features:
/// - True 3D perspective matrix transform (`Matrix4.setEntry(3, 2, 0.0011)`)
/// - Physical 3D volume & depth slices along the Z-axis (extruded bevel rim)
/// - Continuous 360° horizontal rotation (yaw) and bounded vertical tilt (pitch)
/// - Double-sided rendering (front & back faces, properly oriented)
/// - Custom front and back padding (e.g. full-bleed back photo)
/// - Dynamic specular gloss & holographic iridescent glare that tracks rotation
/// - Smooth spring / cubic snap-back to nearest face when drag ends
/// - Realistic lanyard slot cut-out at top of the card
/// - Seamless mouse hover tracking when not dragging
class Interactive3dNameCard extends StatefulWidget {
  final Widget front;
  final Widget back;
  final bool isFlipped;
  final ValueChanged<bool>? onFlipChanged;
  final VoidCallback? onTap;
  final double borderRadius;
  final Color? glowColor;
  final Color? backgroundColor;
  final Color? borderColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? backPadding;
  final double maxPitchDegrees;
  final double thickness;

  const Interactive3dNameCard({
    super.key,
    required this.front,
    required this.back,
    this.isFlipped = false,
    this.onFlipChanged,
    this.onTap,
    this.borderRadius = AppRadius.xxl,
    this.glowColor,
    this.backgroundColor,
    this.borderColor,
    this.padding = const EdgeInsets.all(24),
    this.backPadding = EdgeInsets.zero,
    this.maxPitchDegrees = 22.0,
    this.thickness = 14.0,
  });

  @override
  State<Interactive3dNameCard> createState() => _Interactive3dNameCardState();
}

class _Interactive3dNameCardState extends State<Interactive3dNameCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  Animation<double>? _yawAnimation;
  Animation<double>? _pitchAnimation;

  double _currentYaw = 0.0; // Horizontal rotation in radians
  double _currentPitch = 0.0; // Vertical tilt in radians

  bool _isDragging = false;
  bool _isHovered = false;
  Offset _hoverOffset = Offset.zero; // Normalized hover offset [-1.0, 1.0]

  @override
  void initState() {
    super.initState();
    _currentYaw = widget.isFlipped ? math.pi : 0.0;
    _animController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 520),
        )..addListener(() {
          if (_yawAnimation != null) {
            _currentYaw = _yawAnimation!.value;
          }
          if (_pitchAnimation != null) {
            _currentPitch = _pitchAnimation!.value;
          }
          setState(() {});
        });
  }

  @override
  void didUpdateWidget(Interactive3dNameCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFlipped != oldWidget.isFlipped && !_isDragging) {
      _animateToFlipState(widget.isFlipped);
    }
  }

  double _normalizeYaw(double yaw) {
    return (yaw % (2 * math.pi) + 2 * math.pi) % (2 * math.pi);
  }

  bool get _isFacingBack {
    final norm = _normalizeYaw(_currentYaw);
    return norm > math.pi / 2 && norm < 3 * math.pi / 2;
  }

  double _calculateTargetYaw(bool wantBack) {
    final turns = (_currentYaw / (2 * math.pi)).round();
    if (wantBack) {
      final c1 = turns * 2 * math.pi + math.pi;
      final c2 = (turns - 1) * 2 * math.pi + math.pi;
      return (c1 - _currentYaw).abs() < (c2 - _currentYaw).abs() ? c1 : c2;
    } else {
      final c1 = turns * 2 * math.pi;
      final c2 = (turns + 1) * 2 * math.pi;
      final c3 = (turns - 1) * 2 * math.pi;
      double closest = c1;
      double minDiff = (c1 - _currentYaw).abs();
      for (final c in [c2, c3]) {
        final d = (c - _currentYaw).abs();
        if (d < minDiff) {
          minDiff = d;
          closest = c;
        }
      }
      return closest;
    }
  }

  void _animateTo(double targetYaw, double targetPitch) {
    _animController.stop();
    final startYaw = _currentYaw;
    final startPitch = _currentPitch;

    _yawAnimation = Tween<double>(begin: startYaw, end: targetYaw).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _pitchAnimation = Tween<double>(begin: startPitch, end: targetPitch)
        .animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
        );

    _animController.forward(from: 0.0);
  }

  void _animateToFlipState(bool wantBack) {
    final targetYaw = _calculateTargetYaw(wantBack);
    _animateTo(targetYaw, 0.0);
  }

  void _handleTap() {
    if (widget.onTap != null) {
      widget.onTap!();
    } else {
      final newBack = !_isFacingBack;
      widget.onFlipChanged?.call(newBack);
      _animateToFlipState(newBack);
    }
  }

  void _onPanStart(DragStartDetails details) {
    _animController.stop();
    setState(() => _isDragging = true);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final maxPitchRad = widget.maxPitchDegrees * (math.pi / 180.0);
    setState(() {
      _currentYaw += details.delta.dx * 0.010;
      _currentPitch = (_currentPitch - details.delta.dy * 0.010).clamp(
        -maxPitchRad,
        maxPitchRad,
      );
    });

    final facingBack = _isFacingBack;
    if (facingBack != widget.isFlipped) {
      widget.onFlipChanged?.call(facingBack);
    }
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() => _isDragging = false);
    final facingBack = _isFacingBack;
    final targetYaw = _calculateTargetYaw(facingBack);
    _animateTo(targetYaw, 0.0);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectivePitch =
        (_isHovered && !_isDragging && !_animController.isAnimating)
            ? _currentPitch - (_hoverOffset.dy * 0.05)
            : _currentPitch;
    final effectiveYaw =
        (_isHovered && !_isDragging && !_animController.isAnimating)
            ? _currentYaw + (_hoverOffset.dx * 0.05)
            : _currentYaw;

    final normYaw = _normalizeYaw(effectiveYaw);
    final isFront = normYaw <= math.pi / 2 || normYaw >= 3 * math.pi / 2;

    final transform =
        Matrix4.identity()
          ..setEntry(3, 2, 0.0011) // 3D Perspective Depth
          ..rotateX(effectivePitch)
          ..rotateY(effectiveYaw);

    return MouseRegion(
      cursor:
          _isDragging ? SystemMouseCursors.grabbing : SystemMouseCursors.grab,
      onEnter: (_) => setState(() => _isHovered = true),
      onHover: (event) {
        final box = context.findRenderObject() as RenderBox?;
        if (box != null && box.hasSize) {
          final dx = ((event.localPosition.dx / box.size.width) * 2 - 1).clamp(
            -1.0,
            1.0,
          );
          final dy = ((event.localPosition.dy / box.size.height) * 2 - 1).clamp(
            -1.0,
            1.0,
          );
          setState(() => _hoverOffset = Offset(dx, dy));
        }
      },
      onExit:
          (_) => setState(() {
            _isHovered = false;
            _hoverOffset = Offset.zero;
          }),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _handleTap,
        onPanStart: _onPanStart,
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        child: Transform(
          alignment: Alignment.center,
          transform: transform,
          child: _buildVolumetricCard(
            context,
            isFront: isFront,
            yaw: effectiveYaw,
            pitch: effectivePitch,
          ),
        ),
      ),
    );
  }

  Widget _buildVolumetricCard(
    BuildContext context, {
    required bool isFront,
    required double yaw,
    required double pitch,
  }) {
    final isDark = AppTheme.isDark(context);
    final cardBg = widget.backgroundColor ?? const Color(0xFF0B111E);
    final borderCol = widget.borderColor ?? const Color(0xFF283A5A);
    final glow =
        widget.glowColor ??
        (isFront ? AppTheme.brandAccent : AppTheme.brandTertiary);

    final glareX = math.sin(yaw).clamp(-1.0, 1.0);
    final glareY = math.sin(pitch).clamp(-1.0, 1.0);

    final halfThickness = widget.thickness / 2.0;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        // ─── 1. Realistic 3D Cast Shadow ─────────────────────────────
        Positioned.fill(
          child: Transform(
            alignment: Alignment.center,
            transform:
                Matrix4.identity()
                  ..setTranslationRaw(glareX * 16.0, glareY * 16.0 + 14.0, -20.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.65),
                    blurRadius: 42,
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: glow.withValues(alpha: isDark ? 0.25 : 0.15),
                    blurRadius: 36,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
        ),

        // ─── 2. Physical 3D Volume Edge Rim (Depth Slices) ───────────
        for (double z = -halfThickness + 1.5; z <= halfThickness - 1.5; z += 2.0)
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()..setTranslationRaw(0.0, 0.0, z),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF131D2E),
                borderRadius: BorderRadius.circular(widget.borderRadius),
                border: Border.all(
                  color: const Color(0xFF283850).withValues(alpha: 0.50),
                  width: 1.2,
                ),
              ),
            ),
          ),

        // ─── 3. Card Faces (Front at +Z, Back at -Z) ─────────────────
        if (isFront)
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()..setTranslationRaw(0.0, 0.0, halfThickness),
            child: _buildSurfaceContainer(
              context,
              isFront: true,
              cardBg: cardBg,
              borderCol: borderCol,
              glow: glow,
              glareX: glareX,
              glareY: glareY,
              isDark: isDark,
              child: widget.front,
              padding: widget.padding ?? const EdgeInsets.all(24),
            ),
          )
        else
          Transform(
            alignment: Alignment.center,
            transform:
                Matrix4.identity()
                  ..setTranslationRaw(0.0, 0.0, -halfThickness)
                  ..rotateY(math.pi),
            child: _buildSurfaceContainer(
              context,
              isFront: false,
              cardBg: cardBg,
              borderCol: borderCol,
              glow: glow,
              glareX: glareX,
              glareY: glareY,
              isDark: isDark,
              child: widget.back,
              padding: widget.backPadding ?? EdgeInsets.zero,
            ),
          ),
      ],
    );
  }

  Widget _buildSurfaceContainer(
    BuildContext context, {
    required bool isFront,
    required Color cardBg,
    required Color borderCol,
    required Color glow,
    required double glareX,
    required double glareY,
    required bool isDark,
    required Widget child,
    required EdgeInsetsGeometry padding,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(
          color:
              _isHovered || _isDragging
                  ? glow.withValues(alpha: isDark ? 0.75 : 0.52)
                  : borderCol,
          width: _isHovered || _isDragging ? 1.6 : 1.0,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius - 1),
        child: Stack(
          children: [
            // Top Lanyard slot cut-out accent (only on front for cleaner aesthetic)
            if (isFront)
              Positioned(
                top: 10,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 54,
                    height: 9,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.18),
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),

            // Card Face Content
            Padding(padding: padding, child: child),

            // Specular Holographic Glare & Iridescent Shimmer Overlay
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(glareX * 0.85, glareY * 0.85),
                      radius: 0.95,
                      colors: [
                        Colors.white.withValues(alpha: isDark ? 0.12 : 0.20),
                        glow.withValues(alpha: isDark ? 0.08 : 0.11),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.45, 1.0],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
