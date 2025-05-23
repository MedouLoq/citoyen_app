import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'auth/login_screen.dart';
// TODO: Add http package to your pubspec.yaml: dependencies:
//   http: ^1.0.0 // Use the latest version

class VerificationScreen extends StatefulWidget {
  final String phoneNumber;
  // TODO: Replace with your actual backend base URL
  final String baseUrl = "http://10.0.2.2:8000/api"; 

  const VerificationScreen({
    Key? key,
    required this.phoneNumber,
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

  // Function to call the verify code endpoint
  Future<void> _verifyCode() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final response = await http.post(
          Uri.parse('${widget.baseUrl}/verify-code/'), // Ensure trailing slash if needed by Django URL config
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'phone_number': widget.phoneNumber,
            'code': _codeController.text,
          }),
        );

        final responseBody = jsonDecode(response.body);

        if (response.statusCode == 200) {
          // Verification successful
          print('Verification successful: ${responseBody['message']}');
          // TODO: Navigate to the next screen (e.g., home screen)
          // Navigator.of(context).pushReplacement(/* ... */);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseBody['message'] ?? 'Verification successful!')),
          );
          // Example: Navigate back or to home screen after a short delay
          await Future.delayed(const Duration(seconds: 1));
          if (mounted) {
             Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          }

        } else {
          // Verification failed
          setState(() {
            _errorMessage = responseBody['error'] ?? 'Verification failed. Please try again.';
          });
        }
      } catch (e) {
        // Handle network errors or other exceptions
        print('Error verifying code: $e');
        setState(() {
          _errorMessage = 'An error occurred. Please check your connection and try again.';
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

  // Function to call the send verification code endpoint
  Future<void> _resendCode() async {
    setState(() {
      _isResending = true; // Use a separate flag for resend loading state
      _errorMessage = null;
    });

    try {
      final response = await http.post(
        Uri.parse('${widget.baseUrl}/send-verification-code/'), // Ensure trailing slash if needed
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'phone_number': widget.phoneNumber,
        }),
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Code resent successfully
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseBody['message'] ?? 'Verification code resent.')),
        );
      } else {
        // Failed to resend code
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseBody['error'] ?? 'Failed to resend code.')),
        );
      }
    } catch (e) {
      // Handle network errors or other exceptions
      print('Error resending code: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred while resending the code.')),
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
        title: const Text('Verify Phone Number'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Enter the verification code sent to ${widget.phoneNumber}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(
                  labelText: 'Verification Code',
                  border: OutlineInputBorder(),
                  hintText: 'Enter 6-digit code', // Assuming 6 digits based on Django backend
                  counterText: "", // Hide the default counter
                ),
                keyboardType: TextInputType.number,
                maxLength: 6, // Match backend expectation if fixed length
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the code';
                  }
                  // Add more specific validation if needed (e.g., exactly 6 digits)
                  if (value.length != 6) { 
                    return 'Code must be 6 digits';
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
                      child: const Text('Verify'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                      ),
                    ),
              const SizedBox(height: 15),
              _isResending
                  ? const SizedBox(
                      height: 24, // Match TextButton height approximately
                      width: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : TextButton(
                      onPressed: _isLoading ? null : _resendCode, // Disable while verifying
                      child: const Text('Resend Code'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

