import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class ImageHandler {
  Future<XFile?> selectImgFromGallery() async {
    return await ImagePicker().pickImage(source: ImageSource.gallery);
  }

  Future<String> _createImagesFolder() async {
    // Get the app's documents directory
    final Directory appDocDir = await getApplicationDocumentsDirectory();

    // Define the path for the new folder (e.g., 'images')
    final String imagesFolderPath = '${appDocDir.path}/images';

    // Create the directory if it doesn't exist
    final Directory imagesDir = Directory(imagesFolderPath);
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    } else {
      //print('Images folder already exists at: $imagesFolderPath');
    }

    // Return the path to the images folder
    return imagesFolderPath;
  }

  Future<String> saveImageToFolder(XFile? pickedImage) async {
    // Create or get the images folder
    String imagesFolderPath = await _createImagesFolder();

    if (pickedImage != null) {
      // Define the file path to save the image
      final String fileName = pickedImage.name; // Get the image file name
      final String imagePath = '$imagesFolderPath/$fileName';

      // Save the image to the images folder
      final File imageFile = File(imagePath);
      await imageFile.writeAsBytes(await pickedImage.readAsBytes());

      // Return the saved image file path
      return imagePath;
    }

    return "";
  }

  Future<bool> deleteImage(String imagePath) async {
    if (imagePath.isNotEmpty) {
      final File imageFile = File(imagePath);

      if (await imageFile.exists()) {
        try {
          await imageFile.delete();
          return true; // Success
        } catch (e) {
          return false; // Failure
        }
      }
    }

    return false; // File doesn't exist
  }
}
