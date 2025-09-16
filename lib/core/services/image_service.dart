import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../models/api_error.dart';
import 'accommodation_api_service.dart';

/// Service for handling image uploads and processing
class ImageService {
  static final ImageService _instance = ImageService._internal();
  factory ImageService() => _instance;
  ImageService._internal();

  final AccommodationApiService _apiService = AccommodationApiService();

  /// Prepare and upload images for accommodation
  /// Returns list of uploaded image URLs (with automatic auth)
  Future<List<String>> prepareAccommodationImages(
    List<XFile> imageFiles
  ) async {
    if (imageFiles.isEmpty) return [];

    try {
      // First validate all images
      for (int i = 0; i < imageFiles.length; i++) {
        final XFile imageFile = imageFiles[i];
        
        // Validate image
        if (!isValidImageFile(imageFile)) {
          throw ApiError(message: 'Invalid image file: ${imageFile.name}');
        }
        
        if (!await isValidImageSize(imageFile)) {
          throw ApiError(message: 'Image too large: ${imageFile.name}');
        }
        
        print('✅ Validated image ${i + 1}/${imageFiles.length}: ${imageFile.name}');
      }

      // Upload images to backend
      print('📤 Uploading ${imageFiles.length} images to server...');
      final List<String> imageUrls = await _apiService.uploadImages(imageFiles);
      
      print('✅ All images uploaded successfully. Total URLs: ${imageUrls.length}');
      return imageUrls;
      
    } catch (e) {
      print('❌ Image Upload Error: ${e.toString()}');
      if (e is ApiError) {
        rethrow;
      }
      throw ApiError(
        message: 'Unexpected error while uploading images: ${e.toString()}',
      );
    }
  }

  /// Prepare single image for upload
  /// Returns image URL (with automatic auth)
  Future<String> prepareSingleImage(XFile imageFile) async {
    final List<String> urls = await prepareAccommodationImages([imageFile]);
    return urls.isNotEmpty ? urls.first : '';
  }

  /// Delete image file from local storage
  /// TODO: Replace with API call when backend is ready
  Future<bool> deleteImage(String imagePath) async {
    try {
      final File imageFile = File(imagePath);
      
      if (await imageFile.exists()) {
        await imageFile.delete();
        print('✅ Image deleted successfully: $imagePath');
        return true;
      } else {
        print('⚠️ Image file not found: $imagePath');
        return false;
      }
    } catch (e) {
      print('❌ Delete Image Error: ${e.toString()}');
      return false;
    }
  }

  /// Delete multiple image files from local storage
  /// TODO: Replace with API call when backend is ready
  Future<bool> deleteImages(List<String> imagePaths) async {
    if (imagePaths.isEmpty) return true;

    try {
      int deletedCount = 0;
      
      for (final String imagePath in imagePaths) {
        if (await deleteImage(imagePath)) {
          deletedCount++;
        }
      }

      print('✅ Deleted $deletedCount/${imagePaths.length} images');
      return deletedCount == imagePaths.length;
      
    } catch (e) {
      print('❌ Delete Images Error: ${e.toString()}');
      return false;
    }
  }


  /// Validate image file
  static bool isValidImageFile(XFile imageFile) {
    final String fileName = imageFile.name.toLowerCase();
    final List<String> allowedExtensions = ['.jpg', '.jpeg', '.png', '.webp'];
    
    return allowedExtensions.any((ext) => fileName.endsWith(ext));
  }

  /// Get image file size in MB
  static Future<double> getImageSizeInMB(XFile imageFile) async {
    final File file = File(imageFile.path);
    final int lengthInBytes = await file.length();
    return lengthInBytes / (1024 * 1024); // Convert to MB
  }

  /// Validate image size (max 5MB per image)
  static Future<bool> isValidImageSize(XFile imageFile, {double maxSizeMB = 5.0}) async {
    final double sizeInMB = await getImageSizeInMB(imageFile);
    return sizeInMB <= maxSizeMB;
  }
}
