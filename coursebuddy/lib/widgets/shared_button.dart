import 'package:flutter/material.dart';
import 'package:coursebuddy/assets/theme/app_theme.dart';

class SharedButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const SharedButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        // Use the primaryColor from your theme
        backgroundColor: AppTheme.primaryColor,
        // Use a light color for the icon and text
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 6,
      ),
      icon: Icon(icon, size: 22),
      label: Text(
        label,
        style: TextStyle(
          fontSize: 16,
          // Use textColor from your theme if needed, or keep white for contrast
          color: AppTheme.textColor,
        ),
      ),
      onPressed: onPressed,
    );
  }
}
