import 'package:flutter/material.dart';
import '../core/themes/app_theme.dart';

// =============================================
// PAGE HEADER
// =============================================
class PageHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const PageHeader({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        subtitle,
        style: TextStyle(color: Colors.white.withOpacity(0.45), fontSize: 13),
      ),
    ],
  );
}

// =============================================
// PROFILE CARD
// =============================================
class ProfileCard extends StatelessWidget {
  final String name;
  final String headline;
  final String email;
  final String? pictureUrl;
  final String badge;
  final IconData badgeIcon;

  const ProfileCard({
    super.key,
    required this.name,
    required this.headline,
    required this.email,
    required this.pictureUrl,
    required this.badge,
    required this.badgeIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.primaryCyan.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryCyan.withOpacity(0.06),
            blurRadius: 20,
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 38,
            backgroundColor: AppColors.primaryCyan.withOpacity(0.2),
            backgroundImage: pictureUrl != null
                ? NetworkImage(pictureUrl!)
                : null,
            child: pictureUrl == null
                ? const Icon(
                    Icons.person,
                    color: AppColors.primaryCyan,
                    size: 32,
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  headline,
                  style: const TextStyle(
                    color: AppColors.primaryCyan,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  email,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                RoleBadge(label: badge, icon: badgeIcon),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================
// ROLE BADGE
// =============================================
class RoleBadge extends StatelessWidget {
  final String label;
  final IconData icon;

  const RoleBadge({super.key, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: AppColors.primaryCyan.withOpacity(0.12),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.primaryCyan.withOpacity(0.3)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.primaryCyan, size: 12),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.primaryCyan,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

// =============================================
// COMING SOON BANNER
// =============================================
class ComingSoonBanner extends StatelessWidget {
  const ComingSoonBanner({super.key});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.primaryCyan.withOpacity(0.06),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.primaryCyan.withOpacity(0.15)),
    ),
    child: Row(
      children: [
        const Icon(
          Icons.rocket_launch_outlined,
          color: AppColors.primaryCyan,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'More features coming soon',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Job listings, AI match & more.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.45),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// =============================================
// ADD BUTTON
// =============================================
class AddButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const AddButton({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.primaryCyan.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primaryCyan.withOpacity(0.28)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.add_circle_outline,
            color: AppColors.primaryCyan,
            size: 19,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.primaryCyan,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    ),
  );
}

// =============================================
// EMPTY STATE
// =============================================
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const EmptyState({super.key, required this.icon, required this.message});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 50),
    child: Column(
      children: [
        Icon(icon, color: Colors.white10, size: 52),
        const SizedBox(height: 14),
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withOpacity(0.28),
            fontSize: 13,
            height: 1.7,
          ),
        ),
      ],
    ),
  );
}

// =============================================
// ACTION BUTTONS
// =============================================
class ActionButtons extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ActionButtons({
    super.key,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) => Column(
    children: [
      IconButton(
        icon: const Icon(
          Icons.edit_outlined,
          color: AppColors.primaryCyan,
          size: 17,
        ),
        onPressed: onEdit,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      ),
      const SizedBox(height: 6),
      IconButton(
        icon: Icon(
          Icons.delete_outline,
          color: Colors.redAccent.withOpacity(0.65),
          size: 17,
        ),
        onPressed: onDelete,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      ),
    ],
  );
}

// =============================================
// EDUCATION CARD
// =============================================
class EducationCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const EducationCard({
    super.key,
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isCurrent = item['is_current'] == 1 || item['is_current'] == true;
    final endLabel = isCurrent ? 'Present' : '${item['end_year'] ?? ''}';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryCyan.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.school_outlined,
              color: AppColors.primaryCyan,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['institution'] ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${item['degree']} · ${item['field_of_study']}',
                  style: const TextStyle(
                    color: AppColors.primaryCyan,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${item['start_year']} – $endLabel',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          ActionButtons(onEdit: onEdit, onDelete: onDelete),
        ],
      ),
    );
  }
}

// =============================================
// WORK CARD
// =============================================
class WorkCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const WorkCard({
    super.key,
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isCurrent = item['is_current'] == 1 || item['is_current'] == true;
    final endLabel = isCurrent ? 'Present' : (item['end_date'] ?? '');
    final empType = (item['employment_type'] as String? ?? '')
        .replaceAll('_', ' ')
        .toUpperCase();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryCyan.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.business_center_outlined,
              color: AppColors.primaryCyan,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['job_title'] ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item['company'] ?? '',
                  style: const TextStyle(
                    color: AppColors.primaryCyan,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(
                      '${item['start_date']} – $endLabel',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 11,
                      ),
                    ),
                    if (empType.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          empType,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          ActionButtons(onEdit: onEdit, onDelete: onDelete),
        ],
      ),
    );
  }
}

// =============================================
// STAT BOX
// =============================================
class StatBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const StatBox({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primaryCyan, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 11,
            ),
          ),
        ],
      ),
    ),
  );
}

// =============================================
// INFO TILE
// =============================================
class InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const InfoTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 9),
    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.04),
      borderRadius: BorderRadius.circular(13),
      border: Border.all(color: Colors.white.withOpacity(0.07)),
    ),
    child: Row(
      children: [
        Icon(icon, color: AppColors.primaryCyan, size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.38),
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// =============================================
// SECTION TITLE
// =============================================
class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) => Text(
    title,
    style: const TextStyle(
      color: AppColors.primaryCyan,
      fontSize: 12,
      fontWeight: FontWeight.bold,
      letterSpacing: 1,
    ),
  );
}

// =============================================
// BOTTOM NAV ITEM
// =============================================
class NavItem {
  final IconData outlinedIcon;
  final IconData filledIcon;
  final String label;

  const NavItem(this.outlinedIcon, this.filledIcon, this.label);
}

// =============================================
// BOTTOM NAVIGATION BAR
// =============================================
class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<NavItem> items;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.08))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final item = items[i];
              final sel = i == currentIndex;
              return GestureDetector(
                onTap: () => onTap(i),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: sel
                        ? AppColors.primaryCyan.withOpacity(0.12)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        sel ? item.filledIcon : item.outlinedIcon,
                        color: sel ? AppColors.primaryCyan : Colors.white38,
                        size: 22,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: TextStyle(
                          color: sel ? AppColors.primaryCyan : Colors.white38,
                          fontSize: 10,
                          fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// =============================================
// EXPERTISE CHIP
// =============================================
class ExpertiseChip extends StatelessWidget {
  final String label;

  const ExpertiseChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) => Container(
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

// =============================================
// JOB CARD
// =============================================
class JobCard extends StatelessWidget {
  final Map<String, dynamic> job;
  final VoidCallback? onApply;

  const JobCard({super.key, required this.job, this.onApply});

  @override
  Widget build(BuildContext context) {
    final title = job['title'] ?? 'Position';
    final company = job['company'] ?? 'Company';
    final location = job['location'] ?? 'Location';
    final employmentType = (job['employment_type'] ?? 'full_time')
        .toString()
        .replaceAll('_', ' ')
        .toUpperCase();
    final salaryMin = job['salary_min'];
    final salaryMax = job['salary_max'];
    final currency = job['salary_currency'] ?? 'USD';

    String salaryText = 'Salary not specified';
    if (salaryMin != null || salaryMax != null) {
      if (salaryMin != null && salaryMax != null) {
        salaryText =
            '$currency ${salaryMin.toString()} - ${salaryMax.toString()}';
      } else if (salaryMin != null) {
        salaryText = '$currency ${salaryMin.toString()}+';
      } else if (salaryMax != null) {
        salaryText = 'Up to $currency ${salaryMax.toString()}';
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryCyan.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.business_center,
                  color: AppColors.primaryCyan,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      company,
                      style: const TextStyle(
                        color: AppColors.primaryCyan,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryCyan.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  employmentType,
                  style: const TextStyle(
                    color: AppColors.primaryCyan,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                color: Colors.white.withOpacity(0.4),
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                location,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.attach_money,
                color: Colors.white.withOpacity(0.4),
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                salaryText,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          if (onApply != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onApply,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryCyan,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Apply Now',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
