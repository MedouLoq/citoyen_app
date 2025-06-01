import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // For web storage
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // For native storage
import 'package:citoyen_app/screens/dashboard_screen.dart'; // Your DashboardScreen
import 'package:google_fonts/google_fonts.dart'; // Google Fonts (optional)
import 'package:citoyen_app/widgets/custom_text_field.dart'; // Custom widgets (optional)
import 'package:citoyen_app/screens/auth/register_screen.dart'; // Registration screen


class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController(); // Phone or email
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Function to store the token securely based on the platform
  Future<void> _storeToken(String token) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
    } else {
      const storage = FlutterSecureStorage();
      await storage.write(key: 'auth_token', value: token);
    }
  }

  // Login function
  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      const String apiUrl = 'http://10.0.2.2:8000/api/login/'; // Replace with your API URL

      try {
        final response = await http
            .post(
          Uri.parse(apiUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'identifier': _identifierController.text,
            'password': _passwordController.text,
          }),
        )
            .timeout(const Duration(seconds: 120));

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          final token = responseData['token'];

          await _storeToken(token); // Store the token securely

          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const DashboardScreen()),
            );
          }
        } else {
          // Handle login failure
          String errorMessage = 'Erreur de connexion';
          if (response.statusCode == 400) {
            final responseData = jsonDecode(response.body);
            if (responseData.containsKey('errors')) {
              errorMessage = 'Veuillez corriger les erreurs'; // Form errors
            } else if (responseData.containsKey('error')) {
              errorMessage = responseData['error'];
            }
          } else if (response.statusCode == 401) {
            errorMessage = 'Identifiant ou mot de passe incorrect';
          } else {
            errorMessage = 'Erreur de connexion. Code: ${response.statusCode}';
          }
          if (mounted) {
            _showSnackBar(errorMessage);
          }
        }
      } catch (error) {
        String errorMessage = 'Erreur de connexion. Veuillez vérifier votre connexion Internet.';
        if (error is FormatException) {
          errorMessage = 'Erreur de format de réponse du serveur';
        } else if (error is http.ClientException) {
          errorMessage = 'Erreur lors de la communication avec le serveur';
        } else if (error is TimeoutException) {
          errorMessage = "Délai d'attente dépassé. Veuillez vérifier votre connexion.";
        }
        print('Error during login: $error'); // Log the error
        if (mounted) {
          _showSnackBar(errorMessage);
        }
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Helper function to show a SnackBar
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Logo (Placeholder)
                  Icon(
                    Icons.flag_circle_outlined,
                    size: 80,
                    color: colors.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Bienvenue!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: colors.onBackground,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Connectez-vous pour continuer',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: colors.onBackground.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 40),
                  CustomTextField(
                    controller: _identifierController,
                    labelText: 'Numéro de téléphone',
                    hintText: 'Entrez votre téléphone',
                    prefixIcon: Icons.person_outline,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre identifiant';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    controller: _passwordController,
                    labelText: 'Mot de passe',
                    hintText: 'Entrez votre mot de passe',
                    prefixIcon: Icons.lock_outline,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre mot de passe';
                      }
                      if (value.length < 4) {
                        return 'Le mot de passe doit contenir au moins 4 caractères';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // TODO: Navigate to Forgot Password screen
                        print('Forgot Password tapped');
                      },
                      child: Text(
                        'Mot de passe oublié?',
                        style: GoogleFonts.inter(color: colors.primary, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  _isLoading
                      ? Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                      ))
                      : ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text('Se connecter',
                        style: GoogleFonts.inter(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Pas encore de compte?',
                        style: GoogleFonts.inter(
                            color: colors.onBackground.withOpacity(0.7)),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) =>
                                const RegisterScreen()), // Navigate to registration
                          );
                        },
                        child: Text(
                          'S\'inscrire',
                          style: GoogleFonts.inter(
                              color: colors.primary,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}