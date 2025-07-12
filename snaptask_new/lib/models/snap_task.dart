import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';

part 'snap_task.g.dart';

@HiveType(typeId: 0)
class SnapTask extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  String filePath;

  @HiveField(4)
  TaskType type;

  @HiveField(5)
  DateTime timestamp;

  @HiveField(6)
  bool isCompleted;

  @HiveField(7)
  DateTime? startTime;

  @HiveField(8)
  DateTime? endTime;

  @HiveField(9)
  Duration? timeTaken;

  @HiveField(10)
  DateTime? alarmTime;

  @HiveField(11)
  bool hasAlarm;

  @HiveField(12)
  String priority;

  @HiveField(13)
  List<String> tags;

  SnapTask({
    required this.id,
    required this.title,
    this.description = '',
    required this.filePath,
    required this.type,
    required this.timestamp,
    this.isCompleted = false,
    this.startTime,
    this.endTime,
    this.timeTaken,
    this.alarmTime,
    this.hasAlarm = false,
    this.priority = 'medium',
    this.tags = const [],
  });

  void startTimer() {
    startTime = DateTime.now();
  }

  void stopTimer() {
    if (startTime != null) {
      endTime = DateTime.now();
      timeTaken = endTime!.difference(startTime!);
    }
  }

  String get formattedTimeTaken {
    if (timeTaken == null) return 'Not started';
    final hours = timeTaken!.inHours;
    final minutes = timeTaken!.inMinutes % 60;
    final seconds = timeTaken!.inSeconds % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  String get formattedStartTime {
    if (startTime == null) return 'Not started';
    return '${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}';
  }

  String get formattedEndTime {
    if (endTime == null) return 'Not finished';
    return '${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}';
  }

  bool get isRunning => startTime != null && endTime == null;
}

@HiveType(typeId: 1)
enum TaskType {
  @HiveField(0)
  photo,
  @HiveField(1)
  video,
  @HiveField(2)
  audio,
  @HiveField(3)
  text,
}

enum TaskPriority {
  low,
  medium,
  high,
  urgent,
}

extension TaskPriorityExtension on TaskPriority {
  String get displayName {
    switch (this) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
      case TaskPriority.urgent:
        return 'Urgent';
    }
  }

  Color get color {
    switch (this) {
      case TaskPriority.low:
        return Colors.green;
      case TaskPriority.medium:
        return Colors.blue;
      case TaskPriority.high:
        return Colors.orange;
      case TaskPriority.urgent:
        return Colors.red;
    }
  }
} 