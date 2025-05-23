// lib/screens/dashboard_home_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:citoyen_app/widgets/custom_bottom_nav_bar.dart';
import 'package:citoyen_app/providers/dashboard_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math' as math;
import 'package:citoyen_app/screens/problem/problem_detail_screen.dart';
import 'package:citoyen_app/providers/problem_provider.dart';

class DashboardHomeTab extends StatefulWidget {
  const DashboardHomeTab({Key? key}) : super(key: key);

  @override
  State<DashboardHomeTab> createState() => _DashboardHomeTabState();
}

class _DashboardHomeTabState extends State<DashboardHomeTab> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final ScrollController _scrollController = ScrollController();
  
  // Track if user has scrolled for parallax effects
  bool _hasScrolled = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward();
    
    // Listen for scroll events for parallax effect
    _scrollController.addListener(_onScroll);
    
    // Fetch data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DashboardProvider>(context, listen: false).fetchData(context);
    });
  }
  
  void _onScroll() {
    if (_scrollController.offset > 10 && !_hasScrolled) {
      setState(() {
        _hasScrolled = true;
      });
    } else if (_scrollController.offset <= 10 && _hasScrolled) {
      setState(() {
        _hasScrolled = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;
    
    return Consumer<DashboardProvider>(
      builder: (context, dashboardProvider, _) {
        if (dashboardProvider.isLoading) {
          return _buildLoadingState(colors);
        } else if (dashboardProvider.errorMessage.isNotEmpty) {
          return _buildErrorState(dashboardProvider.errorMessage, colors);
        } else {
          return CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Beautiful Header with Parallax Effect
              SliverToBoxAdapter(
                child: _buildWelcomeHeader(context, dashboardProvider, size),
              ),
              
              // Stats Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                  child: Text(
                    'Vos Statistiques',
                    style: GoogleFonts.inter(
                      fontSize: 20, 
                      fontWeight: FontWeight.w700, 
                      color: colors.onBackground
                    ),
                  ).animate(controller: _controller)
                    .fadeIn(delay: 400.ms, duration: 600.ms)
                    .slideX(begin: -0.2, curve: Curves.easeOutCubic),
                ),
              ),
              
              // Stats Cards - Horizontal Scroll
              SliverToBoxAdapter(
                child: _buildStatCardsRow(context, dashboardProvider, colors),
              ),
              
              // Recent Activity Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Activité Récente',
                        style: GoogleFonts.inter(
                          fontSize: 20, 
                          fontWeight: FontWeight.w700, 
                          color: colors.onBackground
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          // TODO: View all activities
                        },
                        icon: Icon(Icons.history, size: 16, color: colors.primary),
                        label: Text(
                          'Tout voir',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: colors.primary
                          ),
                        ),
                      ),
                    ],
                  ).animate(controller: _controller)
                    .fadeIn(delay: 600.ms, duration: 600.ms)
                    .slideX(begin: -0.2, curve: Curves.easeOutCubic),
                ),
              ),
              
              // Activity Items
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final activity = dashboardProvider.recentActivity[index];
                    return _buildActivityItem(
                      context,
                      _getActivityTitle(activity),
                      _getActivitySubtitle(activity),
                      _formatTimeAgo(activity['changed_at']),
                      _getActivityIcon(activity),
                      _getActivityIconColor(activity, colors),
                      index,
                      activity  
                    );
                  },
                  childCount: dashboardProvider.recentActivity.length,
                ),
              ),
              
              // Extra space at bottom
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          );
        }
      },
    );
  }
  
  // Beautiful animated loading state
Widget _buildLoadingState(ColorScheme colors) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 80,
          height: 80,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
          ),
        )
        .animate(
          onPlay: (controller) => controller.repeat(),
        )
        .scale(duration: 600.ms, curve: Curves.elasticOut)
        .then()
        .custom(
          duration: 2.seconds,
          builder: (context, value, child) => Transform.rotate(
            angle: 2 * math.pi * value,
            child: child,
          ),
          begin: 0,
          end: 1,
        ),

        const SizedBox(height: 24),

        Text(
          'Chargement de votre dashboard...',
          style: GoogleFonts.inter(
            fontSize: 16,
            color: colors.onBackground.withOpacity(0.7),
          ),
        )
        .animate()
        .fadeIn(delay: 300.ms, duration: 800.ms)
        .slideY(begin: 0.3, curve: Curves.easeOutCubic),
      ],
    ),
  );
}

  // Error state with retry button
  Widget _buildErrorState(String errorMessage, ColorScheme colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 80,
              color: colors.error,
            ).animate()
              .scale(duration: 400.ms, curve: Curves.easeOut)
              .then()
              .shake(hz: 4, rotation: 0.1),
            const SizedBox(height: 24),
            Text(
              'Une erreur est survenue',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colors.onBackground,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: colors.onBackground.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Provider.of<DashboardProvider>(context, listen: false).fetchData(context);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ).animate()
              .fadeIn(delay: 400.ms, duration: 600.ms)
              .scale(delay: 400.ms, duration: 600.ms),
          ],
        ),
      ),
    );
  }

  // Beautiful welcome header with wave pattern and avatar
  Widget _buildWelcomeHeader(BuildContext context, DashboardProvider dashboardProvider, Size size) {
    final colors = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    
    // Calculate parallax effect based on scroll
    final parallaxOffset = _hasScrolled ? -20.0 : 0.0;
    
    return Container(
      height: 200,
      width: size.width,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Stack(
        children: [
          // Animated background with gradient and subtle pattern
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colors.primary,
                    Color.lerp(colors.primary, colors.secondary, 0.7)!,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: colors.primary.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  children: [
                    // Animated wave pattern for the background (simulated with multiple ovals)
                    ...List.generate(3, (index) {
  return Positioned(
    right: -50,
    bottom: -80 + (index * 30),
    child: Container(
      width: 200 + (index * 20),
      height: 200 + (index * 20),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.onPrimary.withOpacity(0.1),
      ),
    )
    .animate(onPlay: (controller) => controller.repeat())
    .custom(
      duration: Duration(seconds: 4 + index),
      curve: Curves.easeInOut,
      builder: (context, value, child) => Transform.scale(
        scale: 1.0 + (0.1 * math.sin(value * math.pi * 2)),
        child: child,
      ),
      begin: 0,
      end: 1,
    ),
  );
}),

                    
                    // Small decorative dots pattern
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.1,
                        child: CustomPaint(
                          painter: DotPatternPainter(dotColor: colors.onPrimary),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ).animate(controller: _controller)
            .fadeIn(duration: 800.ms, curve: Curves.easeOut)
            .slideY(begin: 0.2, curve: Curves.easeOutQuint)
            .animate(autoPlay: true)
            .custom(
              duration: 400.ms,
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, parallaxOffset * value),
                  child: child,
                );
              },
            ),
          
          // Content
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // User info & welcome text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Bonjour,',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: colors.onPrimary.withOpacity(0.9),
                          ),
                        ).animate(controller: _controller)
                          .fadeIn(duration: 600.ms, delay: 200.ms)
                          .slideY(begin: 0.3, end: 0, curve: Curves.easeOutCubic),
                        
                        const SizedBox(height: 4),
                        
                        Text(
                          dashboardProvider.userName,
                          style: GoogleFonts.inter(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: colors.onPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ).animate(controller: _controller)
                          .fadeIn(duration: 600.ms, delay: 400.ms)
                          .slideY(begin: 0.3, end: 0, curve: Curves.easeOutCubic),
                        
                        const SizedBox(height: 8),
                        
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: colors.onPrimary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.location_on_rounded,
                                size: 14,
                                color: colors.onPrimary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Votre quartier',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: colors.onPrimary,
                                ),
                              ),
                            ],
                          ),
                        ).animate(controller: _controller)
                          .fadeIn(duration: 600.ms, delay: 600.ms)
                          .slideY(begin: 0.3, end: 0, curve: Curves.easeOutCubic),
                      ],
                    ),
                  ),
                  
                  const SizedBox(width: 20),
                  
                  // User Avatar with notification indicator
                  Stack(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: colors.onPrimary, width: 2),
                          color: colors.onPrimary.withOpacity(0.2),
                        ),
                        child: Center(
                          child: Text(
                            dashboardProvider.userName.isNotEmpty 
                                ? dashboardProvider.userName.substring(0, 1).toUpperCase()
                                : "?",
                            style: GoogleFonts.inter(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: colors.onPrimary,
                            ),
                          ),
                        ),
                      ).animate(controller: _controller)
                        .fadeIn(duration: 800.ms, delay: 200.ms)
                        .scale(begin: Offset(0.7, 0.7), end: Offset(1.0, 1.0), curve: Curves.elasticOut),
                      
                      // Notification indicator
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colors.primary,
                              width: 2,
                            ),
                          ),
                        ),
                      ).animate(controller: _controller)
                        .fadeIn(duration: 400.ms, delay: 1000.ms)
                        .scale(begin: Offset(0.5, 0.5), curve: Curves.elasticOut),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Horizontal scrolling stats cards
  Widget _buildStatCardsRow(BuildContext context, DashboardProvider dashboardProvider, ColorScheme colors) {
    return SizedBox(
      // Increased height to prevent overflow
      height: 180,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        scrollDirection: Axis.horizontal,
        children: [
          _buildStatCard(
            context,
            'Problèmes Signalés',
            dashboardProvider.problemCount.toString(),
            Icons.report_problem_rounded,
            colors.error,
            0,
          ),
          _buildStatCard(
            context,
            'En Attente',
            dashboardProvider.pendingProblems.toString(),
            Icons.hourglass_top_rounded,
            colors.secondary,
            1,
          ),
          _buildStatCard(
            context,
            'Réclamations',
            dashboardProvider.complaintCount.toString(),
            Icons.comment_bank_rounded,
            Colors.purple,
            2,
          ),
          _buildStatCard(
            context,
            'Résolus',
            dashboardProvider.resolvedProblems.toString(),
            Icons.check_circle_rounded,
            Colors.green,
            3,
          ),
        ],
      ),
    );
  }

  // Enhanced stat card with refined design and animations
  Widget _buildStatCard(BuildContext context, String title, String count, IconData icon, Color color, int index) {
    final colors = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    
    // Adjust background colors based on theme brightness
    final cardColor = brightness == Brightness.dark 
        ? Color.lerp(colors.surface, color, 0.15)! 
        : Color.lerp(Colors.white, color, 0.08)!;
    
    final iconBackColor = Color.lerp(cardColor, color, 0.15)!;
    
    // Create the card content first without animations
    final cardContent = Container(
      width: 160,
      margin: EdgeInsets.only(
        left: index == 0 ? 4 : 8,
        right: 8,
      ),
      child: Card(
        elevation: 4,
        shadowColor: color.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: color.withOpacity(0.2),
            width: 1,
          ),
        ),
        color: cardColor,
        child: Padding(
          // Reduced vertical padding to help with overflow
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // Use min size to prevent expansion
            children: [
              // Icon with custom background
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBackColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 22, color: color),
              ),
              
              const SizedBox(height: 8), // Reduced spacing
              
              // Count with large text
              Text(
                count,
                style: GoogleFonts.inter(
                  fontSize: 24, // Slightly reduced font size
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              
              // Title
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
    
    // Apply animations to the card content
    return cardContent.animate(controller: _controller)
      .fadeIn(duration: 600.ms, delay: 200.ms + (index * 100).ms)
      .slideX(begin: 0.2, end: 0, curve: Curves.easeOutCubic)
      .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.0, 1.0), curve: Curves.easeOut);
  }

  // Enhanced activity item with animations
  Widget _buildActivityItem(BuildContext context, String title, String subtitle, String time, IconData icon, Color iconColor, int index, Map<String, dynamic> activity  ) {
    final colors = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    
    return Container(
      margin: EdgeInsets.only(
        bottom: 12, 
        left: 16, 
        right: 16, 
        top: index == 0 ? 0 : 0
      ),
      child: Card(
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            title: Text(
              title, 
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600, 
                fontSize: 15, 
                color: colors.onSurface
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  subtitle, 
                  style: GoogleFonts.inter(
                    fontSize: 13, 
                    color: colors.onSurface.withOpacity(0.7)
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 12,
                      color: colors.onSurface.withOpacity(0.5),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      time, 
                      style: GoogleFonts.inter(
                        fontSize: 12, 
                        color: colors.onSurface.withOpacity(0.5)
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: Icon(
              Icons.chevron_right_rounded,
              color: colors.primary.withOpacity(0.7),
            ),
       onTap: () {
  // Check the activity type and navigate accordingly
  if (activity['record_type'] == 'PROBLEM') {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProblemDetailScreen(problemId: activity['id']),
      ),
    );
  } else if (activity['record_type'] == 'COMPLAINT') {
    // For now, just show a placeholder message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Détails de réclamation à venir'),
        duration: Duration(seconds: 2),
      ),
    );
    
    // When you implement the ComplaintDetailScreen, replace with:
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => ComplaintDetailScreen(complaintId: activity['id']),
    //   ),
    // );
  }

            },
          ),
        ),
      ),
    ).animate(controller: _controller)
      .fadeIn(delay: 800.ms + (index * 100).ms, duration: 600.ms)
      .slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic);
  }

  // Helper functions for activity items
// Replace the _getActivityTitle function with this:
String _getActivityTitle(Map<String, dynamic> activity) {
  // Use the title field from the API if available
  if (activity.containsKey('title') && activity['title'] != null) {
    return activity['title'];
  }
  
  // Fallback to the old logic if title is not available
  if (activity['record_type'] == 'PROBLEM') {
    return 'Nouveau problème signalé';
  } else if (activity['record_type'] == 'COMPLAINT') {
    return 'Nouvelle réclamation soumise';
  }
  return 'Activité inconnue';
}


String _getActivitySubtitle(Map<String, dynamic> activity) {
  if (activity['record_type'] == 'PROBLEM') {
    return activity['description'] ?? 'Pas de description'; // Use description
  } else if (activity['record_type'] == 'COMPLAINT') {
    return activity['subject'] ?? 'Pas de sujet'; // Use subject
  }
  return 'Pas de détails';
}

String _formatTimeAgo(String? changedAt) {
  if (changedAt == null) return 'Inconnu';

  try {
    DateTime dateTime = DateTime.parse(changedAt).toLocal();
    Duration difference = DateTime.now().toLocal().difference(dateTime);

    if (difference.inDays > 0) {
      return 'Il y a ${difference.inDays} jours';
    } else if (difference.inHours > 0) {
      return 'Il y a ${difference.inHours} heures';
    } else if (difference.inMinutes > 0) {
      return 'Il y a ${difference.inMinutes} minutes';
    } else {
      return 'À l\'instant';
    }
  } catch (e) {
    print('Error formatting time: $e');
    return 'Il y a longtemps';
  }
}

IconData _getActivityIcon(Map<String, dynamic> activity) {
  if (activity['record_type'] == 'PROBLEM') {
    return Icons.report_problem_rounded;
  } else if (activity['record_type'] == 'COMPLAINT') {
    return Icons.comment_bank_rounded;
  }
  return Icons.info_rounded;
}

Color _getActivityIconColor(Map<String, dynamic> activity, ColorScheme colors) {
  if (activity['record_type'] == 'PROBLEM') {
    return colors.error;
  } else if (activity['record_type'] == 'COMPLAINT') {
    return colors.secondary;
  }
  return colors.primary;
}


 }

// Custom painter for dot pattern
class DotPatternPainter extends CustomPainter {
  final Color dotColor;
  
  DotPatternPainter({required this.dotColor});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = dotColor
      ..style = PaintingStyle.fill;
    
    const double spacing = 20;
    const double dotRadius = 1;
    
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
      }
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}