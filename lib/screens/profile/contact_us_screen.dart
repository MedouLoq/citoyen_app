import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:citoyen_app/l10n/app_localizations.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({Key? key}) : super(key: key);

  // Fonction pour lancer le composeur téléphonique
  _launchPhoneDialer(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw 'Impossible de lancer $phoneNumber';
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      body: Stack(
        children: [
          // Dégradé d'arrière-plan
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1565C0), // Bleu clair de l'écran d'accueil
                  Color(0xFF0D47A1), // Bleu plus foncé de l'écran d'accueil
                ],
              ),
            ),
          ),

          // Motif d'arrière-plan (optionnel, si vous avez un pattern.png)
          // Opacity(
          //   opacity: 0.05,
          //   child: Container(
          //     decoration: const BoxDecoration(
          //       image: DecorationImage(
          //         image: AssetImage('assets/images/pattern.png'),
          //         repeat: ImageRepeat.repeat,
          //       ),
          //     ),
          //   ),
          // ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    localizations?.contactUs ?? 'Nous Contacter',
                    style: GoogleFonts.montserrat(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  // Emplacement du logo
                  Center(
                    child: Container(
                      height: 120,
                      width: 120,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Image.asset(
                          'assets/images/municipal_logo.jpg'), // Icône de remplacement
                      // Vous pouvez remplacer ceci par Image.asset('assets/images/your_logo.png')
                    ),
                  ),
                  const SizedBox(height: 40),
                  _buildContactInfoCard(
                    context,
                    icon: Icons.phone,
                    title: localizations?.arafatPhoneNumber ??
                        'Numéro de téléphone d\'Arafat',
                    content: '+222 36310068',
                    onTap: () => _launchPhoneDialer('+22236310068'),
                  ),
                  const Spacer(),
                  Text(
                    localizations?.weAreHereToHelp ??
                        'Nous sommes là pour vous aider !',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String content,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF0D47A1), size: 28),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0D47A1),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
