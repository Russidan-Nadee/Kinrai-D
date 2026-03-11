import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/language_provider.dart';
import '../../../../core/di/injection.dart';
import '../../../dislikes/presentation/providers/dislike_provider.dart';
import '../../../protein_preferences/presentation/providers/protein_preference_provider.dart';
import '../widgets/profile_header.dart';
import '../widgets/language_section.dart';
import '../../../protein_preferences/presentation/widgets/protein_preferences_section.dart';
import '../../../dislikes/presentation/widgets/dislike_list_section.dart';
import '../widgets/sign_out_section.dart';

class ProfilePage extends StatefulWidget {
  final String title;

  const ProfilePage({super.key, required this.title});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isFirstLoad = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_isFirstLoad) {
      _isFirstLoad = false;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        if (authProvider.isGuest) return;

        final dislikeProvider = getIt<DislikeProvider>();
        final proteinProvider = getIt<ProteinPreferenceProvider>();
        final languageProvider = Provider.of<LanguageProvider>(context, listen: false);

        dislikeProvider.loadDislikes(language: languageProvider.currentLanguageCode);
        proteinProvider.loadProteinPreferences(language: languageProvider.currentLanguageCode);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final l10n = AppLocalizations.of(context);

    if (authProvider.isGuest) {
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
              // Guest Avatar + Name
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.grey[200],
                      child: Icon(Icons.person_outline, size: 48, color: Colors.grey[500]),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.guestUser,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Benefits
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3EE),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFF6B35).withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.createAccountFor,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 10),
                    for (final benefit in [
                      l10n.benefitSaveDislikes,
                      l10n.benefitSelectProtein,
                      l10n.benefitPersonalizedMenus,
                    ])
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle,
                                size: 16, color: Color(0xFFFF6B35)),
                            const SizedBox(width: 8),
                            Text(benefit, style: TextStyle(color: Colors.grey[700])),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Sign Up / Login buttons
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => authProvider.exitGuestMode(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B35),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(l10n.signUpOrSignIn,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),

              const SizedBox(height: 32),
              Divider(color: Colors.grey[300]),
              const SizedBox(height: 16),

              // Language Section still accessible
              const LanguageSection(),
            ],
          ),
        ),
      );
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<DislikeProvider>.value(
          value: getIt<DislikeProvider>(),
        ),
        ChangeNotifierProvider<ProteinPreferenceProvider>.value(
          value: getIt<ProteinPreferenceProvider>(),
        ),
      ],
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
