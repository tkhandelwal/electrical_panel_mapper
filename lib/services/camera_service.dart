import 'dart:io';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class CameraService {
  CameraController? controller;
  List<CameraDescription>? cameras;
  
  Future<void> initializeCamera() async {
    cameras = await availableCameras();
    if (cameras!.isEmpty) return;
    
    controller = CameraController(
      cameras![0],
      ResolutionPreset.high,
      enableAudio: false,
    );
    
    await controller!.initialize();
  }

  Future<String> takePicture() async {
    if (controller == null || !controller!.value.isInitialized) {
      throw Exception('Camera not initialized');
    }

    final Directory appDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${appDir.path}/PanelImages';
    await Directory(dirPath).create(recursive: true);
    
    final String filePath = join(
      dirPath,
      '${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    try {
      XFile file = await controller!.takePicture();
      await file.saveTo(filePath);
      return filePath;
    } catch (e) {
      throw Exception('Failed to capture image: $e');
    }
  }

  Future<List<String>> getStoredImages() async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${appDir.path}/PanelImages';
    
    if (!await Directory(dirPath).exists()) {
      return [];
    }
    
    final List<FileSystemEntity> entities = await Directory(dirPath).list().toList();
    return entities
        .where((entity) => entity is File && entity.path.endsWith('.jpg'))
        .map((entity) => entity.path)
        .toList();
  }

  void dispose() {
    controller?.dispose();
  }
}