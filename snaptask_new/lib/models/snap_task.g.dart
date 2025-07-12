// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'snap_task.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SnapTaskAdapter extends TypeAdapter<SnapTask> {
  @override
  final int typeId = 0;

  @override
  SnapTask read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SnapTask(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      filePath: fields[3] as String,
      type: fields[4] as TaskType,
      timestamp: fields[5] as DateTime,
      isCompleted: fields[6] as bool,
      startTime: fields[7] as DateTime?,
      endTime: fields[8] as DateTime?,
      timeTaken: fields[9] as Duration?,
      alarmTime: fields[10] as DateTime?,
      hasAlarm: fields[11] as bool,
      priority: fields[12] as String,
      tags: (fields[13] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, SnapTask obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.filePath)
      ..writeByte(4)
      ..write(obj.type)
      ..writeByte(5)
      ..write(obj.timestamp)
      ..writeByte(6)
      ..write(obj.isCompleted)
      ..writeByte(7)
      ..write(obj.startTime)
      ..writeByte(8)
      ..write(obj.endTime)
      ..writeByte(9)
      ..write(obj.timeTaken)
      ..writeByte(10)
      ..write(obj.alarmTime)
      ..writeByte(11)
      ..write(obj.hasAlarm)
      ..writeByte(12)
      ..write(obj.priority)
      ..writeByte(13)
      ..write(obj.tags);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SnapTaskAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TaskTypeAdapter extends TypeAdapter<TaskType> {
  @override
  final int typeId = 1;

  @override
  TaskType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TaskType.photo;
      case 1:
        return TaskType.video;
      case 2:
        return TaskType.audio;
      case 3:
        return TaskType.text;
      default:
        return TaskType.photo;
    }
  }

  @override
  void write(BinaryWriter writer, TaskType obj) {
    switch (obj) {
      case TaskType.photo:
        writer.writeByte(0);
        break;
      case TaskType.video:
        writer.writeByte(1);
        break;
      case TaskType.audio:
        writer.writeByte(2);
        break;
      case TaskType.text:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
