import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth/auth_screen.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

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

    // Check if user has already accepted agreement
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
                          'Belediyti',
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
                          'Votre voix, votre ville.',
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
                            'Continuer vers Belediyti',
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
        setState(() {
          _selectedLanguage = code;
        });
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
                    'Termes et Conditions',
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
                          'Qu\'est-ce que cette application?',
                          'Une application mobile intelligente visant à renforcer la relation entre la municipalité et le citoyen, en facilitant le signalement des problèmes locaux et le suivi de leur résolution, et en améliorant la qualité des services quotidiens, tels que la propreté, les routes, l\'eau, etc.'),
                      _buildAgreementSection(
                          'Rôle principal de l\'application',
                          '• Faciliter le processus de signalement des pannes et des problèmes dans les quartiers (tels que les nids-de-poule, l\'accumulation de déchets, les fuites d\'eau, les infractions de construction...)\n'
                              '• Fournir une plateforme unifiée de communication entre les citoyens et la municipalité.\n'
                              '• Envoyer des notifications et des alertes municipales telles que les campagnes de nettoyage, les travaux publics ou les alertes d\'urgence.\n'
                              '• Permettre au citoyen de suivre son problème grâce à un système de suivi précis (reçu - en cours de traitement - résolu).'),
                      _buildAgreementSection(
                          'Droits du citoyen',
                          '• Le droit de signaler des problèmes à tout moment et de n\'importe quel endroit.\n'
                              '• La possibilité de joindre des photos et un emplacement GPS pour clarifier le problème.\n'
                              '• Recevoir des notifications instantanées sur le statut du signalement ou de la plainte.\n'
                              '• Soumettre des plaintes générales concernant les services ou les performances.\n'
                              '• Suivre la plainte et fournir des commentaires supplémentaires en cas de retard dans la résolution.'),
                      _buildAgreementSection(
                          'Responsabilités du citoyen',
                          '• Le signalement doit être précis et honnête, sans faux signalements ou signalements malveillants.\n'
                              '• Respecter la classification des problèmes selon les bonnes catégories (propreté, routes, eau...).\n'
                              '• Interagir poliment et respectueusement avec les réponses de la municipalité via l\'application.\n'
                              '• S\'engager à ne pas utiliser l\'application à des fins personnelles ou en dehors du cadre de l\'intérêt public.'),
                      _buildAgreementSection(
                          'Avantages de l\'application',
                          '• Amélioration de la transparence du travail municipal.\n'
                              '• Accélération de la réponse aux problèmes.\n'
                              '• Communication rapide des informations officielles aux citoyens.\n'
                              '• Implication du citoyen dans l\'amélioration de son environnement et des services qui l\'entourent.'),
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
                        'Refuser',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor:
                            const Color(0xFF757575), // Gray text for reject
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Accept button
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _saveAgreementAcceptance();
                        _navigateToNextScreen();
                      },
                      icon: const Icon(Icons.check_circle_rounded),
                      label: Text(
                        'Accepter et Continuer',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor:
                            const Color(0xFF1565C0), // Match with title color
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildAgreementSection(String title, String content) {
    // Determine icon based on section title
    IconData getIconForTitle(String title) {
      if (title.contains('Qu\'est-ce que cette application')) {
        return Icons.app_shortcut_rounded;
      } else if (title.contains('Rôle principal')) {
        return Icons.phone_android_rounded;
      } else if (title.contains('Droits du citoyen')) {
        return Icons.person_rounded;
      } else if (title.contains('Responsabilités')) {
        return Icons.warning_rounded;
      } else if (title.contains('Avantages')) {
        return Icons.star_rounded;
      }
      return Icons.article_rounded; // Default icon
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F9FF), // Light blue background for sections
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1565C0).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  getIconForTitle(title),
                  color: const Color(0xFF1565C0),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title
                      .replaceAll(RegExp(r'🎯|📱|👤|⚠️|🧩'), '')
                      .trim(), // Remove emoji from title
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(
                        0xFF0D47A1), // Darker blue for section titles
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Padding(
            padding:
                const EdgeInsets.only(left: 42.0), // Align with text after icon
            child: Text(
              content,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color:
                    const Color(0xFF424242), // Dark gray for better readability
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
