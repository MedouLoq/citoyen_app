// lib/screens/report_problem_details_screen.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // To check platform
import 'package:shared_preferences/shared_preferences.dart'; // For web storage
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // For native storage
import 'package:geocoding/geocoding.dart'; // Import geocoding package
import 'package:intl/intl.dart'; // For date formatting if needed

// CategoryModel definition (assuming it exists as provided)
class CategoryModel {
  final String id;
  final String name;
  final String logoPath;

  CategoryModel({required this.id, required this.name, required this.logoPath});
}

// Function to get auth token (assuming it exists as provided)
Future<String?> _getAuthToken() async {
  String? token;
  if (kIsWeb) {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('auth_token');
    print("Retrieved token from SharedPreferences (Web): $token");
  } else {
    const storage = FlutterSecureStorage();
    token = await storage.read(key: 'auth_token');
    print("Retrieved token from FlutterSecureStorage (Mobile): $token");
  }
  if (token == null || token.isEmpty) {
    print("Warning: Auth token is null or empty.");
  }
  return token;
}

class ReportProblemDetailsScreen extends StatefulWidget {
  final CategoryModel category;

  const ReportProblemDetailsScreen({Key? key, required this.category})
      : super(key: key);

  @override
  _ReportProblemDetailsScreenState createState() =>
      _ReportProblemDetailsScreenState();
}

class _ReportProblemDetailsScreenState
    extends State<ReportProblemDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();

  // Attachments
  List<XFile> _photoFiles = [];
  XFile? _videoFile;
  File? _voiceRecordFile;
  List<PlatformFile> _documentFiles = [];

  // Map variables
  MapController? _mapController;
  LatLng? _selectedLocation;
  LatLng? _userLocation;
  bool _isLoadingLocation = true;
  List<Marker> _markers = [];

  // Audio recording
  FlutterSoundRecorder? _audioRecorder;
  bool _isRecording = false;
  bool _isRecorderInitialized = false;
  String _recordingPath = '';
  Duration _recordingDuration = Duration.zero;
  Stream<RecordingDisposition>? _recordingStream;

  // Submission and Error State
  bool _isSubmitting = false;
  String _errorMessage = '';

  // --- State Variables for Municipality ID ---
  String? _municipalityId;
  bool _isFetchingMunicipalityId = false;
  String? _municipalityCandidateName;
  // --- End State Variables ---

  // Theme Colors - Reverted to use Theme context
  // Color _primaryColor; // Will be derived from Theme
  // Color _lightBackground; // Will be derived from Theme
  // Color _borderColor; // Will be derived from Theme
  // Color _iconColor; // Will be derived from Theme
  // Color _secondaryTextColor; // Will be derived from Theme

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _requestLocationPermission();
    _initializeAudioRecorder();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _audioRecorder?.closeRecorder();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _requestLocationPermission() async {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
          _errorMessage = 'Les services de localisation sont désactivés';
        });
      }
      _showLocationServiceDialog();
      return;
    }

    // Check location permission
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          setState(() {
            _isLoadingLocation = false;
            _errorMessage = 'Permission de localisation refusée';
          });
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
          _errorMessage = 'Permission de localisation définitivement refusée';
        });
      }
      _showPermissionDialog();
      return;
    }

    // Permission granted, get location
    await _getCurrentLocation();
  }

  void _showLocationServiceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Services de localisation désactivés'),
          content: const Text(
              'Veuillez activer les services de localisation dans les paramètres de votre appareil.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Geolocator.openLocationSettings();
              },
              child: const Text('Paramètres'),
            ),
          ],
        );
      },
    );
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permission requise'),
          content: const Text(
              'Cette application nécessite la permission de localisation pour fonctionner. Veuillez l\'activer dans les paramètres.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Geolocator.openAppSettings();
              },
              child: const Text('Paramètres'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _getCurrentLocation() async {
    if (!mounted) return;
    setState(() {
      _isLoadingLocation = true;
      _errorMessage = '';
    });
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 20),
      );

      if (!mounted) return;
      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
        _selectedLocation = _userLocation;
        _isLoadingLocation = false;
        _updateMarkers();
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _mapController != null && _userLocation != null) {
          _mapController!.move(_userLocation!, 15);
        }
      });

      await _getMunicipalityDetails(position);
    } catch (e) {
      print("Error getting location: $e");
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
          _errorMessage =
              'Erreur de localisation: Impossible d\'obtenir la position.';
        });
        _showSnackBar('Erreur de localisation: $e');
      }
    }
  }

  Future<void> _getMunicipalityDetails(Position? position) async {
    if (position == null) {
      print("Position is null, cannot fetch municipality details.");
      if (mounted) setState(() => _errorMessage = "Position non disponible.");
      return;
    }
    if (_isFetchingMunicipalityId || !mounted) return;

    setState(() {
      _isFetchingMunicipalityId = true;
      _municipalityId = null;
      _municipalityCandidateName = null;
    });

    print(
        "Starting geocoding for Lat: ${position.latitude}, Lon: ${position.longitude}");

    try {
      String? candidateName;

      if (kIsWeb) {
        // Use web-compatible geocoding fallback
        print("Running on web - using fallback geocoding");
        candidateName =
            await _webGeocodingFallback(position.latitude, position.longitude);
      } else {
        // Use native geocoding for mobile
        print("Running on mobile - using native geocoding");
        candidateName =
            await _nativeGeocoding(position.latitude, position.longitude);
      }

      if (!mounted) return;

      print("Municipality Candidate extracted: $candidateName");

      setState(() {
        _municipalityCandidateName = candidateName;
      });

      if (candidateName != null && candidateName.isNotEmpty) {
        print("Fetching ID for candidate: $candidateName");
        String? fetchedId = await _fetchMunicipalityId(
          candidateName,
          position.latitude,
          position.longitude,
        );

        if (!mounted) return;
        print("Fetched Municipality ID: $fetchedId");

        setState(() {
          _municipalityId = fetchedId;
        });

        if (fetchedId == null || fetchedId.isEmpty) {
          _showSnackBar("Municipalité '$candidateName' non trouvée.",
              isError: true);
        }
      } else {
        _showSnackBar("Impossible d'extraire le nom de la municipalité.",
            isError: true);
      }
    } catch (e) {
      print("Error during geocoding or fetching municipality ID: $e");
      if (mounted) {
        _showSnackBar("Erreur (géocodage/municipalité): $e", isError: true);
        setState(() => _errorMessage = "Erreur détermination municipalité.");
      }
    } finally {
      if (mounted) {
        setState(() => _isFetchingMunicipalityId = false);
      }
    }
  }

// Native geocoding for mobile platforms
  Future<String?> _nativeGeocoding(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      ).timeout(const Duration(seconds: 10));

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        print("Native geocoding result: ${place.toJson()}");

        // Extract candidate name with priority
        String? candidateName = place.subAdministrativeArea?.isNotEmpty == true
            ? place.subAdministrativeArea
            : place.locality?.isNotEmpty == true
                ? place.locality
                : place.administrativeArea?.isNotEmpty == true
                    ? place.administrativeArea
                    : place.street?.isNotEmpty == true
                        ? place.street
                        : place.name?.isNotEmpty == true
                            ? place.name
                            : null;

        return candidateName;
      }
      return null;
    } catch (e) {
      print("Native geocoding failed: $e");
      return null;
    }
  }

// Web-compatible geocoding fallback using OpenStreetMap Nominatim
  Future<String?> _webGeocodingFallback(
      double latitude, double longitude) async {
    try {
      // Using OpenStreetMap Nominatim API for reverse geocoding
      final url = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude&zoom=10&addressdetails=1');

      print("Web geocoding URL: $url");

      final response = await http.get(
        url,
        headers: {
          'User-Agent':
              'YourApp/1.0 (your-email@example.com)', // Required by Nominatim
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      print("Web geocoding response status: ${response.statusCode}");
      print("Web geocoding response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data != null && data['address'] != null) {
          final address = data['address'];

          // Extract municipality name from different possible fields
          String? candidateName;

          // Try different address components in priority order
          if (address['city'] != null &&
              address['city'].toString().isNotEmpty) {
            candidateName = address['city'];
          } else if (address['town'] != null &&
              address['town'].toString().isNotEmpty) {
            candidateName = address['town'];
          } else if (address['village'] != null &&
              address['village'].toString().isNotEmpty) {
            candidateName = address['village'];
          } else if (address['municipality'] != null &&
              address['municipality'].toString().isNotEmpty) {
            candidateName = address['municipality'];
          } else if (address['suburb'] != null &&
              address['suburb'].toString().isNotEmpty) {
            candidateName = address['suburb'];
          } else if (address['county'] != null &&
              address['county'].toString().isNotEmpty) {
            candidateName = address['county'];
          } else if (address['state'] != null &&
              address['state'].toString().isNotEmpty) {
            candidateName = address['state'];
          }

          print("Web geocoding extracted candidate: $candidateName");
          return candidateName;
        }
      }

      print("Web geocoding failed: No valid address data");
      return null;
    } catch (e) {
      print("Web geocoding failed with error: $e");
      return null;
    }
  }

// Alternative: Try both methods and use the best result
  Future<String?> _hybridGeocoding(double latitude, double longitude) async {
    String? nativeResult;
    String? webResult;

    // Try native geocoding first (faster if available)
    if (!kIsWeb) {
      try {
        nativeResult = await _nativeGeocoding(latitude, longitude);
        print("Native geocoding result: $nativeResult");
      } catch (e) {
        print("Native geocoding failed: $e");
      }
    }

    // Try web geocoding as fallback or primary method on web
    try {
      webResult = await _webGeocodingFallback(latitude, longitude);
      print("Web geocoding result: $webResult");
    } catch (e) {
      print("Web geocoding failed: $e");
    }

    // Return the best available result
    if (nativeResult != null && nativeResult.isNotEmpty) {
      return nativeResult;
    } else if (webResult != null && webResult.isNotEmpty) {
      return webResult;
    }

    return null;
  }

// Fix the _fetchMunicipalityId method to handle integer response
  Future<String?> _fetchMunicipalityId(
      String candidateName, double lat, double lon) async {
    const String baseUrl = "http://10.0.2.2:8000"; // Ensure this is correct
    final encodedName = Uri.encodeComponent(candidateName.trim());
    final url = Uri.parse(
        "$baseUrl/get_municipality_id/?name=$encodedName&lat=$lat&lon=$lon");

    print("Fetching Municipality ID from URL: $url");

    try {
      final response = await http.get(
        url,
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 15));

      print(
          "Backend Response Status (get_municipality_id): ${response.statusCode}");
      print(
          "Backend Response Body (get_municipality_id): ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Handle both int and String responses from backend
        final dynamic municipalityId = data['municipality_id'];
        String? fetchedId;

        if (municipalityId is int) {
          fetchedId = municipalityId.toString();
        } else if (municipalityId is String) {
          fetchedId = municipalityId.isNotEmpty ? municipalityId : null;
        } else {
          print(
              "Unexpected municipality_id type: ${municipalityId.runtimeType}");
          fetchedId = null;
        }

        print("Parsed municipality_id: $fetchedId");
        return fetchedId;
      } else {
        print(
            "Error fetching municipality ID: Status ${response.statusCode}, Body: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Exception during HTTP request for municipality ID: $e");
      return null;
    }
  }

  void _updateMarkers() {
    if (_selectedLocation == null || !mounted) return;
    setState(() {
      _markers = [
        Marker(
          point: _selectedLocation!,
          width: 40,
          height: 40,
          child: Icon(
            Icons.location_pin,
            color: Colors.red.shade700,
            size: 40,
          ),
        ),
      ];
    });
  }

  Future<void> _initializeAudioRecorder() async {
    try {
      _audioRecorder = FlutterSoundRecorder();
      final microphoneStatus = await Permission.microphone.request();
      if (!microphoneStatus.isGranted) {
        print("Microphone permission denied");
        if (mounted) _showSnackBar("Permission microphone refusée");
        setState(() => _isRecorderInitialized = false);
        return;
      }
      await _audioRecorder!.openRecorder();
      _audioRecorder!
          .setSubscriptionDuration(const Duration(milliseconds: 100));
      if (mounted) setState(() => _isRecorderInitialized = true);
    } catch (e) {
      print("Error initializing audio recorder: $e");
      if (mounted) setState(() => _isRecorderInitialized = false);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      if (source == ImageSource.gallery) {
        final List<XFile> pickedFiles = await picker.pickMultiImage(
          maxWidth: 1200,
          maxHeight: 1200,
          imageQuality: 85,
        );
        if (pickedFiles.isNotEmpty && mounted) {
          setState(() => _photoFiles = pickedFiles.take(3).toList());
        }
      } else {
        final XFile? pickedFile = await picker.pickImage(
          source: source,
          maxWidth: 1200,
          maxHeight: 1200,
          imageQuality: 85,
        );
        if (pickedFile != null && mounted) {
          if (_photoFiles.length < 3) {
            setState(() => _photoFiles.add(pickedFile));
          } else {
            _showSnackBar("Vous ne pouvez joindre que 3 images maximum.");
          }
        }
      }
    } catch (e) {
      if (mounted) _showSnackBar("Erreur sélection d'image: $e");
    }
  }

  // --- Updated Video Picking ---
  Future<void> _pickOrRecordVideo(ImageSource source) async {
    // Request camera permission if needed
    if (source == ImageSource.camera) {
      final cameraStatus = await Permission.camera.request();
      if (!cameraStatus.isGranted) {
        if (mounted) _showSnackBar("Permission caméra refusée");
        return;
      }
    }

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickVideo(source: source);
      if (pickedFile != null && mounted) {
        setState(() {
          _videoFile = pickedFile;
        });
      }
    } catch (e) {
      if (mounted) _showSnackBar("Erreur sélection/enregistrement vidéo: $e");
    }
  }
  // --- End Updated Video Picking ---

  Future<void> _toggleAudioRecording() async {
    if (!_isRecorderInitialized || _audioRecorder == null) {
      if (mounted) _showSnackBar("Enregistreur audio non initialisé");
      return;
    }

    if (_isRecording) {
      try {
        final path = await _audioRecorder!.stopRecorder();
        if (path != null && mounted) {
          setState(() {
            _voiceRecordFile = File(path);
            _isRecording = false;
            _recordingStream = null;
            _recordingDuration = Duration.zero;
          });
          _showSnackBar("Enregistrement terminé: ${p.basename(path)}",
              isError: false);
        }
      } catch (e) {
        print("Error stopping recording: $e");
        if (mounted) _showSnackBar("Erreur lors de l'arrêt: $e");
        setState(() {
          _isRecording = false;
          _recordingStream = null;
        });
      }
    } else {
      try {
        final microphoneStatus = await Permission.microphone.request();
        if (!microphoneStatus.isGranted) {
          if (mounted) _showSnackBar("Permission microphone refusée");
          return;
        }

        final Directory tempDir = await getTemporaryDirectory();
        _recordingPath =
            '${tempDir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.aac';

        await _audioRecorder!.startRecorder(
          toFile: _recordingPath,
          codec: Codec.aacADTS,
        );

        _recordingStream = _audioRecorder!.onProgress;
        _recordingStream?.listen((disposition) {
          if (mounted)
            setState(() => _recordingDuration = disposition.duration);
        });

        if (mounted) {
          setState(() {
            _isRecording = true;
            _voiceRecordFile = null;
          });
          _showSnackBar("Enregistrement en cours...", isError: false);
        }
      } catch (e) {
        print("Error starting recording: $e");
        if (mounted) _showSnackBar("Erreur lors du démarrage: $e");
        setState(() {
          _isRecording = false;
          _recordingStream = null;
        });
      }
    }
  }

  Future<void> _pickDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ["pdf", "doc", "docx", "txt"],
        allowMultiple: true,
      );
      if (result != null && result.files.isNotEmpty && mounted) {
        setState(() => _documentFiles = result.files.take(3).toList());
      }
    } catch (e) {
      if (mounted) _showSnackBar("Erreur sélection de document: $e");
    }
  }

  Future<void> _submitProblem() async {
    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
      _showSnackBar("Veuillez remplir les champs obligatoires.");
      return;
    }
    if (_selectedLocation == null) {
      _showSnackBar("Veuillez sélectionner la position du problème.");
      return;
    }
    if (_isFetchingMunicipalityId) {
      _showSnackBar("Veuillez patienter (municipalité)...");
      return;
    }
    // Optional: Require municipality ID
    /*
    if (_municipalityId == null || _municipalityId!.isEmpty) {
      _showSnackBar("Municipalité non déterminée. Soumission impossible.", isError: true);
      return;
    }
    */

    if (!mounted) return;
    setState(() {
      _isSubmitting = true;
      _errorMessage = '';
    });

    String? authToken = await _getAuthToken();
    if (authToken == null || authToken.isEmpty) {
      _showSnackBar("Erreur: Token d'authentification manquant.");
      if (mounted) setState(() => _isSubmitting = false);
      return;
    }

    try {
      var uri = Uri.parse(
          "http://10.0.2.2:8000/api/problems/report/"); // Ensure correct endpoint
      var request = http.MultipartRequest("POST", uri);
      request.headers['Authorization'] = 'Token $authToken';

      request.fields["description"] = _descriptionController.text;
      request.fields["latitude"] = _selectedLocation!.latitude.toString();
      request.fields["longitude"] = _selectedLocation!.longitude.toString();
      request.fields["category"] = widget.category.id;

      if (_municipalityId != null && _municipalityId!.isNotEmpty) {
        request.fields["municipality"] = _municipalityId!;
        print("Sending Municipality ID: $_municipalityId");
      } else {
        print("Municipality ID is null or empty, not sending field.");
      }

      // Add files
      for (var photoFile in _photoFiles) {
        request.files.add(await http.MultipartFile.fromPath(
            "photo", photoFile.path,
            filename: p.basename(photoFile.path)));
      }
      if (_videoFile != null) {
        request.files.add(await http.MultipartFile.fromPath(
            "video", _videoFile!.path,
            filename: p.basename(_videoFile!.path)));
      }
      if (_voiceRecordFile != null) {
        request.files.add(await http.MultipartFile.fromPath(
            "voice_record", _voiceRecordFile!.path,
            filename: p.basename(_voiceRecordFile!.path)));
      }
      for (var docFile in _documentFiles) {
        if (docFile.path != null) {
          request.files.add(await http.MultipartFile.fromPath(
              "document", docFile.path!,
              filename: docFile.name));
        }
      }

      print("Submitting problem report...");
      var response = await request.send().timeout(const Duration(seconds: 90));

      if (!mounted) return;
      String responseBody = await response.stream.bytesToString();
      print("Submission Response Status: ${response.statusCode}");
      print("Submission Response Body: $responseBody");

      if (response.statusCode == 201) {
        _showSnackBar("Problème signalé avec succès!", isError: false);
        if (mounted) Navigator.pop(context);
      } else {
        String errorMsg = response.reasonPhrase ?? 'Erreur inconnue';
        try {
          var decodedBody = jsonDecode(responseBody);
          errorMsg = decodedBody['detail'] ??
              decodedBody['error'] ??
              decodedBody.toString();
        } catch (_) {
          errorMsg = responseBody.isNotEmpty ? responseBody : errorMsg;
        }
        _showSnackBar("Échec: $errorMsg (Code: ${response.statusCode})",
            isError: true);
        setState(() => _errorMessage = "Échec: $errorMsg");
      }
    } catch (e) {
      print("Error submitting problem: $e");
      if (mounted) {
        _showSnackBar("Erreur réseau/système: $e", isError: true);
        setState(() => _errorMessage = "Erreur: $e");
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = true}) {
    if (!mounted) return;
    // Use Theme colors for SnackBar
    final Color snackBarColor = isError
        ? (Theme.of(context).colorScheme.error)
        : (Theme.of(context).colorScheme.primary);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: snackBarColor,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final EdgeInsets safePadding = MediaQuery.of(context).padding;
    final ThemeData theme = Theme.of(context);
    // Derive colors from theme
    final Color primaryColor = theme.colorScheme.primary;
    final Color onPrimaryColor = theme.colorScheme.onPrimary;
    final Color secondaryContainerColor = theme.colorScheme.secondaryContainer;
    final Color onSecondaryContainerColor =
        theme.colorScheme.onSecondaryContainer;
    final Color errorColor = theme.colorScheme.error;
    final Color surfaceColor = theme.colorScheme.surface;
    final Color onSurfaceColor = theme.colorScheme.onSurface;
    final Color onSurfaceVariantColor = theme.colorScheme.onSurfaceVariant;
    final Color outlineColor = theme.colorScheme.outline;
    final Color lightBackgroundColor =
        theme.colorScheme.surfaceVariant.withOpacity(0.3);
    final Color secondaryTextColor = onSurfaceVariantColor.withOpacity(0.7);
    final Color iconColor =
        primaryColor; // Use primary color for icons by default
    final Color borderColor = outlineColor.withOpacity(0.5);

    return Scaffold(
      backgroundColor: theme.colorScheme.background, // Use theme background
      appBar: AppBar(
        title: Text(
          'Signaler un Problème',
          style: GoogleFonts.inter(
              fontWeight: FontWeight.bold, color: onPrimaryColor),
        ),
        backgroundColor: primaryColor,
        foregroundColor: onPrimaryColor,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Colors.white), // force white here
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + safePadding.bottom),
            children: [
              // Loading/Error/Info Section
              if (_isLoadingLocation)
                const Center(
                        child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator()))
                    .animate()
                    .fadeIn(),
              if (_isFetchingMunicipalityId)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: primaryColor)),
                        const SizedBox(width: 8),
                        Text("Recherche municipalité...",
                            style: GoogleFonts.inter(color: primaryColor)),
                      ]),
                ).animate().fadeIn(),
              if (_errorMessage.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: errorColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: errorColor.withOpacity(0.3)),
                  ),
                  child: Row(children: [
                    Icon(Icons.error_outline, color: errorColor, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Text(_errorMessage,
                            style: GoogleFonts.inter(
                                color: errorColor, fontSize: 13))),
                  ]),
                ).animate().fadeIn(),
              if (_municipalityId != null &&
                  _municipalityId!.isNotEmpty &&
                  !_isFetchingMunicipalityId)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    "Municipalité: ${_municipalityCandidateName ?? ''} (ID: $_municipalityId)",
                    style: GoogleFonts.inter(
                        color: primaryColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ).animate().fadeIn(),
              if (_municipalityId == null &&
                  _municipalityCandidateName != null &&
                  !_isFetchingMunicipalityId &&
                  !_isLoadingLocation)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    "Municipalité '${_municipalityCandidateName}' non trouvée.",
                    style: GoogleFonts.inter(
                        color: Colors.orange.shade900,
                        fontWeight: FontWeight.w500,
                        fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ).animate().fadeIn(),

              // Description Section
              _buildSectionTitle('Description du problème*', theme),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                decoration: _inputDecoration(
                  hintText: 'Décrivez le problème en détail...',
                  theme: theme,
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.trim().isEmpty)
                    return 'Veuillez fournir une description';
                  if (value.trim().length < 10) return 'Minimum 10 caractères';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: Icon(_isRecording ? Icons.stop_circle : Icons.mic,
                    color: _isRecording ? errorColor : iconColor),
                label: Text(
                  _isRecording
                      ? 'Arrêter (${_formatDuration(_recordingDuration)})'
                      : 'Note Vocale',
                  style: GoogleFonts.inter(
                      color: _isRecording ? errorColor : iconColor,
                      fontWeight: FontWeight.w600),
                ),
                onPressed: _toggleAudioRecording,
                style: ElevatedButton.styleFrom(
                  backgroundColor: surfaceColor, // Use surface color
                  foregroundColor: iconColor,
                  elevation: 0,
                  side: BorderSide(color: borderColor),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              if (_voiceRecordFile != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(children: [
                    Icon(Icons.audiotrack, color: primaryColor, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Text(p.basename(_voiceRecordFile!.path),
                            style: const TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis)),
                    IconButton(
                        icon: const Icon(Icons.clear, size: 16),
                        onPressed: () =>
                            setState(() => _voiceRecordFile = null)),
                  ]),
                ),
              const SizedBox(height: 24),

              // Location Section
              _buildAttachmentSection(
                title: 'Emplacement du problème*',
                subtitle: 'Vous devez choisir un emplacement',
                icon: Icons.location_on,
                theme: theme,
                content: Column(
                  children: [
                    // Replace your FlutterMap widget section with this updated version:

                    Container(
                      height: 250,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: borderColor),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _isLoadingLocation || _userLocation == null
                            ? Center(
                                child: Text('Chargement de la carte...',
                                    style:
                                        TextStyle(color: secondaryTextColor)))
                            : Stack(
                                children: [
                                  FlutterMap(
                                    mapController: _mapController,
                                    options: MapOptions(
                                      initialCenter: _userLocation!,
                                      initialZoom: 15,
                                      minZoom: 5,
                                      maxZoom: 18,
                                      onTap: (tapPosition, point) {
                                        if (mounted) {
                                          setState(() {
                                            _selectedLocation = point;
                                            _updateMarkers();
                                            _getMunicipalityDetails(Position(
                                                latitude: point.latitude,
                                                longitude: point.longitude,
                                                timestamp: DateTime.now(),
                                                accuracy: 0,
                                                altitude: 0,
                                                heading: 0,
                                                speed: 0,
                                                speedAccuracy: 0,
                                                altitudeAccuracy: 0,
                                                headingAccuracy: 0));
                                          });
                                        }
                                      },
                                    ),
                                    children: [
                                      TileLayer(
                                        urlTemplate:
                                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                        userAgentPackageName:
                                            'com.example.citoyen_app', // Replace with your package name
                                      ),
                                      MarkerLayer(markers: _markers),
                                    ],
                                  ),

                                  // Zoom Controls
                                  Positioned(
                                    right: 10,
                                    top: 10,
                                    child: Column(
                                      children: [
                                        // Zoom In Button
                                        Container(
                                          decoration: BoxDecoration(
                                            color: theme.colorScheme.surface,
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.2),
                                                spreadRadius: 1,
                                                blurRadius: 3,
                                                offset: const Offset(0, 1),
                                              ),
                                            ],
                                          ),
                                          child: IconButton(
                                            icon: Icon(Icons.add,
                                                color: theme
                                                    .colorScheme.onSurface),
                                            iconSize: 20,
                                            padding: const EdgeInsets.all(8),
                                            constraints: const BoxConstraints(
                                                minWidth: 36, minHeight: 36),
                                            onPressed: () {
                                              if (_mapController != null) {
                                                final currentZoom =
                                                    _mapController!.camera.zoom;
                                                if (currentZoom < 18) {
                                                  _mapController!.move(
                                                      _mapController!
                                                          .camera.center,
                                                      currentZoom + 1);
                                                }
                                              }
                                            },
                                          ),
                                        ),
                                        const SizedBox(height: 2),

                                        // Zoom Out Button
                                        Container(
                                          decoration: BoxDecoration(
                                            color: theme.colorScheme.surface,
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.2),
                                                spreadRadius: 1,
                                                blurRadius: 3,
                                                offset: const Offset(0, 1),
                                              ),
                                            ],
                                          ),
                                          child: IconButton(
                                            icon: Icon(Icons.remove,
                                                color: theme
                                                    .colorScheme.onSurface),
                                            iconSize: 20,
                                            padding: const EdgeInsets.all(8),
                                            constraints: const BoxConstraints(
                                                minWidth: 36, minHeight: 36),
                                            onPressed: () {
                                              if (_mapController != null) {
                                                final currentZoom =
                                                    _mapController!.camera.zoom;
                                                if (currentZoom > 5) {
                                                  _mapController!.move(
                                                      _mapController!
                                                          .camera.center,
                                                      currentZoom - 1);
                                                }
                                              }
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // My Location Button
                                  Positioned(
                                    right: 10,
                                    bottom: 10,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.surface,
                                        borderRadius: BorderRadius.circular(4),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.2),
                                            spreadRadius: 1,
                                            blurRadius: 3,
                                            offset: const Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                      child: IconButton(
                                        icon: Icon(Icons.my_location,
                                            color: _selectedLocation ==
                                                    _userLocation
                                                ? theme.colorScheme.primary
                                                : theme.colorScheme.onSurface),
                                        iconSize: 20,
                                        padding: const EdgeInsets.all(8),
                                        constraints: const BoxConstraints(
                                            minWidth: 36, minHeight: 36),
                                        onPressed: () async {
                                          if (_userLocation != null &&
                                              _mapController != null) {
                                            // Move map to user location
                                            _mapController!
                                                .move(_userLocation!, 15);

                                            // Set selected location to user location
                                            setState(() {
                                              _selectedLocation = _userLocation;
                                              _updateMarkers();
                                            });

                                            // Update municipality info
                                            await _getMunicipalityDetails(
                                                Position(
                                              latitude: _userLocation!.latitude,
                                              longitude:
                                                  _userLocation!.longitude,
                                              timestamp: DateTime.now(),
                                              accuracy: 0,
                                              altitude: 0,
                                              heading: 0,
                                              speed: 0,
                                              speedAccuracy: 0,
                                              altitudeAccuracy: 0,
                                              headingAccuracy: 0,
                                            ));

                                            _showSnackBar(
                                                "Centré sur votre position",
                                                isError: false);
                                          } else {
                                            // Try to get location again if not available
                                            await _getCurrentLocation();
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    if (_selectedLocation != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Lat: ${_selectedLocation!.latitude.toStringAsFixed(5)}, Lon: ${_selectedLocation!.longitude.toStringAsFixed(5)}',
                          style: TextStyle(
                              fontSize: 12, color: secondaryTextColor),
                        ),
                      )
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Documents Section
              _buildAttachmentSection(
                title: 'Documents à l\'appui',
                subtitle: 'Vous pouvez joindre jusqu\'à 3 documents',
                icon: Icons.description,
                theme: theme,
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.attach_file),
                      label: const Text('Choisir des documents'),
                      onPressed: _pickDocument,
                      style: _attachmentButtonStyle(theme: theme),
                    ),
                    const SizedBox(height: 8),
                    ..._documentFiles.map((file) => _buildFileInfo(
                        file.name,
                        () => setState(() => _documentFiles.remove(file)),
                        theme)),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Images Section
              _buildAttachmentSection(
                title: 'Images à l\'appui',
                subtitle: 'Vous pouvez joindre jusqu\'à 3 images',
                icon: Icons.camera_alt,
                theme: theme,
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Caméra'),
                          onPressed: _photoFiles.length < 3
                              ? () => _pickImage(ImageSource.camera)
                              : null,
                          style: _attachmentButtonStyle(
                              theme: theme, isPrimary: true),
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.photo_library),
                          label: const Text('Galerie'),
                          onPressed: _photoFiles.length < 3
                              ? () => _pickImage(ImageSource.gallery)
                              : null,
                          style: _attachmentButtonStyle(theme: theme),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _photoFiles
                          .map((file) => _buildImageThumbnail(file, theme))
                          .toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // --- Video Section (Updated) ---
              _buildAttachmentSection(
                title: 'Vidéo à l\'appui',
                subtitle: 'Vous pouvez joindre une seule vidéo',
                icon: Icons.videocam,
                theme: theme,
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Record Video Button
                        ElevatedButton.icon(
                          icon: const Icon(Icons.videocam),
                          label: const Text('Enregistrer'),
                          onPressed: _videoFile == null
                              ? () => _pickOrRecordVideo(ImageSource.camera)
                              : null,
                          style: _attachmentButtonStyle(
                              theme: theme, isPrimary: true),
                        ),
                        // Pick Video Button
                        ElevatedButton.icon(
                          icon: const Icon(Icons.video_library),
                          label: const Text('Galerie'),
                          onPressed: _videoFile == null
                              ? () => _pickOrRecordVideo(ImageSource.gallery)
                              : null,
                          style: _attachmentButtonStyle(theme: theme),
                        ),
                      ],
                    ),
                    if (_videoFile != null)
                      _buildFileInfo(p.basename(_videoFile!.path),
                          () => setState(() => _videoFile = null), theme),
                  ],
                ),
              ),
              // --- End Video Section ---
              const SizedBox(height: 32),

              // Submit Button
              Center(
                child: _isSubmitting
                    ? CircularProgressIndicator(color: primaryColor)
                    : ElevatedButton(
                        onPressed: _submitProblem,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: onPrimaryColor,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 64, vertical: 16),
                          textStyle: GoogleFonts.inter(
                              fontSize: 16, fontWeight: FontWeight.bold),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('ENVOYER'),
                      ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper Widgets using Theme ---

  InputDecoration _inputDecoration(
      {required String hintText, IconData? icon, required ThemeData theme}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
          fontSize: 14),
      prefixIcon: icon != null
          ? Icon(icon, color: theme.colorScheme.primary, size: 20)
          : null,
      filled: true,
      fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide:
            BorderSide(color: theme.colorScheme.outline.withOpacity(0.5)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide:
            BorderSide(color: theme.colorScheme.outline.withOpacity(0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
            color: theme.colorScheme.error.withOpacity(0.7), width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: theme.colorScheme.error, width: 1.5),
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: theme.colorScheme.onSurface, // Use onSurface color
      ),
    );
  }

  Widget _buildAttachmentSection({
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget content,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface, // Use surface color
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: theme.colorScheme.primary, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          color: theme.colorScheme.onSurfaceVariant
                              .withOpacity(0.7)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          content,
        ],
      ),
    );
  }

  ButtonStyle _attachmentButtonStyle(
      {required ThemeData theme, bool isPrimary = false}) {
    return ElevatedButton.styleFrom(
      backgroundColor: isPrimary
          ? theme.colorScheme.primaryContainer
          : theme.colorScheme.secondaryContainer,
      foregroundColor: isPrimary
          ? theme.colorScheme.onPrimaryContainer
          : theme.colorScheme.onSecondaryContainer,
      elevation: 0,
      side: BorderSide(
          color: isPrimary
              ? theme.colorScheme.primary.withOpacity(0.3)
              : theme.colorScheme.outline.withOpacity(0.5)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      textStyle: GoogleFonts.inter(fontWeight: FontWeight.w500),
    );
  }

  Widget _buildFileInfo(
      String fileName, VoidCallback onClear, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        children: [
          Icon(Icons.insert_drive_file_outlined,
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
              size: 16),
          const SizedBox(width: 8),
          Expanded(
              child: Text(fileName,
                  style: const TextStyle(fontSize: 13),
                  overflow: TextOverflow.ellipsis)),
          SizedBox(
            height: 24,
            width: 24,
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(Icons.close,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7)),
              onPressed: onClear,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageThumbnail(XFile file, ThemeData theme) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            File(file.path),
            width: 70,
            height: 70,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: -5,
          right: -5,
          child: SizedBox(
            height: 24,
            width: 24,
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(Icons.cancel,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                  size: 18),
              onPressed: () => setState(() => _photoFiles.remove(file)),
            ),
          ),
        ),
      ],
    );
  }
}
