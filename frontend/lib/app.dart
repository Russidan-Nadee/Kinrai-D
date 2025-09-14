import 'package:flutter/material.dart';
import 'features/admin/presentation/pages/admin_main_page.dart';

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

class _MainNavigationState extends State<MainNavigation> with TickerProviderStateMixin {
  int _currentIndex = 0;
  bool _isCollapsed = false;
  late AnimationController _animationController;
  late Animation<double> _widthAnimation;

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
    _widthAnimation = Tween<double>(
      begin: 240,
      end: 80,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // ใช้ Left Sidebar หมดเลย แต่ responsive
        return Scaffold(
          body: Row(
            children: [
              _buildLeftSidebar(context, constraints),
              Expanded(
                child: _pages[_currentIndex],
              ),
            ],
          ),
        );
      },
    );
  }


  Widget _buildLeftSidebar(BuildContext context, BoxConstraints constraints) {
    final isMobile = constraints.maxWidth < 600;
    final sidebarWidth = isMobile ? 80.0 : (_isCollapsed ? 80.0 : 240.0);
    return Container(
      width: sidebarWidth,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFF8A50),
            Color(0xFFFF6B35),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSidebarHeader(context, isMobile),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: [
                const SizedBox(height: 16),
                _buildNavItem(
                  context: context,
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home,
                  label: 'Main',
                  index: 0,
                  isCompact: isMobile || _isCollapsed,
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.person_outline,
                  selectedIcon: Icons.person,
                  label: 'Profile',
                  index: 1,
                  isCompact: isMobile || _isCollapsed,
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.admin_panel_settings_outlined,
                  selectedIcon: Icons.admin_panel_settings,
                  label: 'Admin',
                  index: 2,
                  isCompact: isMobile || _isCollapsed,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarHeader(BuildContext context, bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Column(
        children: [
          Row(
            children: [
              if (!isMobile && !_isCollapsed) ...[
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
                  onPressed: _toggleSidebar,
                  icon: Icon(
                    _isCollapsed ? Icons.menu : Icons.chevron_left,
                    color: Colors.white,
                  ),
                  splashRadius: 20,
                ),
              ] else ...[
                // Mobile: แสดงแค่ logo
                Expanded(
                  child: Icon(
                    Icons.restaurant_menu,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
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

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required int index,
    required bool isCompact,
  }) {
    final isSelected = _currentIndex == index;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            setState(() {
              _currentIndex = index;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(
              horizontal: _isCollapsed ? 16 : 20,
              vertical: 16,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: isSelected
                ? Colors.white.withOpacity(0.9)
                : Colors.white.withOpacity(0.1),
              border: isSelected
                ? Border.all(color: Colors.white, width: 1)
                : null,
              boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
            ),
            child: isCompact
                ? Center(
                    child: Icon(
                      isSelected ? selectedIcon : icon,
                      color: isSelected ? const Color(0xFFFF6B35) : Colors.white,
                      size: 24,
                    ),
                  )
                : Row(
                    children: [
                      Icon(
                        isSelected ? selectedIcon : icon,
                        color: isSelected ? const Color(0xFFFF6B35) : Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          label,
                          style: TextStyle(
                            color: isSelected ? const Color(0xFFFF6B35) : Colors.white,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final String title;

  const HomePage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to Kinrai D!',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Text(
              '$title Page',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  final String title;

  const ProfilePage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
      ),
      body: const Center(
        child: Text(
          'Profile page is coming soon!',
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}