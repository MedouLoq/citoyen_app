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

class RegisterFormWidget extends StatefulWidget {
  final String language;

  const RegisterFormWidget({
    Key? key,
    required this.language,
  }) : super(key: key);

  @override
  State<RegisterFormWidget> createState() => _RegisterFormWidgetState();
}

class _RegisterFormWidgetState extends State<RegisterFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nniController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _selectedMunicipalityId;

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

  Future<bool> _sendVerificationCode(
      String phoneNumber, String language) async {
    try {
      final response = await http
          .post(
            Uri.parse('http://10.0.2.2:8000/api/send_verification_code/'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'phone_number': phoneNumber,
              'language': language,
            }),
          )
          .timeout(const Duration(seconds: 30));

      return response.statusCode == 200;
    } catch (error) {
      print('Error sending verification code: $error');
      return false;
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
          bool codeSent =
              await _sendVerificationCode(phoneNumber, widget.language);

          if (codeSent && mounted) {
            _showSnackBar(
                widget.language == 'ar'
                    ? 'تم إنشاء الحساب بنجاح! تم إرسال رمز التحقق.'
                    : 'Inscription réussie! Code de vérification envoyé.',
                isError: false);
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => VerificationScreen(
                  phoneNumber: phoneNumber,
                  language: widget.language,
                ),
              ),
            );
          } else if (mounted) {
            _showSnackBar(widget.language == 'ar'
                ? 'تم إنشاء الحساب، لكن فشل في إرسال الرمز. يرجى المحاولة مرة أخرى.'
                : 'Inscription réussie, mais échec de l\'envoi du code. Veuillez réessayer.');
          }
        } else {
          String errorMessage = widget.language == 'ar'
              ? 'خطأ في التسجيل'
              : 'Erreur d\'inscription';
          if (response.statusCode == 400) {
            final responseData = jsonDecode(response.body);
            if (responseData.containsKey('errors')) {
              errorMessage = widget.language == 'ar'
                  ? 'يرجى تصحيح الأخطاء'
                  : 'Veuillez corriger les erreurs';
            }
          } else {
            errorMessage = widget.language == 'ar'
                ? 'خطأ في التسجيل. الرمز: ${response.statusCode}'
                : 'Erreur d\'inscription. Code: ${response.statusCode}';
          }
          if (mounted) {
            _showSnackBar(errorMessage);
          }
        }
      } catch (error) {
        String errorMessage = widget.language == 'ar'
            ? 'خطأ في التسجيل. يرجى التحقق من اتصال الإنترنت.'
            : 'Erreur d\'inscription. Veuillez vérifier votre connexion Internet.';
        if (error is FormatException) {
          errorMessage = widget.language == 'ar'
              ? 'خطأ في تنسيق استجابة الخادم'
              : 'Erreur de format de réponse du serveur';
        } else if (error is http.ClientException) {
          errorMessage = widget.language == 'ar'
              ? 'خطأ في التواصل مع الخادم'
              : 'Erreur lors de la communication avec le serveur';
        } else if (error is TimeoutException) {
          errorMessage = widget.language == 'ar'
              ? 'انتهت مهلة الانتظار. يرجى التحقق من الاتصال.'
              : "Délai d'attente dépassé. Veuillez vérifier votre connexion.";
        }
        print('Error during registration: $error');
        if (mounted) {
          _showSnackBar(errorMessage);
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
      if (_selectedMunicipalityId == null && mounted) {
        _showSnackBar(widget.language == 'ar'
            ? 'يرجى اختيار البلدية'
            : 'Veuillez sélectionner la municipalité');
      }
    }
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade400 : Colors.green.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Welcome Text
          Text(
            widget.language == 'ar' ? 'انضم إلينا' : 'Rejoignez-nous',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: colors.onBackground,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.language == 'ar'
                ? 'أنشئ حسابك للبدء'
                : 'Créez votre compte pour commencer',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: colors.onBackground.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 30),

          // Full Name Field
          CustomTextField(
            controller: _fullNameController,
            labelText: widget.language == 'ar' ? 'الاسم الكامل' : 'Nom complet',
            hintText: widget.language == 'ar'
                ? 'أدخل اسمك الكامل'
                : 'Entrez votre nom complet',
            prefixIcon: Icons.person_outline,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return widget.language == 'ar'
                    ? 'يرجى إدخال اسمك الكامل'
                    : 'Veuillez entrer votre nom complet';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Phone Number Field
          CustomTextField(
            controller: _phoneController,
            labelText:
                widget.language == 'ar' ? 'رقم الهاتف' : 'Numéro de téléphone',
            hintText: widget.language == 'ar'
                ? 'أدخل رقم هاتفك'
                : 'Entrez votre numéro de téléphone',
            prefixIcon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return widget.language == 'ar'
                    ? 'يرجى إدخال رقم هاتفك'
                    : 'Veuillez entrer votre numéro de téléphone';
              }
              final phoneRegExp = RegExp(r'^[234]\d{7}$');
              if (!phoneRegExp.hasMatch(value)) {
                return widget.language == 'ar'
                    ? 'يجب أن يبدأ الرقم بـ 2 أو 3 أو 4 ويحتوي على 8 أرقام'
                    : 'Le numéro doit commencer par 2, 3 ou 4 et contenir 8 chiffres';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // NNI Field
          CustomTextField(
            controller: _nniController,
            labelText: widget.language == 'ar' ? 'رقم البطاقة الوطنية' : 'NNI',
            hintText: widget.language == 'ar'
                ? 'أدخل رقم بطاقتك الوطنية'
                : 'Entrez votre NNI',
            prefixIcon: Icons.credit_card,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return widget.language == 'ar'
                    ? 'يرجى إدخال رقم البطاقة الوطنية'
                    : 'Veuillez entrer votre NNI';
              }
              final nniRegExp = RegExp(r'^\d{10}$');
              if (!nniRegExp.hasMatch(value)) {
                return widget.language == 'ar'
                    ? 'يجب أن يحتوي رقم البطاقة على 10 أرقام بالضبط'
                    : 'La NNI doit contenir exactement 10 chiffres';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Municipality Dropdown (Simplified for this example)
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: colors.outline),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonFormField<String>(
              value: _selectedMunicipalityId,
              decoration: InputDecoration(
                labelText: widget.language == 'ar' ? 'البلدية' : 'Municipalité',
                hintText: widget.language == 'ar'
                    ? 'اختر بلديتك'
                    : 'Sélectionnez votre municipalité',
                prefixIcon: Icon(Icons.location_city, color: colors.primary),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              items: widget.language == 'ar'
                  ? const [
                      DropdownMenuItem(value: '1', child: Text('نواكشوط')),
                      DropdownMenuItem(value: '2', child: Text('نواذيبو')),
                      DropdownMenuItem(value: '3', child: Text('روصو')),
                    ]
                  : const [
                      DropdownMenuItem(value: '1', child: Text('Nouakchott')),
                      DropdownMenuItem(value: '2', child: Text('Nouadhibou')),
                      DropdownMenuItem(value: '3', child: Text('Rosso')),
                    ],
              onChanged: (value) {
                setState(() {
                  _selectedMunicipalityId = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return widget.language == 'ar'
                      ? 'يرجى اختيار البلدية'
                      : 'Veuillez sélectionner la municipalité';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 16),

          // Password Field
          CustomTextField(
            controller: _passwordController,
            labelText: widget.language == 'ar' ? 'كلمة المرور' : 'Mot de passe',
            hintText: widget.language == 'ar'
                ? 'أدخل كلمة المرور'
                : 'Entrez votre mot de passe',
            prefixIcon: Icons.lock_outline,
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return widget.language == 'ar'
                    ? 'يرجى إدخال كلمة المرور'
                    : 'Veuillez entrer votre mot de passe';
              }
              if (value.length < 6) {
                return widget.language == 'ar'
                    ? 'كلمة المرور يجب أن تحتوي على 6 أحرف على الأقل'
                    : 'Le mot de passe doit contenir au moins 6 caractères';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Confirm Password Field
          CustomTextField(
            controller: _confirmPasswordController,
            labelText: widget.language == 'ar'
                ? 'تأكيد كلمة المرور'
                : 'Confirmer le mot de passe',
            hintText: widget.language == 'ar'
                ? 'أعد إدخال كلمة المرور'
                : 'Confirmez votre mot de passe',
            prefixIcon: Icons.lock_outline,
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return widget.language == 'ar'
                    ? 'يرجى تأكيد كلمة المرور'
                    : 'Veuillez confirmer votre mot de passe';
              }
              if (value != _passwordController.text) {
                return widget.language == 'ar'
                    ? 'كلمات المرور غير متطابقة'
                    : 'Les mots de passe ne correspondent pas';
              }
              return null;
            },
          ),
          const SizedBox(height: 30),

          // Register Button
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 50,
            child: _isLoading
                ? Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 4, 77, 234)
                          .withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                  )
                : ElevatedButton(
                    onPressed: _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 4, 77, 234),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: Text(
                      widget.language == 'ar'
                          ? 'إنشاء الحساب'
                          : 'Créer le compte',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
