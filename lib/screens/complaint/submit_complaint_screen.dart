// lib/screens/submit_complaint_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:provider/provider.dart'; // Added import
import 'package:citoyen_app/providers/complaint_provider.dart'; // Adjust path as needed

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
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

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
  String? _audioPath;
  PlatformFile? _preuveFile; // Changed from _evidenceFile to _preuveFile

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

    _animationController.forward();
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    _animationController.dispose();
    _submitAnimationController.dispose();
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
        photoPath: _photoFile?.path, // Use .path for XFile
        videoPath: _videoFile?.path, // Use .path for XFile
        voiceRecordPath: _voiceRecordFile?.path, // Use .path for File
        evidencePath: _preuveFile?.path, // Use .path for PlatformFile
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

  // Placeholder for file picking logic
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
  }  Future<void> _recordVoice() async {
    if (_isRecording) {
      _audioRecorder.stop();
      setState(() {
        _isRecording = false;
      });
    } else {
      if (await _audioRecorder.hasPermission()) {
  final directory = await getApplicationDocumentsDirectory();
  final path = p.join(directory.path, 'audio_${DateTime.now().millisecondsSinceEpoch}.m4a');
  
  // Fixed: Provide RecordConfig as first positional argument
  await _audioRecorder.start(
    const RecordConfig(
      encoder: AudioEncoder.aacLc, // You can choose different encoders
      bitRate: 128000,
      sampleRate: 44100,
    ),
    path: path,
  );
  
  setState(() {
    _isRecording = true;
    _audioPath = path;
    _voiceRecordFile = File(path);
  });
}
    }
  }

  Future<void> _playRecordedVoice() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
      setState(() {
        _isPlaying = false;
      });
    } else {
      if (_audioPath != null) {
        await _audioPlayer.play(DeviceFileSource(_audioPath!));
        setState(() {
          _isPlaying = true;
        });
        _audioPlayer.onPlayerComplete.listen((event) {
          setState(() {
            _isPlaying = false;
          });
        });
      } else {
        _showSnackBar('Aucun enregistrement vocal disponible.');
      }
    }
  }  Future<void> _pickPreuve() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
    );

    if (result != null) {
      setState(() => _preuveFile = result.files.first);
    }
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
            expandedHeight: 120,
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
                    Color.fromARGB(255, 25, 4, 219),
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
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
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
                              delay: 1000,
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFF7FAFC),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.feedback_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Votre voix compte',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1A202C),
                      ),
                    ),
                    Text(
                      'Aidez-nous à améliorer nos services',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF718096),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
            delay / 1200,
            (delay + 400) / 1200,
            curve: Curves.easeOutCubic,
          ),
        ));

        return FadeTransition(
          opacity: delayedAnimation,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - delayedAnimation.value)),
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
      icon: Icons.location_city,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: DropdownButtonFormField<String>(
          value: _selectedMunicipalityId,
          hint: Text(
            'Sélectionner une municipalité',
            style: GoogleFonts.inter(
              color: const Color(0xFF9CA3AF),
              fontSize: 14,
            ),
          ),
          decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            prefixIcon: Icon(
              Icons.location_on,
              color: const Color(0xFF667EEA),
              size: 20,
            ),
          ),
          items: _municipalities.map((m) {
            return DropdownMenuItem<String>(
              value: m['id'],
              child: Text(
                m['name'],
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF374151),
                ),
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() => _selectedMunicipalityId = value);
          },
          validator: (value) => value == null ? 'Champ obligatoire' : null,
        ),
      ),
    );
  }

  Widget _buildSubjectSection(ThemeData theme) {
    return _buildSection(
      title: 'Sujet de la Réclamation',
      isRequired: true,
      icon: Icons.subject,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextFormField(
          controller: _subjectController,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: const Color(0xFF374151),
          ),
          decoration: InputDecoration(
            hintText: 'Ex: Retard de service, Problème avec un agent',
            hintStyle: GoogleFonts.inter(
              color: const Color(0xFF9CA3AF),
              fontSize: 14,
            ),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            prefixIcon: Icon(
              Icons.edit_outlined,
              color: const Color(0xFF667EEA),
              size: 20,
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Veuillez entrer un sujet.';
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
      icon: Icons.description,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextFormField(
          controller: _descriptionController,
          maxLines: 6,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: const Color(0xFF374151),
          ),
          decoration: InputDecoration(
            hintText: 'Donnez tous les détails pertinents ici...',
            hintStyle: GoogleFonts.inter(
              color: const Color(0xFF9CA3AF),
              fontSize: 14,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.all(16),
            alignLabelWithHint: true,
          ),
          validator: (value) {
            if (value == null || value.trim().length < 20) {
              return 'Veuillez fournir une description d\'au moins 20 caractères.';
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget _buildAttachmentsSection(ThemeData theme) {
    return _buildSection(
      title: 'Pièces Jointes',
      isRequired: false,
      icon: Icons.attach_file,
      child: Column(
        children: [
          _buildAttachmentButton(
            icon: Icons.camera_alt,
            label: 'Joindre une Photo',
            subtitle: _photoFile != null ? 'Photo sélectionnée' : 'Optionnel',
            onTap: _pickImage,
            isSelected: _photoFile != null,
          ),
          const SizedBox(height: 12),
          _buildAttachmentButton(
            icon: Icons.videocam,
            label: 'Joindre une Vidéo',
            subtitle: _videoFile != null ? 'Vidéo sélectionnée' : 'Optionnel',
            onTap: _pickVideo,
            isSelected: _videoFile != null,
          ),
          const SizedBox(height: 12),
          _buildAttachmentButton(
            icon: Icons.mic,
            label: 'Joindre une Note Vocale',
            subtitle:
                _voiceRecordFile != null ? 'Audio enregistré' : 'Optionnel',
            onTap: _recordVoice,
            isSelected: _voiceRecordFile != null,
          ),
          const SizedBox(height: 12),
          _buildAttachmentButton(
            icon: Icons.description,
            label: 'Joindre une Preuve',
            subtitle: _preuveFile != null
                ? _preuveFile!.name
                : 'Requis - PDF, DOC, Image',
            onTap: _pickPreuve,
            isSelected: _preuveFile != null,
            isRequired: true,
          ),
        ],
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
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFE53E3E),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildAttachmentButton({
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
    required bool isSelected,
    bool isRequired = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF667EEA).withOpacity(0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF667EEA)
                : isRequired
                    ? const Color(0xFFE53E3E).withOpacity(0.3)
                    : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF667EEA)
                    : const Color(0xFF667EEA).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : const Color(0xFF667EEA),
                size: 20,
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
                        label,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF374151),
                        ),
                      ),
                      if (isRequired) ...[
                        const SizedBox(width: 4),
                        Text(
                          '*',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFE53E3E),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: isSelected
                          ? const Color(0xFF667EEA)
                          : const Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(ThemeData theme) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF667EEA),
                  Color(0xFF764BA2),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF667EEA).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitComplaint,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isSubmitting
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                            strokeWidth: 2,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Soumission en cours...',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      'Soumettre la Réclamation',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }
}

import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';


import 'package:path_provider/path_provider.dart';



  Widget _buildVoiceRecordingSection(ThemeData theme) {
    return _buildSection(
      title: 'Enregistrement Vocal (Optionnel)',
      isRequired: false,
      icon: Icons.mic,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _recordVoice,
                  icon: Icon(_isRecording ? Icons.stop : Icons.mic),
                  label: Text(_isRecording ? 'Arrêter l\'enregistrement' : 'Enregistrer un message vocal'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isRecording ? Colors.redAccent : theme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              if (_audioPath != null)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: ElevatedButton.icon(
                    onPressed: _playRecordedVoice,
                    icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                    label: Text(_isPlaying ? 'Pause' : 'Écouter'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isPlaying ? Colors.orangeAccent : Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          if (_audioPath != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'Fichier vocal: ${p.basename(_audioPath!)}',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ),
        ],
      ),
    );
  }

