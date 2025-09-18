import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/admin/presentation/pages/admin_main_page.dart';
import 'features/random_menu/presentation/widgets/random_menu_widget.dart';
import 'core/providers/language_provider.dart';
import 'core/providers/auth_provider.dart';
import 'core/l10n/app_localizations.dart';

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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        return Scaffold(
          endDrawer: isMobile && _isCollapsed
              ? Drawer(child: _buildMobileDrawer(context))
              : null,
          body: Stack(
            children: [
              Row(
                children: [
                  if (!(constraints.maxWidth < 600 && _isCollapsed))
                    _buildLeftSidebar(context, constraints),
                  Expanded(child: _pages[_currentIndex]),
                ],
              ),
              if (isMobile && _isCollapsed)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 8,
                  right: 16,
                  child: Builder(
                    builder: (BuildContext context) {
                      return FloatingActionButton.small(
                        onPressed: () {
                          Scaffold.of(context).openEndDrawer();
                        },
                        backgroundColor: const Color(0xFFFF6B35),
                        child: const Icon(Icons.menu, color: Colors.white),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLeftSidebar(BuildContext context, BoxConstraints constraints) {
    final isMobile = constraints.maxWidth < 600;
    final sidebarWidth = isMobile
        ? (_isCollapsed ? 50.0 : 240.0)
        : (_isCollapsed ? 80.0 : 240.0);
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
      decoration: const BoxDecoration(color: Colors.transparent),
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
                // Mobile: แสดงแค่ปุ่มเดียว เมื่อพับเก็บ หรือแสดงเต็ม เมื่อขยาย
                if (_isCollapsed) ...[
                  // แสดงแค่ปุ่มเดียว
                  Center(
                    child: IconButton(
                      onPressed: _toggleSidebar,
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
                    onPressed: _toggleSidebar,
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
                  ? Colors.white.withValues(alpha: 0.9)
                  : Colors.white.withValues(alpha: 0.1),
              border: isSelected
                  ? Border.all(color: Colors.white, width: 1)
                  : null,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
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
                      color: isSelected
                          ? const Color(0xFFFF6B35)
                          : Colors.white,
                      size: 24,
                    ),
                  )
                : Row(
                    children: [
                      Icon(
                        isSelected ? selectedIcon : icon,
                        color: isSelected
                            ? const Color(0xFFFF6B35)
                            : Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          _getNavLabel(context, index),
                          style: TextStyle(
                            color: isSelected
                                ? const Color(0xFFFF6B35)
                                : Colors.white,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
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

  String _getNavLabel(BuildContext context, int index) {
    final l10n = AppLocalizations.of(context);
    switch (index) {
      case 0:
        return l10n.main;
      case 1:
        return l10n.profile;
      case 2:
        return l10n.admin;
      default:
        return '';
    }
  }

  Widget _buildMobileDrawer(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFF8A50), Color(0xFFFF6B35)],
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              left: 16,
              right: 16,
              bottom: 16,
            ),
            child: Row(
              children: [
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
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: [
                const SizedBox(height: 16),
                _buildMobileNavItem(
                  context: context,
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home,
                  label: 'Main',
                  index: 0,
                ),
                _buildMobileNavItem(
                  context: context,
                  icon: Icons.person_outline,
                  selectedIcon: Icons.person,
                  label: 'Profile',
                  index: 1,
                ),
                _buildMobileNavItem(
                  context: context,
                  icon: Icons.admin_panel_settings_outlined,
                  selectedIcon: Icons.admin_panel_settings,
                  label: 'Admin',
                  index: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileNavItem({
    required BuildContext context,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required int index,
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
            Navigator.of(context).pop(); // ปิด drawer
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: isSelected
                  ? Colors.white.withValues(alpha: 0.9)
                  : Colors.white.withValues(alpha: 0.1),
              border: isSelected
                  ? Border.all(color: Colors.white, width: 1)
                  : null,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  isSelected ? selectedIcon : icon,
                  color: isSelected ? const Color(0xFFFF6B35) : Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    _getNavLabel(context, index),
                    style: TextStyle(
                      color: isSelected
                          ? const Color(0xFFFF6B35)
                          : Colors.white,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
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
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.main),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                l10n.welcome,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: const Color(0xFFFF6B35),
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Random Menu Feature
              const Expanded(
                child: SingleChildScrollView(child: RandomMenuWidget()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfilePage extends StatefulWidget {
  final String title;

  const ProfilePage({super.key, required this.title});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final List<Map<String, String>> _languages = [
    {'code': 'th', 'name': 'ไทย', 'flag': '🇹🇭'},
    {'code': 'en', 'name': 'English', 'flag': '🇺🇸'},
    {'code': 'ja', 'name': '日本語', 'flag': '🇯🇵'},
    {'code': 'zh', 'name': '中文', 'flag': '🇨🇳'},
  ];

  @override
  Widget build(BuildContext context) {
    Provider.of<LanguageProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profile),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.orange[50]!, Colors.orange[100]!],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFFF6B35).withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B35),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          authProvider.user?.email ?? l10n.user,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFF6B35),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.manageSettings,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Language Selection
            Text(
              l10n.selectLanguage,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: _languages.map((language) {
                  return _buildLanguageOption(
                    language['code']!,
                    language['name']!,
                    language['flag']!,
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 32),

            // Sign Out Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.logout, color: Colors.red[700], size: 20),
                      const SizedBox(width: 8),
                      Text(
                        l10n.signOut,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.red[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final authProvider = Provider.of<AuthProvider>(
                          context,
                          listen: false,
                        );
                        await authProvider.signOut();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[600],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(l10n.signOut),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String code, String name, String flag) {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    final l10n = AppLocalizations.of(context);
    final isSelected = languageProvider.currentLanguageCode == code;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () async {
            await languageProvider.changeLanguage(code);

            // Show confirmation
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.languageChanged(name)),
                  duration: const Duration(seconds: 2),
                  backgroundColor: const Color(0xFFFF6B35),
                ),
              );
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFFFF6B35).withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: isSelected
                  ? Border.all(color: const Color(0xFFFF6B35), width: 1)
                  : null,
            ),
            child: Row(
              children: [
                Text(flag, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? const Color(0xFFFF6B35)
                        : Colors.grey[700],
                  ),
                ),
                const Spacer(),
                if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    color: Color(0xFFFF6B35),
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
