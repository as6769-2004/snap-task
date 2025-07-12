import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:provider/provider.dart';
import '../models/snap_task.dart';
import '../services/storage_service.dart';
import '../services/media_handler.dart';
import '../services/permission_service.dart';
import '../services/settings_service.dart';
import '../widgets/capture_button.dart';
import '../widgets/mode_selector.dart';
import '../widgets/task_creation_dialog.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  CameraController? _controller;
  FlutterSoundRecorder? _audioRecorder;
  bool _isInitialized = false;
  bool _isRecording = false;
  bool _isAudioRecording = false;
  TaskType _currentMode = TaskType.photo;
  String? _capturedFilePath;
  bool _isFlashOn = false;
  bool _isFrontCamera = false;
  List<CameraDescription> _cameras = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
    _initializeAudioRecorder();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    _audioRecorder?.closeRecorder();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      _controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        _controller = CameraController(
          _cameras[_isFrontCamera ? 1 : 0],
          ResolutionPreset.high,
          enableAudio: true,
          imageFormatGroup: ImageFormatGroup.jpeg,
        );

        await _controller!.initialize();
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
        }
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  Future<void> _initializeAudioRecorder() async {
    _audioRecorder = FlutterSoundRecorder();
    await _audioRecorder!.openRecorder();
  }

  Future<void> _capturePhoto() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      final image = await _controller!.takePicture();
      setState(() {
        _capturedFilePath = image.path;
      });
      _showTaskCreationDialog(TaskType.photo, image.path);
    } catch (e) {
      debugPrint('Error capturing photo: $e');
    }
  }

  Future<void> _startVideoRecording() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      await _controller!.startVideoRecording();
      setState(() {
        _isRecording = true;
      });
    } catch (e) {
      debugPrint('Error starting video recording: $e');
    }
  }

  Future<void> _stopVideoRecording() async {
    if (_controller == null) return;

    try {
      final video = await _controller!.stopVideoRecording();
      setState(() {
        _isRecording = false;
        _capturedFilePath = video.path;
      });
      _showTaskCreationDialog(TaskType.video, video.path);
    } catch (e) {
      debugPrint('Error stopping video recording: $e');
    }
  }

  Future<void> _startAudioRecording() async {
    if (_audioRecorder == null) return;

    try {
      final path = await MediaHandler.getAudioPath();
      await _audioRecorder!.startRecorder(
        toFile: path,
        codec: Codec.aacADTS,
      );
      setState(() {
        _isAudioRecording = true;
      });
    } catch (e) {
      debugPrint('Error starting audio recording: $e');
    }
  }

  Future<void> _stopAudioRecording() async {
    if (_audioRecorder == null) return;

    try {
      final path = await _audioRecorder!.stopRecorder();
      setState(() {
        _isAudioRecording = false;
        _capturedFilePath = path ?? '';
      });
      if (path != null) {
        _showTaskCreationDialog(TaskType.audio, path);
      }
    } catch (e) {
      debugPrint('Error stopping audio recording: $e');
    }
  }

  void _showTaskCreationDialog(TaskType type, String filePath) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => TaskCreationDialog(
        initialType: type,
        initialFilePath: filePath,
      ),
    ).then((task) {
      if (task != null) {
        _saveTask(task);
      }
    });
  }

  Future<void> _saveTask(SnapTask task) async {
    try {
      await StorageService.instance.saveTask(task);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Task "${task.title}" saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving task: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onModeChanged(TaskType mode) {
    setState(() {
      _currentMode = mode;
    });
  }

  void _onCapturePressed() {
    switch (_currentMode) {
      case TaskType.photo:
        _capturePhoto();
        break;
      case TaskType.video:
        if (_isRecording) {
          _stopVideoRecording();
        } else {
          _startVideoRecording();
        }
        break;
      case TaskType.audio:
        if (_isAudioRecording) {
          _stopAudioRecording();
        } else {
          _startAudioRecording();
        }
        break;
      case TaskType.text:
        _showTaskCreationDialog(TaskType.text, '');
        break;
    }
  }

  Future<void> _toggleFlash() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      await _controller!.setFlashMode(_isFlashOn ? FlashMode.off : FlashMode.torch);
      setState(() {
        _isFlashOn = !_isFlashOn;
      });
    } catch (e) {
      debugPrint('Error toggling flash: $e');
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;

    setState(() {
      _isFrontCamera = !_isFrontCamera;
    });

    await _controller?.dispose();
    await _initializeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsService>(
      builder: (context, settings, child) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              // Camera Preview
              if (_isInitialized && _controller != null)
                CameraPreview(_controller!)
              else
                Container(
                  color: Colors.black,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: settings.getScaledIconSize(64),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Initializing camera...',
                          style: settings.getTextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              
              // Top Controls - Snapchat Style
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 20,
                    left: 20,
                    right: 20,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Left side - Flash
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: IconButton(
                          onPressed: _toggleFlash,
                          icon: Icon(
                            _isFlashOn ? Icons.flash_on : Icons.flash_off,
                            color: Colors.white,
                            size: settings.getScaledIconSize(24),
                          ),
                        ),
                      ),
                      
                      // Center - Mode Selector
                      ModeSelector(
                        currentMode: _currentMode,
                        onModeChanged: _onModeChanged,
                      ),
                      
                      // Right side - Switch Camera
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: IconButton(
                          onPressed: _switchCamera,
                          icon: Icon(
                            Icons.flip_camera_ios,
                            color: Colors.white,
                            size: settings.getScaledIconSize(24),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Bottom Controls - Snapchat Style with Shutter at Bottom
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).padding.bottom + 20,
                    left: 20,
                    right: 20,
                  ),
                  child: Column(
                    children: [
                      // Mode indicator
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _getModeText(),
                          style: settings.getTextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Bottom row with controls
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Gallery Button
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: IconButton(
                              onPressed: () {
                                // Open gallery
                              },
                              icon: Icon(
                                Icons.photo_library,
                                color: Colors.white,
                                size: settings.getScaledIconSize(28),
                              ),
                            ),
                          ),
                          
                          // Capture Button - Large and Centered
                          Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 4,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: GestureDetector(
                              onTap: _onCapturePressed,
                              onLongPress: _currentMode == TaskType.video ? _startVideoRecording : null,
                              onLongPressEnd: _currentMode == TaskType.video ? (_) => _stopVideoRecording() : null,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _isRecording || _isAudioRecording ? Colors.red : Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _getCaptureIcon(),
                                  color: _isRecording || _isAudioRecording ? Colors.white : Colors.black,
                                  size: settings.getScaledIconSize(36),
                                ),
                              ),
                            ),
                          ),
                          
                          // Additional Options Button
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: IconButton(
                              onPressed: () {
                                _showTaskCreationDialog(TaskType.text, '');
                              },
                              icon: Icon(
                                Icons.add,
                                color: Colors.white,
                                size: settings.getScaledIconSize(28),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              // Recording Indicator - Snapchat Style
              if (_isRecording || _isAudioRecording)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 80,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isRecording ? 'Recording Video' : 'Recording Audio',
                            style: settings.getTextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  IconData _getCaptureIcon() {
    if (_isRecording || _isAudioRecording) {
      return Icons.stop;
    }
    
    switch (_currentMode) {
      case TaskType.photo:
        return Icons.camera_alt;
      case TaskType.video:
        return Icons.videocam;
      case TaskType.audio:
        return Icons.mic;
      case TaskType.text:
        return Icons.text_fields;
    }
  }

  String _getModeText() {
    switch (_currentMode) {
      case TaskType.photo:
        return 'PHOTO';
      case TaskType.video:
        return 'VIDEO';
      case TaskType.audio:
        return 'AUDIO';
      case TaskType.text:
        return 'TEXT';
    }
  }
} 