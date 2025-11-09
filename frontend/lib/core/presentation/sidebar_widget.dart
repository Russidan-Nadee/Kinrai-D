import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'sidebar_header.dart';
import 'sidebar_nav_item.dart';

class SidebarWidget extends StatelessWidget {
  final bool isMobile;
  final bool isCollapsed;
  final int currentIndex;
  final VoidCallback onToggle;
  final Function(int) onNavigate;
  final bool isAdmin;

  const SidebarWidget({
    super.key,
    required this.isMobile,
    required this.isCollapsed,
    required this.currentIndex,
    required this.onToggle,
    required this.onNavigate,
    this.isAdmin = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final sidebarWidth = isMobile
        ? (isCollapsed ? 50.0 : 240.0)
        : (isCollapsed ? 80.0 : 240.0);

    return Container(
      width: sidebarWidth,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFF8A50), Color(0xFFFF6B35)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          SidebarHeader(
            isMobile: isMobile,
            isCollapsed: isCollapsed,
            onToggle: onToggle,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: [
                const SizedBox(height: 16),
                SidebarNavItem(
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home,
                  label: l10n.main,
                  index: 0,
                  currentIndex: currentIndex,
                  isCollapsed: isMobile || isCollapsed,
                  onTap: () => onNavigate(0),
                ),
                SidebarNavItem(
                  icon: Icons.person_outline,
                  selectedIcon: Icons.person,
                  label: l10n.profile,
                  index: 1,
                  currentIndex: currentIndex,
                  isCollapsed: isMobile || isCollapsed,
                  onTap: () => onNavigate(1),
                ),
                if (isAdmin)
                  SidebarNavItem(
                    icon: Icons.admin_panel_settings_outlined,
                    selectedIcon: Icons.admin_panel_settings,
                    label: l10n.admin,
                    index: 2,
                    currentIndex: currentIndex,
                    isCollapsed: isMobile || isCollapsed,
                    onTap: () => onNavigate(2),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
