import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:wifi_scanner/l10n/app_localizations.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context) ?? AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.privacyPolicy),
      ),
      body: FutureBuilder<String>(
        future: rootBundle.loadString('PRIVACY_POLICY.md'),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Markdown(
              data: snapshot.data!,
              selectable: true,
            );
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading Privacy Policy'));
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
