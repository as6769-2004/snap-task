import 'package:hive/hive.dart';
import '../models/snap_task.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  static StorageService get instance => _instance;

  late Box<SnapTask> _taskBox;

  Future<void> initialize() async {
    _taskBox = await Hive.openBox<SnapTask>('tasks');
  }

  Future<void> saveTask(SnapTask task) async {
    await _taskBox.put(task.id, task);
  }

  Future<void> updateTask(SnapTask task) async {
    await _taskBox.put(task.id, task);
  }

  Future<void> deleteTask(SnapTask task) async {
    await _taskBox.delete(task.id);
  }

  List<SnapTask> getAllTasks() {
    return _taskBox.values.toList();
  }

  Future<List<SnapTask>> getAllTasksAsync() async {
    return _taskBox.values.toList();
  }

  List<SnapTask> getCompletedTasks() {
    return _taskBox.values.where((task) => task.isCompleted).toList();
  }

  List<SnapTask> getPendingTasks() {
    return _taskBox.values.where((task) => !task.isCompleted).toList();
  }

  List<SnapTask> getTasksByType(TaskType type) {
    return _taskBox.values.where((task) => task.type == type).toList();
  }

  List<SnapTask> getTasksByPriority(String priority) {
    return _taskBox.values.where((task) => task.priority == priority).toList();
  }

  List<SnapTask> getTasksWithAlarm() {
    return _taskBox.values.where((task) => task.hasAlarm).toList();
  }

  List<SnapTask> getRunningTasks() {
    return _taskBox.values.where((task) => task.isRunning).toList();
  }

  void close() {
    _taskBox.close();
  }
} 