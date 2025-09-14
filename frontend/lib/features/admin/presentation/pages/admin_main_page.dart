import 'package:flutter/material.dart';
import '../../domain/entities/admin_menu_entity.dart';
import '../../domain/usecases/get_admin_menus.dart';
import '../../data/datasources/admin_remote_data_source.dart';
import '../../data/repositories/admin_repository_impl.dart';
import '../../../../core/api/api_client.dart';
import '../widgets/admin_tab_bar.dart';
import 'tabs/menus_tab.dart';
import 'tabs/categories_tab.dart';

class AdminMainPage extends StatefulWidget {
  const AdminMainPage({super.key});

  @override
  State<AdminMainPage> createState() => _AdminMainPageState();
}

class _AdminMainPageState extends State<AdminMainPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late GetAdminMenus _getAdminMenus;
  AdminMenuListEntity? _adminInfo;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeDependencies();
    _loadAdminInfo();
  }

  void _initializeDependencies() {
    final apiClient = ApiClient();
    apiClient.initialize();
    final remoteDataSource = AdminRemoteDataSourceImpl(apiClient: apiClient);
    final repository = AdminRepositoryImpl(remoteDataSource: remoteDataSource);
    _getAdminMenus = GetAdminMenus(repository: repository);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAdminInfo() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final info = await _getAdminMenus();
      
      setState(() {
        _adminInfo = info;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading data: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAdminInfo,
          ),
        ],
        bottom: AdminTabBar(controller: _tabController),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          MenusTab(
            adminInfo: _adminInfo,
            isLoading: _isLoading,
            errorMessage: _errorMessage,
            onRefresh: _loadAdminInfo,
          ),
          const CategoriesTab(),
        ],
      ),
    );
  }
}