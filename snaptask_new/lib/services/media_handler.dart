import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/snap_task.dart';

class MediaHandler {
  static Future<String> getAudioPath() async {
    final directory = await getApplicationDocumentsDirectory();
    final audioDir = Directory('${directory.path}/audio');
    if (!await audioDir.exists()) {
      await audioDir.create(recursive: true);
    }
    return '${audioDir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.aac';
  }

  static Future<String> savePhoto(File photo) async {
    final directory = await getApplicationDocumentsDirectory();
    final photosDir = Directory('${directory.path}/photos');
    if (!await photosDir.exists()) {
      await photosDir.create(recursive: true);
    }
    
    final fileName = 'photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final savedPath = '${photosDir.path}/$fileName';
    
    await photo.copy(savedPath);
    return savedPath;
  }

  static Future<String> saveVideo(File video) async {
    final directory = await getApplicationDocumentsDirectory();
    final videosDir = Directory('${directory.path}/videos');
    if (!await videosDir.exists()) {
      await videosDir.create(recursive: true);
    }
    
    final fileName = 'video_${DateTime.now().millisecondsSinceEpoch}.mp4';
    final savedPath = '${videosDir.path}/$fileName';
    
    await video.copy(savedPath);
    return savedPath;
  }

  static Future<String> saveAudio(File audio) async {
    final directory = await getApplicationDocumentsDirectory();
    final audioDir = Directory('${directory.path}/audio');
    if (!await audioDir.exists()) {
      await audioDir.create(recursive: true);
    }
    
    final fileName = 'audio_${DateTime.now().millisecondsSinceEpoch}.aac';
    final savedPath = '${audioDir.path}/$fileName';
    
    await audio.copy(savedPath);
    return savedPath;
  }

  static bool fileExists(String filePath) {
    return File(filePath).existsSync();
  }

  static Future<void> deleteFile(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  static String getFileExtension(TaskType type) {
    switch (type) {
      case TaskType.photo:
        return '.jpg';
      case TaskType.video:
        return '.mp4';
      case TaskType.audio:
        return '.aac';
      case TaskType.text:
        return '.txt';
    }
  }
} 