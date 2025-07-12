import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../models/snap_task.dart';
import '../services/settings_service.dart';
import '../services/media_handler.dart';
import '../services/storage_service.dart';

class TaskCreationDialog extends StatefulWidget {
  final TaskType? initialType;
  final String? initialFilePath;
  final SnapTask? editingTask;

  const TaskCreationDialog({
    super.key,
    this.initialType,
    this.initialFilePath,
    this.editingTask,
  });

  @override
  State<TaskCreationDialog> createState() => _TaskCreationDialogState();
}

class _TaskCreationDialogState extends State<TaskCreationDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagsController = TextEditingController();
  
  TaskType _selectedType = TaskType.text;
  TaskPriority _selectedPriority = TaskPriority.medium;
  DateTime? _alarmTime;
  bool _hasAlarm = false;
  String? _newImagePath;
  List<String> _tags = [];
  bool _isListening = false;
  bool _showAdvancedOptions = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.editingTask != null;
    
    if (widget.editingTask != null) {
      // Initialize with existing task data
      final task = widget.editingTask!;
      _titleController.text = task.title;
      _descriptionController.text = task.description;
      _selectedType = task.type;
      _selectedPriority = _getPriorityFromString(task.priority);
      _alarmTime = task.alarmTime;
      _hasAlarm = task.hasAlarm;
      _tags = List.from(task.tags);
      _newImagePath = task.filePath;
    } else {
      // Initialize for new task
      if (widget.initialType != null) {
        _selectedType = widget.initialType!;
      }
      if (widget.initialFilePath != null) {
        _newImagePath = widget.initialFilePath!;
      }
    }
  }

  TaskPriority _getPriorityFromString(String priority) {
    switch (priority) {
      case 'low':
        return TaskPriority.low;
      case 'medium':
        return TaskPriority.medium;
      case 'high':
        return TaskPriority.high;
      case 'urgent':
        return TaskPriority.urgent;
      default:
        return TaskPriority.medium;
    }
  }

  String _getPriorityString(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return 'low';
      case TaskPriority.medium:
        return 'medium';
      case TaskPriority.high:
        return 'high';
      case TaskPriority.urgent:
        return 'urgent';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final savedPath = await MediaHandler.savePhoto(File(image.path));
      setState(() {
        _newImagePath = savedPath;
        _selectedType = TaskType.photo;
      });
    }
  }

  Future<void> _startVoiceToText(TextEditingController controller) async {
    setState(() {
      _isListening = true;
    });

    // Simulate voice-to-text functionality
    await Future.delayed(const Duration(seconds: 2));
    
    setState(() {
      controller.text = "Voice input placeholder - tap to speak";
      _isListening = false;
    });

    // Show a dialog to inform user about voice-to-text
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF0F3460),
          title: const Text(
            'Voice-to-Text',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Voice-to-text functionality will be implemented in the next update. For now, please type your text manually.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'OK',
                style: TextStyle(color: Colors.yellow),
              ),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _selectAlarmTime() async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.yellow,
              onPrimary: Colors.black,
              surface: Color(0xFF0F3460),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (time != null) {
      final now = DateTime.now();
      final selectedDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );
      
      setState(() {
        _alarmTime = selectedDateTime;
        _hasAlarm = true;
      });
    }
  }

  void _addTag() {
    final tag = _tagsController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagsController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  Future<void> _saveTask() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a title'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      SnapTask task;
      
      if (_isEditing && widget.editingTask != null) {
        // Update existing task
        task = widget.editingTask!;
        task.title = _titleController.text.trim();
        task.description = _descriptionController.text.trim();
        task.type = _selectedType;
        task.priority = _getPriorityString(_selectedPriority);
        task.alarmTime = _alarmTime;
        task.hasAlarm = _hasAlarm;
        task.tags = _tags;
        if (_newImagePath != null && _newImagePath != task.filePath) {
          task.filePath = _newImagePath!;
        }
        
        await StorageService.instance.updateTask(task);
      } else {
        // Create new task
        task = SnapTask(
          id: const Uuid().v4(),
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          type: _selectedType,
          priority: _getPriorityString(_selectedPriority),
          filePath: _newImagePath ?? '',
          timestamp: DateTime.now(),
          isCompleted: false,
          alarmTime: _alarmTime,
          hasAlarm: _hasAlarm,
          tags: _tags,
          startTime: null,
          endTime: null,
          timeTaken: Duration.zero,
        );
        
        await StorageService.instance.saveTask(task);
      }

      if (mounted) {
        Navigator.of(context).pop(task);
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

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsService>(
      builder: (context, settings, child) {
        return Dialog(
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
                        _isEditing ? Icons.edit : Icons.add_task,
                        color: Colors.yellow,
                        size: settings.getScaledIconSize(24),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _isEditing ? 'Edit Task' : 'Create New Task',
                        style: settings.getTextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
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
                        // Title
                        Text(
                          'Title *',
                          style: settings.getTextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _titleController,
                          style: settings.getTextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Enter task title',
                            hintStyle: settings.getTextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                            filled: true,
                            fillColor: const Color(0xFF16213E),
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
                        
                        const SizedBox(height: 16),
                        
                        // Description
                        Text(
                          'Description',
                          style: settings.getTextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _descriptionController,
                          maxLines: 3,
                          style: settings.getTextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Enter task description',
                            hintStyle: settings.getTextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                            filled: true,
                            fillColor: const Color(0xFF16213E),
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
                        
                        const SizedBox(height: 16),
                        
                        // Type Selection
                        Text(
                          'Type',
                          style: settings.getTextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTypeButton(TaskType.photo, Icons.photo, 'Photo'),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildTypeButton(TaskType.video, Icons.videocam, 'Video'),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildTypeButton(TaskType.audio, Icons.mic, 'Audio'),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildTypeButton(TaskType.text, Icons.text_fields, 'Text'),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Priority Selection
                        Text(
                          'Priority',
                          style: settings.getTextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _buildPriorityButton(TaskPriority.low, 'Low', Colors.green),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildPriorityButton(TaskPriority.medium, 'Medium', Colors.blue),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildPriorityButton(TaskPriority.high, 'High', Colors.orange),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildPriorityButton(TaskPriority.urgent, 'Urgent', Colors.red),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Add Photo Button
                        if (_selectedType == TaskType.photo || _newImagePath != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Photo',
                                style: settings.getTextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: _pickImage,
                                      icon: Icon(
                                        Icons.photo_library,
                                        color: Colors.white,
                                        size: settings.getScaledIconSize(20),
                                      ),
                                      label: Text(
                                        _newImagePath != null ? 'Change Photo' : 'Add Photo',
                                        style: settings.getTextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.purple,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (_newImagePath != null) ...[
                                    const SizedBox(width: 8),
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _newImagePath = null;
                                        });
                                      },
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                        size: settings.getScaledIconSize(20),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              if (_newImagePath != null) ...[
                                const SizedBox(height: 8),
                                Container(
                                  height: 100,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.black,
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(
                                      File(_newImagePath!),
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Center(
                                          child: Icon(Icons.error, color: Colors.red),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        
                        const SizedBox(height: 16),
                        
                        // Advanced Options Toggle
                        Row(
                          children: [
                            Text(
                              'Advanced Options',
                              style: settings.getTextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            Switch(
                              value: _showAdvancedOptions,
                              onChanged: (value) {
                                setState(() {
                                  _showAdvancedOptions = value;
                                });
                              },
                              activeColor: Colors.yellow,
                            ),
                          ],
                        ),
                        
                        if (_showAdvancedOptions) ...[
                          const SizedBox(height: 16),
                          
                          // Alarm Settings
                          Text(
                            'Alarm',
                            style: settings.getTextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _selectAlarmTime,
                                  icon: Icon(
                                    Icons.alarm,
                                    color: Colors.white,
                                    size: settings.getScaledIconSize(20),
                                  ),
                                  label: Text(
                                    _alarmTime != null
                                        ? '${_alarmTime!.hour.toString().padLeft(2, '0')}:${_alarmTime!.minute.toString().padLeft(2, '0')}'
                                        : 'Set Alarm',
                                    style: settings.getTextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _alarmTime != null ? Colors.yellow : Colors.purple,
                                    foregroundColor: _alarmTime != null ? Colors.black : Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                              if (_alarmTime != null) ...[
                                const SizedBox(width: 8),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _alarmTime = null;
                                      _hasAlarm = false;
                                    });
                                  },
                                  icon: Icon(
                                    Icons.clear,
                                    color: Colors.red,
                                    size: settings.getScaledIconSize(20),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Tags
                          Text(
                            'Tags',
                            style: settings.getTextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _tagsController,
                                  style: settings.getTextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Add tag',
                                    hintStyle: settings.getTextStyle(
                                      fontSize: 16,
                                      color: Colors.white70,
                                    ),
                                    filled: true,
                                    fillColor: const Color(0xFF16213E),
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
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: _addTag,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.yellow,
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  'Add',
                                  style: settings.getTextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          if (_tags.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: _tags.map((tag) {
                                return Chip(
                                  label: Text(
                                    tag,
                                    style: settings.getTextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                    ),
                                  ),
                                  backgroundColor: Colors.yellow.withOpacity(0.2),
                                  deleteIcon: Icon(
                                    Icons.close,
                                    color: Colors.yellow,
                                    size: settings.getScaledIconSize(16),
                                  ),
                                  onDeleted: () => _removeTag(tag),
                                );
                              }).toList(),
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                ),
                
                // Action Buttons
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: settings.getTextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _saveTask,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.yellow,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            _isEditing ? 'Update' : 'Create',
                            style: settings.getTextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTypeButton(TaskType type, IconData icon, String label) {
    final isSelected = _selectedType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.yellow : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.yellow : Colors.purple,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.black : Colors.white,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityButton(TaskPriority priority, String label, Color color) {
    final isSelected = _selectedPriority == priority;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPriority = priority;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : Colors.purple,
            width: 1,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? Colors.white : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
} 