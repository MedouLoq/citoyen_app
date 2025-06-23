// lib/screens/complaint_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:citoyen_app/providers/complaint_provider.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';
import 'package:just_audio/just_audio.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path/path.dart' as p;

class ComplaintDetailScreen extends StatefulWidget {
  final String complaintId;

  const ComplaintDetailScreen({
    Key? key,
    required this.complaintId,
  }) : super(key: key);

  @override
  State<ComplaintDetailScreen> createState() => _ComplaintDetailScreenState();
}

class _ComplaintDetailScreenState extends State<ComplaintDetailScreen>
    with SingleTickerProviderStateMixin {
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
      duration: const Duration(milliseconds: 800),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchDetails();
      _staggerController.forward();
    });
  }

  Future<void> _fetchDetails() async {
    final provider = Provider.of<ComplaintProvider>(context, listen: false);
    await provider.fetchComplaintDetail(widget.complaintId);
    if (mounted && provider.selectedComplaint != null) {
      final complaint = provider.selectedComplaint!;
      _initializeMediaPlayers(complaint);
    }
  }

  void _initializeMediaPlayers(Map<String, dynamic> complaint) {
    _initializeVideoPlayer(complaint['video_url']);
    _initializeAudioPlayer(complaint['voice_record_url']);
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
    _staggerController.dispose();
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

    return Scaffold(
      backgroundColor: colors.surface,
      body: Consumer<ComplaintProvider>(
        builder: (context, complaintProvider, _) {
          if (complaintProvider.isLoading &&
              complaintProvider.selectedComplaint == null) {
            return _buildLoadingState(colors);
          } else if (complaintProvider.errorMessage.isNotEmpty &&
              complaintProvider.selectedComplaint == null) {
            return _buildErrorState(complaintProvider.errorMessage, colors);
          } else if (complaintProvider.selectedComplaint == null) {
            return _buildErrorState(
              complaintProvider.errorMessage.isNotEmpty
                  ? complaintProvider.errorMessage
                  : 'Réclamation non trouvée',
              colors,
            );
          } else {
            final complaint = complaintProvider.selectedComplaint!;
            final String? photoUrl = complaint['photo_url'] as String?;
            return _buildComplaintDetailContent(
                complaint, photoUrl, theme, safePadding, screenWidth);
          }
        },
      ),
    );
  }

  Widget _buildLoadingState(ColorScheme colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: colors.primary, strokeWidth: 3),
          const SizedBox(height: 20),
          Text(
            'Chargement des détails...',
            style:
                GoogleFonts.inter(color: colors.onSurfaceVariant, fontSize: 16),
          )
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildErrorState(String message, ColorScheme colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, color: colors.error, size: 60),
            const SizedBox(height: 20),
            Text(
              'Oups! Erreur',
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
              label: const Text('Retour'),
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
  Widget _buildComplaintDetailContent(
      Map<String, dynamic> complaint,
      String? photoUrl,
      ThemeData theme,
      EdgeInsets safePadding,
      double screenWidth) {
    final ColorScheme colors = theme.colorScheme;

    // Format dates
    String formattedCreatedDate = 'Date inconnue';
    try {
      final date = DateTime.parse(complaint['created_at']);
      formattedCreatedDate =
          DateFormat('dd MMMM yyyy, HH:mm', 'fr_FR').format(date);
    } catch (e) {
      print("Error parsing date: $e");
    }

    // Status Configuration
    final statusConfig = _getStatusConfig(complaint['status'], colors);
    final statusLabel =
        statusConfig['label'] ?? complaint['status_display'] ?? 'Inconnu';
    final statusColor = statusConfig['color'] ?? colors.onSurfaceVariant;
    final statusIcon = statusConfig['icon'] ?? Icons.help_outline;

    // Extract other attachments
    final String? videoUrl = complaint['video_url'] as String?;
    final String? voiceRecordUrl = complaint['voice_record_url'] as String?;
    final String? evidenceUrl = complaint['evidence_url'] as String?;
    final String? evidenceName = complaint['evidence_name'] as String?;

    // Animation Interval Calculation
    const double intervalLength = 0.15;
    double start = 0.0;

    Widget animateItem(Widget child, {double delayFactor = 1.0}) {
      final intervalStart = start;
      final intervalEnd = (start + intervalLength).clamp(0.0, 1.0);
      start = intervalEnd;

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
              offset: Offset(0, (1.0 - animationValue) * 20),
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
            tooltip: 'Retour',
            onPressed: () => Navigator.of(context).pop(),
          ),
          flexibleSpace: FlexibleSpaceBar(
            titlePadding:
                const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
            centerTitle: false,
            title: Text(
              'Détail de la Réclamation',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                color: colors.onPrimary,
                fontSize: 16,
              ),
            ),
            background: photoUrl != null && photoUrl.isNotEmpty
                ? _buildHeaderImage(photoUrl, colors)
                : Container(color: colors.primary),
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
              const SizedBox(height: 24),

              // Subject Section
              animateItem(
                  _buildSectionTitle('Sujet', Icons.title_rounded, theme)),
              const SizedBox(height: 10),
              animateItem(_buildInfoCard(
                child: Text(
                  complaint['subject'] ?? 'Sujet non spécifié',
                  style: GoogleFonts.inter(
                      fontSize: 16,
                      color: colors.onSurface,
                      fontWeight: FontWeight.w600),
                ),
                theme: theme,
              )),
              const SizedBox(height: 24),

              // Description Section
              animateItem(_buildSectionTitle(
                  'Description', Icons.description_outlined, theme)),
              const SizedBox(height: 10),
              animateItem(_buildInfoCard(
                child: Text(
                  complaint['description'] ?? 'Pas de description fournie.',
                  style: GoogleFonts.inter(
                      fontSize: 15, color: colors.onSurface, height: 1.5),
                ),
                theme: theme,
              )),
              const SizedBox(height: 24),

              // Municipality Section
              if (complaint['municipality'] != null) ...[
                animateItem(_buildSectionTitle('Municipalité Concernée',
                    Icons.location_city_rounded, theme)),
                const SizedBox(height: 10),
                animateItem(_buildInfoCard(
                  child: Row(
                    children: [
                      Icon(Icons.location_on_rounded,
                          color: colors.primary, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          complaint['municipality']['name'] ??
                              'Municipalité inconnue',
                          style: GoogleFonts.inter(
                              fontSize: 15, color: colors.onSurface),
                        ),
                      ),
                    ],
                  ),
                  theme: theme,
                )),
                const SizedBox(height: 24),
              ],

              // Comment Section (if available)
              if (complaint['comment'] != null &&
                  complaint['comment'].toString().isNotEmpty) ...[
                animateItem(_buildSectionTitle(
                    'Commentaire de l\'Administration',
                    Icons.comment_outlined,
                    theme)),
                const SizedBox(height: 10),
                animateItem(_buildInfoCard(
                  child: Text(
                    complaint['comment'],
                    style: GoogleFonts.inter(
                        fontSize: 15, color: colors.onSurface, height: 1.5),
                  ),
                  theme: theme,
                )),
                const SizedBox(height: 24),
              ],

              // Attachments Section
              if (_hasAttachments(complaint)) ...[
                animateItem(_buildSectionTitle(
                    'Pièces Jointes', Icons.attach_file_rounded, theme)),
                const SizedBox(height: 16),

                // Video Player
                if (videoUrl != null && videoUrl.isNotEmpty)
                  animateItem(_buildVideoPlayer(videoUrl, theme)),

                // Audio Player
                if (voiceRecordUrl != null && voiceRecordUrl.isNotEmpty)
                  animateItem(_buildAudioPlayer(voiceRecordUrl, theme)),

                // Evidence Document
                if (evidenceUrl != null && evidenceUrl.isNotEmpty)
                  animateItem(
                      _buildDocumentCard(evidenceUrl, evidenceName, theme)),

                const SizedBox(height: 24),
              ],

              // Citizen Information
              if (complaint['citizen'] != null) ...[
                animateItem(_buildSectionTitle(
                    'Informations du Citoyen', Icons.person_rounded, theme)),
                const SizedBox(height: 10),
                animateItem(_buildCitizenInfo(complaint['citizen'], theme)),
              ],
            ]),
          ),
        ),
      ],
    );
  }

  Map<String, dynamic> _getStatusConfig(String status, ColorScheme colors) {
    switch (status) {
      case 'PENDING':
        return {
          'label': 'En attente',
          'color': colors.secondary,
          'icon': Icons.schedule_rounded,
        };
      case 'REVIEWING':
        return {
          'label': 'En examen',
          'color': Colors.blue,
          'icon': Icons.search_rounded,
        };
      case 'RESOLVED':
        return {
          'label': 'Résolue',
          'color': Colors.green,
          'icon': Icons.check_circle_rounded,
        };
      case 'REJECTED':
        return {
          'label': 'Rejetée',
          'color': colors.error,
          'icon': Icons.cancel_rounded,
        };
      default:
        return {
          'label': status,
          'color': colors.onSurfaceVariant,
          'icon': Icons.help_outline_rounded,
        };
    }
  }

  bool _hasAttachments(Map<String, dynamic> complaint) {
    return (complaint['video_url'] != null &&
            complaint['video_url'].toString().isNotEmpty) ||
        (complaint['voice_record_url'] != null &&
            complaint['voice_record_url'].toString().isNotEmpty) ||
        (complaint['evidence_url'] != null &&
            complaint['evidence_url'].toString().isNotEmpty);
  }

  Widget _buildHeaderImage(String photoUrl, ColorScheme colors) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          photoUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: colors.surfaceVariant,
              child: Center(
                child: Icon(
                  Icons.image_not_supported,
                  color: colors.onSurfaceVariant,
                  size: 48,
                ),
              ),
            );
          },
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                colors.primary.withOpacity(0.3),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, ThemeData theme) {
    return Row(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({required Widget child, required ThemeData theme}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: child,
    );
  }

  Widget _buildVideoPlayer(String videoUrl, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(Icons.videocam, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Vidéo',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          if (_isVideoLoading)
            Container(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_videoController != null &&
              _videoController!.value.isInitialized)
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              child: AspectRatio(
                aspectRatio: _videoController!.value.aspectRatio,
                child: Stack(
                  children: [
                    VideoPlayer(_videoController!),
                    Center(
                      child: IconButton(
                        icon: Icon(
                          _videoController!.value.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                          color: Colors.white,
                          size: 48,
                        ),
                        onPressed: () {
                          setState(() {
                            _videoController!.value.isPlaying
                                ? _videoController!.pause()
                                : _videoController!.play();
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Container(
              height: 200,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, color: theme.colorScheme.error),
                    const SizedBox(height: 8),
                    Text('Erreur de chargement vidéo'),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAudioPlayer(String audioUrl, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.mic, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Enregistrement vocal',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_isAudioLoading)
            Center(child: CircularProgressIndicator())
          else if (_audioPlayer != null)
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    _isAudioPlaying ? Icons.pause : Icons.play_arrow,
                    color: theme.colorScheme.primary,
                  ),
                  onPressed: () {
                    if (_isAudioPlaying) {
                      _audioPlayer!.pause();
                    } else {
                      _audioPlayer!.play();
                    }
                  },
                ),
                Expanded(
                  child: Column(
                    children: [
                      LinearProgressIndicator(
                        value: _audioDuration.inMilliseconds > 0
                            ? _audioPosition.inMilliseconds /
                                _audioDuration.inMilliseconds
                            : 0.0,
                        backgroundColor:
                            theme.colorScheme.outline.withOpacity(0.3),
                        valueColor:
                            AlwaysStoppedAnimation(theme.colorScheme.primary),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(_audioPosition),
                            style: GoogleFonts.inter(fontSize: 12),
                          ),
                          Text(
                            _formatDuration(_audioDuration),
                            style: GoogleFonts.inter(fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            )
          else
            Row(
              children: [
                Icon(Icons.error, color: theme.colorScheme.error),
                const SizedBox(width: 8),
                Text('Erreur de chargement audio'),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildDocumentCard(
      String documentUrl, String? documentName, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _launchUrl(documentUrl),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.attach_file, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Document joint',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    if (documentName != null && documentName.isNotEmpty)
                      Text(
                        documentName,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                  ],
                ),
              ),
              Icon(
                Icons.open_in_new,
                color: theme.colorScheme.primary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCitizenInfo(Map<String, dynamic> citizen, ThemeData theme) {
    return _buildInfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (citizen['full_name'] != null)
            _buildInfoRow('Nom complet', citizen['full_name'], theme),
          if (citizen['nni'] != null)
            _buildInfoRow('NNI', citizen['nni'], theme),
          if (citizen['address'] != null)
            _buildInfoRow('Adresse', citizen['address'], theme),
          if (citizen['municipality'] != null)
            _buildInfoRow(
                'Municipalité', citizen['municipality']['name'], theme),
        ],
      ),
      theme: theme,
    );
  }

  Widget _buildInfoRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
