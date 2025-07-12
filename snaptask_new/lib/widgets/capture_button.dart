import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/snap_task.dart';
import '../services/settings_service.dart';

class CaptureButton extends StatelessWidget {
  final bool isRecording;
  final VoidCallback onPressed;
  final TaskType mode;

  const CaptureButton({
    super.key,
    required this.isRecording,
    required this.onPressed,
    required this.mode,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsService>(
      builder: (context, settings, child) {
        return GestureDetector(
          onTap: onPressed,
          child: Container(
            width: settings.getScaledIconSize(80),
            height: settings.getScaledIconSize(80),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isRecording ? Colors.red : Colors.yellow,
                width: settings.getScaledIconSize(4),
              ),
              color: isRecording ? Colors.red : Colors.transparent,
            ),
            child: Center(
              child: Container(
                width: settings.getScaledIconSize(60),
                height: settings.getScaledIconSize(60),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isRecording ? Colors.white : Colors.yellow,
                ),
                child: Icon(
                  _getModeIcon(),
                  color: isRecording ? Colors.red : Colors.black,
                  size: settings.getScaledIconSize(30),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _getModeIcon() {
    switch (mode) {
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
} 