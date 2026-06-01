import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wifi_scanner/l10n/app_localizations.dart';
import '../../../../core/providers/global_providers.dart';
import '../widgets/stats_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final hive = ref.watch(hiveServiceProvider);
    final history = hive.getHistory();
    final totalScans = history.length;
    final lastScan = history.isNotEmpty ? history.first : null;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: Text(l10n.appTitle),
            actions: [
              IconButton(
                onPressed: () => context.push('/settings'),
                icon: const Icon(Icons.settings_outlined),
                tooltip: l10n.settings,
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                StatsCard(
                  totalScans: totalScans,
                  lastSsid: lastScan?.ssid ?? l10n.noScansYet,
                ),
                const SizedBox(height: 24),
                _buildActionCard(
                  context,
                  title: l10n.scanQrCode,
                  subtitle: l10n.scanDescription,
                  icon: Icons.qr_code_scanner,
                  color: Theme.of(context).colorScheme.primaryContainer,
                  onTap: () => context.push('/scanner'),
                ),
                const SizedBox(height: 16),
                _buildActionCard(
                  context,
                  title: l10n.scanHistory,
                  subtitle: l10n.historyDescription,
                  icon: Icons.history,
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  onTap: () => context.push('/history'),
                ),
                if (history.isNotEmpty) ...[
                  const SizedBox(height: 32),
                  Text(
                    l10n.recentScan,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.wifi),
                      ),
                      title: Text(
                        lastScan!.ssid,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(lastScan.securityTypeString),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/result', extra: lastScan),
                    ),
                  ),
                ],
              ]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/scanner'),
        label: Text(l10n.scanNow),
        icon: const Icon(Icons.camera_alt),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon,
                  size: 32,
                  color: Theme.of(context).colorScheme.onPrimaryContainer),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onPrimaryContainer
                              .withValues(alpha: 0.7),
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
}
