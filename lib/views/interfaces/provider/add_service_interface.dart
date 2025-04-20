import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:sahel_alik/utils/image_upload_utils.dart'; // Import image upload utility
import 'package:sahel_alik/services/service_service.dart'; // Import ServiceService
import 'package:sahel_alik/models/service.dart'; // Import ServiceModel
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sahel_alik/utils/validation_utils.dart';

import '../../widgets/custom_button.dart';

class AddServiceInterface extends StatefulWidget {
  const AddServiceInterface({super.key});

  @override
  State<AddServiceInterface> createState() => _AddServiceInterfaceState();
}

class _AddServiceInterfaceState extends State<AddServiceInterface> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _locationController = TextEditingController();
  String? _selectedCategory; // To hold selected category
  File? _image;
  List<Map<String, String>> _getLocalizedCategories(BuildContext context) {
    return [
      {'name': AppLocalizations.of(context)!.categoryMaid, 'value': 'Maid'},
      {
        'name': AppLocalizations.of(context)!.categoryCleaner,
        'value': 'Cleaner'
      },
      {
        'name': AppLocalizations.of(context)!.categoryMechanic,
        'value': 'Mechanic'
      },
      {'name': AppLocalizations.of(context)!.categoryBarber, 'value': 'Barber'},
      {
        'name': AppLocalizations.of(context)!.categoryPlumber,
        'value': 'Plumber'
      },
      {
        'name': AppLocalizations.of(context)!.categoryElectrician,
        'value': 'Electrician'
      },
      {
        'name': AppLocalizations.of(context)!.categoryCarpenter,
        'value': 'Carpenter'
      },
      {
        'name': AppLocalizations.of(context)!.categoryPainter,
        'value': 'Painter'
      },
      {
        'name': AppLocalizations.of(context)!.categoryGardener,
        'value': 'Gardener'
      },
      {'name': AppLocalizations.of(context)!.categoryChef, 'value': 'Chef'},
      {'name': AppLocalizations.of(context)!.categoryTutor, 'value': 'Tutor'},
      {'name': AppLocalizations.of(context)!.categoryDriver, 'value': 'Driver'},
      {'name': AppLocalizations.of(context)!.categoryMore, 'value': 'More'},
    ];
  }

  Position? _position;
  String? _address;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedImage =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });
    }
  }

  Future<void> _getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return;
      _showSnackBarSafe(AppLocalizations.of(context)!.locationServicesDisabled);
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (!mounted) return;
        _showSnackBarSafe(
            AppLocalizations.of(context)!.locationPermissionsDenied);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (!mounted) return;
      _showSnackBarSafe(
          AppLocalizations.of(context)!.locationPermissionsPermanentlyDenied);
      return;
    }

    try {
      _position = await Geolocator.getCurrentPosition();
      if (_position != null) {
        _getAddressFromCoordinates();
      }
    } catch (e) {
      // Error logged
      if (!mounted) return;
      _showSnackBarSafe(AppLocalizations.of(context)!.errorGettingLocation);
    }
  }

  Future<void> _getAddressFromCoordinates() async {
    if (_position != null) {
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          _position!.latitude,
          _position!.longitude,
        );

        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          _address = '${place.street}, ${place.locality}, ${place.country}';
          _locationController.text = _address ?? '';
        }
      } catch (e) {
        // Error logged
        if (!mounted) return;
        _showSnackBarSafe(AppLocalizations.of(context)!.errorGettingAddress);
      }
    }
  }

  void _validateAndAddService() {
    if (_formKey.currentState!.validate()) {
      if (_position == null) {
        _showSnackBarSafe(AppLocalizations.of(context)!.locationRequired);
        return;
      }
      _addService();
    }
  }

  void _showSnackBarSafe(String message,
      {bool isSuccess = false, bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess
            ? Colors.green
            : isError
                ? Colors.red
                : null,
      ),
    );
  }

  Future<void> _addService() async {
    setState(() {
      _isLoading = true;
    });

    String? imageUrl;
    if (_image != null) {
      imageUrl = await uploadImageToCloudinary(_image);
      if (imageUrl == null) {
        if (!mounted) return;
        _showSnackBarSafe(AppLocalizations.of(context)!.failedToUploadImage);
        setState(() {
          _isLoading = false;
        });
        return;
      }
    }

    // Removed unused service variable

    final serviceToUpload = ServiceModel(
      title: _titleController.text,
      description: _descriptionController.text,
      price: double.tryParse(_priceController.text) ?? 0.0,
      location: _position != null
          ? GeoPoint(_position!.latitude, _position!.longitude)
          : null,
      imageUrl: imageUrl,
      userId: FirebaseAuth.instance.currentUser?.uid,
      category: _selectedCategory,
    );

    final serviceService = ServiceService();
    ServiceModel? addedService =
        await serviceService.addService(serviceToUpload);

    setState(() {
      _isLoading = false;
    });

    if (addedService != null) {
      if (!mounted) return;
      _showSnackBarSafe(AppLocalizations.of(context)!.serviceAddedSuccessfully,
          isSuccess: true);
      // Clear the form
      _titleController.clear();
      _descriptionController.clear();
      _priceController.clear();
      _locationController.clear();
      setState(() {
        _image = null;
        _position = null;
        _address = null;
      });
    } else {
      if (!mounted) return;
      _showSnackBarSafe(AppLocalizations.of(context)!.failedToAddService,
          isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.addService)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                InkWell(
                  onTap: _pickImage,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt,
                            size: 40,
                            color: Theme.of(context).colorScheme.primary),
                        const SizedBox(height: 8),
                        Text(
                          AppLocalizations.of(context)!.choosePhoto,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_image != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Image.file(
                      _image!,
                      height: 100,
                    ),
                  ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.category,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: _getLocalizedCategories(context)
                      .map((Map<String, String> category) {
                    return DropdownMenuItem<String>(
                      value: category['value'],
                      child: Text(category['name']!),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCategory = newValue;
                    });
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.serviceName,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.description,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  maxLines: 3,
                  validator: (value) =>
                      ValidationUtils.validateServiceDescription(
                          value, context),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _priceController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.price,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      ValidationUtils.validatePrice(value, context),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.address,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  enabled: false,
                ),
                CustomButton(
                  onPressed: _getLocation,
                  text: AppLocalizations.of(context)!.chooseLocation,
                ),
                const SizedBox(height: 30),
                CustomButton(
                  onPressed: _isLoading
                      ? () {}
                      : () {
                          _validateAndAddService();
                        },
                  text: AppLocalizations.of(context)!.addServiceButton,
                  loading: _isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
