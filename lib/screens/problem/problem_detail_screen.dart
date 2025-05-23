// lib/screens/problem_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:citoyen_app/providers/problem_provider.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:timeline_tile/timeline_tile.dart';

class ProblemDetailScreen extends StatefulWidget {
  final String problemId;
  
  const ProblemDetailScreen({
    Key? key,
    required this.problemId,
  }) : super(key: key);

  @override
  State<ProblemDetailScreen> createState() => _ProblemDetailScreenState();
}

class _ProblemDetailScreenState extends State<ProblemDetailScreen> {
  bool _isMapExpanded = false;
  
  @override
  void initState() {
    super.initState();
    // Fetch problem details when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProblemProvider>(context, listen: false).fetchProblemDetail(widget.problemId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    
    return Scaffold(
      body: Consumer<ProblemProvider>(
        builder: (context, problemProvider, _) {
          if (problemProvider.isLoading) {
            return _buildLoadingState(colors);
          } else if (problemProvider.errorMessage.isNotEmpty) {
            return _buildErrorState(problemProvider.errorMessage, colors);
          } else if (problemProvider.selectedProblem == null) {
            return _buildErrorState('Problème non trouvé', colors);
          } else {
            final problem = problemProvider.selectedProblem!;
            return _buildProblemDetail(problem, colors);
          }
        },
      ),
    );
  }
  
  Widget _buildProblemDetail(Map<String, dynamic> problem, ColorScheme colors) {
    // Format dates
    String formattedCreatedDate = '';
    try {
      final date = DateTime.parse(problem['created_at']);
      formattedCreatedDate = DateFormat('dd MMMM yyyy, HH:mm').format(date);
    } catch (e) {
      formattedCreatedDate = 'Date inconnue';
    }
    
    // Get status color and label
    final statusColors = {
      'PENDING': colors.secondary,
      'IN_PROGRESS': Colors.blue,
      'RESOLVED': Colors.green,
      'REJECTED': Colors.red,
    };
    
    final statusLabels = {
      'PENDING': 'En attente',
      'IN_PROGRESS': 'En cours',
      'RESOLVED': 'Résolu',
      'REJECTED': 'Rejeté',
    };
    
    final statusColor = statusColors[problem['status']] ?? colors.primary;
    final statusLabel = statusLabels[problem['status']] ?? 'Inconnu';
    
    // Create map marker if coordinates are available
    Set<Marker> markers = {};
    CameraPosition? initialCameraPosition;
    
    if (problem['latitude'] != null && problem['longitude'] != null) {
      final position = LatLng(
        double.parse(problem['latitude'].toString()),
        double.parse(problem['longitude'].toString()),
      );
      
      markers.add(
        Marker(
          markerId: const MarkerId('problem_location'),
          position: position,
        ),
      );
      
      initialCameraPosition = CameraPosition(
        target: position,
        zoom: 15,
      );
    }
    
    return CustomScrollView(
      slivers: [
        // App Bar with image if available
        SliverAppBar(
          expandedHeight: problem['image'] != null ? 250.0 : 0.0,
          pinned: true,
          flexibleSpace: problem['image'] != null
              ? FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        problem['image'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: colors.surfaceVariant,
                            child: Center(
                              child: Icon(
                                Icons.image_not_supported,
                                color: colors.onSurfaceVariant,
                                size: 50,
                              ),
                            ),
                          );
                        },
                      ),
                      // Gradient overlay for better text visibility
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                            stops: const [0.7, 1.0],
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : null,
          title: Text(
            'Détail du problème',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () {
                // TODO: Implement share functionality
              },
            ),
          ],
        ),
        
        // Problem details
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status and date row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Chip(
                      label: Text(
                        statusLabel,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      backgroundColor: statusColor,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    Text(
                      formattedCreatedDate,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: colors.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0),
                
                const SizedBox(height: 16),
                
                // Category
                if (problem['category'] != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: colors.primaryContainer.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      problem['category']['name'] ?? 'Catégorie inconnue',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: colors.primary,
                      ),
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideY(begin: 0.2, end: 0),
                
                const SizedBox(height: 16),
                
                // Description
                Text(
                  'Description',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: 200.ms).slideY(begin: 0.2, end: 0),
                
                const SizedBox(height: 8),
                
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colors.surfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colors.outline.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    problem['description'] ?? 'Pas de description',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: colors.onSurface,
                    ),
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: 300.ms).slideY(begin: 0.2, end: 0),
                
                const SizedBox(height: 24),
                
                // Location
                Text(
                  'Emplacement',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: 400.ms).slideY(begin: 0.2, end: 0),
                
                const SizedBox(height: 8),
                
                // Municipality
                if (problem['municipality'] != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.surfaceVariant.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colors.outline.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: colors.primary,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            problem['municipality']['name'] ?? 'Lieu inconnu',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              color: colors.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: 500.ms).slideY(begin: 0.2, end: 0),
                
                const SizedBox(height: 16),
                
                // Map
                if (initialCameraPosition != null)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: _isMapExpanded ? 300 : 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: colors.shadow.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        children: [
                          GoogleMap(
                            initialCameraPosition: initialCameraPosition,
                            markers: markers,
                            zoomControlsEnabled: false,
                            mapToolbarEnabled: false,
                            myLocationButtonEnabled: false,
                          ),
                          Positioned(
                            right: 8,
                            bottom: 8,
                            child: FloatingActionButton.small(
                              heroTag: 'expand_map',
                              onPressed: () {
                                setState(() {
                                  _isMapExpanded = !_isMapExpanded;
                                });
                              },
                              child: Icon(
                                _isMapExpanded ? Icons.fullscreen_exit : Icons.fullscreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: 600.ms).slideY(begin: 0.2, end: 0),
                
                const SizedBox(height: 24),
                
                // Admin Comment Section (if available)
                if (problem['comment'] != null && problem['comment'].toString().isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Commentaire de l\'administration',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colors.onSurface,
                        ),
                      ).animate().fadeIn(duration: 400.ms, delay: 700.ms).slideY(begin: 0.2, end: 0),
                      
                      const SizedBox(height: 8),
                      
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colors.primaryContainer.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: colors.primary.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: colors.primary.withOpacity(0.2),
                                  child: Icon(
                                    Icons.admin_panel_settings,
                                    color: colors.primary,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Administration',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: colors.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              problem['comment'],
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                color: colors.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 400.ms, delay: 800.ms).slideY(begin: 0.2, end: 0),
                      
                      const SizedBox(height: 24),
                    ],
                  ),
                
                // Status History Timeline
                if (problem['status_history'] != null && (problem['status_history'] as List).isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Historique des statuts',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colors.onSurface,
                        ),
                      ).animate().fadeIn(duration: 400.ms, delay: 900.ms).slideY(begin: 0.2, end: 0),
                      
                      const SizedBox(height: 16),
                      
                      _buildStatusTimeline(problem['status_history'], colors),
                    ],
                  ),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildStatusTimeline(List<dynamic> statusHistory, ColorScheme colors) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: statusHistory.length,
      itemBuilder: (context, index) {
        final statusLog = statusHistory[index];
        
        // Format date
        String formattedDate = '';
        try {
          final date = DateTime.parse(statusLog['changed_at']);
          formattedDate = DateFormat('dd MMM yyyy, HH:mm').format(date);
        } catch (e) {
          formattedDate = 'Date inconnue';
        }
        
        // Get status colors
        final statusColors = {
          'PENDING': colors.secondary,
          'IN_PROGRESS': Colors.blue,
          'RESOLVED': Colors.green,
          'REJECTED': Colors.red,
        };
        
        final statusLabels = {
          'PENDING': 'En attente',
          'IN_PROGRESS': 'En cours',
          'RESOLVED': 'Résolu',
          'REJECTED': 'Rejeté',
        };
        
        final newStatusColor = statusColors[statusLog['new_status']] ?? colors.primary;
        final newStatusLabel = statusLabels[statusLog['new_status']] ?? 'Inconnu';
        
        final oldStatusLabel = statusLabels[statusLog['old_status']] ?? 'Inconnu';
        
        return TimelineTile(
          alignment: TimelineAlign.manual,
          lineXY: 0.2,
          isFirst: index == 0,
          isLast: index == statusHistory.length - 1,
          indicatorStyle: IndicatorStyle(
            width: 20,
            height: 20,
            indicator: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: newStatusColor,
              ),
              child: Center(
                child: Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 12,
                ),
              ),
            ),
          ),
          beforeLineStyle: LineStyle(
            color: colors.outline.withOpacity(0.5),
          ),
          afterLineStyle: LineStyle(
            color: colors.outline.withOpacity(0.5),
          ),
          endChild: Container(
            margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: newStatusColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        newStatusLabel,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: newStatusColor,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      formattedDate,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: colors.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Statut changé de "$oldStatusLabel" à "$newStatusLabel"',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: colors.onSurface,
                  ),
                ),
                if (statusLog['comment'] != null && statusLog['comment'].toString().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Commentaire: ${statusLog['comment']}',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: colors.onSurface.withOpacity(0.8),
                    ),
                  ),
                ],
              ],
            ),
          ),
          startChild: Container(
            margin: const EdgeInsets.only(right: 8),
            child: Text(
              formattedDate.split(',')[0],
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: colors.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ).animate().fadeIn(duration: 400.ms, delay: (900 + (index * 100)).ms).slideY(begin: 0.2, end: 0);
      },
    );
  }
  
  Widget _buildLoadingState(ColorScheme colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: colors.primary),
          const SizedBox(height: 16),
          Text(
            'Chargement des détails...',
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Détail du problème',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
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
                  Provider.of<ProblemProvider>(context, listen: false)
                      .fetchProblemDetail(widget.problemId);
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
