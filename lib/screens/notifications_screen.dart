// lib/screens/notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:citoyen_app/providers/notification_provider.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final ScrollController _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    // Fetch notifications when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotificationProvider>(context, listen: false).fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'Marquer tout comme lu',
            onPressed: () {
              Provider.of<NotificationProvider>(context, listen: false).markAllAsRead();
            },
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, notificationProvider, _) {
          if (notificationProvider.isLoading) {
            return _buildLoadingState(colors);
          } else if (notificationProvider.errorMessage.isNotEmpty) {
            return _buildErrorState(notificationProvider.errorMessage, colors);
          } else if (notificationProvider.notifications.isEmpty) {
            return _buildEmptyState(colors);
          } else {
            return RefreshIndicator(
              onRefresh: () => notificationProvider.fetchNotifications(),
              child: ListView.builder(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(top: 8, bottom: 80),
                itemCount: notificationProvider.notifications.length,
                itemBuilder: (context, index) {
                  final notification = notificationProvider.notifications[index];
                  return _buildNotificationCard(notification, colors, index);
                },
              ),
            );
          }
        },
      ),
    );
  }
  
  Widget _buildNotificationCard(Map<String, dynamic> notification, ColorScheme colors, int index) {
    // Format date
    String formattedDate = '';
    try {
      final date = DateTime.parse(notification['created_at']);
      formattedDate = DateFormat('dd MMM yyyy, HH:mm').format(date);
    } catch (e) {
      formattedDate = 'Date inconnue';
    }
    
    // Determine icon and color based on notification type
    IconData icon;
    Color iconColor;
    
    switch (notification['type']) {
      case 'PROBLEM_STATUS':
        icon = Icons.report_problem_rounded;
        iconColor = colors.error;
        break;
      case 'COMPLAINT_STATUS':
        icon = Icons.comment_bank_rounded;
        iconColor = colors.secondary;
        break;
      case 'ADMIN_MESSAGE':
        icon = Icons.message_rounded;
        iconColor = colors.primary;
        break;
      case 'SYSTEM':
        icon = Icons.info_rounded;
        iconColor = Colors.blue;
        break;
      default:
        icon = Icons.notifications_rounded;
        iconColor = colors.primary;
    }
    
    // Determine if notification is read
    final isRead = notification['is_read'] ?? false;
    
    return Card(
      margin: EdgeInsets.fromLTRB(16, index == 0 ? 0 : 8, 16, 8),
      elevation: isRead ? 1 : 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isRead ? colors.surface : colors.surface,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // Mark as read if not already
          if (!isRead) {
            Provider.of<NotificationProvider>(context, listen: false)
                .markAsRead(notification['id']);
          }
          
          // Navigate based on notification type and reference
          _handleNotificationTap(notification);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon with background
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              
              const SizedBox(width: 16),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title with unread indicator
                    Row(
                      children: [
                        if (!isRead)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: colors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        Expanded(
                          child: Text(
                            notification['title'] ?? 'Notification',
                            style: GoogleFonts.inter(
                              fontWeight: isRead ? FontWeight.w500 : FontWeight.w600,
                              fontSize: 16,
                              color: colors.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Message
                    Text(
                      notification['message'] ?? 'Pas de message',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: colors.onSurface.withOpacity(0.7),
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Date
                    Text(
                      formattedDate,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: colors.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate()
      .fadeIn(duration: 300.ms, delay: (50 * index).ms)
      .slideY(begin: 0.1, end: 0, duration: 300.ms, curve: Curves.easeOutQuad);
  }
  
  void _handleNotificationTap(Map<String, dynamic> notification) {
    // Handle navigation based on notification type and reference
    final type = notification['type'];
    final referenceId = notification['reference_id'];
    
    if (type == 'PROBLEM_STATUS' && referenceId != null) {
      Navigator.pushNamed(
        context,
        '/problem_detail',
        arguments: referenceId,
      );
    } else if (type == 'COMPLAINT_STATUS' && referenceId != null) {
      Navigator.pushNamed(
        context,
        '/complaint_detail',
        arguments: referenceId,
      );
    } else if (type == 'ADMIN_MESSAGE') {
      // Maybe show a dialog with the full message
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(notification['title'] ?? 'Message'),
          content: Text(notification['message'] ?? ''),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fermer'),
            ),
          ],
        ),
      );
    }
    // For SYSTEM notifications, just mark as read with no navigation
  }
  
  Widget _buildLoadingState(ColorScheme colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: colors.primary),
          const SizedBox(height: 16),
          Text(
            'Chargement des notifications...',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: colors.onBackground.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildErrorState(String errorMessage, ColorScheme colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 60,
              color: colors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Erreur de chargement',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colors.onBackground,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: colors.onBackground.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Provider.of<NotificationProvider>(context, listen: false).fetchNotifications();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEmptyState(ColorScheme colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off_rounded,
              size: 60,
              color: colors.onBackground.withOpacity(0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'Pas de notifications',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colors.onBackground,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Vous n\'avez pas de notifications pour le moment. Nous vous informerons des mises à jour importantes ici.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: colors.onBackground.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Provider.of<NotificationProvider>(context, listen: false).fetchNotifications();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Actualiser'),
            ),
          ],
        ),
      ),
    );
  }
}
