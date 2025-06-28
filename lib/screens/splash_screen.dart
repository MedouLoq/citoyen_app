import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth/auth_screen.dart';
import 'dart:async';
import 'package:citoyen_app/l10n/app_localizations.dart';

class SplashScreen extends StatefulWidget {
  final Function(Locale) onLocaleChanged;

  const SplashScreen({super.key, required this.onLocaleChanged});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  bool _showContent = false;
  bool _showAgreement = false;
  bool _hasAcceptedAgreement = false;
  String _selectedLanguage = 'fr'; // Default language is French
  late AnimationController _logoAnimationController;
  late AnimationController _backgroundAnimationController;

  @override
  void initState() {
    super.initState();
    _logoAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _backgroundAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _loadSavedLanguage();
    _checkAgreementStatus();

    // Start initial animations
    Future.delayed(const Duration(milliseconds: 500), () {
      _logoAnimationController.forward();
      _backgroundAnimationController.forward();
    });

    // Show content after initial animations
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showContent = true;
        });
      }
    });
  }

  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString('selectedLanguage');
    if (savedLanguage != null) {
      setState(() {
        _selectedLanguage = savedLanguage;
      });
      widget.onLocaleChanged(Locale(savedLanguage));
    }
  }

  Future<void> _saveAndUpdateLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedLanguage', languageCode);
    setState(() {
      _selectedLanguage = languageCode;
    });
    widget.onLocaleChanged(Locale(languageCode));
  }

  // Check if user has already accepted the agreement
  Future<void> _checkAgreementStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final hasAccepted = prefs.getBool('hasAcceptedAgreement') ?? false;

    if (mounted) {
      setState(() {
        _hasAcceptedAgreement = hasAccepted;
      });
    }
  }

  // Save that user has accepted agreement
  Future<void> _saveAgreementAcceptance() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasAcceptedAgreement', true);
    setState(() {
      _hasAcceptedAgreement = true;
    });
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    _backgroundAnimationController.dispose();
    super.dispose();
  }

  void _navigateToNextScreen() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const AuthScreen()),
    );
  }

  void _showAgreementDialog() {
    // Only show agreement if user hasn't accepted it before
    if (_hasAcceptedAgreement) {
      _navigateToNextScreen();
    } else {
      setState(() {
        _showAgreement = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient animation
          AnimatedBuilder(
            animation: _backgroundAnimationController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.lerp(
                        const Color(0xFF1565C0),
                        const Color(0xFF0D47A1),
                        _backgroundAnimationController.value,
                      )!,
                      Color.lerp(
                        const Color(0xFF0D47A1),
                        const Color(0xFF01579B),
                        _backgroundAnimationController.value,
                      )!,
                    ],
                  ),
                ),
              );
            },
          ),

          // Background pattern
          Opacity(
            opacity: 0.05,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                      'assets/images/pattern.png'), // Add this image to your assets
                  repeat: ImageRepeat.repeat,
                ),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Language selector at the top right
                  Align(
                    alignment: Alignment.topRight,
                    child: _buildLanguageSelector(),
                  ),

                  const Spacer(),

                  // Logo and title animation
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // App Logo with custom animation
                        AnimatedBuilder(
                          animation: _logoAnimationController,
                          builder: (context, child) {
                            return Transform.scale(
                              scale:
                                  0.5 + (_logoAnimationController.value * 0.5),
                              child: Opacity(
                                opacity: _logoAnimationController.value,
                                child: Container(
                                  height: 120,
                                  width: 120,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 15,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: const Center(
                                    child: Image(
                                      image: AssetImage(
                                          'assets/images/belediyeti.png'),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 24),

                        // App name
                        Text(
                          localizations?.appName ?? 'App Name',
                          style: GoogleFonts.montserrat(
                            fontSize: 38,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        )
                            .animate()
                            .fadeIn(delay: 1000.ms, duration: 1000.ms)
                            .slideY(begin: 0.3, end: 0),

                        const SizedBox(height: 12),

                        // App tagline
                        Text(
                          localizations?.appTagline ?? 'App Tagline',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withOpacity(0.9),
                            letterSpacing: 0.5,
                          ),
                        )
                            .animate()
                            .fadeIn(delay: 1500.ms, duration: 1000.ms)
                            .slideY(begin: 0.3, end: 0),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Action buttons section
                  if (_showContent)
                    Column(
                      children: [
                        // Continue button
                        ElevatedButton(
                          onPressed: _showAgreementDialog,
                          style: ElevatedButton.styleFrom(
                            foregroundColor: const Color(0xFF0D47A1),
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 5,
                            shadowColor: Colors.black38,
                          ),
                          child: Text(
                            localizations?.continueButton ?? 'Continue',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                            .animate()
                            .fadeIn(delay: 2000.ms, duration: 800.ms)
                            .slideY(begin: 0.5, end: 0),

                        const SizedBox(height: 28),
                      ],
                    ),
                ],
              ),
            ),
          ),

          // Agreement overlay
          if (_showAgreement) _buildAgreementOverlay(),
        ],
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _languageOption('fr', 'Français'),
          const SizedBox(width: 8),
          _languageOption('ar', 'العربية'),
        ],
      ),
    ).animate().fadeIn(delay: 2500.ms, duration: 800.ms);
  }

  Widget _languageOption(String code, String label) {
    final isSelected = _selectedLanguage == code;

    return GestureDetector(
      onTap: () {
        _saveAndUpdateLanguage(code);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color:
              isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildAgreementOverlay() {
    final localizations = AppLocalizations.of(context);
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Title with icon
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.verified_user_rounded,
                    color: const Color(0xFF1565C0),
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    localizations?.termsAndConditions ?? 'Terms and Conditions',
                    style: GoogleFonts.montserrat(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(
                          0xFF1565C0), // Deep blue title for emphasis
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAgreementSection(
                          localizations?.whatIsThisApp ?? 'What is this app?',
                          localizations?.whatIsThisAppContent ??
                              'No content provided'),
                      _buildAgreementSection(
                          localizations?.mainRoleOfApp ?? 'Main role of app',
                          localizations?.mainRoleOfAppContent ??
                              'No content provided'),
                      _buildAgreementSection(
                          localizations?.citizenRights ?? 'Citizen Rights',
                          localizations?.citizenRightsContent ??
                              'No content provided'),
                      _buildAgreementSection(
                          localizations?.citizenResponsibilities ??
                              'Citizen Responsibilities',
                          localizations?.citizenResponsibilitiesContent ??
                              'No content provided'),
                      _buildAgreementSection(
                          localizations?.appBenefits ?? 'App Benefits',
                          localizations?.appBenefitsContent ??
                              'No content provided'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Action buttons
              Row(
                children: [
                  // Reject button
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _showAgreement = false;
                        });
                      },
                      icon: const Icon(Icons.close_rounded),
                      label: Text(
                        localizations?.rejectButton ?? 'Reject',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.redAccent,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Accept button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await _saveAgreementAcceptance();
                        _navigateToNextScreen();
                      },
                      icon: const Icon(Icons.check_circle_rounded,
                          color: Colors.white),
                      label: Text(
                        localizations?.acceptButton ?? 'Accept',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1565C0),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                        shadowColor: Colors.black38,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAgreementSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0D47A1),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.black87,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
