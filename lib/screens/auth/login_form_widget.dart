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

class LoginFormWidget extends StatefulWidget {
  final String language;

  const LoginFormWidget({
    Key? key,
    required this.language,
  }) : super(key: key);

  @override
  State<LoginFormWidget> createState() => _LoginFormWidgetState();
}

class _LoginFormWidgetState extends State<LoginFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
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

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      const String apiUrl = 'http://10.0.2.2:8000/api/login/';

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

          await _storeToken(token);

          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const DashboardScreen()),
            );
          }
        } else {
          String errorMessage = 'خطأ في تسجيل الدخول';
          if (response.statusCode == 400) {
            final responseData = jsonDecode(response.body);
            if (responseData.containsKey('errors')) {
              errorMessage = 'يرجى تصحيح الأخطاء';
            } else if (responseData.containsKey('error')) {
              errorMessage = responseData['error'];
            }
          } else if (response.statusCode == 401) {
            errorMessage = 'اسم المستخدم أو كلمة المرور غير صحيحة';
          } else {
            errorMessage = 'خطأ في الاتصال. الرمز: ${response.statusCode}';
          }
          if (mounted) {
            _showSnackBar(errorMessage);
          }
        }
      } catch (error) {
        String errorMessage = 'خطأ في الاتصال. يرجى التحقق من اتصال الإنترنت.';
        if (error is FormatException) {
          errorMessage = 'خطأ في تنسيق استجابة الخادم';
        } else if (error is http.ClientException) {
          errorMessage = 'خطأ في التواصل مع الخادم';
        } else if (error is TimeoutException) {
          errorMessage = 'انتهت مهلة الانتظار. يرجى التحقق من الاتصال.';
        }
        print('Error during login: $error');
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
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade400,
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
            'مرحباً بك!',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: colors.onBackground,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'سجل دخولك للمتابعة',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: colors.onBackground.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 40),

          // Username/Phone Field
          CustomTextField(
            controller: _identifierController,
            labelText: 'اسم المستخدم',
            hintText: 'أدخل رقم الهاتف أو البريد الإلكتروني',
            prefixIcon: Icons.person_outline,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'يرجى إدخال اسم المستخدم';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Password Field
          CustomTextField(
            controller: _passwordController,
            labelText: 'كلمة المرور',
            hintText: 'أدخل كلمة المرور',
            prefixIcon: Icons.lock_outline,
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'يرجى إدخال كلمة المرور';
              }
              if (value.length < 4) {
                return 'كلمة المرور يجب أن تحتوي على 4 أحرف على الأقل';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),

          // Forgot Password
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                // TODO: Navigate to Forgot Password screen
                print('Forgot Password tapped');
              },
              child: Text(
                'نسيت كلمة المرور؟',
                style: GoogleFonts.inter(
                  color: const Color.fromARGB(255, 4, 77, 234),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),

          // Login Button
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
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 4, 77, 234),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: Text(
                      'تسجيل الدخول',
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
