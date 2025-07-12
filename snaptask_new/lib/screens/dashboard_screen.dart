import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/snap_task.dart';
import '../services/storage_service.dart';
import '../services/settings_service.dart';
import '../services/media_handler.dart';
import '../widgets/task_card.dart';
import '../widgets/task_creation_dialog.dart';
import 'dart:io';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<SnapTask> _tasks = [];
  List<SnapTask> _filteredTasks = [];
  String _searchQuery = '';
  String _selectedPriority = 'all';
  String _selectedType = 'all';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    try {
      final tasks = await StorageService.instance.getAllTasks();
      setState(() {
        _tasks = tasks;
        _filteredTasks = tasks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterTasks() {
    setState(() {
      _filteredTasks = _tasks.where((task) {
        final matchesSearch = task.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            task.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            task.tags.any((tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()));
        
        final matchesPriority = _selectedPriority == 'all' || task.priority == _selectedPriority;
        final matchesType = _selectedType == 'all' || task.type.name == _selectedType;
        
        return matchesSearch && matchesPriority && matchesType;
      }).toList();
    });
  }

  Future<void> _toggleTaskCompletion(SnapTask task) async {
    try {
      task.isCompleted = !task.isCompleted;
      await StorageService.instance.updateTask(task);
      _loadTasks();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating task: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _startTaskTimer(SnapTask task) async {
    try {
      task.startTimer();
      await StorageService.instance.updateTask(task);
      _loadTasks();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error starting timer: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _stopTaskTimer(SnapTask task) async {
    try {
      task.stopTimer();
      await StorageService.instance.updateTask(task);
      _loadTasks();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error stopping timer: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _editTask(SnapTask task) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => TaskCreationDialog(
        initialType: task.type,
        initialFilePath: task.filePath,
        editingTask: task,
      ),
    ).then((editedTask) {
      if (editedTask != null) {
        _loadTasks();
      }
    });
  }

  Future<void> _deleteTask(SnapTask task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F3460),
        title: const Text(
          'Delete Task',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete "${task.title}"?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await StorageService.instance.deleteTask(task);
        _loadTasks();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Task deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting task: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showTaskDetails(SnapTask task) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF0F3460),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFF16213E),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info,
                      color: Colors.yellow,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        task.title,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Edit Button
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _editTask(task);
                      },
                      icon: const Icon(Icons.edit, color: Colors.yellow),
                    ),
                    // Delete Button
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _deleteTask(task);
                      },
                      icon: const Icon(Icons.delete, color: Colors.red),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),
              
              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Media Preview
                      if (task.filePath.isNotEmpty) ...[
                        Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.black,
                          ),
                          child: _buildMediaPreview(task),
                        ),
                        const SizedBox(height: 16),
                      ],
                      
                      if (task.description.isNotEmpty) ...[
                        const Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          task.description,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      
                      // Priority and Type
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getPriorityColor(task.priority),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _getPriorityLabel(task.priority),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.purple,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _getTypeLabel(task.type),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Time tracking
                      const Text(
                        'Time Tracking',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.timer, color: Colors.red, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            'Total Time: ${task.formattedTimeTaken}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.play_arrow, color: Colors.green, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            'Start: ${task.formattedStartTime}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.stop, color: Colors.red, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            'End: ${task.formattedEndTime}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                      
                      if (task.tags.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const Text(
                          'Tags',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: task.tags.map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.yellow.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.yellow.withOpacity(0.5)),
                              ),
                              child: Text(
                                tag,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.yellow,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                      
                      if (task.hasAlarm && task.alarmTime != null) ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Icon(Icons.alarm, color: Colors.yellow, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              'Alarm: ${task.alarmTime!.hour.toString().padLeft(2, '0')}:${task.alarmTime!.minute.toString().padLeft(2, '0')}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.yellow,
                              ),
                            ),
                          ],
                        ),
                      ],
                      
                      const SizedBox(height: 16),
                      Text(
                        'Created: ${_formatDateTime(task.timestamp)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMediaPreview(SnapTask task) {
    if (!MediaHandler.fileExists(task.filePath)) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getTypeIcon(task.type),
              color: Colors.white54,
              size: 48,
            ),
            const SizedBox(height: 8),
            const Text(
              'Media not found',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    switch (task.type) {
      case TaskType.photo:
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            File(task.filePath),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Icon(Icons.error, color: Colors.red),
              );
            },
          ),
        );
      case TaskType.video:
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            color: Colors.black,
            child: const Center(
              child: Icon(Icons.videocam, color: Colors.white, size: 48),
            ),
          ),
        );
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

  void _showCreateTaskDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const TaskCreationDialog(),
    ).then((task) {
      if (task != null) {
        _loadTasks();
      }
    });
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

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsService>(
      builder: (context, settings, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Dashboard',
              style: settings.getTextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                onPressed: _showCreateTaskDialog,
                icon: Icon(
                  Icons.add,
                  color: Colors.yellow,
                  size: settings.getScaledIconSize(24),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              // Search and Filters
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Search
                    TextField(
                      onChanged: (value) {
                        _searchQuery = value;
                        _filterTasks();
                      },
                      style: settings.getTextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search tasks...',
                        hintStyle: settings.getTextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.white70,
                          size: settings.getScaledIconSize(20),
                        ),
                        filled: true,
                        fillColor: const Color(0xFF0F3460),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.purple),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.yellow, width: 2),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Filters
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedPriority,
                            decoration: InputDecoration(
                              labelText: 'Priority',
                              labelStyle: settings.getTextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                              filled: true,
                              fillColor: const Color(0xFF0F3460),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.purple),
                              ),
                            ),
                            dropdownColor: const Color(0xFF0F3460),
                            style: settings.getTextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                            items: [
                              const DropdownMenuItem(value: 'all', child: Text('All Priorities')),
                              const DropdownMenuItem(value: 'low', child: Text('Low')),
                              const DropdownMenuItem(value: 'medium', child: Text('Medium')),
                              const DropdownMenuItem(value: 'high', child: Text('High')),
                              const DropdownMenuItem(value: 'urgent', child: Text('Urgent')),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedPriority = value!;
                              });
                              _filterTasks();
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedType,
                            decoration: InputDecoration(
                              labelText: 'Type',
                              labelStyle: settings.getTextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                              filled: true,
                              fillColor: const Color(0xFF0F3460),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.purple),
                              ),
                            ),
                            dropdownColor: const Color(0xFF0F3460),
                            style: settings.getTextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                            items: [
                              const DropdownMenuItem(value: 'all', child: Text('All Types')),
                              const DropdownMenuItem(value: 'photo', child: Text('Photo')),
                              const DropdownMenuItem(value: 'video', child: Text('Video')),
                              const DropdownMenuItem(value: 'audio', child: Text('Audio')),
                              const DropdownMenuItem(value: 'text', child: Text('Text')),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedType = value!;
                              });
                              _filterTasks();
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Task List
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.yellow),
                      )
                    : _filteredTasks.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.task_alt,
                                  color: Colors.white54,
                                  size: settings.getScaledIconSize(64),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No tasks found',
                                  style: settings.getTextStyle(
                                    fontSize: 18,
                                    color: Colors.white54,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Create your first task!',
                                  style: settings.getTextStyle(
                                    fontSize: 14,
                                    color: Colors.white38,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.only(bottom: 16),
                            itemCount: _filteredTasks.length,
                            itemBuilder: (context, index) {
                              final task = _filteredTasks[index];
                              return TaskCard(
                                task: task,
                                onTap: () => _showTaskDetails(task),
                                onToggleComplete: () => _toggleTaskCompletion(task),
                                onStartTimer: () => _startTaskTimer(task),
                                onStopTimer: () => _stopTaskTimer(task),
                              );
                            },
                          ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _showCreateTaskDialog,
            backgroundColor: Colors.red,
            child: Icon(
              Icons.add,
              color: Colors.white,
              size: settings.getScaledIconSize(24),
            ),
          ),
        );
      },
    );
  }
} 