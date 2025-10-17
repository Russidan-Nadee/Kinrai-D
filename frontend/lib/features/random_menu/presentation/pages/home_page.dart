import 'package:flutter/material.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../widgets/random_menu_widget.dart';

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
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
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
              child: RandomMenuWidget(),
            ),
          ],
        ),
      ),
    );
  }
}
