import 'dart:io';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class CameraService {
  static CameraController? _controller;
  static List<CameraDescription> _cameras = [];

  static Future<void> initialize() async {
    _cameras = await availableCameras();
  }

  static Future<CameraController> getController() async {
    if (_controller != null) return _controller!;

    if (_cameras.isEmpty) {
      await initialize();
    }

    _controller = CameraController(
      _cameras.first,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await _controller!.initialize();
    return _controller!;
  }

  static Future<String?> takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return null;
    }

    final Directory appDir = await getApplicationDocumentsDirectory();
    final String fileName = 'visit_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final String filePath = path.join(appDir.path, 'photos', fileName);

    await Directory(path.join(appDir.path, 'photos')).create(recursive: true);

    final XFile photo = await _controller!.takePicture();
    final File savedImage = await File(photo.path).copy(filePath);

    return savedImage.path;
  }

  static void dispose() {
    _controller?.dispose();
    _controller = null;
  }
}
