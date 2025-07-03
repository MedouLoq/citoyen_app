// lib/providers/notification_provider.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class NotificationProvider with ChangeNotifier {
  List<Map<String, dynamic>> _notifications = [];
  List<Map<String, dynamic>> get notifications => _notifications;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  int _unreadCount = 0;
  int get unreadCount => _unreadCount;

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

  Future<void> fetchNotifications() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    const String baseUrl =
        'http://192.168.137.1:8000'; // Replace with your base URL

    final token = await _getToken();

    if (token == null) {
      _errorMessage = "Not authenticated";
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/notifications/'),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _notifications = List<Map<String, dynamic>>.from(data);

        // Count unread notifications
        _unreadCount =
            _notifications.where((n) => !(n['is_read'] ?? false)).length;
      } else {
        throw Exception(
            'Failed to fetch notifications: Status code ${response.statusCode}');
      }
    } catch (e) {
      _errorMessage = 'Failed to load notifications: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String notificationId) async {
    const String baseUrl =
        'http://192.168.137.1:8000'; // Replace with your base URL

    final token = await _getToken();

    if (token == null) {
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/notifications/$notificationId/read/'),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Update local state
        final index =
            _notifications.indexWhere((n) => n['id'] == notificationId);
        if (index != -1) {
          _notifications[index]['is_read'] = true;

          // Update unread count
          _unreadCount =
              _notifications.where((n) => !(n['is_read'] ?? false)).length;

          notifyListeners();
        }
      }
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    const String baseUrl =
        'http://192.168.137.1:8000'; // Replace with your base URL

    final token = await _getToken();

    if (token == null) {
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/notifications/mark_all_read/'),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Update local state
        for (var notification in _notifications) {
          notification['is_read'] = true;
        }

        // Reset unread count
        _unreadCount = 0;

        notifyListeners();
      }
    } catch (e) {
      print('Error marking all notifications as read: $e');
    }
  }
}
