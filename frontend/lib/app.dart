import 'package:flutter/material.dart';
import 'features/admin/presentation/pages/admin_main_page.dart';
import 'features/random_menu/presentation/pages/home_page.dart';
import 'features/profile/presentation/pages/profile_page.dart';
import 'core/presentation/sidebar_widget.dart';
import 'core/presentation/bottom_navigation_widget.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainNavigation();
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  bool _isCollapsed = true;
  late AnimationController _animationController;

  final List<Widget> _pages = [
    const HomePage(title: 'Main'),
    const ProfilePage(title: 'Profile'),
    const AdminMainPage(),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleSidebar() {
    setState(() {
      _isCollapsed = !_isCollapsed;
    });

    if (_isCollapsed) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _navigateToPage(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        return Scaffold(
          body: Row(
            children: [
              // Desktop: Show sidebar
              if (!isMobile)
                SidebarWidget(
                  isMobile: isMobile,
                  isCollapsed: _isCollapsed,
                  currentIndex: _currentIndex,
                  onToggle: _toggleSidebar,
                  onNavigate: _navigateToPage,
                ),
              // Content area
              Expanded(child: _pages[_currentIndex]),
            ],
          ),
          // Mobile: Bottom Navigation Bar
          bottomNavigationBar: isMobile
              ? BottomNavigationWidget(
                  currentIndex: _currentIndex,
                  onNavigate: _navigateToPage,
                )
              : null,
        );
      },
    );
  }
}
