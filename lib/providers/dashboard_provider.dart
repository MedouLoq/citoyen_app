// lib/providers/dashboard_provider.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart' show ChangeNotifier, kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // For web storage
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // For native storage

class DashboardProvider with ChangeNotifier {
  String _userName = 'Utilisateur';
  String get userName => _userName;

  String _municipality = 'Municipalité';
  String get municipality => _municipality;

  int _problemCount = 0;
  int get problemCount => _problemCount;

  int _pendingProblems = 0;
  int get pendingProblems => _pendingProblems;

  int _complaintCount = 0;
  int get complaintCount => _complaintCount;

  int _resolvedProblems = 0;
  int get resolvedProblems => _resolvedProblems;

  List<Map<String, dynamic>> _recentActivity = [];
  List<Map<String, dynamic>> get recentActivity => _recentActivity;

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

  Future<void> fetchData(BuildContext context) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    const String baseUrl =
        'http://192.168.151.228:8000'; // Replace with your base URL

    final token = await _getToken(); // Use helper function to get token

    if (token == null) {
      _errorMessage = "Not authenticated";
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      // Helper function to make API requests with token
      Future<dynamic> _apiCall(String endpoint) async {
        try {
          final response = await http.get(
            Uri.parse('$baseUrl$endpoint'),
            headers: {
              'Authorization': 'Token $token',
              'Content-Type': 'application/json',
            },
          ).timeout(const Duration(seconds: 10));

          if (response.statusCode == 200) {
            return jsonDecode(response.body);
          } else {
            throw Exception(
                'Failed to fetch $endpoint: Status code ${response.statusCode}, Body: ${response.body}');
          }
        } on TimeoutException catch (e) {
          throw Exception('Timeout fetching $endpoint: $e');
        } catch (e) {
          throw Exception('Error fetching $endpoint: $e');
        }
      }

      const String API_BASE_URL = "http://192.168.151.228:8000";
      const String PROFILE_URL = "$API_BASE_URL/api/profile/";
      // Fetch user profile
// Add this debug code in your Flutter app
      final profileData = await _apiCall('/api/profile/');

// Debug: Print the entire response to see the structure
      print('=== PROFILE DATA DEBUG ===');
      print('Full response: ${json.encode(profileData)}');
      print('Keys available: ${profileData.keys.toList()}');
      print(
          'citizen_profile exists: ${profileData.containsKey('citizen_profile')}');
      if (profileData.containsKey('citizen_profile')) {
        print('citizen_profile content: ${profileData['citizen_profile']}');
        if (profileData['citizen_profile'] != null) {
          print(
              'citizen_profile keys: ${profileData['citizen_profile'].keys.toList()}');
        }
      }
      print('=== END DEBUG ===');

// Your existing code
      _userName = profileData['citizen_profile']?['full_name'] ??
          profileData['username'] ??
          'Utilisateur';
      _municipality = profileData['citizen_profile']?['municipality']
              ?['name'] ??
          'Unknown Municipality';
      // Fetch dashboard stats
      final statsData = await _apiCall('/api/dashboard/stats/');
      _problemCount = statsData['problem_count'] ?? 0;
      _pendingProblems = statsData['pending_problems'] ?? 0;
      _complaintCount = statsData['complaint_count'] ?? 0;
      _resolvedProblems = statsData['resolved_problems'] ?? 0;

      // Fetch recent activity
      final activityData = await _apiCall('/api/dashboard/activity/');
      _recentActivity = List<Map<String, dynamic>>.from(activityData);
    } catch (error) {
      print('Error fetching dashboard data: $error');
      _errorMessage = 'Failed to load data: $error';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
