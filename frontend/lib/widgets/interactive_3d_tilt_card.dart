import 'package:flutter/material.dart';
import '../core/theme.dart';

/// Interactive 3D perspective tilt card with cursor-tracking shader spotlight.
///
/// Inspired by Lusion (oryzo.ai), Shader.se, and MadeInEvolve:
/// - Applies real 3D perspective matrix (`Matrix4.setEntry(3, 2, perspective)`)
/// - Tracks pointer hover (desktop) and pan/touch gestures (mobile/tablet)
/// - Renders a dynamic radial specular glare/spotlight over the card surface
/// - Blends seamlessly with RadarScholar's Dark Obsidian & Light Porcelain themes
class Interactive3dTiltCard extends StatefulWidget {
  final Widget child;
  final double maxTiltDegrees;
  final double borderRadius;
  final Color? glowColor;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? borderColor;
  final bool enableScaleOnHover;

  const Interactive3dTiltCard({
    super.key,
    required this.child,
    this.maxTiltDegrees = 8.5,
    this.borderRadius = AppRadius.xl,
    this.glowColor,
    this.padding,
    this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.enableScaleOnHover = true,
  });

  @override
  State<Interactive3dTiltCard> createState() => _Interactive3dTiltCardState();
}

class _Interactive3dTiltCardState extends State<Interactive3dTiltCard> {
  /// Normalized pointer offset from center in [-1.0, 1.0].
  Offset _normalizedPointer = Offset.zero;

  /// Fractional pointer position in [0.0, 1.0] for radial glare shader.
  Alignment _glareAlignment = Alignment.center;

  bool _isHovered = false;

  void _updatePointer(Offset localPosition, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    final dx = ((localPosition.dx / size.width) * 2 - 1).clamp(-1.0, 1.0);
    final dy = ((localPosition.dy / size.height) * 2 - 1).clamp(-1.0, 1.0);
    setState(() {
      _isHovered = true;
      _normalizedPointer = Offset(dx, dy);
      _glareAlignment = Alignment(dx, dy);
    });
  }

  void _resetPointer() {
    if (!_isHovered && _normalizedPointer == Offset.zero) return;
    setState(() {
      _isHovered = false;
      _normalizedPointer = Offset.zero;
      _glareAlignment = Alignment.center;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final effectiveGlow = widget.glowColor ?? AppTheme.primaryOf(context);
    final cardBg = widget.backgroundColor ?? AppTheme.cardColorOf(context);
    final baseBorder = widget.borderColor ?? AppTheme.borderColorOf(context);

    final maxRadians = widget.maxTiltDegrees * (3.1415926535 / 180.0);
    final rotateX = -_normalizedPointer.dy * maxRadians;
    final rotateY = _normalizedPointer.dx * maxRadians;

    return MouseRegion(
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _isHovered = true),
      onHover: (event) {
        final box = context.findRenderObject() as RenderBox?;
        if (box != null && box.hasSize) {
          _updatePointer(event.localPosition, box.size);
        }
      },
      onExit: (_) => _resetPointer(),
      child: GestureDetector(
        onTap: widget.onTap,
        onPanUpdate: (details) {
          final box = context.findRenderObject() as RenderBox?;
          if (box != null && box.hasSize) {
            _updatePointer(details.localPosition, box.size);
          }
        },
        onPanEnd: (_) => _resetPointer(),
        onPanCancel: _resetPointer,
        child: TweenAnimationBuilder<Offset>(
          tween: Tween<Offset>(
            begin: Offset.zero,
            end: Offset(rotateX, rotateY),
          ),
          duration: Duration(milliseconds: _isHovered ? 90 : 380),
          curve: Curves.easeOutCubic,
          builder: (context, angles, child) {
            final transform = Matrix4.identity()
              ..setEntry(3, 2, 0.0011)
              ..rotateX(angles.dx)
              ..rotateY(angles.dy);
            if (widget.enableScaleOnHover && _isHovered) {
              transform.scaleByDouble(1.015, 1.015, 1.0, 1.0);
            }

            return Transform(
              alignment: FractionalOffset.center,
              transform: transform,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  border: Border.all(
                    color: _isHovered
                        ? effectiveGlow.withValues(alpha: isDark ? 0.55 : 0.42)
                        : baseBorder,
                    width: _isHovered ? 1.3 : 1.0,
                  ),
                  boxShadow: [
                    ...AppTheme.cardShadowOf(context, isHovered: _isHovered),
                    if (_isHovered)
                      BoxShadow(
                        color: effectiveGlow.withValues(
                          alpha: isDark ? 0.16 : 0.10,
                        ),
                        blurRadius: 28,
                        spreadRadius: 1,
                        offset: Offset(
                          -_normalizedPointer.dx * 8,
                          -_normalizedPointer.dy * 8 + 6,
                        ),
                      ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(widget.borderRadius - 1),
                  child: Stack(
                    children: [
                      Padding(
                        padding: widget.padding ?? EdgeInsets.zero,
                        child: child,
                      ),
                      // Specular cursor-following shader spotlight
                      if (_isHovered)
                        Positioned.fill(
                          child: IgnorePointer(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: RadialGradient(
                                  center: _glareAlignment,
                                  radius: 0.95,
                                  colors: [
                                    effectiveGlow.withValues(
                                      alpha: isDark ? 0.14 : 0.08,
                                    ),
                                    Colors.white.withValues(
                                      alpha: isDark ? 0.04 : 0.12,
                                    ),
                                    Colors.transparent,
                                  ],
                                  stops: const [0.0, 0.35, 1.0],
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
          child: widget.child,
        ),
      ),
    );
  }
}
