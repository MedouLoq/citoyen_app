import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:citoyen_app/screens/dashboard_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:citoyen_app/widgets/custom_text_field.dart';
import 'package:citoyen_app/screens/verification_screen_api.dart';
import 'package:dropdown_search/dropdown_search.dart';

class AuthScreen extends StatefulWidget {
  final String selectedLanguage;

  const AuthScreen({Key? key, required this.selectedLanguage})
      : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  late String _selectedLanguage;
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  Map<String, dynamic>? _selectedMunicipality;

  bool _isLoading = false;

  // Login form controllers
  final _loginFormKey = GlobalKey<FormState>();
  final _loginIdentifierController = TextEditingController();
  final _loginPasswordController = TextEditingController();

  // Register form controllers
  final _registerFormKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nniController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _selectedMunicipalityId;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = widget.selectedLanguage;
    _tabController = TabController(length: 2, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _animationController.reset();
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    _loginIdentifierController.dispose();
    _loginPasswordController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _nniController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Store token function
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
    if (_loginFormKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      const String apiUrl = 'http://192.168.151.228:8000/api/login/';

      try {
        final response = await http
            .post(
              Uri.parse(apiUrl),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'identifier': _loginIdentifierController.text,
                'password': _loginPasswordController.text,
              }),
            )
            .timeout(const Duration(seconds: 12));

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          final token = responseData['token'];

          await _storeToken(token);

          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const DashboardScreen()),
            );
          }
        } else {
          String errorMessage = _selectedLanguage == 'ar'
              ? 'خطأ في تسجيل الدخول'
              : 'Erreur de connexion';
          if (response.statusCode == 400) {
            final responseData = jsonDecode(response.body);
            if (responseData.containsKey('errors')) {
              errorMessage = _selectedLanguage == 'ar'
                  ? 'يرجى تصحيح الأخطاء'
                  : 'Veuillez corriger les erreurs';
            } else if (responseData.containsKey('error')) {
              errorMessage = responseData['error'];
            }
          } else if (response.statusCode == 401) {
            errorMessage = _selectedLanguage == 'ar'
                ? 'اسم المستخدم أو كلمة المرور غير صحيحة'
                : 'Identifiant ou mot de passe incorrect';
          } else {
            errorMessage = _selectedLanguage == 'ar'
                ? 'خطأ في الاتصال. الرمز: ${response.statusCode}'
                : 'Erreur de connexion. Code: ${response.statusCode}';
          }
          if (mounted) {
            _showSnackBar(errorMessage);
          }
        }
      } catch (error) {
        String errorMessage = _selectedLanguage == 'ar'
            ? 'خطأ في الاتصال. يرجى التحقق من اتصال الإنترنت.'
            : 'Erreur de connexion. Veuillez vérifier votre connexion Internet.';
        if (error is FormatException) {
          errorMessage = _selectedLanguage == 'ar'
              ? 'خطأ في تنسيق استجابة الخادم'
              : 'Erreur de format de réponse du serveur';
        } else if (error is http.ClientException) {
          errorMessage = _selectedLanguage == 'ar'
              ? 'خطأ في التواصل مع الخادم'
              : 'Erreur lors de la communication avec le serveur';
        } else if (error is TimeoutException) {
          errorMessage = _selectedLanguage == 'ar'
              ? 'انتهت مهلة الانتظار. يرجى التحقق من الاتصال.'
              : "Délai d'attente dépassé. Veuillez vérifier votre connexion.";
        }
        print('Error during login: $error');
        if (mounted) {
          _showSnackBar(errorMessage);
        }
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Send verification code function
  Future<bool> _sendVerificationCode(
      String phoneNumber, String language) async {
    try {
      final response = await http
          .post(
            Uri.parse('http://192.168.151.228:8000/api/send-code/'),
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

  // Register function
  Future<void> _register() async {
    if (_registerFormKey.currentState!.validate() &&
        _selectedMunicipalityId != null) {
      setState(() {
        _isLoading = true;
      });

      const String apiUrl = 'http://192.168.151.228:8000/api/register/';

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
              await _sendVerificationCode(phoneNumber, _selectedLanguage);

          if (codeSent && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(_selectedLanguage == 'ar'
                      ? 'تم إنشاء الحساب بنجاح! تم إرسال رمز التحقق.'
                      : 'Inscription réussie! Code de vérification envoyé.')),
            );
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                  builder: (context) => VerificationScreen(
                        phoneNumber: phoneNumber,
                        language: _selectedLanguage,
                      )),
            );
          } else if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(_selectedLanguage == 'ar'
                      ? 'تم إنشاء الحساب، لكن فشل في إرسال الرمز. يرجى المحاولة مرة أخرى.'
                      : 'Inscription réussie, mais échec de l\'envoi du code. Veuillez réessayer.')),
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
            _showSnackBar(errorMessage);
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
        } else if (error is http.ClientException) {
          errorMessage = _selectedLanguage == 'ar'
              ? 'خطأ في التواصل مع الخادم'
              : 'Erreur lors de la communication avec le serveur';
        } else if (error is TimeoutException) {
          errorMessage = _selectedLanguage == 'ar'
              ? 'انتهت مهلة الانتظار. يرجى التحقق من الاتصال.'
              : "Délai d'attente dépassé. Veuillez vérifier votre connexion.";
        }
        print('Error during registration: $error');
        if (mounted) {
          _showSnackBar(errorMessage);
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
      if (_selectedMunicipality == null && mounted) {
        _showSnackBar(errorMessage);
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isRTL = _selectedLanguage == 'ar';

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Directionality(
          textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
          child: Column(
            children: [
              // Header with app title and language toggle
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedLanguage == 'ar'
                          ? 'المصادقة'
                          : 'Authentification',
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(
                            255, 4, 77, 234), // Green color from image
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedLanguage =
                              _selectedLanguage == 'ar' ? 'fr' : 'ar';
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 4, 77, 234)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: const Color.fromARGB(255, 4, 77, 234)),
                        ),
                        child: Text(
                          _selectedLanguage == 'ar' ? 'FR' : 'AR',
                          style: GoogleFonts.inter(
                            color: const Color.fromARGB(255, 4, 77, 234),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Beautiful animated tab switcher
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24.0),
                decoration: BoxDecoration(
                  color:
                      const Color.fromARGB(255, 4, 77, 234), // Green background
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorPadding: const EdgeInsets.all(4),
                  labelColor: const Color.fromARGB(255, 4, 77, 234),
                  unselectedLabelColor: Colors.white,
                  labelStyle: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  unselectedLabelStyle: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                  tabs: [
                    Tab(
                      text: _selectedLanguage == 'ar'
                          ? 'تسجيل الدخول'
                          : 'Se connecter',
                    ),
                    Tab(
                      text: _selectedLanguage == 'ar'
                          ? 'إنشاء حساب'
                          : 'S\'inscrire',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Tab content with animation
              Expanded(
                child: AnimatedBuilder(
                  animation: _fadeAnimation,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.1, 0),
                          end: Offset.zero,
                        ).animate(_slideAnimation),
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildLoginForm(colors),
                            _buildRegisterForm(colors),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm(ColorScheme colors) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Form(
        key: _loginFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _selectedLanguage == 'ar' ? 'تسجيل الدخول' : 'Connexion',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 4, 77, 234),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedLanguage == 'ar'
                  ? 'أدخل بياناتك للمتابعة'
                  : 'Entrez vos informations pour continuer',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: colors.onBackground.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 40),
            CustomTextField(
              controller: _loginIdentifierController,
              labelText: _selectedLanguage == 'ar'
                  ? 'رقم الهاتف'
                  : 'Numéro de téléphone',
              hintText: _selectedLanguage == 'ar'
                  ? 'أدخل رقم الهاتف'
                  : 'Entrez votre numéro de téléphone',
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return _selectedLanguage == 'ar'
                      ? 'يرجى إدخال رقم الهاتف'
                      : 'Veuillez entrer votre numéro de téléphone';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            CustomTextField(
              controller: _loginPasswordController,
              labelText:
                  _selectedLanguage == 'ar' ? 'كلمة المرور' : 'Mot de passe',
              hintText: _selectedLanguage == 'ar'
                  ? 'أدخل كلمة المرور'
                  : 'Entrez votre mot de passe',
              prefixIcon: Icons.lock_outline,
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return _selectedLanguage == 'ar'
                      ? 'يرجى إدخال كلمة المرور'
                      : 'Veuillez entrer votre mot de passe';
                }
                if (value.length < 4) {
                  return _selectedLanguage == 'ar'
                      ? 'يجب أن تحتوي كلمة المرور على 4 أحرف على الأقل'
                      : 'Le mot de passe doit contenir au moins 4 caractères';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            Align(
              alignment: _selectedLanguage == 'ar'
                  ? Alignment.centerLeft
                  : Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // TODO: Navigate to Forgot Password screen
                  print('Forgot Password tapped');
                },
                child: Text(
                  _selectedLanguage == 'ar'
                      ? 'نسيت كلمة المرور؟'
                      : 'Mot de passe oublié?',
                  style: GoogleFonts.inter(
                    color: const Color.fromARGB(255, 4, 77, 234),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          const Color.fromARGB(255, 4, 77, 234)),
                    ),
                  )
                : ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 4, 77, 234),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _selectedLanguage == 'ar'
                          ? 'تسجيل الدخول'
                          : 'Se connecter',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterForm(ColorScheme colors) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Form(
        key: _registerFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _selectedLanguage == 'ar'
                  ? 'إنشاء حساب جديد'
                  : 'Créer un nouveau compte',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 4, 77, 234),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedLanguage == 'ar'
                  ? 'املأ البيانات التالية للتسجيل'
                  : 'Remplissez les informations suivantes pour vous inscrire',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: colors.onBackground.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 40),

            CustomTextField(
              controller: _fullNameController,
              labelText:
                  _selectedLanguage == 'ar' ? 'الاسم الكامل' : 'Nom complet',
              hintText: _selectedLanguage == 'ar'
                  ? 'أدخل اسمك الكامل'
                  : 'Entrez votre nom complet',
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

            CustomTextField(
              controller: _phoneController,
              labelText: _selectedLanguage == 'ar'
                  ? 'رقم الهاتف'
                  : 'Numéro de téléphone',
              hintText: _selectedLanguage == 'ar'
                  ? 'أدخل رقم هاتفك'
                  : 'Entrez votre numéro de téléphone',
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return _selectedLanguage == 'ar'
                      ? 'يرجى إدخال رقم هاتفك'
                      : 'Veuillez entrer votre numéro de téléphone';
                }
                final phoneRegExp = RegExp(r'^[234]\d{7}$');
                if (!phoneRegExp.hasMatch(value)) {
                  return _selectedLanguage == 'ar'
                      ? 'يجب أن يبدأ الرقم بـ 2 أو 3 أو 4 ويحتوي على 8 أرقام'
                      : 'Le numéro doit commencer par 2, 3 ou 4 et contenir 8 chiffres';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            CustomTextField(
              controller: _nniController,
              labelText:
                  _selectedLanguage == 'ar' ? 'رقم البطاقة الوطنية' : 'NNI',
              hintText: _selectedLanguage == 'ar'
                  ? 'أدخل رقم بطاقتك الوطنية'
                  : 'Entrez votre NNI',
              prefixIcon: Icons.credit_card,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return _selectedLanguage == 'ar'
                      ? 'يرجى إدخال رقم البطاقة الوطنية'
                      : 'Veuillez entrer votre NNI';
                }
                final nniRegExp = RegExp(r'^\d{10}$');
                if (!nniRegExp.hasMatch(value)) {
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
              items: (String filter, _) async {
                try {
                  final res = await http
                      .get(Uri.parse(
                          'http://192.168.151.228:8000/api/municipalities/'))
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
                } catch (e) {
                  print('Error loading municipalities: $e');
                }
                return <Map<String, dynamic>>[];
              },
              itemAsString: (item) => item?['name'] ?? '',
              compareFn: (a, b) => a != null && b != null && a['id'] == b['id'],
              selectedItem:
                  _selectedMunicipality, // Use the full object instead of creating a temporary one
              decoratorProps: DropDownDecoratorProps(
                decoration: InputDecoration(
                  labelText:
                      _selectedLanguage == 'ar' ? 'البلدية' : 'Municipalité',
                  hintText: _selectedLanguage == 'ar'
                      ? 'اختر بلديتك'
                      : 'Sélectionnez votre municipalité',
                  labelStyle: GoogleFonts.inter(
                    color: colors.onSurface.withOpacity(0.7),
                  ),
                  hintStyle: GoogleFonts.inter(
                    color: colors.onSurface.withOpacity(0.5),
                  ),
                  prefixIcon: Icon(
                    Icons.location_city,
                    color:
                        const Color.fromARGB(255, 4, 77, 234).withOpacity(0.8),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(
                      color: colors.outline.withOpacity(0.5),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(
                      color: colors.outline.withOpacity(0.5),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(
                      color: const Color.fromARGB(255, 4, 77, 234),
                      width: 2.0,
                    ),
                  ),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _selectedMunicipality = value; // Store the full object
                  _selectedMunicipalityId =
                      value?['id']?.toString(); // Keep the ID for API calls
                });
              },
            ),

            const SizedBox(height: 20),

            CustomTextField(
              controller: _passwordController,
              labelText:
                  _selectedLanguage == 'ar' ? 'كلمة المرور' : 'Mot de passe',
              hintText: _selectedLanguage == 'ar'
                  ? 'أدخل كلمة المرور'
                  : 'Entrez votre mot de passe',
              prefixIcon: Icons.lock_outline,
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return _selectedLanguage == 'ar'
                      ? 'يرجى إدخال كلمة المرور'
                      : 'Veuillez entrer votre mot de passe';
                }
                if (value.length < 6) {
                  return _selectedLanguage == 'ar'
                      ? 'يجب أن تحتوي كلمة المرور على 8 أحرف على الأقل'
                      : 'Le mot de passe doit contenir au moins 8 caractères';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            CustomTextField(
              controller: _confirmPasswordController,
              labelText: _selectedLanguage == 'ar'
                  ? 'تأكيد كلمة المرور'
                  : 'Confirmer le mot de passe',
              hintText: _selectedLanguage == 'ar'
                  ? 'أعد إدخال كلمة المرور'
                  : 'Confirmez votre mot de passe',
              prefixIcon: Icons.lock_outline,
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return _selectedLanguage == 'ar'
                      ? 'يرجى تأكيد كلمة المرور'
                      : 'Veuillez confirmer votre mot de passe';
                }
                if (value != _passwordController.text) {
                  return _selectedLanguage == 'ar'
                      ? 'كلمات المرور غير متطابقة'
                      : 'Les mots de passe ne correspondent pas';
                }
                return null;
              },
            ),
            const SizedBox(height: 30),

            _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          const Color.fromARGB(255, 4, 77, 234)),
                    ),
                  )
                : ElevatedButton(
                    onPressed: _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 4, 77, 234),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _selectedLanguage == 'ar'
                          ? 'إنشاء حساب'
                          : 'Créer un compte',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
