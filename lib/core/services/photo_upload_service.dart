// lib/core/services/photo_upload_service.dart
//
// Handles picking an image from gallery/camera and uploading it to
// Firebase Storage under "profile_photos/{uid}.jpg".
// Returns a download URL on success, or an AppException on failure.

import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../errors/app_exception.dart';
import '../errors/result.dart';

class PhotoUploadService {
  PhotoUploadService({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;
  final _picker = ImagePicker();

  // ── Pick from gallery ────────────────────────────────────────
  Future<Result<File>> pickFromGallery() => _pick(ImageSource.gallery);

  // ── Pick from camera ─────────────────────────────────────────
  Future<Result<File>> pickFromCamera() => _pick(ImageSource.camera);

  Future<Result<File>> _pick(ImageSource source) async {
    // ── Request the appropriate OS permission first ───────────────
    final permission = source == ImageSource.gallery
        ? (Platform.isAndroid
            ? Permission.photos          // Android 13+ granular photos
            : Permission.photos)         // iOS photo library
        : Permission.camera;

    // On Android <13, photos permission may not exist — fall back to storage
    PermissionStatus status = await permission.request();
    if (status.isPermanentlyDenied) {
      await openAppSettings();
      return failure(const ValidationException(
          'Permission permanently denied. Please enable it in Settings.'));
    }
    if (!status.isGranted) {
      return failure(const ValidationException(
          'Permission denied. Please allow access to continue.'));
    }

    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (picked == null) {
        return failure(const ValidationException('No image selected.'));
      }
      return success(File(picked.path));
    } catch (e) {
      return failure(UnknownException('Could not open image picker: $e'));
    }
  }

  // ── Upload to Firebase Storage ───────────────────────────────
  /// Uploads [file] and returns the public download URL.
  /// Progress is reported via [onProgress] (0.0 → 1.0).
  Future<Result<String>> uploadProfilePhoto(
    String uid,
    File file, {
    void Function(double progress)? onProgress,
  }) async {
    try {
      final ref = _storage
          .ref()
          .child('profile_photos')
          .child('$uid.jpg');

      final task = ref.putFile(
        file,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      task.snapshotEvents.listen((snap) {
        if (snap.totalBytes > 0) {
          onProgress?.call(snap.bytesTransferred / snap.totalBytes);
        }
      });

      await task;
      final url = await ref.getDownloadURL();
      return success(url);
    } on FirebaseException catch (e) {
      return failure(
          ServerException(e.message ?? 'Upload failed.', statusCode: null));
    } catch (e) {
      return failure(UnknownException('Upload failed: $e'));
    }
  }

  // ── Pick + upload in one call ────────────────────────────────
  /// Convenience: shows picker then uploads. Returns the download URL.
  Future<Result<String>> pickAndUpload(
    String uid,
    ImageSource source, {
    void Function(double progress)? onProgress,
  }) async {
    final pickResult = await _pick(source);
    if (pickResult.isFailure) return failure(pickResult.error);
    return await uploadProfilePhoto(uid, pickResult.data, onProgress: onProgress);
  }
}
