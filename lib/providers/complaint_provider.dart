// lib/providers/complaint_provider.dart - Authentication Fix
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ComplaintProvider with ChangeNotifier {
  // Base URL for API calls
  static const String _baseUrl = "http://192.168.185.228:8000";

  // State variables
  List<Map<String, dynamic>> _complaints = [];
  Map<String, dynamic>? _selectedComplaint;
  bool _isLoading = false;
  String _errorMessage = '';

  // Getters
  List<Map<String, dynamic>> get complaints => _complaints;
  Map<String, dynamic>? get selectedComplaint => _selectedComplaint;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // Get authentication token
  Future<String?> _getAuthToken() async {
    String? token;
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      token = prefs.getString('auth_token');
    } else {
      const storage = FlutterSecureStorage();
      token = await storage.read(key: 'auth_token');
    }
    return token;
  }

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Set error message
  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  // Clear error message
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  // Fetch all complaints for the authenticated user
  Future<void> fetchComplaints() async {
    _setLoading(true);
    _setError('');

    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('Token d\'authentification manquant');
      }

      final response = await http.get(
        Uri.parse("$_baseUrl/api/complaints/"),
        headers: {
          'Authorization':
              'Token $token', // FIXED: Changed from 'Bearer' to 'Token'
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Handle both paginated and non-paginated responses
        if (data is Map && data.containsKey('results')) {
          _complaints = List<Map<String, dynamic>>.from(data['results']);
        } else if (data is List) {
          _complaints = List<Map<String, dynamic>>.from(data);
        } else {
          throw Exception('Format de réponse inattendu');
        }

        _setError('');
      } else if (response.statusCode == 401) {
        throw Exception('Session expirée. Veuillez vous reconnecter.');
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['detail'] ?? 'Erreur ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching complaints: $e");
      _setError(e.toString());
      _complaints = []; // Clear complaints on error
    } finally {
      _setLoading(false);
    }
  }

  // Fetch details for a specific complaint
  Future<void> fetchComplaintDetail(String complaintId) async {
    _setLoading(true);
    _setError('');

    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('Token d\'authentification manquant');
      }

      final response = await http.get(
        Uri.parse("$_baseUrl/api/complaints/$complaintId/"),
        headers: {
          'Authorization':
              'Token $token', // FIXED: Changed from 'Bearer' to 'Token'
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _selectedComplaint = data;
        _setError('');
      } else if (response.statusCode == 401) {
        throw Exception('Session expirée. Veuillez vous reconnecter.');
      } else if (response.statusCode == 404) {
        throw Exception('Réclamation non trouvée');
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['detail'] ?? 'Erreur ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching complaint detail: $e");
      _setError(e.toString());
      _selectedComplaint = null;
    } finally {
      _setLoading(false);
    }
  }

  // Submit a new complaint
  Future<bool> submitComplaint({
    required String subject,
    required String description,
    String? municipalityId,
    String? photoPath,
    String? videoPath,
    String? voiceRecordPath,
    String? evidencePath,
  }) async {
    _setLoading(true);
    _setError('');

    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('Token d\'authentification manquant');
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse("$_baseUrl/api/complaints/submit/"),
      );

      // Add headers - FIXED: Changed from 'Bearer' to 'Token'
      request.headers['Authorization'] = 'Token $token';

      // Add form fields
      request.fields['subject'] = subject;
      request.fields['description'] = description;
      if (municipalityId != null) {
        request.fields['municipality'] = municipalityId;
      }

      // Add files if provided
      if (photoPath != null) {
        request.files
            .add(await http.MultipartFile.fromPath('photo', photoPath));
      }
      if (videoPath != null) {
        request.files
            .add(await http.MultipartFile.fromPath('video', videoPath));
      }
      if (voiceRecordPath != null) {
        request.files.add(
            await http.MultipartFile.fromPath('voice_record', voiceRecordPath));
      }
      if (evidencePath != null) {
        request.files.add(await http.MultipartFile.fromPath(
            'evidence', evidencePath)); // Changed 'document' to 'evidence'
      }

      final response =
          await request.send().timeout(const Duration(seconds: 60));
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        // Successfully submitted, refresh the complaints list
        await fetchComplaints();
        _setError('');
        return true;
      } else if (response.statusCode == 401) {
        throw Exception('Session expirée. Veuillez vous reconnecter.');
      } else {
        final errorData = jsonDecode(responseBody);
        throw Exception(errorData['detail'] ?? 'Erreur ${response.statusCode}');
      }
    } catch (e) {
      print("Error submitting complaint: $e");
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get complaints by status
  List<Map<String, dynamic>> getComplaintsByStatus(String status) {
    if (status == 'ALL') {
      return _complaints;
    }
    return _complaints
        .where((complaint) => complaint['status'] == status)
        .toList();
  }

  // Get complaint count by status
  int getComplaintCountByStatus(String status) {
    return getComplaintsByStatus(status).length;
  }

  // Get total complaints count
  int get totalComplaintsCount => _complaints.length;

  // Get complaints statistics
  Map<String, int> get complaintsStats {
    final stats = <String, int>{
      'PENDING': 0,
      'REVIEWING': 0,
      'RESOLVED': 0,
      'REJECTED': 0,
    };

    for (final complaint in _complaints) {
      final status = complaint['status'] as String?;
      if (status != null && stats.containsKey(status)) {
        stats[status] = stats[status]! + 1;
      }
    }

    return stats;
  }

  // Search complaints by subject or description
  List<Map<String, dynamic>> searchComplaints(String query) {
    if (query.isEmpty) return _complaints;

    final lowercaseQuery = query.toLowerCase();
    return _complaints.where((complaint) {
      final subject = (complaint['subject'] as String?)?.toLowerCase() ?? '';
      final description =
          (complaint['description'] as String?)?.toLowerCase() ?? '';
      return subject.contains(lowercaseQuery) ||
          description.contains(lowercaseQuery);
    }).toList();
  }

  // Filter complaints by date range
  List<Map<String, dynamic>> filterComplaintsByDateRange(
      DateTime startDate, DateTime endDate) {
    return _complaints.where((complaint) {
      try {
        final createdAt = DateTime.parse(complaint['created_at']);
        return createdAt.isAfter(startDate.subtract(const Duration(days: 1))) &&
            createdAt.isBefore(endDate.add(const Duration(days: 1)));
      } catch (e) {
        return false;
      }
    }).toList();
  }

  // Get recent complaints (last 7 days)
  List<Map<String, dynamic>> get recentComplaints {
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    return filterComplaintsByDateRange(sevenDaysAgo, DateTime.now());
  }

  // Clear selected complaint
  void clearSelectedComplaint() {
    _selectedComplaint = null;
    notifyListeners();
  }

  // Refresh complaints (alias for fetchComplaints)
  Future<void> refreshComplaints() async {
    await fetchComplaints();
  }

  // Update complaint in local list after receiving updates
  void updateComplaintInList(Map<String, dynamic> updatedComplaint) {
    final index = _complaints
        .indexWhere((complaint) => complaint['id'] == updatedComplaint['id']);
    if (index != -1) {
      _complaints[index] = updatedComplaint;
      notifyListeners();
    }
  }

  // Remove complaint from local list
  void removeComplaintFromList(String complaintId) {
    _complaints.removeWhere((complaint) => complaint['id'] == complaintId);
    notifyListeners();
  }

  // Add new complaint to local list
  void addComplaintToList(Map<String, dynamic> newComplaint) {
    _complaints.insert(0, newComplaint); // Add to beginning of list
    notifyListeners();
  }

  // Check if a complaint exists in the local list
  bool hasComplaint(String complaintId) {
    return _complaints.any((complaint) => complaint['id'] == complaintId);
  }

  // Get complaint by ID from local list
  Map<String, dynamic>? getComplaintById(String complaintId) {
    try {
      return _complaints
          .firstWhere((complaint) => complaint['id'] == complaintId);
    } catch (e) {
      return null;
    }
  }

  // Reset provider state
  void reset() {
    _complaints = [];
    _selectedComplaint = null;
    _isLoading = false;
    _errorMessage = '';
    notifyListeners();
  }

  // Dispose method to clean up resources
  @override
  void dispose() {
    // Clean up any resources if needed
    super.dispose();
  }
}
