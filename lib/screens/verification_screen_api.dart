// ============================================================================
// 2. UPDATED VERIFICATION SCREEN (Arabic/French)
// ============================================================================
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'auth/auth_screen.dart';

class VerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String language; // Add language parameter
  final String baseUrl = "http://192.168.137.1:8000/api";

  const VerificationScreen({
    Key? key,
    required this.phoneNumber,
    this.language = 'ar', // Default to Arabic
  }) : super(key: key);

  @override
  _VerificationScreenState createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _isResending = false;

  // Localized text helper
  String _getText(String arText, String frText) {
    return widget.language == 'ar' ? arText : frText;
  }

  Future<void> _verifyCode() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final response = await http.post(
          Uri.parse('${widget.baseUrl}/verify-code/'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'phone_number': widget.phoneNumber,
            'code': _codeController.text,
            'language': widget.language, // Pass language to backend
          }),
        );

        final responseBody = jsonDecode(response.body);

        if (response.statusCode == 200) {
          print('Verification successful: ${responseBody['message']}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(responseBody['message'] ??
                    _getText('تم التحقق بنجاح!', 'Vérification réussie!'))),
          );
          await Future.delayed(const Duration(seconds: 1));
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const AuthScreen()),
            );
          }
        } else {
          setState(() {
            _errorMessage = responseBody['error'] ??
                _getText('فشل التحقق. يرجى المحاولة مرة أخرى.',
                    'Échec de la vérification. Veuillez réessayer.');
          });
        }
      } catch (e) {
        print('Error verifying code: $e');
        setState(() {
          _errorMessage = _getText(
              'حدث خطأ. يرجى التحقق من اتصالك والمحاولة مرة أخرى.',
              'Une erreur s\'est produite. Veuillez vérifier votre connexion et réessayer.');
        });
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _resendCode() async {
    setState(() {
      _isResending = true;
      _errorMessage = null;
    });

    try {
      final response = await http.post(
        Uri.parse('${widget.baseUrl}/send-verification-code/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'phone_number': widget.phoneNumber,
          'language': widget.language, // Pass language to backend
        }),
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(responseBody['message'] ??
                  _getText('تم إعادة إرسال رمز التحقق.',
                      'Code de vérification renvoyé.'))),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(responseBody['error'] ??
                  _getText('فشل في إعادة إرسال الرمز.',
                      'Échec du renvoi du code.'))),
        );
      }
    } catch (e) {
      print('Error resending code: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(_getText('حدث خطأ أثناء إعادة إرسال الرمز.',
                'Une erreur s\'est produite lors du renvoi du code.'))),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            _getText('تحقق من رقم الهاتف', 'Vérifier le numéro de téléphone')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                _getText('أدخل رمز التحقق المرسل إلى ${widget.phoneNumber}',
                    'Entrez le code de vérification envoyé au ${widget.phoneNumber}'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _codeController,
                decoration: InputDecoration(
                  labelText: _getText('رمز التحقق', 'Code de vérification'),
                  border: const OutlineInputBorder(),
                  hintText: _getText('أدخل الرمز المكون من 6 أرقام',
                      'Entrez le code à 6 chiffres'),
                  counterText: "",
                ),
                keyboardType: TextInputType.number,
                maxLength: 6,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return _getText(
                        'يرجى إدخال الرمز', 'Veuillez entrer le code');
                  }
                  if (value.length != 6) {
                    return _getText('يجب أن يكون الرمز 6 أرقام',
                        'Le code doit contenir 6 chiffres');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _verifyCode,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                      ),
                      child: Text(_getText('تحقق', 'Vérifier')),
                    ),
              const SizedBox(height: 15),
              _isResending
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : TextButton(
                      onPressed: _isLoading ? null : _resendCode,
                      child: Text(
                          _getText('إعادة إرسال الرمز', 'Renvoyer le code')),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
