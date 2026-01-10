import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:green_frontend/features/media/application/use_cases/upload_media.dart';
import 'package:green_frontend/features/media/application/use_cases/get_media_metadata.dart';
import 'package:green_frontend/features/media/application/use_cases/delete_media.dart';
import 'package:green_frontend/features/media/application/use_cases/get_signed_url.dart';
import 'package:green_frontend/features/media/domain/entities/media.dart';

class MediaProvider with ChangeNotifier {
  final UploadMediaUseCase uploadMediaUseCase;
  final GetMediaMetadataUseCase getMediaMetadataUseCase;
  final DeleteMediaUseCase deleteMediaUseCase;
  final GetSignedUrlUseCase getSignedUrlUseCase;
  final ImagePicker imagePicker;

  List<MediaAsset> _userMedia = [];
  bool _isLoading = false;
  String? _error;

  MediaProvider({
    required this.uploadMediaUseCase,
    required this.getMediaMetadataUseCase,
    required this.deleteMediaUseCase,
    required this.getSignedUrlUseCase,
    required this.imagePicker,
  });

  List<MediaAsset> get userMedia => _userMedia;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<MediaAsset?> pickImageFromGallery() async {
    try {
      final pickedFile = await imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        return await uploadMedia(pickedFile.path, pickedFile.name);
      }
      return null;
    } catch (e) {
      _error = 'Error al seleccionar imagen: $e';
      notifyListeners();
      return null;
    }
  }

  Future<MediaAsset?> pickImageFromCamera() async {
    try {
      final pickedFile = await imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        return await uploadMedia(pickedFile.path, pickedFile.name);
      }
      return null;
    } catch (e) {
      _error = 'Error al tomar foto: $e';
      notifyListeners();
      return null;
    }
  }

  Future<MediaAsset> uploadMedia(String filePath, String fileName) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final media = await uploadMediaUseCase.execute(filePath, fileName);
      
      // Agregar a la lista local
      if (!_userMedia.any((m) => m.id == media.id)) {
        _userMedia.add(media);
      }
      
      _isLoading = false;
      notifyListeners();
      return media;
    } catch (e) {
      _error = 'Error al subir media: $e';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<MediaAsset> getMediaMetadata(String mediaId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final media = await getMediaMetadataUseCase.execute(mediaId);
      _isLoading = false;
      notifyListeners();
      return media;
    } catch (e) {
      _error = 'Error al obtener metadata: $e';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteMedia(String mediaId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await deleteMediaUseCase.execute(mediaId);
      
      // Remover de la lista local
      _userMedia.removeWhere((m) => m.id == mediaId);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Error al eliminar media: $e';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<String> getSignedUrl(String mediaId, {Duration? expiry}) async {
    try {
      return await getSignedUrlUseCase.execute(mediaId, expiry: expiry);
    } catch (e) {
      _error = 'Error al obtener URL firmada: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<String> downloadMedia(String mediaId, String savePath) async {
    try {
      final media = _userMedia.firstWhere((m) => m.id == mediaId);
      if (media.localPath != null && await File(media.localPath!).exists()) {
        final destFile = File(savePath);
        await File(media.localPath!).copy(destFile.path);
        return savePath;
      }
      throw Exception('Media no disponible localmente');
    } catch (e) {
      _error = 'Error al descargar media: $e';
      notifyListeners();
      rethrow;
    }
  }

  String? getLocalPath(String mediaId) {
    try {
      final media = _userMedia.firstWhere((m) => m.id == mediaId);
      return media.localPath;
    } catch (_) {
      return null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clear() {
    _userMedia = [];
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}