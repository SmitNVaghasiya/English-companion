import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../providers/notification_provider.dart';
import '../screens/progress_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/notification_settings_screen.dart';
import 'notification_badge.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Drawer(
      backgroundColor: isDark ? AppColors.lightBlack : Colors.white,
      elevation: 0,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkGray : theme.primaryColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: isDark ? Colors.grey[800] : Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: isDark ? Colors.white : theme.primaryColor,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'User Name',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'user@example.com',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.home_rounded,
            title: 'Home',
            isSelected: ModalRoute.of(context)?.settings.name == '/home',
            onTap: () => _navigateAndClose(context, '/home'),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.chat_rounded,
            title: 'Chat',
            isSelected: ModalRoute.of(context)?.settings.name == '/chat',
            onTap: () => _navigateAndClose(context, '/chat'),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.school_rounded,
            title: 'Learn',
            onTap: () => _navigateAndClose(context, '/learn'),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.mic_rounded, // Changed from assignment_rounded to mic_rounded
            title: 'Voice Practice',
            isSelected: ModalRoute.of(context)?.settings.name == '/practice',
            onTap: () => _navigateAndClose(context, '/practice'),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.trending_up_rounded,
            title: 'Progress Tracker',
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProgressScreen(),
                  ),
                ),
          ),
          Consumer<NotificationProvider>(
            builder:
                (context, provider, _) => _buildDrawerItem(
                  context,
                  icon: Icons.notifications_rounded,
                  title: 'Notifications',
                  badge: provider.unreadCount,
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationsScreen(),
                        ),
                      ),
                ),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.person_rounded,
            title: 'Profile',
            onTap: () => _navigateAndClose(context, '/profile'),
          ),
          const Divider(height: 1, thickness: 1),
          _buildDrawerItem(
            context,
            icon: Icons.settings_rounded,
            title: 'Settings',
            onTap: () => _navigateAndClose(context, '/settings'),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.notifications_active_rounded,
            title: 'Notification Settings',
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationSettingsScreen(),
                  ),
                ),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.help_outline_rounded,
            title: 'Help & Feedback',
            onTap: () => _navigateAndClose(context, '/help'),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    bool isSelected = false,
    required VoidCallback onTap,
    int? badge,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final leadingIcon = Icon(
      icon,
      color:
          isSelected
              ? AppColors.primaryColor
              : isDark
              ? Colors.white70
              : Colors.grey[700],
      size: 24,
    );

    return ListTile(
      leading:
          badge != null && badge > 0
              ? NotificationBadge(count: badge, child: leadingIcon)
              : leadingIcon,
      title: Text(
        title,
        style: TextStyle(
          color:
              isSelected
                  ? AppColors.primaryColor
                  : isDark
                  ? Colors.white
                  : Colors.black87,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          fontSize: 15,
        ),
      ),
      selected: isSelected,
      selectedTileColor:
          isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[100],
      onTap: onTap,
    );
  }

  void _navigateAndClose(BuildContext context, String route) async {
    try {
      // Close the drawer first
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      
      // Add a small delay to ensure the drawer is closed before navigation
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Check if we're already on the target route to prevent duplicate navigation
      if (!context.mounted) return;
      
      final currentRoute = ModalRoute.of(context)?.settings.name;
      if (currentRoute != route) {
        // Use pushReplacementNamed to avoid stacking duplicate routes
        await Navigator.pushReplacementNamed(context, route);
      }
      
      debugPrint('Navigated to $route');
    } catch (e) {
      debugPrint('Error navigating to $route: $e');
      // Show error to user if navigation fails
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not navigate to $route: ${e.toString()}'),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
