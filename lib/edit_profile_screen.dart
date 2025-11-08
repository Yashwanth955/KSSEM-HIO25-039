import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';
import 'user_model.dart';
import 'isar_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _sportController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _locationController;
  late TextEditingController _mobileController;

  late UserProfile _currentUserProfile;

  @override
  void initState() {
    super.initState();
    _currentUserProfile = Provider.of<AppState>(context, listen: false).userProfile!;
    _nameController = TextEditingController(text: _currentUserProfile.name);
    _ageController = TextEditingController(text: _currentUserProfile.age?.toString() ?? '');
    _sportController = TextEditingController(text: _currentUserProfile.sport);
    _heightController = TextEditingController(text: _currentUserProfile.height?.toString() ?? '');
    _weightController = TextEditingController(text: _currentUserProfile.weight?.toString() ?? '');
    _locationController = TextEditingController(text: _currentUserProfile.location ?? '');
    _mobileController = TextEditingController(text: _currentUserProfile.mobileNumber ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _sportController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _locationController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final isarService = Provider.of<IsarService>(context, listen: false);
      final appState = Provider.of<AppState>(context, listen: false);

      final updatedProfile = _currentUserProfile.copyWith(
        name: _nameController.text,
        age: int.tryParse(_ageController.text),
        sport: _sportController.text,
        height: double.tryParse(_heightController.text),
        weight: double.tryParse(_weightController.text),
        location: _locationController.text.isNotEmpty ? _locationController.text : null,
        mobileNumber: _mobileController.text.isNotEmpty ? _mobileController.text : null,
        // profilePhotoPath and email are not edited here for simplicity,
        // but could be added if needed.
      );

      await isarService.saveUserProfile(updatedProfile);
      appState.setUserProfile(updatedProfile);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveProfile,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              _buildTextFormField(
                controller: _nameController,
                labelText: 'Name',
                validator: (value) => value == null || value.isEmpty ? 'Please enter your name' : null,
              ),
              _buildTextFormField(
                controller: _ageController,
                labelText: 'Age',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter your age';
                  if (int.tryParse(value) == null) return 'Please enter a valid age';
                  return null;
                },
              ),
              _buildTextFormField(
                controller: _sportController,
                labelText: 'Primary Sport/Activity',
                 validator: (value) => value == null || value.isEmpty ? 'Please enter your sport' : null,
              ),
               _buildTextFormField(
                controller: _mobileController,
                labelText: 'Mobile Number',
                keyboardType: TextInputType.phone,
                // Add validator if needed, e.g., for format or length
              ),
              _buildTextFormField(
                controller: _heightController,
                labelText: 'Height (cm)',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                 validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter your height';
                  if (double.tryParse(value) == null) return 'Please enter a valid height';
                  return null;
                },
              ),
              _buildTextFormField(
                controller: _weightController,
                labelText: 'Weight (kg)',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter your weight';
                  if (double.tryParse(value) == null) return 'Please enter a valid weight';
                  return null;
                },
              ),
              _buildTextFormField(
                controller: _locationController,
                labelText: 'Location (e.g., City, Country)',
                // No validator, location is optional
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveProfile,
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        keyboardType: keyboardType,
        validator: validator,
      ),
    );
  }
}
