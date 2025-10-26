import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/language_provider.dart';
import '../../../../core/di/injection.dart';
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
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    // Load data only on first app launch (singleton provider persists data)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileProvider = getIt<ProfileProvider>();
      final languageProvider = Provider.of<LanguageProvider>(context, listen: false);

      // Only load if data is empty (first time)
      if (profileProvider.availableProteinTypes.isEmpty &&
          profileProvider.dislikes.isEmpty) {
        profileProvider.loadAllProfileData(language: languageProvider.currentLanguageCode);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final authProvider = Provider.of<AuthProvider>(context);
    final l10n = AppLocalizations.of(context);

    return ChangeNotifierProvider<ProfileProvider>.value(
      value: getIt<ProfileProvider>(), // Use singleton provider from DI
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
