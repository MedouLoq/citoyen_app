// ============================================================================
// 1. UPDATED REGISTER SCREEN
// ============================================================================
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:citoyen_app/widgets/custom_text_field.dart';
import '../verification_screen_api.dart';
import 'package:dropdown_search/dropdown_search.dart';
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
  String? _selectedMunicipalityId;
  String _selectedLanguage = 'ar'; // Default to Arabic for Mauritania

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
            'municipality': _selectedMunicipalityId,
            'password': _passwordController.text,
            'password_confirm': _confirmPasswordController.text,
          }),
        )
            .timeout(const Duration(seconds: 30));

     final phoneNumber = _phoneController.text;
     
    if (response.statusCode == 201) {
      final responseData = jsonDecode(response.body);
      
      // *** UPDATED: Send verification code with language preference ***
      bool codeSent = await _sendVerificationCode(phoneNumber, _selectedLanguage);

      if (codeSent && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_selectedLanguage == 'ar' 
              ? 'تم إنشاء الحساب بنجاح! تم إرسال رمز التحقق.'
              : 'Inscription réussie! Code de vérification envoyé.')
          ),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => VerificationScreen(
              phoneNumber: phoneNumber,
              language: _selectedLanguage, // Pass language preference
            )
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_selectedLanguage == 'ar' 
              ? 'تم إنشاء الحساب، لكن فشل في إرسال الرمز. يرجى المحاولة مرة أخرى.'
              : 'Inscription réussie, mais échec de l\'envoi du code. Veuillez réessayer.')
          ),
        );
      }
    } else {
          String errorMessage = _selectedLanguage == 'ar' 
            ? 'خطأ في التسجيل' 
            : 'Erreur d\'inscription';
          if (response.statusCode == 400) {
            final responseData = jsonDecode(response.body);
            if (responseData.containsKey('errors')) {
              errorMessage = _selectedLanguage == 'ar' 
                ? 'يرجى تصحيح الأخطاء' 
                : 'Veuillez corriger les erreurs';
            }
          } else {
            errorMessage = _selectedLanguage == 'ar' 
              ? 'خطأ في التسجيل. الرمز: ${response.statusCode}'
              : 'Erreur d\'inscription. Code: ${response.statusCode}';
          }
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(errorMessage)),
            );
          }
        }
      } catch (error) {
        String errorMessage = _selectedLanguage == 'ar' 
          ? 'خطأ في التسجيل. يرجى التحقق من اتصال الإنترنت.'
          : 'Erreur d\'inscription. Veuillez vérifier votre connexion Internet.';
        if (error is FormatException) {
          errorMessage = _selectedLanguage == 'ar' 
            ? 'خطأ في تنسيق استجابة الخادم'
            : 'Erreur de format de réponse du serveur';
        }
        else if (error is http.ClientException) {
          errorMessage = _selectedLanguage == 'ar' 
            ? 'خطأ في التواصل مع الخادم'
            : 'Erreur lors de la communication avec le serveur';
        }
        else if (error is TimeoutException){
          errorMessage = _selectedLanguage == 'ar' 
            ? 'انتهت مهلة الانتظار. يرجى التحقق من الاتصال.'
            : "Délai d'attente dépassé. Veuillez vérifier votre connexion.";
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
      String errorMessage = _selectedLanguage == 'ar' 
        ? 'يرجى اختيار البلدية'
        : 'Veuillez sélectionner la municipalité de résidence';
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
        title: Text(
          _selectedLanguage == 'ar' ? 'إنشاء حساب' : 'Créer un compte', 
          style: GoogleFonts.inter(fontWeight: FontWeight.w600)
        ),
        backgroundColor: colors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: colors.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          // Language toggle button
          IconButton(
            icon: Text(
              _selectedLanguage == 'ar' ? 'FR' : 'AR',
              style: TextStyle(
                color: colors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () {
              setState(() {
                _selectedLanguage = _selectedLanguage == 'ar' ? 'fr' : 'ar';
              });
            },
          ),
        ],
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
                    _selectedLanguage == 'ar' ? 'انضم إلينا' : 'Rejoignez-nous',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: colors.onBackground,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _selectedLanguage == 'ar' 
                      ? 'أنشئ حسابك للبدء' 
                      : 'Créez votre compte pour commencer',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: colors.onBackground.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // Rest of your form fields remain the same...
                  CustomTextField(
                    controller: _fullNameController,
                    labelText: _selectedLanguage == 'ar' ? 'الاسم الكامل' : 'Nom complet',
                    hintText: _selectedLanguage == 'ar' ? 'أدخل اسمك الكامل' : 'Entrez votre nom complet',
                    prefixIcon: Icons.person_outline,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return _selectedLanguage == 'ar' 
                          ? 'يرجى إدخال اسمك الكامل'
                          : 'Veuillez entrer votre nom complet';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  
                  // Phone number field with updated validation message
                  CustomTextField(
                    controller: _phoneController,
                    labelText: _selectedLanguage == 'ar' ? 'رقم الهاتف' : 'Numéro de téléphone',
                    hintText: _selectedLanguage == 'ar' ? 'أدخل رقم هاتفك' : 'Entrez votre numéro de téléphone',
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return _selectedLanguage == 'ar' 
                          ? 'يرجى إدخال رقم هاتفك'
                          : 'Veuillez entrer votre numéro de téléphone';
                      }
                      // Updated validation for Chinguisoft requirements
                      final phoneRegExp = RegExp(r'^[234]\d{7}$');
                      if (!phoneRegExp.hasMatch(value)) {
                        return _selectedLanguage == 'ar' 
                          ? 'يجب أن يبدأ الرقم بـ 2 أو 3 أو 4 ويحتوي على 8 أرقام'
                          : 'Le numéro doit commencer par 2, 3 ou 4 et contenir 8 chiffres';
                      }
                      return null;
                    },
                  ),
                  
                  // Continue with the rest of your existing form fields...
                  // (NNI, Municipality dropdown, Password fields)
                  // Just update the text labels based on _selectedLanguage
                  
                  const SizedBox(height: 20),
                  CustomTextField(
                    controller: _nniController,
                    labelText: _selectedLanguage == 'ar' ? 'رقم البطاقة الوطنية' : 'NNI',
                    hintText: _selectedLanguage == 'ar' ? 'أدخل رقم بطاقتك الوطنية' : 'Entrez votre NNI',
                    prefixIcon: Icons.credit_card,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return _selectedLanguage == 'ar' 
                          ? 'يرجى إدخال رقم البطاقة الوطنية'
                          : 'Veuillez entrer votre NNI';
                      }
                       final phoneRegExp = RegExp(r'^\d{10}$');
                      if (!phoneRegExp.hasMatch(value)) {
                        return _selectedLanguage == 'ar' 
                          ? 'يجب أن يحتوي رقم البطاقة على 10 أرقام بالضبط'
                          : 'La NNI doit contenir exactement 10 chiffres';
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
                    child: Text(
                      _selectedLanguage == 'ar' ? 'التسجيل' : 'S\'inscrire',
                      style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold)
                    ),
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

// *** UPDATED: Helper function with language support ***
Future<bool> _sendVerificationCode(String phoneNumber, String language) async {
  print('Attempting to send verification code to $phoneNumber in $language...');
  try {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/api/send-code/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'phone_number': phoneNumber,
        'language': language, // Pass language preference to backend
      }),
    );

    if (response.statusCode == 200) {
      print('Verification code sent successfully via Chinguisoft API.');
      return true;
    } else {
      final responseBody = jsonDecode(response.body);
      print('Failed to send verification code. Status: ${response.statusCode}, Body: ${response.body}');
      return false;
    }
  } catch (e) {
    print('Exception caught sending verification code: $e');
    return false;
  }
}