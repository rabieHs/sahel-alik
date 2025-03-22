import 'dart:io';
import 'package:flutter/material.dart';
import '../../../models/service.dart';
import '../../../services/service_service.dart'; // Import ServiceService
import '../../../utils/image_upload_utils.dart'; // Import ImageUploadUtils
import 'package:image_picker/image_picker.dart'; // Import image_picker

class UpdateServicePage extends StatefulWidget {
  final ServiceModel service;

  const UpdateServicePage({Key? key, required this.service}) : super(key: key);

  @override
  _UpdateServicePageState createState() => _UpdateServicePageState();
}

class _UpdateServicePageState extends State<UpdateServicePage> {
  File? _imageFile; // State variable for selected image file
  final _formKey = GlobalKey<FormState>();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _priceController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.service.title ?? '';
    _descriptionController.text = widget.service.description ?? '';
    _priceController.text = widget.service.price.toString();
  }

  Future<void> _pickImage() async {
    final pickedFile = await getImageFromGallery(); // Call top-level function
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateService() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      String title = _titleController.text;
      String description = _descriptionController.text;
      double price = double.parse(_priceController.text);
      String? imageUrl =
          widget.service.imageUrl; // Default to existing image URL

      if (_imageFile != null) {
        // Upload new image if selected
        imageUrl = await uploadImageToCloudinary(_imageFile);
      }

      final updatedService = ServiceModel(
        id: widget.service.id, // Keep the same service ID
        title: title,
        description: description,
        price: price,
        imageUrl:
            imageUrl ?? widget.service.imageUrl, // Use new URL or keep old one
        location: widget.service.location, // Keep same location
        userId: widget.service.userId, // Keep same userId
        email: widget.service.email,
        phone: widget.service.phone,
        rating: widget.service.rating,
      );

      final serviceService = ServiceService();
      ServiceModel? updatedServiceResult = await serviceService.updateService(
          widget.service.id!,
          updatedService); // Pass serviceId and get ServiceModel?

      setState(() {
        _isLoading = false;
      });

      if (updatedServiceResult != null) {
        // Check if result is not null for success
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Service updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Go back to service list after update
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update service. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Service'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Image update UI
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    _imageFile != null // Display selected image if available
                        ? Image.file(
                            _imageFile!,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : (widget.service.imageUrl != null
                            ? ColorFiltered(
                                colorFilter: ColorFilter.mode(
                                    Colors.black.withOpacity(0.5),
                                    BlendMode.saturation),
                                child: Image.network(
                                  widget.service.imageUrl!,
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Placeholder(
                                fallbackHeight: 200,
                                fallbackWidth: double.infinity,
                              )),
                    Icon(Icons.camera_alt, color: Colors.white, size: 40),
                    Text(
                      'Select Image',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter title';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter description';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter valid price';
                  }
                  return null;
                },
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : _updateService, // Disable button when loading
                child: Text(_isLoading ? 'Updating...' : 'Update Service'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
