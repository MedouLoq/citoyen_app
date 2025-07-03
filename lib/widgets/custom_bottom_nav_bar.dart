import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import 'package:citoyen_app/l10n/app_localizations.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final safeAreaBottom = MediaQuery.of(context).padding.bottom;
    final brightness = Theme.of(context).brightness;
    final localizations = AppLocalizations.of(context);

    // Enhanced gradient colors with more depth
    final gradientColors = brightness == Brightness.dark
        ? [
            colors.surface.withOpacity(0.95),
            Color.lerp(colors.surface, colors.primary, 0.08)!.withOpacity(0.95),
            Color.lerp(colors.surface, colors.primary, 0.03)!.withOpacity(0.98),
          ]
        : [
            Colors.white.withOpacity(0.95),
            Color.lerp(Colors.white, colors.primary, 0.05)!.withOpacity(0.95),
            Color.lerp(Colors.white, colors.primary, 0.02)!.withOpacity(0.98),
          ];

    return Container(
      height: 70 + safeAreaBottom, // Increased height for better proportions
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: EdgeInsets.only(bottom: safeAreaBottom),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          // Primary shadow with blur
          BoxShadow(
            color: colors.primary.withOpacity(0.15),
            blurRadius: 25,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
          // Secondary shadow for depth
          BoxShadow(
            color: brightness == Brightness.dark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
          // Subtle top highlight
          BoxShadow(
            color: brightness == Brightness.dark
                ? Colors.white.withOpacity(0.05)
                : Colors.white.withOpacity(0.8),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
        border: Border.all(
          color: brightness == Brightness.dark
              ? Colors.white.withOpacity(0.15)
              : colors.primary.withOpacity(0.12),
          width: 1.2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(
                    context,
                    0,
                    Icons.dashboard_outlined,
                    Icons.dashboard_rounded,
                    localizations?.buttonHome ?? 'الرئيسية'),
                _buildNavItem(
                    context,
                    1,
                    Icons.list_alt_outlined,
                    Icons.list_alt_rounded,
                    localizations?.buttonProb ?? 'المشاكل'),
                // Central FAB placeholder with animated space
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  width: 65,
                  height: 50,
                  child: const SizedBox(),
                ),
                _buildNavItem(
                    context,
                    2,
                    Icons.rate_review_outlined,
                    Icons.rate_review_rounded,
                    localizations?.buttonComp ?? 'الشكاوى'),
                _buildNavItem(
                    context,
                    3,
                    Icons.person_outline_rounded,
                    Icons.person_rounded,
                    localizations?.buttonProfile ?? 'الملف الشخصي'),
              ],
            ),
          ),
        ),
      ),
    )
        .animate()
        .slideY(begin: 1, end: 0, duration: 700.ms, curve: Curves.easeOutQuint)
        .fadeIn(duration: 500.ms)
        .scale(
            begin: const Offset(0.9, 0.9),
            duration: 600.ms,
            curve: Curves.easeOutBack);
  }

  Widget _buildNavItem(BuildContext context, int index, IconData icon,
      IconData activeIcon, String label) {
    final colors = Theme.of(context).colorScheme;
    final bool isSelected = currentIndex == index;
    final brightness = Theme.of(context).brightness;

    // Enhanced color scheme with better contrast
    final activeColor = colors.primary;
    final inactiveColor = brightness == Brightness.dark
        ? colors.onSurface.withOpacity(0.6)
        : Colors.grey[600]!;

    // Enhanced background with subtle glow effect
    final activeBackgroundColor =
        isSelected ? activeColor.withOpacity(0.12) : Colors.transparent;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.0),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Animated glow effect for selected item
            if (isSelected)
              AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      activeColor.withOpacity(0.15),
                      activeColor.withOpacity(0.05),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.7, 1.0],
                  ),
                ),
              )
                  .animate(
                    onPlay: (controller) => controller.repeat(reverse: true),
                  )
                  .scaleXY(
                    begin: 0.8,
                    end: 1.1,
                    duration: 2000.ms,
                    curve: Curves.easeInOut,
                  )
                  .fadeIn(begin: 0.5),

            // Animated top indicator with enhanced design
            AnimatedAlign(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: isSelected ? 1.0 : 0.0,
                child: Container(
                  width: 24,
                  height: 3,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        activeColor,
                        Color.lerp(activeColor, colors.secondary, 0.3)!,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: activeColor.withOpacity(0.6),
                        blurRadius: 8,
                        spreadRadius: 0,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ).animate(target: isSelected ? 1 : 0).scaleX(
                    begin: 0.3,
                    end: 1,
                    duration: 400.ms,
                    curve: Curves.elasticOut),
              ),
            ),

            // Main button with enhanced ripple effect
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onTap(index),
                borderRadius: BorderRadius.circular(20),
                splashColor: colors.primary.withOpacity(0.15),
                highlightColor: colors.primary.withOpacity(0.08),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                  height: 52,
                  decoration: BoxDecoration(
                    color: activeBackgroundColor,
                    borderRadius: BorderRadius.circular(20),
                    border: isSelected
                        ? Border.all(
                            color: activeColor.withOpacity(0.2),
                            width: 1,
                          )
                        : null,
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Enhanced animated icon with better positioning
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: isSelected
                            ? BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    activeColor.withOpacity(0.1),
                                    Colors.transparent,
                                  ],
                                ),
                              )
                            : null,
                        child: Icon(
                          isSelected ? activeIcon : icon,
                          color: isSelected ? activeColor : inactiveColor,
                          size: isSelected ? 22 : 20,
                        ),
                      )
                          .animate(target: isSelected ? 1 : 0)
                          .scale(
                              duration: 350.ms,
                              begin: const Offset(0.85, 0.85),
                              end: const Offset(1.0, 1.0),
                              curve: Curves.elasticOut)
                          .then()
                          .shimmer(
                            duration: 800.ms,
                            color: activeColor.withOpacity(0.3),
                          ),

                      const SizedBox(height: 2),

                      // Enhanced text with better typography
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOutCubic,
                        style: GoogleFonts.inter(
                          fontSize: isSelected ? 9.5 : 8.5,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected ? activeColor : inactiveColor,
                          letterSpacing: isSelected ? 0.2 : 0,
                          height: 1.1, // Better line height for Arabic text
                        ),
                        child: Text(
                          label,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                        ),
                      )
                          .animate(target: isSelected ? 1 : 0)
                          .fadeIn(duration: 300.ms)
                          .scale(
                            begin: const Offset(0.9, 0.9),
                            end: const Offset(1.0, 1.0),
                            alignment: Alignment.center,
                          )
                          .then()
                          .shimmer(
                            duration: 1000.ms,
                            color: activeColor.withOpacity(0.2),
                          ),
                    ],
                  ),
                ),
              ),
            ),

            // Enhanced pulse effect for selected item
            if (isSelected)
              Positioned.fill(
                child: IgnorePointer(
                  child: Center(
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: activeColor.withOpacity(0.3),
                      ),
                    )
                        .animate(
                          onPlay: (controller) =>
                              controller.repeat(reverse: true),
                        )
                        .scaleXY(
                          begin: 1,
                          end: 6,
                          duration: 1500.ms,
                          curve: Curves.easeOut,
                        )
                        .fadeOut(
                          begin: 0.4,
                          curve: Curves.easeOut,
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

// Enhanced FAB with more beautiful design
class AnimatedFloatingActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String tooltip;

  const AnimatedFloatingActionButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.tooltip = 'إبلاغ',
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;

    return Tooltip(
      message: tooltip,
      child: Container(
        height: 65,
        width: 65,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colors.primary,
              Color.lerp(colors.primary, colors.secondary, 0.4)!,
              Color.lerp(colors.primary, colors.tertiary, 0.2)!,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0.0, 0.6, 1.0],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: colors.primary.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: colors.primary.withOpacity(0.2),
              blurRadius: 30,
              offset: const Offset(0, 12),
              spreadRadius: 0,
            ),
            // Inner highlight
            BoxShadow(
              color: Colors.white
                  .withOpacity(brightness == Brightness.dark ? 0.1 : 0.3),
              blurRadius: 8,
              offset: const Offset(0, -2),
              spreadRadius: 0,
            ),
          ],
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(20),
            splashColor: Colors.white.withOpacity(0.3),
            highlightColor: Colors.white.withOpacity(0.15),
            child: Center(
              child: Icon(
                icon,
                color: colors.onPrimary,
                size: 30,
              ),
            ),
          ),
        ),
      )
          .animate()
          .scale(
            duration: 400.ms,
            delay: 250.ms,
            curve: Curves.elasticOut,
          )
          .slideY(
            begin: 1.2,
            end: 0,
            duration: 600.ms,
            curve: Curves.easeOutQuint,
          )
          .fadeIn(duration: 400.ms)
          .then()
          .shimmer(
            duration: 1500.ms,
            color: Colors.white.withOpacity(0.3),
          ),
    );
  }
}
