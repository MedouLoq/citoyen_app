import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:citoyen_app/screens/auth/login_screen.dart'; // For logout

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Placeholder user data - replace with actual data fetching
  final String _userName = "Amina KHALIL";
  final String _userEmail = "amina.khalil@example.com";
  final String _userPhone = "+212 6 00 11 22 33";
  final String _userAvatarUrl = "https://via.placeholder.com/150/4CAF50/FFFFFF?Text=AK"; // Placeholder

  Future<void> _logout() async {
    // Simulate logout process
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false, // Remove all previous routes
      );
    }
  }

  Widget _buildProfileOption(BuildContext context, IconData icon, String title, VoidCallback onTap, {Color? iconColor}) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(icon, color: iconColor ?? colors.primary, size: 24),
        title: Text(title, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500, color: colors.onSurface)),
        trailing: Icon(Icons.arrow_forward_ios_rounded, size: 18, color: colors.onSurface.withOpacity(0.5)),
        onTap: onTap,
        splashColor: colors.primary.withOpacity(0.1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text('Mon Profil', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        backgroundColor: colors.background,
        elevation: 0,
        // No back button if it's a tab, or handle based on navigation stack
        automaticallyImplyLeading: false, 
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // User Avatar and Name
            CircleAvatar(
              radius: 55,
              backgroundColor: colors.primary.withOpacity(0.2),
              child: CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(_userAvatarUrl), // Replace with actual image or placeholder
                backgroundColor: colors.surfaceVariant,
                child: _userAvatarUrl.isEmpty 
                    ? Text(_userName.isNotEmpty ? _userName[0].toUpperCase() : 'U', 
                           style: GoogleFonts.inter(fontSize: 40, fontWeight: FontWeight.bold, color: colors.primary))
                    : null,
              ),
            ).animate().fadeIn(duration: 500.ms).scale(curve: Curves.elasticOut),
            const SizedBox(height: 16),
            Text(
              _userName,
              style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: colors.onBackground),
            ).animate().fadeIn(delay: 200.ms, duration: 500.ms).slideY(begin: 0.2, curve: Curves.easeOutCubic),
            Text(
              _userEmail,
              style: GoogleFonts.inter(fontSize: 15, color: colors.onBackground.withOpacity(0.7)),
            ).animate().fadeIn(delay: 300.ms, duration: 500.ms).slideY(begin: 0.2, curve: Curves.easeOutCubic),
            const SizedBox(height: 8),
            Text(
              _userPhone,
              style: GoogleFonts.inter(fontSize: 15, color: colors.onBackground.withOpacity(0.7)),
            ).animate().fadeIn(delay: 400.ms, duration: 500.ms).slideY(begin: 0.2, curve: Curves.easeOutCubic),
            const SizedBox(height: 30),
            // Profile Options
            _buildProfileOption(
              context,
              Icons.edit_outlined,
              'Modifier mes informations',
              () {
                // TODO: Navigate to Edit Profile Screen
                print('Edit Profile Tapped');
              },
            ).animate().fadeIn(delay: 500.ms, duration: 400.ms).slideX(begin: -0.2, curve: Curves.easeOutCubic),
            _buildProfileOption(
              context,
              Icons.lock_outline_rounded,
              'Changer le mot de passe',
              () {
                // TODO: Navigate to Change Password Screen
                print('Change Password Tapped');
              },
            ).animate().fadeIn(delay: 600.ms, duration: 400.ms).slideX(begin: -0.2, curve: Curves.easeOutCubic),
            _buildProfileOption(
              context,
              Icons.notifications_outlined,
              'Préférences de notification',
              () {
                // TODO: Navigate to Notification Settings Screen
                print('Notification Preferences Tapped');
              },
            ).animate().fadeIn(delay: 700.ms, duration: 400.ms).slideX(begin: -0.2, curve: Curves.easeOutCubic),
            _buildProfileOption(
              context,
              Icons.help_outline_rounded,
              'Aide et Support',
              () {
                // TODO: Navigate to Help/Support Screen or show a dialog
                print('Help & Support Tapped');
              },
            ).animate().fadeIn(delay: 800.ms, duration: 400.ms).slideX(begin: -0.2, curve: Curves.easeOutCubic),
            const SizedBox(height: 24),
            // Logout Button
            ElevatedButton.icon(
              icon: Icon(Icons.logout_rounded, color: colors.onError),
              label: Text('Se déconnecter', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: colors.onError)),
              onPressed: _logout,
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.error,
                minimumSize: const Size(double.infinity, 50),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ).animate().fadeIn(delay: 900.ms, duration: 500.ms).scale(curve: Curves.elasticOut),
          ],
        ),
      ),
    );
  }
}

