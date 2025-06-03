import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/notification_model.dart';
import '../providers/notification_provider.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _isLoading = false;
  late NotificationSettings _settings;

  @override
  void initState() {
    super.initState();
    _settings =
        Provider.of<NotificationProvider>(context, listen: false).settings;
  }

  Future<void> _saveSettings() async {
    setState(() {
      _isLoading = true;
    });

    final notificationProvider = Provider.of<NotificationProvider>(
      context,
      listen: false,
    );
    final success = await notificationProvider.updateSettings(_settings);

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Notification settings saved'
                : 'Failed to save notification settings',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
        elevation: 0,
        actions: [
          _isLoading
              ? const Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
              : IconButton(
                icon: const Icon(Icons.save),
                onPressed: _saveSettings,
                tooltip: 'Save settings',
              ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Master switch for all notifications
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notifications',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Enable Notifications'),
                    subtitle: const Text('Turn on/off all notifications'),
                    value: _settings.enableNotifications,
                    onChanged: (value) {
                      setState(() {
                        _settings = _settings.copyWith(
                          enableNotifications: value,
                        );
                      });
                    },
                    secondary: Icon(
                      Icons.notifications,
                      color:
                          _settings.enableNotifications
                              ? theme.colorScheme.primary
                              : isDark
                              ? Colors.white54
                              : Colors.black45,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Notification types
          if (_settings.enableNotifications) ...[
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notification Types',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Daily Reminders'),
                      subtitle: const Text('Remind you to practice daily'),
                      value: _settings.enableDailyReminders,
                      onChanged: (value) {
                        setState(() {
                          _settings = _settings.copyWith(
                            enableDailyReminders: value,
                          );
                        });
                      },
                      secondary: Icon(
                        Icons.alarm,
                        color:
                            _settings.enableDailyReminders
                                ? Colors.blue
                                : isDark
                                ? Colors.white54
                                : Colors.black45,
                      ),
                    ),
                    const Divider(),
                    SwitchListTile(
                      title: const Text('Achievements'),
                      subtitle: const Text('Notify when you earn badges'),
                      value: _settings.enableAchievementNotifications,
                      onChanged: (value) {
                        setState(() {
                          _settings = _settings.copyWith(
                            enableAchievementNotifications: value,
                          );
                        });
                      },
                      secondary: Icon(
                        Icons.emoji_events,
                        color:
                            _settings.enableAchievementNotifications
                                ? Colors.amber
                                : isDark
                                ? Colors.white54
                                : Colors.black45,
                      ),
                    ),
                    const Divider(),
                    SwitchListTile(
                      title: const Text('Progress Updates'),
                      subtitle: const Text(
                        'Notify about your learning progress',
                      ),
                      value: _settings.enableProgressUpdates,
                      onChanged: (value) {
                        setState(() {
                          _settings = _settings.copyWith(
                            enableProgressUpdates: value,
                          );
                        });
                      },
                      secondary: Icon(
                        Icons.trending_up,
                        color:
                            _settings.enableProgressUpdates
                                ? Colors.green
                                : isDark
                                ? Colors.white54
                                : Colors.black45,
                      ),
                    ),
                    const Divider(),
                    SwitchListTile(
                      title: const Text('Learning Tips'),
                      subtitle: const Text(
                        'Helpful tips to improve your English',
                      ),
                      value: _settings.enableTips,
                      onChanged: (value) {
                        setState(() {
                          _settings = _settings.copyWith(enableTips: value);
                        });
                      },
                      secondary: Icon(
                        Icons.lightbulb_outline,
                        color:
                            _settings.enableTips
                                ? Colors.purple
                                : isDark
                                ? Colors.white54
                                : Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Daily reminder time
            if (_settings.enableDailyReminders) ...[
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Daily Reminder Time',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        title: const Text('Reminder Time'),
                        subtitle: Text(
                          _settings.dailyReminderTime != null
                              ? _formatTimeOfDay(_settings.dailyReminderTime!)
                              : 'Not set',
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        leading: Icon(
                          Icons.access_time,
                          color: theme.colorScheme.primary,
                        ),
                        onTap: () async {
                          final TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime:
                                _settings.dailyReminderTime ??
                                const TimeOfDay(hour: 20, minute: 0),
                          );

                          if (pickedTime != null) {
                            setState(() {
                              _settings = _settings.copyWith(
                                dailyReminderTime: pickedTime,
                              );
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],

          const SizedBox(height: 24),

          // Information about notifications
          Card(
            elevation: 1,
            color: isDark ? Colors.grey[850] : Colors.blue[50],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: isDark ? Colors.blue[300] : Colors.blue[700],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'About Notifications',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.blue[300] : Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Daily reminders help you build a consistent learning habit. '
                    'Research shows that regular practice is key to language learning success.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You can always view your notifications in the app, even if you disable push notifications.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  String _formatTimeOfDay(TimeOfDay timeOfDay) {
    final hour = timeOfDay.hourOfPeriod == 0 ? 12 : timeOfDay.hourOfPeriod;
    final minute = timeOfDay.minute.toString().padLeft(2, '0');
    final period = timeOfDay.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}
