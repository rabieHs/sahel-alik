import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:image_picker/image_picker.dart';

Future<String?> uploadImageToCloudinary(File? imageFile) async {
  if (imageFile == null) {
    return null;
  }

  try {
    final cloudinary = CloudinaryPublic(
      "dgvyd70ml", // Your cloud name
      "ohvddsp6", // Your upload preset
    );

    // Generate a unique filename to avoid conflicts
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final uniqueFileName = 'service_image_$timestamp';

    final response = await cloudinary.uploadFile(
      CloudinaryFile.fromFile(
        imageFile.path,
        resourceType: CloudinaryResourceType.Image,
        folder: "sahel_alik", // Store in a specific folder
        publicId: uniqueFileName,
      ),
    );

    print('Cloudinary upload success: ${response.secureUrl}');
    return response.secureUrl;
  } catch (e) {
    print('Error uploading to Cloudinary: $e');

    // Print more detailed error information
    if (e is CloudinaryException) {
      print('Cloudinary error details: ${e.message}');
    }

    return null;
  }
}

Future<XFile?> getImageFromGallery() async {
  final ImagePicker picker = ImagePicker();
  final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
  return pickedFile;
}
