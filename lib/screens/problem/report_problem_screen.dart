// lib/screens/report_problem_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:citoyen_app/providers/problem_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class ReportProblemScreen extends StatefulWidget {
  const ReportProblemScreen({Key? key}) : super(key: key);

  @override
  State<ReportProblemScreen> createState() => _ReportProblemScreenState();
}

class _ReportProblemScreenState extends State<ReportProblemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  
  String? _selectedCategoryId;
  File? _imageFile;
  bool _isSubmitting = false;
  String _errorMessage = '';
  
  // Map related variables
  MapController? _mapController;
  LatLng? _selectedLocation;
  LatLng? _userLocation;
  bool _isLoadingLocation = true;
  List<Marker> _markers = [];
  
  // Mock categories - replace with API data
  final List<Map<String, dynamic>> _categories = [
    {'id': '1', 'name': 'Voirie', 'icon': Icons.traffic},
    {'id': '2', 'name': 'Éclairage', 'icon': Icons.lightbulb},
    {'id': '3', 'name': 'Déchets', 'icon': Icons.delete},
    {'id': '4', 'name': 'Espaces verts', 'icon': Icons.park},
    {'id': '5', 'name': 'Eau', 'icon': Icons.water_drop},
    {'id': '6', 'name': 'Autre', 'icon': Icons.more_horiz},
  ];
  
  @override
  void initState() {
    super.initState();
     _mapController = MapController();
    _requestLocationPermission();
      WidgetsBinding.instance.addPostFrameCallback((_) {
    // Now it's safe to use the controller if needed
  });
  }
  
  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }
  
  Future<void> _requestLocationPermission() async {
    final status = await Permission.location.request();
    
    if (status.isGranted) {
      _getCurrentLocation();
    } else {
      setState(() {
        _isLoadingLocation = false;
        _errorMessage = 'Permission de localisation refusée';
      });
    }
  }
  
Future<void> _getCurrentLocation() async {
  try {
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    
    setState(() {
      _userLocation = LatLng(position.latitude, position.longitude);
      _selectedLocation = _userLocation;
      _isLoadingLocation = false;
      
      // Add marker for user location
      _updateMarkers();
    });
    
    // Add this check before moving the camera
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_mapController != null && _userLocation != null) {
        _mapController!.move(_userLocation!, 15);
      }
    });
    
  } catch (e) {
    setState(() {
      _isLoadingLocation = false;
      _errorMessage = 'Erreur de localisation: $e';
    });
  }
}
  void _updateMarkers() {
  if (_selectedLocation == null) return;

  setState(() {
    _markers = [
      Marker(
        point: _selectedLocation!,
        width: 40,
        height: 40,
        child: Icon(
          Icons.location_pin,
          color: Colors.red,
          size: 40,
        ),
      ),
    ];
  });
}

  
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );
    
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }
  
  Future<void> _submitProblem() async {
    if (_formKey.currentState?.validate() != true) return;
    if (_selectedCategoryId == null) {
      setState(() {
        _errorMessage = 'Veuillez sélectionner une catégorie';
      });
      return;
    }
    if (_selectedLocation == null) {
      setState(() {
        _errorMessage = 'Veuillez sélectionner un emplacement sur la carte';
      });
      return;
    }
    
    setState(() {
      _isSubmitting = true;
      _errorMessage = '';
    });
    
    try {
      final result = await Provider.of<ProblemProvider>(context, listen: false).reportProblem(
        description: _descriptionController.text,
        latitude: _selectedLocation!.latitude,
        longitude: _selectedLocation!.longitude,
        categoryId: _selectedCategoryId!,
        imagePath: _imageFile?.path,
      );
      
      if (result['success']) {
        // Show success message and navigate back
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Problème signalé avec succès!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        setState(() {
          _errorMessage = result['message'];
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors de la soumission: $e';
      });
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Signaler un problème',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Error message
              if (_errorMessage.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: colors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colors.error.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: colors.error),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage,
                          style: GoogleFonts.inter(
                            color: colors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn().slideY(begin: -0.1, end: 0),
              
              // Description field
              Text(
                'Description du problème',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  hintText: 'Décrivez le problème en détail...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: colors.surfaceVariant.withOpacity(0.3),
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez fournir une description';
                  }
                  if (value.trim().length < 10) {
                    return 'La description doit contenir au moins 10 caractères';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 24),
              
              // Category selection
              Text(
                'Catégorie',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final isSelected = _selectedCategoryId == category['id'];
                    
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategoryId = category['id'];
                        });
                      },
                      child: Container(
                        width: 80,
                        margin: EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? colors.primary 
                              : colors.surfaceVariant.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected 
                                ? colors.primary 
                                : colors.outline.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              category['icon'],
                              color: isSelected 
                                  ? colors.onPrimary 
                                  : colors.onSurfaceVariant,
                              size: 32,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              category['name'],
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: isSelected 
                                    ? colors.onPrimary 
                                    : colors.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Location map
              Text(
                'Emplacement',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
             Container(
  height: 250,
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(12),
    border: Border.all(
      color: colors.outline.withOpacity(0.3),
      width: 1,
    ),
  ),
  child: ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: _isLoadingLocation
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  'Chargement de la carte...',
                  style: GoogleFonts.inter(),
                ),
              ],
            ),
          )
        : Stack(
            children: [
              FlutterMap(
  mapController: _mapController,
  options: MapOptions(
    initialCenter: _userLocation ?? LatLng(0, 0),  // changed from 'center' to 'initialCenter'
    initialZoom: 15,  // changed from 'zoom' to 'initialZoom'
    onTap: (tapPosition, point) {
      setState(() {
        _selectedLocation = point;
        _updateMarkers();
      });
    },
  ),
  children: [
    TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'com.example.app',
    ),
    MarkerLayer(
      markers: _markers,
    ),
  ],
),
             Positioned(
                right: 8,
                bottom: 8,
                child: Column(
                  children: [
                    FloatingActionButton.small(
                      heroTag: 'locate_me',
                      onPressed: _getCurrentLocation,
                      child: Icon(Icons.my_location),
                    ),
                    const SizedBox(height: 8),
                    FloatingActionButton.small(
  heroTag: 'zoom_in',
  onPressed: () {
    if (_mapController != null) {
      final currentZoom = _mapController!.camera.zoom;
      final currentCenter = _mapController!.camera.center;
      _mapController!.move(currentCenter, currentZoom + 1);
    }
  },
  child: Icon(Icons.add),
),
                    const SizedBox(height: 8),
                    FloatingActionButton.small(
  heroTag: 'zoom_out',
  onPressed: () {
    if (_mapController != null) {
      final currentZoom = _mapController!.camera.zoom;
      final currentCenter = _mapController!.camera.center;
      _mapController!.move(currentCenter, currentZoom - 1);
    }
  },
  child: Icon(Icons.remove),
),
                     ],
                ),
              ),
            ],
          ),
  ),
),

              const SizedBox(height: 24),
              
              // Photo upload
              Text(
                'Photo (optionnelle)',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: colors.surfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colors.outline.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: _imageFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.file(
                                _imageFile!,
                                fit: BoxFit.cover,
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: CircleAvatar(
                                  backgroundColor: colors.surface.withOpacity(0.7),
                                  radius: 16,
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.close,
                                      size: 16,
                                      color: colors.onSurface,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _imageFile = null;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.camera_alt,
                              size: 48,
                              color: colors.primary.withOpacity(0.7),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Appuyez pour prendre une photo',
                              style: GoogleFonts.inter(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Submit button
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitProblem,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colors.onPrimary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Envoi en cours...',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        'Signaler le problème',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
