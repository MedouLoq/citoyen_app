// lib/screens/complaint_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:citoyen_app/providers/complaint_provider.dart';
import 'package:intl/intl.dart';
import 'complaint_detail_screen.dart';
import 'package:citoyen_app/l10n/app_localizations.dart';

class ComplaintListScreen extends StatefulWidget {
  const ComplaintListScreen({Key? key}) : super(key: key);

  @override
  State<ComplaintListScreen> createState() => _ComplaintListScreenState();
}

class _ComplaintListScreenState extends State<ComplaintListScreen>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  String _filterStatus = 'ALL';

  late AnimationController _refreshAnimationController;
  late AnimationController _listAnimationController;
  late Animation<double> _refreshRotation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _refreshAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _listAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Initialize _refreshRotation after _refreshAnimationController
    _refreshRotation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _refreshAnimationController,
      curve: Curves.easeInOut,
    ));

    // Fetch complaints when screen loads with better error handling
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchComplaintsWithRetry();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _refreshAnimationController.dispose();
    _listAnimationController.dispose();
    super.dispose();
  }

  // Enhanced fetch with retry mechanism
  Future<void> _fetchComplaintsWithRetry({int retryCount = 0}) async {
    final provider = Provider.of<ComplaintProvider>(context, listen: false);
    final localizations = AppLocalizations.of(context);

    try {
      await provider.fetchComplaints();
      _listAnimationController.forward();
    } catch (e) {
      print("Error fetching complaints (attempt ${retryCount + 1}): $e");

      // Retry up to 3 times with exponential backoff
      if (retryCount < 2) {
        await Future.delayed(Duration(seconds: (retryCount + 1) * 2));
        await _fetchComplaintsWithRetry(retryCount: retryCount + 1);
      } else {
        // Show error after all retries failed
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(localizations?.unableToLoadComplaints ??
                  'Impossible de charger les réclamations. Vérifiez votre connexion.'),
              backgroundColor: Colors.red,
              action: SnackBarAction(
                label: localizations?.retry ?? 'Réessayer',
                textColor: Colors.white,
                onPressed: () => _fetchComplaintsWithRetry(),
              ),
            ),
          );
        }
      }
    }
  }

  // Enhanced pull-to-refresh handler
  Future<void> _onRefresh() async {
    _refreshAnimationController.repeat();
    final localizations = AppLocalizations.of(context);

    try {
      await Provider.of<ComplaintProvider>(context, listen: false)
          .fetchComplaints();
      _listAnimationController.reset();
      _listAnimationController.forward();
    } catch (e) {
      print("Error during refresh: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations?.errorDuringRefresh ??
                'Erreur lors de l\'actualisation'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } finally {
      _refreshAnimationController.stop();
      _refreshAnimationController.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: Text(
          localizations?.myComplaints ?? 'Mes Réclamations',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        elevation: 0,
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: _showFilterDialog,
            tooltip: localizations?.filter ?? 'Filtrer',
          ),
          AnimatedBuilder(
            animation: _refreshRotation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _refreshRotation.value * 2 * 3.14159,
                child: IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  onPressed: _onRefresh,
                  tooltip: localizations?.refresh ?? 'Actualiser',
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<ComplaintProvider>(
        builder: (context, complaintProvider, _) {
          // Enhanced loading state
          if (complaintProvider.isLoading &&
              complaintProvider.complaints.isEmpty) {
            return _buildEnhancedLoadingState(colors);
          }
          // Enhanced error state with retry option
          else if (complaintProvider.errorMessage.isNotEmpty &&
              complaintProvider.complaints.isEmpty) {
            return _buildEnhancedErrorState(
                complaintProvider.errorMessage, colors);
          }
          // Enhanced empty state
          else if (complaintProvider.complaints.isEmpty) {
            return _buildEnhancedEmptyState(colors);
          }
          // Main content with enhanced UI
          else {
            // Filter complaints based on selected status
            final filteredComplaints = _filterStatus == 'ALL'
                ? complaintProvider.complaints
                : complaintProvider.complaints
                    .where((complaint) => complaint['status'] == _filterStatus)
                    .toList();

            return RefreshIndicator(
              onRefresh: _onRefresh,
              color: colors.primary,
              backgroundColor: colors.surface,
              strokeWidth: 3.0,
              displacement: 50.0,
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // Enhanced filter chips section
                  SliverToBoxAdapter(
                    child: _buildEnhancedFilterChips(colors, complaintProvider),
                  ),

                  // Enhanced complaint count with statistics
                  SliverToBoxAdapter(
                    child: _buildComplaintStats(
                        filteredComplaints, colors, complaintProvider),
                  ),

                  // Enhanced complaint list
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final complaint = filteredComplaints[index];
                        return _buildEnhancedComplaintCard(
                            complaint, colors, index);
                      },
                      childCount: filteredComplaints.length,
                    ),
                  ),

                  // Bottom padding for FAB
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 100),
                  ),
                ],
              ),
            );
          }
        },
      ),
      floatingActionButton: _buildEnhancedFAB(colors),
    );
  }

  Widget _buildEnhancedFilterChips(
      ColorScheme colors, ComplaintProvider provider) {
    final stats = provider.complaintsStats;
    final localizations = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            _buildEnhancedFilterChip('ALL', localizations?.all ?? 'Toutes',
                colors, provider.totalComplaintsCount),
            const SizedBox(width: 12),
            _buildEnhancedFilterChip(
                'PENDING',
                localizations?.pending ?? 'En attente',
                colors,
                stats['PENDING'] ?? 0),
            const SizedBox(width: 12),
            _buildEnhancedFilterChip(
                'REVIEWING',
                localizations?.reviewing ?? 'En examen',
                colors,
                stats['REVIEWING'] ?? 0),
            const SizedBox(width: 12),
            _buildEnhancedFilterChip(
                'RESOLVED',
                localizations?.resolved ?? 'Résolues',
                colors,
                stats['RESOLVED'] ?? 0),
            const SizedBox(width: 12),
            _buildEnhancedFilterChip(
                'REJECTED',
                localizations?.rejected ?? 'Rejetées',
                colors,
                stats['REJECTED'] ?? 0),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedFilterChip(
      String value, String label, ColorScheme colors, int count) {
    final isSelected = _filterStatus == value;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: FilterChip(
        selected: isSelected,
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? colors.onPrimary : colors.onSurface,
                fontSize: 13,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colors.onPrimary.withOpacity(0.2)
                      : colors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count.toString(),
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? colors.onPrimary : colors.primary,
                  ),
                ),
              ),
            ],
          ],
        ),
        backgroundColor: colors.surface,
        selectedColor: colors.primary,
        checkmarkColor: colors.onPrimary,
        elevation: isSelected ? 4 : 1,
        pressElevation: 6,
        shadowColor: colors.primary.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
          side: BorderSide(
            color:
                isSelected ? colors.primary : colors.outline.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        onSelected: (selected) {
          setState(() {
            _filterStatus = value;
          });
        },
      ),
    );
  }

  Widget _buildComplaintStats(List<Map<String, dynamic>> filteredComplaints,
      ColorScheme colors, ComplaintProvider provider) {
    final localizations = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.primaryContainer.withOpacity(0.3),
            colors.secondaryContainer.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outline.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.analytics_outlined,
            color: colors.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${filteredComplaints.length} ${localizations?.complaints ?? 'réclamations'}',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colors.onSurface,
                  ),
                ),
                if (_filterStatus != 'ALL')
                  Text(
                    localizations?.outOfTotal(provider.totalComplaintsCount) ??
                        'sur ${provider.totalComplaintsCount} au total',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: colors.onSurface.withOpacity(0.6),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedComplaintCard(
      Map<String, dynamic> complaint, ColorScheme colors, int index) {
    final localizations = AppLocalizations.of(context);
    final statusColors = {
      'PENDING': colors.secondary,
      'REVIEWING': Colors.blue,
      'RESOLVED': Colors.green,
      'REJECTED': Colors.red,
    };

    final statusLabels = {
      'PENDING': localizations?.pendingStatus ?? 'En attente',
      'REVIEWING': localizations?.reviewingStatus ?? 'En examen',
      'RESOLVED': localizations?.resolvedStatus ?? 'Résolue',
      'REJECTED': localizations?.rejectedStatus ?? 'Rejetée',
    };

    final statusIcons = {
      'PENDING': Icons.schedule_rounded,
      'REVIEWING': Icons.visibility_rounded,
      'RESOLVED': Icons.check_circle_rounded,
      'REJECTED': Icons.cancel_rounded,
    };

    final statusColor = statusColors[complaint['status']] ?? colors.primary;
    final statusLabel = statusLabels[complaint['status']] ??
        (localizations?.unknownStatus ?? 'Inconnu');
    final statusIcon = statusIcons[complaint['status']] ?? Icons.help_outline;

    // Format date
    String formattedDate = '';
    String timeAgo = '';
    try {
      final date = DateTime.parse(complaint['created_at']);
      formattedDate = DateFormat('dd MMM yyyy, HH:mm').format(date);

      final now = DateTime.now();
      final difference = now.difference(date);
      if (difference.inDays > 0) {
        timeAgo = localizations?.daysAgo(difference.inDays) ??
            'il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
      } else if (difference.inHours > 0) {
        timeAgo = localizations?.hoursAgo(difference.inHours) ??
            'il y a ${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}';
      } else {
        timeAgo = localizations?.minutesAgo(difference.inMinutes) ??
            'il y a ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
      }
    } catch (e) {
      formattedDate = localizations?.unknownDate ?? 'Date inconnue';
      timeAgo = '';
    }

    return AnimatedBuilder(
      animation: _listAnimationController,
      builder: (context, child) {
        final animationValue = Curves.easeOutCubic.transform(
            ((_listAnimationController.value - (index * 0.1)).clamp(0.0, 1.0)));

        return Transform.translate(
          offset: Offset(0, (1 - animationValue) * 50),
          child: Opacity(
            opacity: animationValue,
            child: Container(
              margin: EdgeInsets.fromLTRB(16, index == 0 ? 0 : 8, 16, 8),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: colors.shadow.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: colors.outline.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            ComplaintDetailScreen(complaintId: complaint['id']),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          return SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(1.0, 0.0),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutCubic,
                            )),
                            child: child,
                          );
                        },
                        transitionDuration: const Duration(milliseconds: 300),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with status and date
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: statusColor,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: statusColor.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    statusIcon,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    statusLabel,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  formattedDate,
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: colors.onSurface.withOpacity(0.6),
                                  ),
                                ),
                                if (timeAgo.isNotEmpty)
                                  Text(
                                    timeAgo,
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      color: colors.onSurface.withOpacity(0.5),
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Subject
                        Text(
                          complaint['subject'] ??
                              (localizations?.subjectNotSpecified ??
                                  'Sujet non spécifié'),
                          style: GoogleFonts.inter(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: colors.onSurface,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 8),

                        // Description preview
                        Text(
                          complaint['description'] ??
                              (localizations?.noDescription ??
                                  'Pas de description'),
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: colors.onSurface.withOpacity(0.7),
                            height: 1.4,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 12),

                        // Municipality and attachments row
                        Row(
                          children: [
                            // Municipality
                            if (complaint['municipality'] != null)
                              Expanded(
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.location_on_rounded,
                                      size: 16,
                                      color: colors.primary,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        complaint['municipality']['name'] ??
                                            (localizations
                                                    ?.unknownMunicipality ??
                                                'Municipalité inconnue'),
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          color:
                                              colors.onSurface.withOpacity(0.6),
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            // Attachment indicators
                            if (_hasAttachments(complaint))
                              Row(
                                children: [
                                  if (complaint['photo_url'] != null)
                                    _buildAttachmentIndicator(
                                        Icons.image_rounded, colors),
                                  if (complaint['video_url'] != null)
                                    _buildAttachmentIndicator(
                                        Icons.videocam_rounded, colors),
                                  if (complaint['voice_record_url'] != null)
                                    _buildAttachmentIndicator(
                                        Icons.mic_rounded, colors),
                                  if (complaint['evidence_url'] != null)
                                    _buildAttachmentIndicator(
                                        Icons.attach_file_rounded, colors),
                                ],
                              ),
                          ],
                        ),

                        // Show image thumbnail if available
                        if (complaint['photo_url'] != null)
                          Container(
                            margin: const EdgeInsets.only(top: 16),
                            height: 140,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: colors.shadow.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                complaint['photo_url'],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: colors.surfaceVariant,
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.image_not_supported_rounded,
                                            color: colors.onSurfaceVariant,
                                            size: 32,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            localizations?.imageNotAvailable ??
                                                'Image non disponible',
                                            style: GoogleFonts.inter(
                                              fontSize: 12,
                                              color: colors.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    color: colors.surfaceVariant,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!
                                            : null,
                                        color: colors.primary,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  bool _hasAttachments(Map<String, dynamic> complaint) {
    return complaint['photo_url'] != null ||
        complaint['video_url'] != null ||
        complaint['voice_record_url'] != null ||
        complaint['evidence_url'] != null;
  }

  Widget _buildAttachmentIndicator(IconData icon, ColorScheme colors) {
    return Container(
      margin: const EdgeInsets.only(left: 6),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: colors.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        icon,
        size: 14,
        color: colors.primary,
      ),
    );
  }

  Widget _buildEnhancedFAB(ColorScheme colors) {
    final localizations = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/submit_complaint');
        },
        icon: const Icon(Icons.add_rounded),
        label: Text(
          localizations?.newComplaint ?? 'Nouvelle Réclamation',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  void _showFilterDialog() {
    final localizations = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) {
        final colors = Theme.of(context).colorScheme;
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.filter_list_rounded, color: colors.primary),
              const SizedBox(width: 8),
              Text(
                localizations?.filterByStatus ?? 'Filtrer par statut',
                style: GoogleFonts.inter(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFilterOption(
                  'ALL',
                  localizations?.allComplaints ?? 'Toutes les réclamations',
                  Icons.list_rounded),
              _buildFilterOption(
                  'PENDING',
                  localizations?.pendingComplaints ?? 'En attente',
                  Icons.schedule_rounded),
              _buildFilterOption(
                  'IN_PROGRESS',
                  localizations?.inProgressComplaints ?? 'En cours',
                  Icons.hourglass_empty_rounded),
              _buildFilterOption(
                  'DELEGATED',
                  localizations?.delegatedComplaints ?? 'Délégué',
                  Icons.forward_rounded),
              _buildFilterOption(
                  'REVIEWING',
                  localizations?.reviewingComplaints ?? 'En examen',
                  Icons.visibility_rounded),
              _buildFilterOption(
                  'RESOLVED',
                  localizations?.resolvedComplaints ?? 'Résolues',
                  Icons.check_circle_rounded),
              _buildFilterOption(
                  'REJECTED',
                  localizations?.rejectedComplaints ?? 'Rejetées',
                  Icons.cancel_rounded),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                localizations?.close ?? 'Fermer',
                style: GoogleFonts.inter(color: colors.primary),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterOption(String value, String label, IconData icon) {
    final colors = Theme.of(context).colorScheme;
    return RadioListTile<String>(
      title: Row(
        children: [
          Icon(icon, size: 20, color: colors.onSurface.withOpacity(0.7)),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 14),
          ),
        ],
      ),
      value: value,
      groupValue: _filterStatus,
      activeColor: colors.primary,
      onChanged: (newValue) {
        setState(() {
          _filterStatus = newValue!;
        });
        Navigator.pop(context);
      },
    );
  }

  Widget _buildEnhancedLoadingState(ColorScheme colors) {
    final localizations = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colors.primaryContainer.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: CircularProgressIndicator(
              color: colors.primary,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            localizations?.loadingComplaints ??
                'Chargement des réclamations...',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            localizations?.pleaseWait ?? 'Veuillez patienter',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: colors.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildEnhancedErrorState(String errorMessage, ColorScheme colors) {
    final localizations = AppLocalizations.of(context);
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          height: MediaQuery.of(context).size.height - 200,
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colors.errorContainer.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.cloud_off_rounded,
                  color: colors.error,
                  size: 64,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                localizations?.oopsError ?? 'Oups! Une erreur est survenue',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colors.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                errorMessage,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: colors.onSurface.withOpacity(0.7),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _fetchComplaintsWithRetry,
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(
                      localizations?.retry ?? 'Réessayer',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: colors.onPrimary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                localizations?.pullToRefresh ??
                    'Tirez vers le bas pour actualiser',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: colors.onSurface.withOpacity(0.5),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildEnhancedEmptyState(ColorScheme colors) {
    final localizations = AppLocalizations.of(context);
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          height: MediaQuery.of(context).size.height - 200,
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colors.primaryContainer.withOpacity(0.3),
                      colors.secondaryContainer.withOpacity(0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.inbox_rounded,
                  color: colors.primary,
                  size: 64,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                localizations?.noComplaints ?? 'Aucune réclamation',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                localizations?.noComplaintsMessage ??
                    'Vous n\'avez pas encore soumis de réclamation.\nCommencez par créer votre première réclamation.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: colors.onSurface.withOpacity(0.7),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/submit_complaint');
                },
                icon: const Icon(Icons.add_rounded),
                label: Text(
                  localizations?.createComplaint ?? 'Créer une réclamation',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: colors.onPrimary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                localizations?.pullToRefresh ??
                    'Tirez vers le bas pour actualiser',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: colors.onSurface.withOpacity(0.5),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).scale(begin: const Offset(0.9, 0.9));
  }
}
