import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/providers/auth_provider.dart';
import '../widgets/profile_header.dart';
import '../widgets/language_section.dart';
import '../widgets/protein_preferences_section.dart';
import '../widgets/dislike_list_section.dart';
import '../widgets/sign_out_section.dart';

class ProfilePage extends StatelessWidget {
  final String title;

  const ProfilePage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
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
    );
  }
}
