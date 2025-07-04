// lib/screens/problem_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:citoyen_app/providers/problem_provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_map/flutter_map.dart'; // Replaced google_maps_flutter
import 'package:latlong2/latlong.dart'; // Added for flutter_map
import 'package:video_player/video_player.dart';
import 'package:just_audio/just_audio.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path/path.dart' as p;
import 'package:citoyen_app/l10n/app_localizations.dart'; // Added localization import

class ProblemDetailScreen extends StatefulWidget {
  final String problemId;

  const ProblemDetailScreen({
    Key? key,
    required this.problemId,
  }) : super(key: key);

  @override
  State<ProblemDetailScreen> createState() => _ProblemDetailScreenState();
}

class _ProblemDetailScreenState extends State<ProblemDetailScreen>
    with SingleTickerProviderStateMixin {
  // Added for animations
  // Map State
  bool _isMapExpanded = false;
  final MapController _mapController = MapController();
  LatLng? _problemLocationLatLng; // Use latlong2.LatLng

  // Media Player State
  VideoPlayerController? _videoController;
  AudioPlayer? _audioPlayer;
  bool _isVideoLoading = false;
  bool _isAudioLoading = false;
  bool _isAudioPlaying = false;
  Duration _audioDuration = Duration.zero;
  Duration _audioPosition = Duration.zero;

  // Animation Controller for staggered animations
  late AnimationController _staggerController;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800), // Adjust duration as needed
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchDetails();
      _staggerController.forward(); // Start animations after build
    });
  }

  // Helper function to translate category names
  String _translateCategoryName(BuildContext context, String? categoryName) {
    final localizations = AppLocalizations.of(context);

    if (categoryName == null) {
      return localizations?.unknownCategory ?? 'Catégorie inconnue';
    }

    // Map category names to localization keys
    switch (categoryName.toLowerCase()) {
      case 'routes':
        return localizations?.categoryRoads ?? 'Routes';
      case 'eau':
        return localizations?.categoryWater ?? 'Eau';
      case 'électricité':
      case 'électricite':
      case 'electricite':
        return localizations?.categoryElectricity ?? 'Électricité';
      case 'déchets':
      case 'dechets':
        return localizations?.categoryWaste ?? 'Déchets';
      case 'permis de construire ou de démolir':
      case 'permis':
        return localizations?.categoryBuildingPermit ??
            'Permis de construire ou de démolir';
      case 'autre':
        return localizations?.categoryOther ?? 'Autre';
      default:
        return categoryName; // Return original name if no translation found
    }
  }

  Future<void> _fetchDetails() async {
    final provider = Provider.of<ProblemProvider>(context, listen: false);
    await provider.fetchProblemDetail(widget.problemId);
    if (mounted && provider.selectedProblem != null) {
      final problem = provider.selectedProblem!;
      _initializeMediaPlayers(problem);
      _parseLocation(problem);
      // Trigger map update if location is valid
      if (_problemLocationLatLng != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            // No need to move map initially unless we want specific behavior
            // _mapController.move(_problemLocationLatLng!, 15.0);
            setState(() {}); // Update state to reflect parsed location
          }
        });
      }
    }
  }

  void _initializeMediaPlayers(Map<String, dynamic> problem) {
    _initializeVideoPlayer(problem['video_url']);
    _initializeAudioPlayer(problem['voice_record_url']);
  }

  void _parseLocation(Map<String, dynamic> problem) {
    if (problem['latitude'] != null && problem['longitude'] != null) {
      try {
        setState(() {
          _problemLocationLatLng = LatLng(
            double.parse(problem['latitude'].toString()),
            double.parse(problem['longitude'].toString()),
          );
        });
      } catch (e) {
        print("Error parsing coordinates: $e");
        setState(() {
          _problemLocationLatLng = null;
        });
      }
    }
  }

  Future<void> _initializeVideoPlayer(String? videoUrl) async {
    if (videoUrl == null || videoUrl.isEmpty) return;
    if (!mounted) return;
    setState(() => _isVideoLoading = true);
    try {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      await _videoController!.initialize();
      if (mounted) setState(() => _isVideoLoading = false);
    } catch (e) {
      print("Error initializing video player: $e");
      if (mounted) {
        setState(() => _isVideoLoading = false);
        _showSnackBar("Erreur chargement vidéo", isError: true);
      }
    }
  }

  Future<void> _initializeAudioPlayer(String? audioUrl) async {
    if (audioUrl == null || audioUrl.isEmpty) return;
    if (!mounted) return;
    setState(() => _isAudioLoading = true);
    try {
      _audioPlayer = AudioPlayer();
      final duration = await _audioPlayer!.setUrl(audioUrl);
      if (mounted) {
        setState(() => _audioDuration = duration ?? Duration.zero);
      }
      _audioPlayer!.playerStateStream.listen((state) {
        if (mounted) {
          setState(() => _isAudioPlaying = state.playing);
        }
      });
      _audioPlayer!.positionStream.listen((position) {
        if (mounted) {
          setState(() => _audioPosition = position);
        }
      });
      if (mounted) setState(() => _isAudioLoading = false);
    } catch (e) {
      print("Error initializing audio player: $e");
      if (mounted) {
        setState(() => _isAudioLoading = false);
        _showSnackBar("Erreur chargement audio", isError: true);
      }
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _audioPlayer?.dispose();
    _mapController.dispose();
    _staggerController.dispose(); // Dispose animation controller
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = true}) {
    if (!mounted) return;
    final Color snackBarColor = isError
        ? (Theme.of(context).colorScheme.error)
        : (Theme.of(context).colorScheme.primary);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.inter(color: Colors.white)),
        backgroundColor: snackBarColor,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(15, 5, 15, 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 4,
      ),
    );
  }

  Future<void> _launchUrl(String? urlString) async {
    if (urlString == null || urlString.isEmpty) {
      _showSnackBar("Lien non disponible", isError: true);
      return;
    }
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      _showSnackBar("Impossible d'ouvrir le lien", isError: true);
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final EdgeInsets safePadding = MediaQuery.of(context).padding;
    final double screenWidth = MediaQuery.of(context).size.width;
    final localizations =
        AppLocalizations.of(context); // Initialized localizations

    return Scaffold(
      backgroundColor: colors.surface, // Use surface for main background
      body: Consumer<ProblemProvider>(
        builder: (context, problemProvider, _) {
          if (problemProvider.isLoading &&
              problemProvider.selectedProblem == null) {
            return _buildLoadingState(colors, localizations);
          } else if (problemProvider.errorMessage.isNotEmpty &&
              problemProvider.selectedProblem == null) {
            return _buildErrorState(
                problemProvider.errorMessage, colors, localizations);
          } else if (problemProvider.selectedProblem == null) {
            return _buildErrorState(
                problemProvider.errorMessage.isNotEmpty
                    ? problemProvider.errorMessage
                    : localizations?.problemNotFound ?? 'Problème non trouvé',
                colors,
                localizations);
          } else {
            final problem = problemProvider.selectedProblem!;
            final String? photoUrl = problem['photo_url'] as String?;
            return _buildProblemDetailContent(problem, photoUrl, theme,
                safePadding, screenWidth, localizations);
          }
        },
      ),
    );
  }

  Widget _buildLoadingState(
      ColorScheme colors, AppLocalizations? localizations) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: colors.primary, strokeWidth: 3),
          const SizedBox(height: 20),
          Text(
            localizations?.loadingDetails ?? 'Chargement des détails...',
            style:
                GoogleFonts.inter(color: colors.onSurfaceVariant, fontSize: 16),
          )
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildErrorState(
      String message, ColorScheme colors, AppLocalizations? localizations) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, color: colors.error, size: 60),
            const SizedBox(height: 20),
            Text(
              localizations?.errorOops ?? 'Oups! Erreur',
              style: GoogleFonts.inter(
                  color: colors.error,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                  color: colors.onSurfaceVariant, fontSize: 15, height: 1.4),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 18, color: Colors.white),
              label: Text(localizations?.backButton ?? 'Retour'),
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.errorContainer,
                foregroundColor: colors.onErrorContainer,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            )
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).scale(begin: const Offset(0.9, 0.9));
  }

  // Main Content Builder
  Widget _buildProblemDetailContent(
      Map<String, dynamic> problem,
      String? photoUrl,
      ThemeData theme,
      EdgeInsets safePadding,
      double screenWidth,
      AppLocalizations? localizations) {
    final ColorScheme colors = theme.colorScheme;

    // Format dates
    String formattedCreatedDate = localizations?.unknownDate ?? 'Date inconnue';
    try {
      final date = DateTime.parse(problem['created_at']);
      formattedCreatedDate = DateFormat(
              'dd MMMM yyyy, HH:mm', localizations?.localeName ?? 'fr_FR')
          .format(date);
    } catch (e) {
      print("Error parsing date: $e");
    }

    // Status Configuration
    final statusConfig =
        _getStatusConfig(problem['status'], colors, localizations);
    final statusLabel = statusConfig['label'] ??
        problem['status_display'] ??
        (localizations?.unknownStatus ?? 'Inconnu');
    final statusColor = statusConfig['color'] ?? colors.onSurfaceVariant;
    final statusIcon = statusConfig['icon'] ?? Icons.help_outline;

    // Extract other attachments
    final String? videoUrl = problem['video_url'] as String?;
    final String? voiceRecordUrl = problem['voice_record_url'] as String?;
    final String? documentUrl = problem['document_url'] as String?;
    final String? documentName = problem['document_name'] as String?;

    // Animation Interval Calculation
    const double intervalLength = 0.15; // 15% of total duration per item
    double start = 0.0;

    Widget animateItem(Widget child, {double delayFactor = 1.0}) {
      final intervalStart = start;
      final intervalEnd = (start + intervalLength).clamp(0.0, 1.0);
      start = intervalEnd; // Move start for the next item

      return AnimatedBuilder(
        animation: _staggerController,
        builder: (context, _) {
          final animationValue = Curves.easeOut.transform(
              ((_staggerController.value - intervalStart) /
                      (intervalEnd - intervalStart))
                  .clamp(0.0, 1.0));
          return Opacity(
            opacity: animationValue,
            child: Transform.translate(
              offset: Offset(0, (1.0 - animationValue) * 20), // Slide up effect
              child: child,
            ),
          );
        },
      );
    }

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverAppBar(
          pinned: true,
          stretch: true,
          expandedHeight: photoUrl != null && photoUrl.isNotEmpty
              ? screenWidth * 0.7
              : kToolbarHeight + safePadding.top,
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          elevation: 2,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white),
            tooltip: localizations?.backButton ?? 'Retour',
            onPressed: () => Navigator.of(context).pop(),
          ),
          flexibleSpace: FlexibleSpaceBar(
            titlePadding:
                const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
            centerTitle: false,
            title: Text(
              localizations?.problemDetailTitle ?? 'Détail du Problème',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                color: colors.onPrimary,
                fontSize: 16, // Adjust size for better fit
              ),
            ),
            background: photoUrl != null && photoUrl.isNotEmpty
                ? _buildHeaderImage(photoUrl, colors)
                : Container(color: colors.primary), // Fallback color
            stretchModes: const [
              StretchMode.zoomBackground,
              StretchMode.fadeTitle
            ],
          ),
        ),

        // Main content area
        SliverPadding(
          padding: EdgeInsets.fromLTRB(16, 20, 16, 24 + safePadding.bottom),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Status and Date Row
              animateItem(Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Chip(
                    avatar: Icon(statusIcon, size: 18, color: colors.onPrimary),
                    label: Text(statusLabel,
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            color: colors.onPrimary)),
                    backgroundColor: statusColor,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    labelPadding: const EdgeInsets.only(left: 4),
                    visualDensity: VisualDensity.compact,
                    elevation: 2,
                    shadowColor: statusColor.withOpacity(0.5),
                  ),
                  Text(
                    formattedCreatedDate,
                    style: GoogleFonts.inter(
                        fontSize: 13, color: colors.onSurfaceVariant),
                  ),
                ],
              )),
              const SizedBox(height: 16),

              // Category (with localization)
              if (problem['category'] != null)
                animateItem(Align(
                  alignment: Alignment.centerLeft,
                  child: Chip(
                    avatar: Icon(Icons.category_rounded,
                        size: 18, color: colors.secondary),
                    label: Text(
                      _translateCategoryName(
                          context, problem['category']['name']),
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w500,
                          color: colors.onSecondaryContainer),
                    ),
                    backgroundColor: colors.secondaryContainer.withOpacity(0.6),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    labelPadding: const EdgeInsets.only(left: 4),
                    side: BorderSide(color: colors.secondary.withOpacity(0.3)),
                  ),
                )),
              const SizedBox(height: 24),

              // Description Section
              animateItem(_buildSectionTitle(
                  localizations?.sectionDescription ?? 'Description',
                  Icons.description_outlined,
                  theme)),
              const SizedBox(height: 10),
              animateItem(_buildInfoCard(
                child: Text(
                  problem['description'] ??
                      (localizations?.noDescriptionProvided ??
                          'Pas de description fournie.'),
                  style: GoogleFonts.inter(
                      fontSize: 15, color: colors.onSurface, height: 1.5),
                ),
                theme: theme,
              )),
              const SizedBox(height: 28),

              // Voice Note Section
              if (voiceRecordUrl != null && voiceRecordUrl.isNotEmpty) ...[
                animateItem(_buildSectionTitle(
                    localizations?.voiceNote ?? 'Note Vocale',
                    Icons.graphic_eq_rounded,
                    theme)),
                const SizedBox(height: 10),
                animateItem(_buildInfoCard(
                  child: _buildAudioPlayerWidget(theme, localizations),
                  theme: theme,
                )),
                const SizedBox(height: 28),
              ],

              // Location Section
              animateItem(_buildSectionTitle(
                  localizations?.sectionLocation ?? 'Emplacement',
                  Icons.location_on_outlined,
                  theme)),
              const SizedBox(height: 10),
              animateItem(_buildInfoCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (problem['municipality'] != null)
                      Text(
                        problem['municipality']['name'] ??
                            (localizations?.unknownMunicipality ??
                                'Municipalité inconnue'),
                        style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: colors.onSurface),
                      ),
                    if (problem['municipality'] != null &&
                        _problemLocationLatLng != null)
                      const SizedBox(height: 6),
                    if (_problemLocationLatLng != null)
                      Text(
                        'Lat: ${_problemLocationLatLng!.latitude.toStringAsFixed(5)}, Lon: ${_problemLocationLatLng!.longitude.toStringAsFixed(5)}',
                        style: GoogleFonts.inter(
                            fontSize: 12, color: colors.onSurfaceVariant),
                      ),
                    // Refactored Map Widget
                    if (_problemLocationLatLng != null)
                      _buildMapWidget(theme, localizations)
                    else
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: Text(
                          localizations?.coordinatesNotAvailable ??
                              'Coordonnées non disponibles.',
                          style: GoogleFonts.inter(
                              color: colors.onSurfaceVariant.withOpacity(0.7)),
                        ),
                      ),
                  ],
                ),
                theme: theme,
              )),
              const SizedBox(height: 28),

              // Video Section
              if (videoUrl != null && videoUrl.isNotEmpty) ...[
                animateItem(_buildSectionTitle(
                    localizations?.sectionVideo ?? 'Vidéo',
                    Icons.videocam_rounded,
                    theme)),
                const SizedBox(height: 10),
                animateItem(_buildInfoCard(
                  child: _buildVideoPlayerWidget(theme, localizations),
                  theme: theme,
                )),
                const SizedBox(height: 28),
              ],

              // Document Section
              if (documentUrl != null && documentUrl.isNotEmpty) ...[
                animateItem(_buildSectionTitle(
                    localizations?.sectionDocument ?? 'Document',
                    Icons.attach_file_rounded,
                    theme)),
                const SizedBox(height: 10),
                animateItem(_buildInfoCard(
                  child: _buildDocumentTile(
                      documentName ??
                          (localizations?.sectionDocument ?? 'Document'),
                      documentUrl,
                      theme,
                      localizations),
                  theme: theme,
                )),
                const SizedBox(height: 28),
              ],

              // Admin Comment Section
              if (problem['comment'] != null &&
                  problem['comment'].toString().isNotEmpty) ...[
                animateItem(_buildSectionTitle(
                    localizations?.sectionAdminComment ?? 'Commentaire Admin',
                    Icons.admin_panel_settings_rounded,
                    theme)),
                const SizedBox(height: 10),
                animateItem(_buildInfoCard(
                  child: Text(
                    problem['comment'],
                    style: GoogleFonts.inter(
                        fontSize: 15,
                        color: colors.onPrimaryContainer,
                        height: 1.5),
                  ),
                  theme: theme,
                  isHighlighted: true,
                )),
                const SizedBox(height: 28),
              ],
            ]),
          ),
        ),
      ],
    );
  }

  // --- UI Building Helper Widgets ---

  Map<String, dynamic> _getStatusConfig(
      String? status, ColorScheme colors, AppLocalizations? localizations) {
    switch (status) {
      case 'PENDING':
        return {
          'label': localizations?.statusPending ?? 'En attente',
          'color': Colors.orange.shade700,
          'icon': Icons.hourglass_empty_rounded,
        };
      case 'IN_PROGRESS':
        return {
          'label': localizations?.statusInProgress ?? 'En cours',
          'color': Colors.blue.shade600,
          'icon': Icons.sync_rounded,
        };
      case 'RESOLVED':
        return {
          'label': localizations?.statusResolved ?? 'Résolu',
          'color': Colors.green.shade700,
          'icon': Icons.check_circle_outline_rounded,
        };
      case 'REJECTED':
        return {
          'label': localizations?.statusRejected ?? 'Rejeté',
          'color': colors.error,
          'icon': Icons.cancel_outlined,
        };
      default:
        return {
          'label': localizations?.unknownStatus ?? 'Inconnu',
          'color': colors.onSurfaceVariant,
          'icon': Icons.help_outline_rounded,
        };
    }
  }

  Widget _buildSectionTitle(String title, IconData icon, ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 22),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(
      {required Widget child,
      required ThemeData theme,
      bool isHighlighted = false}) {
    final ColorScheme colors = theme.colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: isHighlighted
              ? colors.primaryContainer.withOpacity(0.2)
              : colors.surfaceVariant.withOpacity(0.4),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isHighlighted
                ? colors.primary.withOpacity(0.4)
                : colors.outline.withOpacity(0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: colors.shadow.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ]),
      child: child,
    );
  }

  Widget _buildHeaderImage(String photoUrl, ColorScheme colors) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceVariant, // Background for loading/error
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            photoUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null)
                return child.animate().fadeIn(duration: 300.ms);
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                  strokeWidth: 2.5,
                  color: colors.onPrimary.withOpacity(0.8),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Icon(
                  Icons.broken_image_outlined,
                  color: colors.onPrimary.withOpacity(0.6),
                  size: 60,
                ),
              );
            },
          ).animate().fadeIn(), // Animate image appearance
          // Enhanced Gradient overlay for better text visibility
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.7), // Darker top
                  Colors.black.withOpacity(0.4),
                  Colors.transparent,
                  Colors.black.withOpacity(0.8), // Darker bottom
                ],
                stops: const [0.0, 0.25, 0.6, 1.0],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Refactored Map Widget using FlutterMap
  Widget _buildMapWidget(ThemeData theme, AppLocalizations? localizations) {
    final ColorScheme colors = theme.colorScheme;
    return Column(
      children: [
        const SizedBox(height: 16),
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOutCubic, // Smoother curve
          height: _isMapExpanded ? 350 : 180,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: colors.shadow.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 1,
                  offset: const Offset(0, 5),
                )
              ]),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                      initialCenter:
                          _problemLocationLatLng!, // Assumes not null here
                      initialZoom: 15.5,
                      minZoom: 5.0,
                      maxZoom: 18.0,
                      interactionOptions: InteractionOptions(
                        flags: _isMapExpanded
                            ? InteractiveFlag.all & ~InteractiveFlag.rotate
                            : InteractiveFlag.none,
                      ),
                      onTap: (_, __) {
                        if (!_isMapExpanded) {
                          setState(() => _isMapExpanded = true);
                        }
                      }),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: const ['a', 'b', 'c'], // Added subdomains
                      userAgentPackageName:
                          'com.example.citoyen_app', // Replace with your actual package name
                      tileProvider: NetworkTileProvider(),
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _problemLocationLatLng!,
                          width: 60,
                          height: 60,
                          alignment: Alignment
                              .topCenter, // Adjust alignment for pin shape
                          child: Icon(Icons.location_pin,
                              color: colors.error,
                              size: 50,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.6),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                )
                              ]).animate().scale(
                              delay: 200.ms,
                              duration: 400.ms,
                              curve: Curves.elasticOut),
                        ),
                      ],
                    ),
                  ],
                ),
                // Expand/Collapse Button
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: FloatingActionButton.small(
                    heroTag: 'map_expand_fab',
                    backgroundColor: colors.surface.withOpacity(0.85),
                    foregroundColor: colors.primary,
                    elevation: 4,
                    tooltip: _isMapExpanded
                        ? (localizations?.reduceMap ?? 'Réduire la carte')
                        : (localizations?.enlargeMap ?? 'Agrandir la carte'),
                    onPressed: () =>
                        setState(() => _isMapExpanded = !_isMapExpanded),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) =>
                          ScaleTransition(scale: animation, child: child),
                      child: Icon(
                        _isMapExpanded
                            ? Icons.fullscreen_exit_rounded
                            : Icons.fullscreen_rounded,
                        key:
                            ValueKey<bool>(_isMapExpanded), // Key for animation
                      ),
                    ),
                  ),
                ),
                // Subtle overlay when collapsed to indicate interactivity
                if (!_isMapExpanded)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.touch_app_outlined,
                          color: Colors.white.withOpacity(0.5),
                          size: 40,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoPlayerWidget(
      ThemeData theme, AppLocalizations? localizations) {
    final ColorScheme colors = theme.colorScheme;
    if (_isVideoLoading) {
      return const Center(
          child: Padding(
        padding: EdgeInsets.symmetric(vertical: 20.0),
        child: CircularProgressIndicator(strokeWidth: 2.5),
      ));
    }
    if (_videoController == null || !_videoController!.value.isInitialized) {
      return Row(children: [
        Icon(Icons.error_outline_rounded,
            color: theme.colorScheme.error, size: 20),
        const SizedBox(width: 8),
        Text(localizations?.videoNotAvailable ??
            "Vidéo non disponible ou erreur")
      ]);
    }
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: AspectRatio(
            aspectRatio: _videoController!.value.aspectRatio,
            child: Stack(
              alignment: Alignment.center,
              children: [
                VideoPlayer(_videoController!),
                // Animated Play/Pause Button
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _videoController!.value.isPlaying
                          ? _videoController!.pause()
                          : _videoController!.play();
                    });
                  },
                  child: AnimatedOpacity(
                    opacity: _videoController!.value.isPlaying ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 300),
                    child: CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.black.withOpacity(0.6),
                      child: Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 45,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        VideoProgressIndicator(
          _videoController!,
          allowScrubbing: true,
          padding: const EdgeInsets.only(top: 8.0),
          colors: VideoProgressColors(
            playedColor: theme.colorScheme.primary,
            bufferedColor: theme.colorScheme.primary.withOpacity(0.4),
            backgroundColor: theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ],
    );
  }

  Widget _buildAudioPlayerWidget(
      ThemeData theme, AppLocalizations? localizations) {
    final ColorScheme colors = theme.colorScheme;
    if (_isAudioLoading) {
      return const Center(
          child: Padding(
        padding: EdgeInsets.symmetric(vertical: 20.0),
        child: CircularProgressIndicator(strokeWidth: 2.5),
      ));
    }
    if (_audioPlayer == null) {
      return Row(children: [
        Icon(Icons.error_outline_rounded,
            color: theme.colorScheme.error, size: 20),
        const SizedBox(width: 8),
        Text(localizations?.audioNotAvailable ??
            "Audio non disponible ou erreur")
      ]);
    }
    return Row(
      children: [
        // Animated Play/Pause Icon Button
        IconButton(
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) =>
                ScaleTransition(scale: animation, child: child),
            child: Icon(
              _isAudioPlaying
                  ? Icons.pause_circle_filled_rounded
                  : Icons.play_circle_filled_rounded,
              key: ValueKey<bool>(_isAudioPlaying), // Key for animation
              color: theme.colorScheme.primary,
              size: 40,
            ),
          ),
          tooltip: _isAudioPlaying
              ? (localizations?.pauseTooltip ?? 'Pause')
              : (localizations?.playTooltip ?? 'Lecture'),
          onPressed: () {
            if (_isAudioPlaying) {
              _audioPlayer!.pause();
            } else {
              _audioPlayer!.play();
            }
          },
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 6.0,
                  thumbShape:
                      const RoundSliderThumbShape(enabledThumbRadius: 8.0),
                  overlayShape:
                      const RoundSliderOverlayShape(overlayRadius: 16.0),
                  activeTrackColor: colors.primary,
                  inactiveTrackColor: colors.primary.withOpacity(0.3),
                  thumbColor: colors.primary,
                  overlayColor: colors.primary.withOpacity(0.2),
                ),
                child: Slider(
                  value: _audioPosition.inSeconds
                      .toDouble()
                      .clamp(0.0, _audioDuration.inSeconds.toDouble()),
                  min: 0.0,
                  max: _audioDuration.inSeconds.toDouble() > 0
                      ? _audioDuration.inSeconds.toDouble()
                      : 1.0, // Avoid max <= min
                  onChanged: (value) {
                    _audioPlayer!.seek(Duration(seconds: value.toInt()));
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_formatDuration(_audioPosition),
                        style: GoogleFonts.inter(
                            fontSize: 12,
                            color: theme.colorScheme.onSurfaceVariant)),
                    Text(_formatDuration(_audioDuration),
                        style: GoogleFonts.inter(
                            fontSize: 12,
                            color: theme.colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentTile(String docName, String? docUrl, ThemeData theme,
      AppLocalizations? localizations) {
    final IconData iconData = _getIconForFilename(docName);
    final ColorScheme colors = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => _launchUrl(docUrl),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
          child: Row(
            children: [
              Icon(iconData, color: theme.colorScheme.primary, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  docName,
                  style: GoogleFonts.inter(
                      fontSize: 14, fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.download_for_offline_rounded,
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                  size: 22),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForFilename(String filename) {
    final extension = p.extension(filename).toLowerCase();
    switch (extension) {
      case '.pdf':
        return Icons.picture_as_pdf_rounded;
      case '.doc':
      case '.docx':
        return Icons.description_rounded;
      case '.txt':
        return Icons.text_snippet_rounded;
      case '.jpg':
      case '.jpeg':
      case '.png':
      case '.gif':
        return Icons.image_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }
}
