import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:sahel_alik/utils/image_upload_utils.dart'; // Import image upload utility
import 'package:sahel_alik/services/service_service.dart'; // Import ServiceService
import 'package:sahel_alik/models/service.dart'; // Import ServiceModel
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../widgets/custom_button.dart';

class AddServiceInterface extends StatefulWidget {
  const AddServiceInterface({super.key});

  @override
  State<AddServiceInterface> createState() => _AddServiceInterfaceState();
}

class _AddServiceInterfaceState extends State<AddServiceInterface> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _locationController = TextEditingController();
  String? _selectedCategory; // To hold selected category
  File? _image;
  List<String> serviceCategories = [
    'Maid',
    'Cleaner',
    'Mechanic',
    'Barber',
    'Plumber',
    'Electrician',
    'Carpenter',
    'Painter',
    'Gardener',
    'Chef',
    'Tutor',
    'Driver',
    'More',
  ];
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable location services.')));
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied.')));
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return;
    }

    try {
      _position = await Geolocator.getCurrentPosition();
      if (_position != null) {
        _getAddressFromCoordinates();
      }
    } catch (e) {
      print("Error getting location: ${e.toString()}");
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Error getting location. Please try again.')));
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
        print("Error getting address from coordinates: ${e.toString()}");
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Error getting address. Please try again.')));
      }
    }
  }

  Future<void> _addService() async {
    setState(() {
      _isLoading = true;
    });

    String? imageUrl;
    if (_image != null) {
      imageUrl = await uploadImageToCloudinary(_image);
      if (imageUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Failed to upload image. Please try again.')));
        setState(() {
          _isLoading = false;
        });
        return;
      }
    }

    final service = ServiceModel(
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Service added successfully'),
          backgroundColor: Colors.green,
        ),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to add service. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Zid Service')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
                      const Text(
                        'Khezar التصويرة',
                        style: TextStyle(fontWeight: FontWeight.bold),
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
                  labelText: 'Category',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: serviceCategories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
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
                  labelText: 'Nom de service',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: 'Soum',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Adresse',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                enabled: false,
              ),
              CustomButton(
                onPressed: _getLocation,
                text: 'ختار لبلاصة',
              ),
              const SizedBox(height: 30),
              CustomButton(
                onPressed: () async {
                  if (_isLoading) return;
                  await _addService();
                },

                // Disable button when loading
                text: _isLoading
                    ? 'Loading...'
                    : 'Zid Service', // Show loading text
              ),
            ],
          ),
        ),
      ),
    );
  }
}
