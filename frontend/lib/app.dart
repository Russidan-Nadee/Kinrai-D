import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/admin/presentation/pages/admin_main_page.dart';
import 'features/random_menu/presentation/pages/home_page.dart';
import 'features/profile/presentation/pages/profile_page.dart';
import 'core/presentation/sidebar_widget.dart';
import 'core/presentation/bottom_navigation_widget.dart';
import 'core/providers/auth_provider.dart';

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
  bool _isCollapsed = false; // Default to expanded on desktop
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

  void _navigateToPage(int index, {required bool isAdmin}) {
    // Prevent navigation to Admin page if not admin
    if (index == 2 && !isAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Access denied. Admin privileges required.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // Show loading indicator while fetching user data
    if (authProvider.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final isAdmin = authProvider.user?.isAdmin ?? false;

    // If current page is Admin but user is not admin, redirect to home
    if (_currentIndex == 2 && !isAdmin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _currentIndex = 0;
        });
      });
    }

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
                  onNavigate: (index) => _navigateToPage(index, isAdmin: isAdmin),
                  isAdmin: isAdmin,
                ),
              // Content area
              Expanded(child: _pages[_currentIndex]),
            ],
          ),
          // Mobile: Bottom Navigation Bar
          bottomNavigationBar: isMobile
              ? BottomNavigationWidget(
                  currentIndex: _currentIndex,
                  onNavigate: (index) => _navigateToPage(index, isAdmin: isAdmin),
                  isAdmin: isAdmin,
                )
              : null,
        );
      },
    );
  }
}
