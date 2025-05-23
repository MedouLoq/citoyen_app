import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:citoyen_app/widgets/custom_text_field.dart';
import '../verification_screen_api.dart';
import 'package:dropdown_search/dropdown_search.dart'; // Import dropdown_search
import 'dart:async';
final String baseUrl = "http://10.0.2.2:8000/api";


class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nniController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _selectedMunicipalityId; // Store Municipality ID

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _nniController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _storeToken(String token) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
    } else {
      const storage = FlutterSecureStorage();
      await storage.write(key: 'auth_token', value: token);
    }
  }

  Future<void> _register() async { 
    if (_formKey.currentState!.validate() && _selectedMunicipalityId != null) {
      setState(() {
        _isLoading = true;
      });

      const String apiUrl = 'http://10.0.2.2:8000/api/register/';

      try {
        final response = await http
            .post(
          Uri.parse(apiUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'full_name': _fullNameController.text,
            'phone_number': _phoneController.text,
            'nni': _nniController.text,
            'municipality': _selectedMunicipalityId, // Send selected Municipality ID
            'password': _passwordController.text,
            'password_confirm': _confirmPasswordController.text,
          }),
        )
            .timeout(const Duration(seconds: 30));

     final phoneNumber =    _phoneController.text;
    if (response.statusCode == 201) { // Assuming 201 means user created
      final responseData = jsonDecode(response.body);
      
      // final token = responseData['token']; // If your registration returns a token
      // await _storeToken(token); // Store token if needed

      // *** IMPORTANT: Call send verification code API ***
      bool codeSent = await _sendVerificationCode(phoneNumber);

      if (codeSent && mounted) {
        // Navigate to VerificationScreen ONLY if the code was sent successfully
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Inscription réussie! Code de vérification envoyé.')),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => VerificationScreen(phoneNumber: phoneNumber)),
        );
      } else if (mounted) {
        // Handle case where sending the code failed
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Inscription réussie, mais échec de l\'envoi du code. Veuillez réessayer ou contacter le support.')),
        );
        // Decide what to do here - maybe stay on registration page or go to login?
      }
    } else {
          String errorMessage = 'Erreur d\'inscription';
          if (response.statusCode == 400) {
            final responseData = jsonDecode(response.body);
            if (responseData.containsKey('errors')) {
              errorMessage = 'Veuillez corriger les erreurs';
            }
          } else {
            errorMessage = 'Erreur d\'inscription. Code: ${response.statusCode}';
          }
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(errorMessage)),
            );
          }
        }
      } catch (error) {
        String errorMessage = 'Erreur d\'inscription. Veuillez vérifier votre connexion Internet.';
        if (error is FormatException) {
          errorMessage = 'Erreur de format de réponse du serveur';
        }
        else if (error is http.ClientException) {
          errorMessage = 'Erreur lors de la communication avec le serveur';
        }
        else if (error is TimeoutException){
          errorMessage = "Délai d'attente dépassé. Veuillez vérifier votre connexion.";
        }
        print('Error during registration: $error');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        }
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      String errorMessage = 'Veuillez sélectionner la municipalité de resudance'; // Show error for unselected municipality
      if (_selectedMunicipalityId == null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text('Créer un compte', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        backgroundColor: colors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: colors.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
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
                  Text(
                    'Rejoignez-nous',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: colors.onBackground,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Créez votre compte pour commencer',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: colors.onBackground.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 40),
                  CustomTextField(
                    controller: _fullNameController,
                    labelText: 'Nom complet',
                    hintText: 'Entrez votre nom complet',
                    prefixIcon: Icons.person_outline,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre nom complet';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    controller: _phoneController,
                    labelText: 'Numéro de téléphone',
                    hintText: 'Entrez votre numéro de téléphone',
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre numéro de téléphone';
                      }
                      final phoneRegExp = RegExp(r'^\d{8}$');
    if (!phoneRegExp.hasMatch(value)) {
      return 'Le numéro doit contenir exactement 8 chiffres';
    }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    controller: _nniController,
                    labelText: 'NNI',
                    hintText: 'Entrez votre NNI',
                    prefixIcon: Icons.credit_card,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre NNI';
                      }
                       final phoneRegExp = RegExp(r'^\d{10}$');
    if (!phoneRegExp.hasMatch(value)) {
      return 'La NNI doit contenir exactement 10 chiffres';
    }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  // Municipality Dropdown
                DropdownSearch<Map<String, dynamic>>(
  // —————————————————————————————
  // 1) Load items asynchronously via `items:`
  // —————————————————————————————
  items: (String filter, _) async {
    final res = await http
      .get(Uri.parse('http://10.0.2.2:8000/api/municipalities/'))
      .timeout(const Duration(seconds: 10));
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data
          .map<Map<String, dynamic>>((e) => {
                'id': e['id'],
                'name': e['name'],
              })
          .toList();
    }
    return <Map<String, dynamic>>[];
  },

  // —————————————————————————————
  // 2) How to show each item as text
  // —————————————————————————————
  itemAsString: (item) => item?['name'] ?? '',

  // —————————————————————————————
  // 3) Equality comparison
  // —————————————————————————————
  compareFn: (a, b) => a != null && b != null && a['id'] == b['id'],

  // —————————————————————————————
  // 4) Initial selection (if any)
  // —————————————————————————————
  selectedItem: _selectedMunicipalityId != null
      ? {
          'id': _selectedMunicipalityId,
          'name': '…', // replace with the actual name if you have it
        }
      : null,

  // —————————————————————————————
  // 5) Decoration (copied exactly from CustomTextField)
  // —————————————————————————————
  decoratorProps: DropDownDecoratorProps(
    decoration: InputDecoration(
      labelText: 'Municipalité',
      hintText: 'Sélectionnez votre municipalité',
      labelStyle: GoogleFonts.inter(
        color: colors.onSurface.withOpacity(0.7),
      ),
      hintStyle: GoogleFonts.inter(
        color: colors.onSurface.withOpacity(0.5),
      ),
      prefixIcon: Icon(
        Icons.location_city,
        color: colors.primary.withOpacity(0.8),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: colors.onSurface.withOpacity(0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: colors.onSurface.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: colors.primary, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: colors.error, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: colors.error, width: 2.0),
      ),
      filled: true,
      fillColor: colors.surfaceVariant.withOpacity(0.05),
      contentPadding: const EdgeInsets.symmetric(
        vertical: 16.0,
        horizontal: 16.0,
      ),
    ),
  ),

  // —————————————————————————————
  // 6) Suffix (dropdown arrow) styling
  // —————————————————————————————
  suffixProps: DropdownSuffixProps(
    dropdownButtonProps: DropdownButtonProps(
      iconClosed: Icon(Icons.keyboard_arrow_down, color: colors.onSurface),
      iconOpened: Icon(Icons.keyboard_arrow_up, color: colors.onSurface),
    ),
  ),

  // —————————————————————————————
  // 7) Popup list styling
  // —————————————————————————————
  popupProps: PopupProps.menu(
    showSearchBox: true,
    itemBuilder: (context, item, isSelected, isHighlighted) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color:
              isSelected ? colors.primary.withOpacity(0.1) : colors.surface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          item['name'] ?? '',
          style: GoogleFonts.inter(
            color: isSelected ? colors.primary : colors.onSurface,
            fontSize: 16,
          ),
        ),
      );
    },
  ),

  // —————————————————————————————
  // 8) On selection change
  // —————————————————————————————
  onChanged: (item) {
    setState(() {
      _selectedMunicipalityId = item?['id']?.toString();
    });
  },

  // —————————————————————————————
  // 9) Validation
  // —————————————————————————————
  validator: (value) =>
      value == null ? 'Veuillez sélectionner votre municipalité' : null,
),

                const SizedBox(height: 20),
                  CustomTextField(
                    controller: _passwordController,
                    labelText: 'Mot de passe',
                    hintText: 'Créez un mot de passe',
                    prefixIcon: Icons.lock_outline,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez créer un mot de passe';
                      }
                      if (value.length < 6) {
                        return 'Le mot de passe doit contenir au moins 6 caractères';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    controller: _confirmPasswordController,
                    labelText: 'Confirmer le mot de passe',
                    hintText: 'Confirmez votre mot de passe',
                    prefixIcon: Icons.lock_outline,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez confirmer votre mot de passe';
                      }
                      if (value != _passwordController.text) {
                        return 'Les mots de passe ne correspondent pas';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  _isLoading
                      ? Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                      ))
                      : ElevatedButton(
                    onPressed: _register,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text('S\'inscrire',
                        style: GoogleFonts.inter(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Déjà un compte?',
                        style: GoogleFonts.inter(
                            color: colors.onBackground.withOpacity(0.7)),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Go back to LoginScreen
                        },
                        child: Text(
                          'Se connecter',
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
  // Corrected _customPopupItemBuilder
  Widget _customPopupItemBuilder(
      BuildContext context,
      Map<String, dynamic> item,
      bool isSelected,
      bool isHighlighted // Added isHighlighted
      ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: !isSelected
          ? null
          : BoxDecoration(
        border: Border.all(color: Theme.of(context).primaryColor),
        borderRadius: BorderRadius.circular(5),
        color: Colors.white,
      ),
      padding: const EdgeInsets.all(20),
      child: Text(
        item['name'] ?? '', // Display name
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}
// --- Helper function to call the send-verification-code endpoint ---
Future<bool> _sendVerificationCode(String phoneNumber) async {
  // Consider showing a brief loading indicator here if needed
  print('Attempting to send verification code to $phoneNumber...');
  try {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/api/send-code/'), // Use the correct endpoint from your Django app
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        // Add Authorization header if this endpoint requires authentication
        // 'Authorization': 'Bearer YOUR_TOKEN', 
      },
      body: jsonEncode(<String, String>{
        'phone_number': phoneNumber,
      }),
    );

    if (response.statusCode == 200) {
      print('Verification code sent successfully via API.');
      return true; // Indicate success
    } else {
      // Log error details from backend if available
      final responseBody = jsonDecode(response.body);
      print('Failed to send verification code. Status: ${response.statusCode}, Body: ${response.body}');
      return false; // Indicate failure
    }
  } catch (e) {
    print('Exception caught sending verification code: $e');
    return false; // Indicate failure due to exception
  }
}
