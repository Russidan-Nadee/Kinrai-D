import 'package:flutter/material.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../widgets/random_menu_widget.dart';

class HomePage extends StatefulWidget {
  final String title;

  const HomePage({super.key, required this.title});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Preload emoji flags to prevent delay in Profile page
    _preloadEmojis();
  }

  void _preloadEmojis() {
    // Force render emojis off-screen to preload font
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final textPainter = TextPainter(
          text: const TextSpan(
            text: '🇹🇭🇺🇸🇯🇵🇨🇳',
            style: TextStyle(fontSize: 24),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.dispose();
      }
    });
  }

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
