// lib/providers/problem_provider.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ProblemProvider with ChangeNotifier {
  List<Map<String, dynamic>> _problems = [];
  List<Map<String, dynamic>> get problems => _problems;

  Map<String, dynamic>? _selectedProblem;
  Map<String, dynamic>? get selectedProblem => _selectedProblem;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  // Helper function to read the token securely
  Future<String?> _getToken() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('auth_token');
    } else {
      const storage = FlutterSecureStorage();
      return storage.read(key: 'auth_token');
    }
  }

  Future<void> fetchProblems() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    const String baseUrl =
        'https://belediyti.pythonanywhere.com'; // Replace with your base URL

    final token = await _getToken();

    if (token == null) {
      _errorMessage = "Not authenticated";
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/problems/'),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _problems = List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception(
            'Failed to fetch problems: Status code ${response.statusCode}');
      }
    } catch (e) {
      _errorMessage = 'Failed to load problems: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  int get totalProblemCount => _problems.length;
// Update the fetchProblemDetail method in your ProblemProvider class
  Future<void> fetchProblemDetail(String id) async {
    _isLoading = true;
    _errorMessage = '';
    _selectedProblem = null;
    notifyListeners();

    const String baseUrl =
        'https://belediyti.pythonanywhere.com'; // Replace with your base URL

    final token = await _getToken();

    if (token == null) {
      _errorMessage = "Not authenticated";
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/problems/$id/'),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _selectedProblem = data;
      } else {
        throw Exception(
            'Failed to fetch problem detail: Status code ${response.statusCode}');
      }
    } catch (e) {
      _errorMessage = 'Failed to load problem detail: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> reportProblem({
    required String description,
    required double latitude,
    required double longitude,
    required String categoryId,
    String? municipalityId,
    String? imagePath,
  }) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    const String baseUrl =
        'https://belediyti.pythonanywhere.com'; // Replace with your base URL

    final token = await _getToken();

    if (token == null) {
      _errorMessage = "Not authenticated";
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': 'Not authenticated'};
    }

    try {
      // Create multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/problems/report/'),
      );

      // Add headers
      request.headers.addAll({
        'Authorization': 'Token $token',
      });

      // Add text fields
      request.fields['description'] = description;
      request.fields['latitude'] = latitude.toString();
      request.fields['longitude'] = longitude.toString();
      request.fields['category'] = categoryId;

      if (municipalityId != null) {
        request.fields['municipality'] = municipalityId;
      }

      // Add image if provided
      if (imagePath != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          imagePath,
        ));
      }

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        // Refresh problem list after successful report
        fetchProblems();
        return {'success': true, 'data': data};
      } else {
        throw Exception(
            'Failed to report problem: Status code ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      _errorMessage = 'Failed to report problem: $e';
      return {'success': false, 'message': _errorMessage};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
