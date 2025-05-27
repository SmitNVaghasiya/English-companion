import 'package:flutter/material.dart';
import 'package:english_companion/core/constants/app_colors.dart';

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
                Text(
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
            icon: Icons.chat_rounded,
            title: 'Chat',
            isSelected: true,
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
            icon: Icons.assignment_rounded,
            title: 'Practice',
            onTap: () => _navigateAndClose(context, '/practice'),
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
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListTile(
      leading: Icon(
        icon,
        color:
            isSelected
                ? AppColors.primaryColor
                : isDark
                ? Colors.white70
                : Colors.grey[700],
        size: 24,
      ),
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
          isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
      onTap: onTap,
    );
  }

  void _navigateAndClose(BuildContext context, String route) {
    try {
      Navigator.pop(context);
      // Placeholder for navigation logic
      debugPrint('Navigating to $route');
    } catch (e) {
      debugPrint('Error navigating to $route: $e');
    }
  }
}
