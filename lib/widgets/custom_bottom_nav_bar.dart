import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';

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
    
    // Define gradient colors based on theme brightness
    final gradientColors = brightness == Brightness.dark
        ? [
            colors.surface,
            Color.lerp(colors.surface, colors.primary, 0.05)!,
          ]
        : [
            Colors.white,
            Color.lerp(Colors.white, colors.primary, 0.03)!,
          ];

    return Container(
      height: 65 + safeAreaBottom, // Reduced height to prevent overflow
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.only(bottom: safeAreaBottom),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: brightness == Brightness.dark
              ? Colors.white.withOpacity(0.1)
              : colors.primary.withOpacity(0.1),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(context, 0, Icons.dashboard_outlined, Icons.dashboard_rounded, 'Accueil'),
              _buildNavItem(context, 1, Icons.list_alt_outlined, Icons.list_alt_rounded, 'Problèmes'),
              // Central FAB placeholder (empty space)
              const SizedBox(width: 60), // Approximate FAB width
              _buildNavItem(context, 2, Icons.rate_review_outlined, Icons.rate_review_rounded, 'Réclamations'),
              _buildNavItem(context, 3, Icons.person_outline_rounded, Icons.person_rounded, 'Profil'),
            ],
          ),
        ),
      ),
    )
    .animate()
    .slideY(begin: 1, end: 0, duration: 600.ms, curve: Curves.easeOutQuint)
    .fadeIn(duration: 400.ms);
  }

  Widget _buildNavItem(BuildContext context, int index, IconData icon, IconData activeIcon, String label) {
    final colors = Theme.of(context).colorScheme;
    final bool isSelected = currentIndex == index;
    final brightness = Theme.of(context).brightness;

    // Define the indicator position
    final indicatorAlignment = isSelected ? Alignment.topCenter : Alignment.center;
    
    // Define colors for active and inactive states with more contrast
    final activeColor = colors.primary;
    final inactiveColor = brightness == Brightness.dark
        ? colors.onSurface.withOpacity(0.5)
        : Colors.grey[600];
    
    // Define the background color for the active item
    final activeBackgroundColor = isSelected
        ? activeColor.withOpacity(0.15)
        : Colors.transparent;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Animated selection indicator
            AnimatedAlign(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              alignment: indicatorAlignment,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: isSelected ? 1.0 : 0.0,
                child: Container(
                  width: 20,
                  height: 3,
                  margin: const EdgeInsets.only(top: 6),
                  decoration: BoxDecoration(
                    color: activeColor,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: activeColor.withOpacity(0.5),
                        blurRadius: 6,
                        spreadRadius: -1,
                      ),
                    ],
                  ),
                )
                .animate(target: isSelected ? 1 : 0)
                .scaleX(begin: 0.2, end: 1, duration: 350.ms, curve: Curves.elasticOut),
              ),
            ),
            
            // Main button with ripple effect
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onTap(index),
                borderRadius: BorderRadius.circular(16),
                splashColor: colors.primary.withOpacity(0.1),
                highlightColor: colors.primary.withOpacity(0.05),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  height: 45, // Reduced height to prevent overflow
                  decoration: BoxDecoration(
                    color: activeBackgroundColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), // Reduced vertical padding
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // Use min size to prevent expansion
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animated icon with effects - Fixed positioning issue
                      Icon(
                        isSelected ? activeIcon : icon,
                        color: isSelected ? activeColor : inactiveColor,
                        size: isSelected ? 22 : 20, // Slightly reduced icon size
                      )
                      .animate(target: isSelected ? 1 : 0)
                      .scale(
                        duration: 300.ms, 
                        begin: const Offset(0.8, 0.8),
                        end: const Offset(1.0, 1.0),
                        curve: Curves.elasticOut
                      ),
                      
                      const SizedBox(height: 2), // Reduced spacing
                      
                      // Animated text with scaling and fading
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                        style: GoogleFonts.inter(
                          fontSize: isSelected ? 10 : 9, // Reduced font size
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected ? activeColor : inactiveColor,
                          letterSpacing: isSelected ? 0.3 : 0,
                        ),
                        child: Text(
                          label,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                      .animate(target: isSelected ? 1 : 0)
                      .fadeIn(duration: 200.ms)
                      .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.0, 1.0), alignment: Alignment.center),
                    ],
                  ),
                ),
              ),
            ),
            
            // Tap ripple effect (custom circular animation)
            if (isSelected)
              Positioned.fill(
                child: IgnorePointer(
                  child: Center(
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.transparent,
                      ),
                    )
                    .animate(
                      onPlay: (controller) => controller.repeat(reverse: true),
                    )
                    .scaleXY(
                      begin: 1, 
                      end: 4, 
                      duration: 1000.ms,
                      curve: Curves.easeOut,
                    )
                    .fadeOut(
                      begin: 0.2,
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

// Optional: Add a beautiful FAB to complement the bottom nav bar
class AnimatedFloatingActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String tooltip;

  const AnimatedFloatingActionButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.tooltip = 'Signaler',
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Tooltip(
      message: tooltip,
      child: Container(
        height: 60,
        width: 60,
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colors.primary,
              Color.lerp(colors.primary, colors.secondary, 0.6)!,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: colors.primary.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: colors.primary.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(18),
            splashColor: Colors.white.withOpacity(0.2),
            highlightColor: Colors.white.withOpacity(0.1),
            child: Center(
              child: Icon(
                icon,
                color: colors.onPrimary,
                size: 28,
              ),
            ),
          ),
        ),
      )
      .animate()
      .scale(
        duration: 350.ms,
        delay: 200.ms,
        curve: Curves.elasticOut,
      )
      .slideY(begin: 1, end: 0, duration: 500.ms, curve: Curves.easeOutQuint)
      .fadeIn(duration: 300.ms),
    );
  }
}