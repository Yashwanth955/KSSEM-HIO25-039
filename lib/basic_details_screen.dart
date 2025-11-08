import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sadhak/user_model.dart'; // CORRECTED PATH
import 'package:sadhak/isar_service.dart'; // CORRECTED PATH
import 'package:sadhak/home_screen.dart'; // CORRECTED PATH
import 'package:sadhak/app_state.dart'; // CORRECTED PATH
import 'package:provider/provider.dart';
import 'util/log.dart';
// Removed Isar dependency import

class BasicDetailsScreen extends StatefulWidget {
  final bool isEditing;
  final UserProfile? userProfile;

  const BasicDetailsScreen({
    super.key,
    this.isEditing = false,
    this.userProfile,
  });

  @override
  State<BasicDetailsScreen> createState() => _BasicDetailsScreenState();
}

class _BasicDetailsScreenState extends State<BasicDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _sportController = TextEditingController();
  final _coachNameController = TextEditingController();
  final _coachMobileController = TextEditingController();
  final _coachWhatsappController = TextEditingController();
  final _locationController = TextEditingController(); // Location controller

  String? _profilePhotoPath;
  bool _isCoachUser = false;
  final IsarService _isarService = IsarService();
  UserProfile? _currentUserProfile;

  @override
  void initState() {
    super.initState();
    _checkCurrentUser();
    if (widget.isEditing && widget.userProfile != null) {
      _currentUserProfile = widget.userProfile;
      _loadUserProfileData();
    } else {
      _fetchUserProfileForCurrentUser();
    }
  }

  Future<void> _checkCurrentUser() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error: No authenticated user found!")),
      );
    }
  }

  Future<void> _fetchUserProfileForCurrentUser() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      final profile = await _isarService.getUserProfileByFirebaseUid(
        firebaseUser.uid,
      );
      if (profile != null) {
        if (!mounted) return;
        setState(() {
          _currentUserProfile = profile;
          _loadUserProfileData();
        });
      }
    }
  }

  void _loadUserProfileData() {
    if (_currentUserProfile != null) {
      _nameController.text = _currentUserProfile!.name ?? '';
      _mobileController.text = _currentUserProfile!.mobileNumber ?? '';
      _ageController.text = _currentUserProfile!.age?.toString() ?? '';
      _heightController.text = _currentUserProfile!.height?.toString() ?? '';
      _weightController.text = _currentUserProfile!.weight?.toString() ?? '';
      _sportController.text = _currentUserProfile!.sport ?? '';
      _profilePhotoPath = _currentUserProfile!.profilePhotoPath;
      _isCoachUser = _currentUserProfile!.isCoachUser;
      _coachNameController.text = _currentUserProfile!.coachName ?? '';
      _coachMobileController.text = _currentUserProfile!.coachPhoneNumber ?? '';
      _coachWhatsappController.text =
          _currentUserProfile!.coachWhatsappNumber ?? '';
      _locationController.text =
          _currentUserProfile!.location ?? ''; // Load location
      setState(() {});
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profilePhotoPath = image.path;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final firebaseUser = FirebaseAuth.instance.currentUser;
    // Capture context before async gaps
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final appState = Provider.of<AppState>(context, listen: false);

    if (firebaseUser == null) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text("User not authenticated. Cannot save profile."),
        ),
      );
      return;
    }

    final profileData = UserProfile(
      id: _currentUserProfile?.id,
      firebaseUid: firebaseUser.uid,
      name: _nameController.text.trim(),
      email: firebaseUser.email,
      mobileNumber: _mobileController.text.trim(),
      age: int.tryParse(_ageController.text.trim()),
      height: double.tryParse(_heightController.text.trim()),
      weight: double.tryParse(_weightController.text.trim()),
      sport: _sportController.text.trim(),
      profilePhotoPath: _profilePhotoPath,
      isCoachUser: _isCoachUser,
      coachName: _isCoachUser ? _coachNameController.text.trim() : null,
      coachPhoneNumber: _isCoachUser
          ? _coachMobileController.text.trim()
          : null,
      coachWhatsappNumber: _isCoachUser
          ? _coachWhatsappController.text.trim()
          : null,
      location: _locationController.text.trim(), // Save location
      createdAt: _currentUserProfile?.createdAt ?? DateTime.now(),
    );

    try {
      await _isarService.saveUserProfile(profileData);
      appState.setUserProfile(profileData);

      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Profile saved successfully!')),
      );

      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      logDebug("Error saving profile: $e");
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Failed to save profile: ${e.toString()}')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _sportController.dispose();
    _coachNameController.dispose();
    _coachMobileController.dispose();
    _coachWhatsappController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Name',
            prefixIcon: Icon(Icons.person),
          ),
          validator: (value) =>
              value == null || value.isEmpty ? 'Please enter your name' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _mobileController,
          decoration: const InputDecoration(
            labelText: 'Mobile Number',
            prefixIcon: Icon(Icons.phone),
          ),
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your mobile number';
            }
            if (value.length < 10) {
              return 'Mobile number must be at least 10 digits';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _ageController,
          decoration: const InputDecoration(
            labelText: 'Age',
            prefixIcon: Icon(Icons.cake),
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your age';
            }
            if (int.tryParse(value) == null || int.parse(value) <= 0) {
              return 'Please enter a valid age';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _locationController,
          decoration: const InputDecoration(
            labelText: 'Location',
            hintText: 'Enter your city or area',
            prefixIcon: Icon(Icons.location_city),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _heightController,
                decoration: const InputDecoration(
                  labelText: 'Height (cm)',
                  prefixIcon: Icon(Icons.height),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter height';
                  }
                  if (double.tryParse(value) == null ||
                      double.parse(value) <= 0) {
                    return 'Valid height';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _weightController,
                decoration: const InputDecoration(
                  labelText: 'Weight (kg)',
                  prefixIcon: Icon(Icons.fitness_center),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter weight';
                  }
                  if (double.tryParse(value) == null ||
                      double.parse(value) <= 0) {
                    return 'Valid weight';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _sportController,
          decoration: const InputDecoration(
            labelText: 'Primary Sport',
            prefixIcon: Icon(Icons.sports_soccer),
          ),
          validator: (value) => value == null || value.isEmpty
              ? 'Please enter your primary sport'
              : null,
        ),
        const SizedBox(height: 20),
        SwitchListTile(
          title: const Text('Are you a coach?'),
          value: _isCoachUser,
          onChanged: (bool value) {
            setState(() {
              _isCoachUser = value;
            });
          },
          secondary: Icon(_isCoachUser ? Icons.school : Icons.person_outline),
        ),
        if (_isCoachUser) ...[
          const SizedBox(height: 16),
          TextFormField(
            controller: _coachNameController,
            decoration: const InputDecoration(
              labelText: 'Coach Name (Your Name as Coach)',
              prefixIcon: Icon(Icons.badge),
            ),
            validator: (value) =>
                _isCoachUser && (value == null || value.isEmpty)
                ? 'Please enter your coach name'
                : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _coachMobileController,
            decoration: const InputDecoration(
              labelText: 'Coach Mobile (Public)',
              prefixIcon: Icon(Icons.contact_phone),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _coachWhatsappController,
            decoration: const InputDecoration(
              labelText: 'Coach WhatsApp (Public)',
              prefixIcon: Icon(Icons.message),
            ),
            keyboardType: TextInputType.phone,
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditing || _currentUserProfile != null
              ? 'Edit Profile'
              : 'Complete Your Profile',
        ),
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: _profilePhotoPath != null
                        ? FileImage(File(_profilePhotoPath!))
                        : null,
                    child: _profilePhotoPath == null
                        ? Icon(
                            Icons.camera_alt,
                            color: Colors.grey[700],
                            size: 50,
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildFormFields(),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Save Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
