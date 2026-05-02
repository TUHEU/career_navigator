import 'package:flutter/material.dart';
import '../../../core/themes/app_theme.dart';

class RoleBadge extends StatelessWidget {
  final String role;
  final bool isDark;

  const RoleBadge({super.key, required this.role, this.isDark = true});

  @override
  Widget build(BuildContext context) {
    final icon = _getIcon();
    final label = _getLabel();
    final color = _getColor();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIcon() {
    switch (role.toLowerCase()) {
      case 'mentor':
        return Icons.school_outlined;
      case 'admin':
        return Icons.admin_panel_settings;
      default:
        return Icons.search_rounded;
    }
  }

  String _getLabel() {
    switch (role.toLowerCase()) {
      case 'mentor':
        return 'Mentor';
      case 'admin':
        return 'Admin';
      default:
        return 'Job Seeker';
    }
  }

  Color _getColor() {
    switch (role.toLowerCase()) {
      case 'mentor':
        return Colors.greenAccent;
      case 'admin':
        return Colors.orangeAccent;
      default:
        return AppColors.primaryCyan;
    }
  }
}

class ExpertiseChip extends StatelessWidget {
  final String label;

  const ExpertiseChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryCyan.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryCyan.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.primaryCyan,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  final String status;
  final bool isDark;

  const StatusBadge({super.key, required this.status, this.isDark = true});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status.toLowerCase()) {
      case 'accepted':
        color = Colors.green;
        break;
      case 'pending':
        color = Colors.orange;
        break;
      case 'rejected':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
