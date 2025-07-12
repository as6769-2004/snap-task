import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/snap_task.dart';
import '../services/settings_service.dart';

class ModeSelector extends StatelessWidget {
  final TaskType currentMode;
  final Function(TaskType) onModeChanged;

  const ModeSelector({
    super.key,
    required this.currentMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsService>(
      builder: (context, settings, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ModeButton(
                icon: Icons.camera_alt,
                label: 'Photo',
                isSelected: currentMode == TaskType.photo,
                onTap: () => onModeChanged(TaskType.photo),
              ),
              _ModeButton(
                icon: Icons.videocam,
                label: 'Video',
                isSelected: currentMode == TaskType.video,
                onTap: () => onModeChanged(TaskType.video),
              ),
              _ModeButton(
                icon: Icons.mic,
                label: 'Audio',
                isSelected: currentMode == TaskType.audio,
                onTap: () => onModeChanged(TaskType.audio),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ModeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsService>(
      builder: (context, settings, child) {
        return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? Colors.yellow : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? Colors.yellow : Colors.white,
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: isSelected ? Colors.black : Colors.white,
                  size: settings.getScaledIconSize(24),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: settings.getTextStyle(
                    fontSize: 12,
                    color: isSelected ? Colors.black : Colors.white,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
} 