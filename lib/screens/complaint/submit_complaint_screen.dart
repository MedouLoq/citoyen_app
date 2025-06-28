// lib/screens/submit_complaint_screen.dart
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:citoyen_app/providers/complaint_provider.dart';

class SubmitComplaintScreen extends StatefulWidget {
  const SubmitComplaintScreen({Key? key}) : super(key: key);

  @override
  State<SubmitComplaintScreen> createState() => _SubmitComplaintScreenState();
}

class _SubmitComplaintScreenState extends State<SubmitComplaintScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();

  late AnimationController _animationController;
  late AnimationController _submitAnimationController;
  late AnimationController _recordingPulseController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  // TODO: Fetch municipalities from an API
  final List<Map<String, dynamic>> _municipalities = [
    {'id': '12', 'name': 'Tevragh-Zeina'},
    {'id': '13', 'name': 'Ksar'},
    {'id': '14', 'name': 'Teyarett'},
    {'id': '16', 'name': 'Toujounine'},
    {'id': '17', 'name': 'Sebkha'},
    {'id': '18', 'name': 'El Mina'},
    {'id': '19', 'name': 'Araffat'},
    {'id': '20', 'name': 'Riyadh'},
    {'id': '15', 'name': 'Dar Naim '},
  ];
  String? _selectedMunicipalityId;

  XFile? _photoFile;
  XFile? _videoFile;
  File? _voiceRecordFile;
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isRecording = false;
  bool _isPlaying = false;
  bool _isStoppingRecording = false;
  String? _audioPath;
  Duration _recordingDuration = Duration.zero;
  Duration _playbackPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  Timer? _recordingTimer;
  PlatformFile? _preuveFile;

  bool _isSubmitting = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _submitAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _recordingPulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _submitAnimationController,
      curve: Curves.elasticOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _recordingPulseController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();

    // Setup audio player listeners
    _audioPlayer.onPositionChanged.listen((position) {
      if (mounted) {
        setState(() {
          _playbackPosition = position;
        });
      }
    });

    _audioPlayer.onDurationChanged.listen((duration) {
      if (mounted) {
        setState(() {
          _totalDuration = duration;
        });
      }
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _playbackPosition = Duration.zero;
        });
      }
    });
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _subjectController.dispose();
    _descriptionController.dispose();
    _animationController.dispose();
    _submitAnimationController.dispose();
    _recordingPulseController.dispose();
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _submitComplaint() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedMunicipalityId == null) {
      _showSnackBar('Veuillez sélectionner une municipalité.');
      return;
    }
    if (_preuveFile == null) {
      _showSnackBar('Veuillez joindre une preuve (document requis).');
      return;
    }

    setState(() => _isSubmitting = true);
    _submitAnimationController.forward();

    try {
      final complaintProvider =
          Provider.of<ComplaintProvider>(context, listen: false);
      final success = await complaintProvider.submitComplaint(
        subject: _subjectController.text,
        description: _descriptionController.text,
        municipalityId: _selectedMunicipalityId,
        photoPath: _photoFile?.path,
        videoPath: _videoFile?.path,
        voiceRecordPath: _voiceRecordFile?.path,
        evidencePath: _preuveFile?.path,
      );

      if (success) {
        _showSnackBar('Réclamation soumise avec succès!', isError: false);
        if (mounted) Navigator.pop(context);
      } else {
        _showSnackBar(
            'Échec de la soumission de la réclamation. ' +
                complaintProvider.errorMessage,
            isError: true);
      }
    } catch (e) {
      _showSnackBar('Une erreur inattendue est survenue: $e', isError: true);
    } finally {
      setState(() => _isSubmitting = false);
      _submitAnimationController.reset();
    }
  }

  void _showSnackBar(String message, {bool isError = true}) {
    if (!mounted) return;
    final snackBarColor =
        isError ? const Color(0xFFE53E3E) : const Color(0xFF38A169);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: snackBarColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );
    if (image != null) {
      setState(() => _photoFile = image);
    }
  }

  Future<void> _pickVideo() async {
    final ImagePicker picker = ImagePicker();
    final XFile? video = await picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      setState(() => _videoFile = video);
    }
  }

  Future<void> _recordVoice() async {
    if (_isRecording || _isStoppingRecording) {
      // Stop recording
      if (_isRecording && !_isStoppingRecording) {
        setState(() {
          _isStoppingRecording = true;
        });

        try {
          _recordingTimer?.cancel();
          _recordingPulseController.stop();
          _recordingPulseController.reset();

          final path = await _audioRecorder.stop();

          setState(() {
            _isRecording = false;
            _isStoppingRecording = false;
            if (path != null && path.isNotEmpty) {
              _audioPath = path;
              _voiceRecordFile = File(path);
              print('Recording saved to: $path'); // Debug log
            }
          });
        } catch (e) {
          _showSnackBar('Erreur lors de l\'arrêt de l\'enregistrement: $e');
          setState(() {
            _isRecording = false;
            _isStoppingRecording = false;
          });
        }
      }
    } else {
      // Start recording
      if (await _audioRecorder.hasPermission()) {
        try {
          final directory = await getApplicationDocumentsDirectory();
          final path = p.join(directory.path,
              'voice_${DateTime.now().millisecondsSinceEpoch}.m4a');

          await _audioRecorder.start(
            const RecordConfig(
              encoder: AudioEncoder.aacLc,
              bitRate: 128000,
              sampleRate: 44100,
            ),
            path: path,
          );

          setState(() {
            _isRecording = true;
            _isStoppingRecording = false;
            _recordingDuration = Duration.zero;
          });

          _recordingPulseController.repeat(reverse: true);
          _startRecordingTimer();
        } catch (e) {
          _showSnackBar('Erreur lors du démarrage de l\'enregistrement: $e');
        }
      } else {
        _showSnackBar('Permission d\'enregistrement audio refusée');
      }
    }
  }

  void _startRecordingTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isRecording && mounted) {
        setState(() {
          _recordingDuration =
              Duration(seconds: _recordingDuration.inSeconds + 1);
        });
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _playRecordedVoice() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
      setState(() {
        _isPlaying = false;
      });
    } else {
      if (_audioPath != null && File(_audioPath!).existsSync()) {
        try {
          await _audioPlayer.play(DeviceFileSource(_audioPath!));
          setState(() {
            _isPlaying = true;
          });
        } catch (e) {
          _showSnackBar('Erreur lors de la lecture: $e');
        }
      } else {
        _showSnackBar('Aucun enregistrement vocal disponible.');
      }
    }
  }

  Future<void> _deleteRecording() async {
    // Stop playback if playing
    if (_isPlaying) {
      await _audioPlayer.stop();
    }

    // Stop recording if recording
    if (_isRecording) {
      _recordingTimer?.cancel();
      _recordingPulseController.stop();
      _recordingPulseController.reset();
      try {
        await _audioRecorder.stop();
      } catch (e) {
        print('Error stopping recorder: $e');
      }
    }

    // Delete file if exists
    if (_audioPath != null) {
      try {
        final file = File(_audioPath!);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        print('Error deleting recording: $e');
      }
    }

    // Reset all recording-related state completely
    setState(() {
      _audioPath = null;
      _voiceRecordFile = null;
      _isPlaying = false;
      _isRecording = false;
      _isStoppingRecording = false;
      _recordingDuration = Duration.zero;
      _playbackPosition = Duration.zero;
      _totalDuration = Duration.zero;
    });
  }

  Future<void> _pickPreuve() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
    );

    if (result != null) {
      setState(() => _preuveFile = result.files.first);
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
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          // Beautiful App Bar
          SliverAppBar(
            expandedHeight: 140,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF667EEA),
                    Color.fromARGB(255, 7, 50, 241),
                  ],
                ),
              ),
              child: FlexibleSpaceBar(
                title: Text(
                  'Déposer une Réclamation',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                centerTitle: true,
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF667EEA),
                        Color.fromARGB(255, 7, 50, 241),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.feedback_rounded,
                      color: Colors.white.withOpacity(0.3),
                      size: 80,
                    ),
                  ),
                ),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // Main Content
          SliverToBoxAdapter(
            child: AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Welcome Card
                            _buildWelcomeCard(),
                            const SizedBox(height: 24),

                            // Municipality Section
                            _buildAnimatedSection(
                              delay: 200,
                              child: _buildMunicipalitySection(theme),
                            ),
                            const SizedBox(height: 24),

                            // Subject Section
                            _buildAnimatedSection(
                              delay: 400,
                              child: _buildSubjectSection(theme),
                            ),
                            const SizedBox(height: 24),

                            // Description Section
                            _buildAnimatedSection(
                              delay: 600,
                              child: _buildDescriptionSection(theme),
                            ),
                            const SizedBox(height: 24),

                            // Voice Recording Section
                            _buildAnimatedSection(
                              delay: 800,
                              child: _buildVoiceRecordingSection(theme),
                            ),
                            const SizedBox(height: 24),

                            // Attachments Section
                            _buildAnimatedSection(
                              delay: 1000,
                              child: _buildAttachmentsSection(theme),
                            ),
                            const SizedBox(height: 32),

                            // Submit Button
                            _buildAnimatedSection(
                              delay: 1200,
                              child: _buildSubmitButton(theme),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            const Color(0xFFF7FAFC),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 25,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667EEA), Color.fromARGB(255, 7, 50, 241)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF667EEA).withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Icon(
              Icons.campaign_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Votre voix compte',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A202C),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Aidez-nous à améliorer nos services ensemble',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF718096),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedSection({required int delay, required Widget child}) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, _) {
        final delayedAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            delay / 1400,
            (delay + 400) / 1400,
            curve: Curves.easeOutCubic,
          ),
        ));

        return FadeTransition(
          opacity: delayedAnimation,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - delayedAnimation.value)),
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildMunicipalitySection(ThemeData theme) {
    return _buildSection(
      title: 'Municipalité Concernée',
      isRequired: true,
      icon: Icons.location_city_rounded,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: DropdownButtonFormField<String>(
          value: _selectedMunicipalityId,
          decoration: const InputDecoration(
            hintText: 'Sélectionnez une municipalité',
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
          items: _municipalities.map((municipality) {
            return DropdownMenuItem<String>(
              value: municipality['id'],
              child: Text(
                municipality['name'],
                style: GoogleFonts.inter(fontSize: 15),
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() => _selectedMunicipalityId = value);
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez sélectionner une municipalité';
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget _buildSubjectSection(ThemeData theme) {
    return _buildSection(
      title: 'Sujet de la Réclamation',
      isRequired: true,
      icon: Icons.title_rounded,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextFormField(
          controller: _subjectController,
          style: GoogleFonts.inter(fontSize: 15),
          decoration: const InputDecoration(
            hintText: 'Résumez votre réclamation en quelques mots',
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Le sujet est requis';
            }
            if (value.trim().length < 5) {
              return 'Le sujet doit contenir au moins 5 caractères';
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget _buildDescriptionSection(ThemeData theme) {
    return _buildSection(
      title: 'Description Détaillée',
      isRequired: true,
      icon: Icons.description_rounded,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextFormField(
          controller: _descriptionController,
          maxLines: 5,
          style: GoogleFonts.inter(fontSize: 15, height: 1.5),
          decoration: const InputDecoration(
            hintText: 'Décrivez votre réclamation en détail...',
            border: InputBorder.none,
            contentPadding: EdgeInsets.all(20),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'La description est requise';
            }
            if (value.trim().length < 20) {
              return 'La description doit contenir au moins 20 caractères';
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget _buildVoiceRecordingSection(ThemeData theme) {
    return _buildSection(
      title: 'Message Vocal (Optionnel)',
      isRequired: false,
      icon: Icons.mic_rounded,
      child: Container(
        // Fixed height to prevent layout shifts and overflow
        constraints: const BoxConstraints(
          minHeight: 180,
          maxHeight: 180,
        ),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              const Color(0xFFF8FAFC),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Recording State: No recording exists
            if (_audioPath == null &&
                !_isRecording &&
                !_isStoppingRecording) ...[
              GestureDetector(
                onTap: _recordVoice,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromARGB(255, 7, 50, 241),
                        Color.fromARGB(255, 7, 50, 241)
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF667EEA).withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.mic_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Appuyez pour enregistrer',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: const Color(0xFF4A5568),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              Flexible(
                child: Text(
                  'Enregistrez un message vocal pour accompagner votre réclamation',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF718096),
                    height: 1.3,
                  ),
                ),
              ),
            ]

            // Recording State: Currently recording
            else if (_isRecording || _isStoppingRecording) ...[
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _isStoppingRecording ? 1.0 : _pulseAnimation.value,
                    child: GestureDetector(
                      onTap: _isStoppingRecording ? null : _recordVoice,
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color:
                              _isStoppingRecording ? Colors.grey : Colors.red,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: (_isStoppingRecording
                                      ? Colors.grey
                                      : Colors.red)
                                  .withOpacity(0.4),
                              blurRadius: 25,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Icon(
                          _isStoppingRecording
                              ? Icons.hourglass_empty
                              : Icons.stop_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: (_isStoppingRecording ? Colors.grey : Colors.red)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _isStoppingRecording ? Colors.grey : Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _isStoppingRecording
                          ? 'Arrêt en cours...'
                          : 'Enregistrement... ${_formatDuration(_recordingDuration)}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: _isStoppingRecording ? Colors.grey : Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _isStoppingRecording
                    ? 'Veuillez patienter...'
                    : 'Appuyez sur le bouton pour arrêter',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: const Color(0xFF718096),
                ),
              ),
            ]

            // Recording State: Recording exists
            else if (_audioPath != null) ...[
              // Playback controls
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Play/Pause button
                  GestureDetector(
                    onTap: _playRecordedVoice,
                    child: Container(
                      width: 55,
                      height: 55,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _isPlaying
                              ? [Colors.orange, Colors.deepOrange]
                              : [
                                  const Color(0xFF38A169),
                                  const Color(0xFF2F855A)
                                ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (_isPlaying
                                    ? Colors.orange
                                    : const Color(0xFF38A169))
                                .withOpacity(0.3),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        _isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                  ),

                  // Recording info
                  Flexible(
                    child: Column(
                      children: [
                        Icon(
                          Icons.audiotrack_rounded,
                          color: const Color(0xFF38A169),
                          size: 20,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Enregistrement prêt',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: const Color(0xFF38A169),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (_totalDuration.inMilliseconds > 0) ...[
                          const SizedBox(height: 2),
                          Text(
                            '${_formatDuration(_playbackPosition)} / ${_formatDuration(_totalDuration)}',
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              color: const Color(0xFF38A169),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Delete button
                  GestureDetector(
                    onTap: _deleteRecording,
                    child: Container(
                      width: 55,
                      height: 55,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE53E3E), Color(0xFFC53030)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE53E3E).withOpacity(0.3),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.delete_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Progress bar
              if (_totalDuration.inMilliseconds > 0) ...[
                Container(
                  width: double.infinity,
                  height: 3,
                  decoration: BoxDecoration(
                    color: const Color(0xFF38A169).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: _totalDuration.inMilliseconds > 0
                        ? (_playbackPosition.inMilliseconds /
                                _totalDuration.inMilliseconds)
                            .clamp(0.0, 1.0)
                        : 0.0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF38A169),
                        borderRadius: BorderRadius.circular(1.5),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
              ],
              Text(
                'Appuyez sur lecture pour écouter votre enregistrement',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: const Color(0xFF38A169),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentsSection(ThemeData theme) {
    return _buildSection(
      title: 'Pièces Jointes',
      isRequired: false,
      icon: Icons.attach_file_rounded,
      child: Column(
        children: [
          // Photo attachment
          _buildAttachmentCard(
            title: 'Photo',
            subtitle:
                _photoFile != null ? 'Photo sélectionnée' : 'Ajouter une photo',
            icon: Icons.photo_camera_rounded,
            isSelected: _photoFile != null,
            onTap: _pickImage,
            color: const Color(0xFF3182CE),
          ),
          const SizedBox(height: 16),

          // Video attachment
          _buildAttachmentCard(
            title: 'Vidéo',
            subtitle:
                _videoFile != null ? 'Vidéo sélectionnée' : 'Ajouter une vidéo',
            icon: Icons.videocam_rounded,
            isSelected: _videoFile != null,
            onTap: _pickVideo,
            color: const Color(0xFF805AD5),
          ),
          const SizedBox(height: 16),

          // Evidence document (required)
          _buildAttachmentCard(
            title: 'Preuve (Requis)',
            subtitle:
                _preuveFile != null ? _preuveFile!.name : 'Ajouter un document',
            icon: Icons.description_rounded,
            isSelected: _preuveFile != null,
            onTap: _pickPreuve,
            isRequired: true,
            color: const Color(0xFFD69E2E),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required Color color,
    bool isRequired = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? color.withOpacity(0.1)
                  : Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isSelected ? color : color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1A202C),
                        ),
                      ),
                      if (isRequired) ...[
                        const SizedBox(width: 4),
                        Text(
                          '*',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: isSelected ? color : const Color(0xFF718096),
                      fontWeight:
                          isSelected ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withOpacity(0.1)
                    : const Color(0xFFF7FAFC),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isSelected
                    ? Icons.check_circle_rounded
                    : Icons.add_circle_outline_rounded,
                color: isSelected ? color : const Color(0xFF718096),
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitComplaint,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF667EEA),
                foregroundColor: Colors.white,
                elevation: 12,
                shadowColor: const Color(0xFF667EEA).withOpacity(0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: _isSubmitting
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'Soumission en cours...',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.send_rounded,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Soumettre la Réclamation',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required bool isRequired,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF667EEA).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF667EEA),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A202C),
              ),
            ),
            if (isRequired) ...[
              const SizedBox(width: 4),
              Text(
                '*',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),
        child,
      ],
    );
  }
}
