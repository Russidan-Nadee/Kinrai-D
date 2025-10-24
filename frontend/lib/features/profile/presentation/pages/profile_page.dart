import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/language_provider.dart';
import '../../../../core/di/injection.dart';
import '../../../protein_preferences/domain/usecases/get_available_protein_types.dart';
import '../../../protein_preferences/domain/usecases/get_user_protein_preferences.dart';
import '../../../protein_preferences/domain/usecases/set_protein_preference.dart';
import '../../../protein_preferences/domain/usecases/remove_protein_preference.dart';
import '../../../protein_preferences/data/repositories/protein_preference_repository_impl.dart';
import '../../../protein_preferences/data/datasources/protein_preference_remote_data_source.dart';
import '../../../dislikes/domain/usecases/get_user_dislikes.dart';
import '../../../dislikes/domain/usecases/remove_dislike.dart';
import '../../../dislikes/domain/usecases/remove_bulk_dislikes.dart';
import '../providers/profile_provider.dart';
import '../widgets/profile_header.dart';
import '../widgets/language_section.dart';
import '../widgets/protein_preferences_section.dart';
import '../widgets/dislike_list_section.dart';
import '../widgets/sign_out_section.dart';

class ProfilePage extends StatefulWidget {
  final String title;

  const ProfilePage({super.key, required this.title});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with AutomaticKeepAliveClientMixin {
  late ProfileProvider _profileProvider;
  bool _isInitialized = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeProvider();
  }

  void _initializeProvider() {
    // Initialize protein preferences dependencies
    final proteinDataSource = ProteinPreferenceRemoteDataSourceImpl();
    final proteinRepository = ProteinPreferenceRepositoryImpl(remoteDataSource: proteinDataSource);

    // Create ProfileProvider with all dependencies
    _profileProvider = ProfileProvider(
      getAvailableProteinTypes: GetAvailableProteinTypes(proteinRepository),
      getUserProteinPreferences: GetUserProteinPreferences(proteinRepository),
      setProteinPreference: SetProteinPreference(proteinRepository),
      removeProteinPreference: RemoveProteinPreference(proteinRepository),
      getUserDislikes: getIt.get<GetUserDislikes>(),
      removeDislike: getIt.get<RemoveDislike>(),
      removeBulkDislikes: getIt.get<RemoveBulkDislikes>(),
    );

    // Load data on first mount only
    if (!_isInitialized) {
      _isInitialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
        _profileProvider.loadAllProfileData(language: languageProvider.currentLanguageCode);
      });
    }
  }

  @override
  void dispose() {
    _profileProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final authProvider = Provider.of<AuthProvider>(context);
    final l10n = AppLocalizations.of(context);

    return ChangeNotifierProvider<ProfileProvider>.value(
      value: _profileProvider,
      child: Scaffold(
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
              ProfileHeader(email: authProvider.user?.email),

              const SizedBox(height: 32),

              // Language Selection
              const LanguageSection(),

              const SizedBox(height: 32),

              // Protein Preferences Section
              const ProteinPreferencesSection(),

              const SizedBox(height: 32),

              // Dislike List Section
              const DislikeListSection(),

              const SizedBox(height: 32),

              // Sign Out Section
              const SignOutSection(),
            ],
          ),
        ),
      ),
    );
  }
}
