// lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:citoyen_app/widgets/custom_bottom_nav_bar.dart'; // Will be created
import 'package:citoyen_app/screens/auth/auth_screen.dart';
import 'package:citoyen_app/screens/complaint/complaint_detail_screen.dart';
import 'package:citoyen_app/screens/complaint/complaint_list_screen.dart';
import 'package:citoyen_app/providers/dashboard_provider.dart';
import 'notifications_screen.dart';
import 'package:citoyen_app/screens/problem/problem_list_screen.dart';
import 'package:citoyen_app/screens/problem/report_problem_details_screen.dart';
import 'package:citoyen_app/screens/profile/profile_screen.dart';
import 'package:citoyen_app/screens/dashboard_home_tab.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'package:citoyen_app/l10n/app_localizations.dart';
import 'problem/category_selection_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  // Placeholder pages for bottom navigation
  final List<Widget> _pages = [
    const DashboardHomeTab(key: ValueKey('DashboardHomeTab')),
    const ProblemListScreen(key: ValueKey('ProblemListScreen')),
    const ComplaintListScreen(key: ValueKey('ComplaintListScreen')),
    const ProfileScreen(key: ValueKey('ProfileScreen')),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final localizations = AppLocalizations.of(context);
    return Consumer<DashboardProvider>(
        builder: (context, dashboardProvider, child) {
      return Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          title: Text(localizations?.dashboardTitle ?? 'Tableau de Bord',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          automaticallyImplyLeading: false, // No back button on main dashboard
          actions: [
            IconButton(
              icon: Icon(Icons.notifications_none_outlined,
                  color: colors.primary),
              onPressed: () {
                // TODO: Implement notifications screen or functionality
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => NotificationsScreen()),
                );
              },
            )
                .animate()
                .fadeIn(delay: 300.ms, duration: 500.ms)
                .slideX(begin: 0.5, curve: Curves.easeOutCubic),
          ],
        ),
        body: IndexedStack(
          // Use IndexedStack to keep state of pages
          index: _currentIndex,
          children: _pages,
        ),
        floatingActionButton: _currentIndex ==
                0 // Show FAB only on Dashboard Home Tab
            ? FloatingActionButton.extended(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) =>
                            CategorySelectionScreen()), // Placeholder
                  );
                },
                backgroundColor: colors.primary,
                icon: Icon(Icons.add_comment_outlined, color: colors.onPrimary),
                label: Text(localizations?.reportButton ?? 'Signaler',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600, color: colors.onPrimary)),
              ).animate().scale(
                delay: 500.ms, duration: 500.ms, curve: Curves.elasticOut)
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: SafeArea(
          child: CustomBottomNavBar(
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
          ),
        ),
      );
    });
  }
}
