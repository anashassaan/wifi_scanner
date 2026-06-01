import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wifi_scanner/l10n/app_localizations.dart';
import '../../../../core/providers/global_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final hive = ref.watch(hiveServiceProvider);
    final l10n = AppLocalizations.of(context) ?? AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        children: [
          _buildSection(context, l10n.appearance),
          SwitchListTile(
            title: Text(l10n.darkMode),
            subtitle: Text(l10n.enableDarkMode),
            value: themeMode == ThemeMode.dark,
            onChanged: (value) async {
              await hive.settingsBox.put('dark_mode', value);
              ref.read(themeModeProvider.notifier).state =
                  value ? ThemeMode.dark : ThemeMode.light;
            },
            secondary: const Icon(Icons.dark_mode_outlined),
          ),
          _buildSection(context, l10n.dataManagement),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: Text(l10n.clearHistory,
                style: const TextStyle(color: Colors.red)),
            subtitle: Text(l10n.clearHistoryDescription),
            onTap: () => _showClearDialog(context, ref, l10n),
          ),
          _buildSection(context, l10n.aboutApp),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.version),
            trailing: const Text('1.0.0'),
          ),
          ListTile(
            leading: const Icon(Icons.policy_outlined),
            title: Text(l10n.privacyPolicy),
            onTap: () => context.push('/settings/privacy'),
          ),
          ListTile(
            leading: const Icon(Icons.code_outlined),
            title: Text(l10n.licenses),
            onTap: () => showLicensePage(context: context),
          ),
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              l10n.madeWithLove,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[500],
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Future<void> _showClearDialog(
      BuildContext context, WidgetRef ref, AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.clearHistoryConfirm),
        content: Text(l10n.clearHistoryWarning),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel)),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child:
                Text(l10n.clearAll, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(hiveServiceProvider).clearHistory();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.historyCleared)),
        );
      }
    }
  }
}
