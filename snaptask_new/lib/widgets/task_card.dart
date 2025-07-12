import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../models/snap_task.dart';
import '../services/settings_service.dart';
import '../services/media_handler.dart';

class TaskCard extends StatefulWidget {
  final SnapTask task;
  final VoidCallback? onTap;
  final VoidCallback? onToggleComplete;
  final VoidCallback? onStartTimer;
  final VoidCallback? onStopTimer;

  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onToggleComplete,
    this.onStartTimer,
    this.onStopTimer,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.task.type == TaskType.video && widget.task.filePath.isNotEmpty) {
      _initializeVideo();
    }
  }

  Future<void> _initializeVideo() async {
    try {
      _videoController = VideoPlayerController.file(File(widget.task.filePath));
      await _videoController!.initialize();
      setState(() {
        _isVideoInitialized = true;
      });
    } catch (e) {
      debugPrint('Error initializing video: $e');
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsService>(
      builder: (context, settings, child) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with title and completion status
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.task.title,
                          style: settings.getTextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (widget.onToggleComplete != null)
                        IconButton(
                          onPressed: widget.onToggleComplete,
                          icon: Icon(
                            widget.task.isCompleted
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            color: widget.task.isCompleted ? Colors.green : Colors.white70,
                            size: settings.getScaledIconSize(24),
                          ),
                        ),
                    ],
                  ),
                  
                  // Description
                  if (widget.task.description.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      widget.task.description,
                      style: settings.getTextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  
                  // Priority and Type
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      // Priority
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getPriorityColor(widget.task.priority),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getPriorityLabel(widget.task.priority),
                          style: settings.getTextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Type
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.purple,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getTypeIcon(widget.task.type),
                              color: Colors.white,
                              size: settings.getScaledIconSize(12),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _getTypeLabel(widget.task.type),
                              style: settings.getTextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  // Tags
                  if (widget.task.tags.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      children: widget.task.tags.take(3).map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.yellow.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.yellow.withOpacity(0.5)),
                          ),
                          child: Text(
                            tag,
                            style: settings.getTextStyle(
                              fontSize: 10,
                              color: Colors.yellow,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                  
                  // Time tracking
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.timer,
                        color: Colors.red,
                        size: settings.getScaledIconSize(16),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Time: ${widget.task.formattedTimeTaken}',
                        style: settings.getTextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                      const Spacer(),
                      if (widget.task.isRunning)
                        Text(
                          'Running',
                          style: settings.getTextStyle(
                            fontSize: 12,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                  
                  // Timer controls
                  if (!widget.task.isCompleted) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        if (widget.task.isRunning)
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: widget.onStopTimer,
                              icon: Icon(
                                Icons.stop,
                                size: settings.getScaledIconSize(16),
                              ),
                              label: Text(
                                'Stop',
                                style: settings.getTextStyle(fontSize: 12),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                              ),
                            ),
                          )
                        else
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: widget.onStartTimer,
                              icon: Icon(
                                Icons.play_arrow,
                                size: settings.getScaledIconSize(16),
                              ),
                              label: Text(
                                'Start',
                                style: settings.getTextStyle(fontSize: 12),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                  
                  // Alarm indicator
                  if (widget.task.hasAlarm && widget.task.alarmTime != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.alarm,
                          color: Colors.yellow,
                          size: settings.getScaledIconSize(16),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Alarm: ${widget.task.alarmTime!.hour.toString().padLeft(2, '0')}:${widget.task.alarmTime!.minute.toString().padLeft(2, '0')}',
                          style: settings.getTextStyle(
                            fontSize: 12,
                            color: Colors.yellow,
                          ),
                        ),
                      ],
                    ),
                  ],
                  
                  // Media preview
                  if (widget.task.filePath.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.black,
                      ),
                      child: _buildMediaPreview(),
                    ),
                  ],
                  
                  // Timestamp
                  const SizedBox(height: 8),
                  Text(
                    'Created: ${_formatDateTime(widget.task.timestamp)}',
                    style: settings.getTextStyle(
                      fontSize: 10,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMediaPreview() {
    switch (widget.task.type) {
      case TaskType.photo:
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            File(widget.task.filePath),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Icon(Icons.error, color: Colors.red),
              );
            },
          ),
        );
      case TaskType.video:
        if (_isVideoInitialized && _videoController != null) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: _videoController!.value.aspectRatio,
              child: VideoPlayer(_videoController!),
            ),
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(color: Colors.yellow),
          );
        }
      case TaskType.audio:
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(
              colors: [Colors.purple, Colors.red],
            ),
          ),
          child: const Center(
            child: Icon(Icons.audiotrack, color: Colors.white, size: 48),
          ),
        );
      case TaskType.text:
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.purple.withOpacity(0.3),
          ),
          child: const Center(
            child: Icon(Icons.text_fields, color: Colors.white, size: 48),
          ),
        );
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.blue;
      case 'high':
        return Colors.orange;
      case 'urgent':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  String _getPriorityLabel(String priority) {
    switch (priority) {
      case 'low':
        return 'Low';
      case 'medium':
        return 'Medium';
      case 'high':
        return 'High';
      case 'urgent':
        return 'Urgent';
      default:
        return 'Medium';
    }
  }

  IconData _getTypeIcon(TaskType type) {
    switch (type) {
      case TaskType.photo:
        return Icons.photo;
      case TaskType.video:
        return Icons.videocam;
      case TaskType.audio:
        return Icons.audiotrack;
      case TaskType.text:
        return Icons.text_fields;
    }
  }

  String _getTypeLabel(TaskType type) {
    switch (type) {
      case TaskType.photo:
        return 'Photo';
      case TaskType.video:
        return 'Video';
      case TaskType.audio:
        return 'Audio';
      case TaskType.text:
        return 'Text';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
} 