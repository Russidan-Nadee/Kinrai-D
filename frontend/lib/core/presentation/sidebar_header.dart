import 'package:flutter/material.dart';

class SidebarHeader extends StatelessWidget {
  final bool isMobile;
  final bool isCollapsed;
  final VoidCallback onToggle;

  const SidebarHeader({
    super.key,
    required this.isMobile,
    required this.isCollapsed,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Column(
        children: [
          Row(
            children: [
              if (!isMobile && !isCollapsed) ...[
                Expanded(
                  child: Text(
                    'Kinrai D',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
              if (!isMobile) ...[
                IconButton(
                  onPressed: onToggle,
                  icon: Icon(
                    isCollapsed ? Icons.menu : Icons.chevron_left,
                    color: Colors.white,
                  ),
                  splashRadius: 20,
                ),
              ] else ...[
                // Mobile: แสดงแค่ปุ่มเดียว เมื่อพับเก็บ หรือแสดงเต็ม เมื่อขยาย
                if (isCollapsed) ...[
                  // แสดงแค่ปุ่มเดียว
                  Center(
                    child: IconButton(
                      onPressed: onToggle,
                      icon: const Icon(
                        Icons.menu,
                        color: Colors.white,
                        size: 20,
                      ),
                      splashRadius: 16,
                    ),
                  ),
                ] else ...[
                  // แสดงเต็ม
                  Expanded(
                    child: Text(
                      'Kinrai D',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                    ),
                  ),
                  IconButton(
                    onPressed: onToggle,
                    icon: const Icon(
                      Icons.chevron_left,
                      color: Colors.white,
                      size: 20,
                    ),
                    splashRadius: 16,
                  ),
                ],
              ],
            ],
          ),
        ],
      ),
    );
  }
}
