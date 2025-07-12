import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/settings_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final List<String> _languages = [
    'English',
    'Spanish',
    'French',
    'German',
    'Chinese',
    'Japanese',
    'Korean',
    'Arabic',
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsService>(
      builder: (context, settings, child) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            title: Text(
              'Settings',
              style: settings.getTextStyle(
                fontSize: 20,
                color: Colors.yellow[400],
                fontWeight: FontWeight.bold,
              ),
            ),
            iconTheme: IconThemeData(
              color: Colors.white,
              size: settings.getScaledIconSize(24),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSection(
                  title: 'Language',
                  icon: Icons.language,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButton<String>(
                      value: settings.language,
                      dropdownColor: Colors.grey[900],
                      style: settings.getTextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                      underline: Container(),
                      isExpanded: true,
                      items: _languages.map((language) {
                        return DropdownMenuItem(
                          value: language,
                          child: Text(language),
                        );
                      }).toList(),
                      onChanged: (value) {
                        settings.updateLanguage(value!);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildSection(
                  title: 'Text Size',
                  icon: Icons.text_fields,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Small',
                              style: settings.getTextStyle(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Large',
                              style: settings.getTextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Slider(
                          value: settings.textSize,
                          min: 0.8,
                          max: 1.4,
                          divisions: 6,
                          activeColor: Colors.yellow[400],
                          inactiveColor: Colors.grey[700],
                          onChanged: (value) {
                            settings.updateTextSize(value);
                          },
                        ),
                        Text(
                          'Preview Text',
                          style: settings.getTextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildSection(
                  title: 'Icon Size',
                  icon: Icons.touch_app,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(
                              Icons.home,
                              color: Colors.white,
                              size: settings.getScaledIconSize(20),
                            ),
                            Icon(
                              Icons.home,
                              color: Colors.white,
                              size: settings.getScaledIconSize(32),
                            ),
                          ],
                        ),
                        Slider(
                          value: settings.iconSize,
                          min: 0.8,
                          max: 1.4,
                          divisions: 6,
                          activeColor: Colors.yellow[400],
                          inactiveColor: Colors.grey[700],
                          onChanged: (value) {
                            settings.updateIconSize(value);
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.camera_alt,
                              color: Colors.yellow[400],
                              size: settings.getScaledIconSize(24),
                            ),
                            const SizedBox(width: 16),
                            Icon(
                              Icons.dashboard,
                              color: Colors.yellow[400],
                              size: settings.getScaledIconSize(24),
                            ),
                            const SizedBox(width: 16),
                            Icon(
                              Icons.history,
                              color: Colors.yellow[400],
                              size: settings.getScaledIconSize(24),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildSection(
                  title: 'App Information',
                  icon: Icons.info,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(
                            Icons.apps,
                            color: Colors.yellow[400],
                            size: settings.getScaledIconSize(20),
                          ),
                          title: Text(
                            'SnapTask',
                            style: settings.getTextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            'Version 1.0.0',
                            style: settings.getTextStyle(
                              fontSize: 14,
                              color: Colors.grey[400],
                            ),
                          ),
                        ),
                        ListTile(
                          leading: Icon(
                            Icons.storage,
                            color: Colors.yellow[400],
                            size: settings.getScaledIconSize(20),
                          ),
                          title: Text(
                            'Storage',
                            style: settings.getTextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          subtitle: Text(
                            'All data stored locally',
                            style: settings.getTextStyle(
                              fontSize: 14,
                              color: Colors.grey[400],
                            ),
                          ),
                        ),
                        ListTile(
                          leading: Icon(
                            Icons.wifi_off,
                            color: Colors.yellow[400],
                            size: settings.getScaledIconSize(20),
                          ),
                          title: Text(
                            'Offline Mode',
                            style: settings.getTextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          subtitle: Text(
                            'Works without internet',
                            style: settings.getTextStyle(
                              fontSize: 14,
                              color: Colors.grey[400],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Consumer<SettingsService>(
      builder: (context, settings, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: Colors.yellow[400],
                  size: settings.getScaledIconSize(24),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: settings.getTextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        );
      },
    );
  }
} 