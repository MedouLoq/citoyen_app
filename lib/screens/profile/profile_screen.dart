import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart'; // For token
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:citoyen_app/screens/auth/auth_screen.dart';
import 'contact_us_screen.dart';

// --- Configuration ---
// Replace with your actual API base URL
const String API_BASE_URL = "http://10.0.2.2:8000";
const String PROFILE_URL = "$API_BASE_URL/api/profile/";
const String PROFILE_UPDATE_URL = "$API_BASE_URL/api/profile/update/";

// --- Models (Simplified) ---
class UserProfile {
  final String id;
  final String username;
  final String? phoneNumber;
  final String? email;
  final String userType;
  final CitizenProfile? citizenProfile;

  UserProfile({
    required this.id,
    required this.username,
    this.phoneNumber,
    this.email,
    required this.userType,
    this.citizenProfile,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json["id"].toString(), // Ensure ID is string if needed
      username: json["username"] ?? "",
      phoneNumber: json["phone_number"],
      email: json["email"],
      userType: json["user_type"] ?? "CITIZEN",
      citizenProfile: json["citizen_profile"] != null
          ? CitizenProfile.fromJson(json["citizen_profile"])
          : null,
    );
  }
}

class CitizenProfile {
  final String fullName;
  final String? nni;
  final String? address;
  final String? profilePictureUrl;
  final String? municipality;
  // Add municipality if needed

  CitizenProfile(
      {required this.fullName,
      this.nni,
      this.address,
      this.profilePictureUrl,
      this.municipality,
      t});

  factory CitizenProfile.fromJson(Map<String, dynamic> json) {
    return CitizenProfile(
      fullName: json["full_name"] ?? "",
      nni: json["nni"],
      address: json["address"],
      municipality: json[""],
      profilePictureUrl:
          json["profile_picture_url"], // Use the URL field from serializer
    );
  }
}

// --- Profile Screen ---
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfile? _userProfile;
  bool _isLoading = true;
  bool _isEditing = false;
  String? _errorMessage;
  File? _selectedImageFile;

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _addressController;
  // Add controllers for other editable fields like NNI if needed

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _addressController = TextEditingController();
    _fetchProfile();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

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

  Future<void> _fetchProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final token = await _getAuthToken();
    if (token == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Authentication token not found. Please log in again.";
      });
      // Optionally redirect to login
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(PROFILE_URL),
        headers: {
          "Authorization":
              "Token $token", // Or "Bearer $token" depending on your auth
          "Content-Type": "application/json",
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          _userProfile = UserProfile.fromJson(data);
          // Initialize controllers with fetched data
          _fullNameController.text =
              _userProfile?.citizenProfile?.fullName ?? "";
          _addressController.text = _userProfile?.citizenProfile?.address ?? "";
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = "Failed to load profile: ${response.statusCode}";
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = "An error occurred: $e";
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile =
          await picker.pickImage(source: source, imageQuality: 80);

      if (pickedFile != null) {
        setState(() {
          _selectedImageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to pick image: $e")),
      );
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Gallery"),
              onTap: () {
                _pickImage(ImageSource.gallery);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text("Camera"),
              onTap: () {
                _pickImage(ImageSource.camera);
                Navigator.of(context).pop();
              },
            ),
            if (_selectedImageFile != null ||
                _userProfile?.citizenProfile?.profilePictureUrl != null)
              ListTile(
                leading: Icon(Icons.delete_outline,
                    color: Theme.of(context).colorScheme.error),
                title: Text("Remove Picture",
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error)),
                onTap: () {
                  setState(() {
                    _selectedImageFile = null; // Mark for removal on save
                  });
                  Navigator.of(context).pop();
                  // Note: Actual removal happens during save by sending null
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true; // Show loading indicator during update
      _errorMessage = null;
    });

    final token = await _getAuthToken();
    if (token == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Authentication token not found.";
      });
      return;
    }

    try {
      var request =
          http.MultipartRequest("PATCH", Uri.parse(PROFILE_UPDATE_URL));
      request.headers["Authorization"] = "Token $token"; // Or Bearer
      // Add text fields
      request.fields["full_name"] = _fullNameController.text;
      request.fields["address"] = _addressController.text;
      // Add other fields...

      // Handle image update/removal
      if (_selectedImageFile != null) {
        request.files.add(await http.MultipartFile.fromPath(
          "profile_picture", // Must match the field name in Django serializer
          _selectedImageFile!.path,
        ));
      } else if (_userProfile?.citizenProfile?.profilePictureUrl != null &&
          _selectedImageFile == null) {
        // If _selectedImageFile is explicitly null after having an image,
        // it means user wants to remove it. Send an empty string or handle null on backend.
        // Sending an empty value for the field often signals clearing it in DRF.
        // Check your CitizenProfileUpdateSerializer logic for how it handles null/empty.
        // If sending null is needed, you might need a different approach than MultipartRequest
        // or adjust the backend to interpret an empty field value as null.
        // For simplicity here, we assume sending no file means no change,
        // and clearing requires a separate action or backend logic adjustment.
        // Let's assume for now we only handle *setting* a new image.
        // To handle *clearing*, you might need to send a specific flag or adjust the backend.
        // A common pattern is to send `profile_picture=` (empty value) to clear.
        // request.fields["profile_picture"] = ""; // Uncomment if backend handles empty string for clearing
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          _userProfile =
              UserProfile.fromJson(data); // Update profile with response
          _fullNameController.text =
              _userProfile?.citizenProfile?.fullName ?? "";
          _addressController.text = _userProfile?.citizenProfile?.address ?? "";
          _selectedImageFile =
              null; // Clear selected file after successful upload
          _isEditing = false; // Exit editing mode
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Profile updated successfully!"),
              backgroundColor: Colors.green),
        );
      } else {
        final errorData = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          _isLoading = false;
          _errorMessage =
              "Failed to update profile: ${response.statusCode} - ${errorData.toString()}";
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Update failed: ${errorData.toString()}"),
              backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = "An error occurred during update: $e";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("An error occurred: $e"),
            backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(_isEditing ? "Modifier le Profil" : "Mon Profil",
            style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        backgroundColor: colors.surface, // Use surface for AppBar
        elevation: 1,
        leading: _isEditing
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => setState(() {
                      _isEditing = false;
                      _selectedImageFile =
                          null; // Discard image changes on cancel
                      // Reset controllers to original values
                      _fullNameController.text =
                          _userProfile?.citizenProfile?.fullName ?? "";
                      _addressController.text =
                          _userProfile?.citizenProfile?.address ?? "";
                    }))
            : null,
        actions: [
          if (!_isEditing && _userProfile != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: "Modifier",
              onPressed: () => setState(() => _isEditing = true),
            ),
          if (_isEditing)
            IconButton(
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.check),
              tooltip: "Sauvegarder",
              onPressed: _isLoading ? null : _updateProfile,
            ),
        ],
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading && _userProfile == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline,
                  color: Theme.of(context).colorScheme.error, size: 50),
              const SizedBox(height: 16),
              Text("Error",
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(color: Theme.of(context).colorScheme.error)),
              const SizedBox(height: 8),
              Text(_errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text("Retry"),
                onPressed: _fetchProfile,
              )
            ],
          ),
        ),
      );
    }

    if (_userProfile == null) {
      return const Center(child: Text("No profile data found."));
    }

    // Display profile data (editable or read-only)
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildAvatarSection(context),
            const SizedBox(height: 24),
            _buildInfoSection(context),
            const SizedBox(height: 32),
            if (!_isEditing) _buildActionButtons(context),
          ]
              .animate(interval: 100.ms)
              .fadeIn(duration: 300.ms)
              .slideY(begin: 0.1, curve: Curves.easeOutCubic),
        ),
      ),
    );
  }

  Widget _buildAvatarSection(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final citizenProfile = _userProfile?.citizenProfile;
    final currentImageUrl = citizenProfile?.profilePictureUrl;
    final placeholderInitial = citizenProfile?.fullName.isNotEmpty == true
        ? citizenProfile!.fullName[0].toUpperCase()
        : "U";

    ImageProvider? backgroundImage;
    if (_selectedImageFile != null) {
      backgroundImage = FileImage(_selectedImageFile!);
    } else if (currentImageUrl != null && currentImageUrl.isNotEmpty) {
      backgroundImage = NetworkImage(currentImageUrl);
    }

    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: 65,
              backgroundColor: colors.primary.withOpacity(0.2),
              child: CircleAvatar(
                radius: 60,
                backgroundImage: backgroundImage,
                backgroundColor: colors.surfaceVariant,
                child: backgroundImage == null
                    ? Text(placeholderInitial,
                        style: GoogleFonts.inter(
                            fontSize: 50,
                            fontWeight: FontWeight.bold,
                            color: colors.primary))
                    : null,
              ),
            ),
            if (_isEditing)
              Positioned(
                right: 0,
                bottom: 0,
                child: Material(
                  color: colors.primary,
                  shape: const CircleBorder(),
                  elevation: 2,
                  child: InkWell(
                    onTap: _showImagePickerOptions,
                    customBorder: const CircleBorder(),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child:
                          Icon(Icons.camera_alt, color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        // Display Name (non-editable here, editable below)
        if (!_isEditing)
          Text(
            citizenProfile?.fullName ?? _userProfile?.username ?? "Utilisateur",
            style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onBackground),
            textAlign: TextAlign.center,
          ),
        if (!_isEditing) const SizedBox(height: 4),
        // Display Phone or Email (non-editable)
        if (!_isEditing)
          Text(
            _userProfile?.phoneNumber ?? _userProfile?.email ?? "",
            style: GoogleFonts.inter(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
      ],
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final citizenProfile = _userProfile?.citizenProfile;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Informations Personnelles",
            style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colors.onSurface)),
        const SizedBox(height: 16),
        _buildEditableTextField(
          controller: _fullNameController,
          label: "Nom complet",
          icon: Icons.person_outline,
          validator: (value) => value == null || value.isEmpty
              ? "Le nom ne peut pas être vide"
              : null,
        ),
        const SizedBox(height: 16),
        _buildEditableTextField(
          controller: _addressController,
          label: "Adresse",
          icon: Icons.location_on_outlined,
          maxLines: 2,
          // No validator needed if address is optional
        ),
        const SizedBox(height: 16),
        // Read-only fields (Example: NNI, Phone)
        _buildReadOnlyInfoTile(context, Icons.badge_outlined, "NNI",
            citizenProfile?.nni ?? "Non défini"),
        _buildReadOnlyInfoTile(context, Icons.phone_outlined, "Téléphone",
            _userProfile?.phoneNumber ?? "Non défini"),
        // Add Municipality if needed
      ],
    );
  }

  Widget _buildEditableTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: _isEditing,
      maxLines: maxLines,
      style: GoogleFonts.inter(color: Theme.of(context).colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(
            color: Theme.of(context).colorScheme.onSurfaceVariant),
        prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.primary),
        filled: true,
        fillColor: _isEditing
            ? Theme.of(context).colorScheme.surface
            : Colors.transparent,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: _isEditing
              ? BorderSide(color: Theme.of(context).colorScheme.outline)
              : BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: _isEditing
              ? BorderSide(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.5))
              : BorderSide.none,
        ),
        focusedBorder: _isEditing
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary, width: 2),
              )
            : null,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
      validator: _isEditing ? validator : null,
      readOnly: !_isEditing,
    );
  }

  Widget _buildReadOnlyInfoTile(
      BuildContext context, IconData icon, String label, String value) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: colors.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: colors.primary, size: 22),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: GoogleFonts.inter(
                      fontSize: 12, color: colors.onSurfaceVariant)),
              const SizedBox(height: 2),
              Text(value,
                  style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: colors.onSurface)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    // Add other actions like Change Password, Logout etc.
    return Column(
      children: [
        _buildProfileOption(context, Icons.info_outline_rounded, "About Us",
            () {
          // TODO: Navigate to About Us screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ContactUsScreen(),
            ),
          );
        }),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          icon: Icon(Icons.logout_rounded, color: colors.onError),
          label: Text("Se déconnecter",
              style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colors.onError)),
          onPressed: () async {
            final prefs = await SharedPreferences.getInstance();
            await prefs.remove("auth_token");
            if (mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const AuthScreen()),
                (Route<dynamic> route) => false,
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.error,
            minimumSize: const Size(double.infinity, 50),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  // Helper for action buttons (reusing from original code)
  Widget _buildProfileOption(
      BuildContext context, IconData icon, String title, VoidCallback onTap,
      {Color? iconColor}) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: colors.outline.withOpacity(0.3))),
      margin: const EdgeInsets.symmetric(vertical: 6),
      color: colors.surface,
      child: ListTile(
        leading: Icon(icon, color: iconColor ?? colors.primary, size: 22),
        title: Text(title,
            style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: colors.onSurface)),
        trailing: Icon(Icons.arrow_forward_ios_rounded,
            size: 18, color: colors.onSurfaceVariant),
        onTap: onTap,
        splashColor: colors.primary.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
