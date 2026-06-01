import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:wifi_scan/wifi_scan.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../domain/models/wifi_model.dart';

class ResultScreen extends StatefulWidget {
  final WifiModel wifiModel;

  const ResultScreen({super.key, required this.wifiModel});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _isConnecting = false;
  bool _isScanning = false;
  bool? _isInRange;

  @override
  void initState() {
    super.initState();
    _checkIfInRange();
  }

  Future<void> _checkIfInRange() async {
    setState(() {
      _isScanning = true;
    });

    try {
      // Permission check for scanning
      if (await Permission.location.request().isGranted) {
        final canScan = await WiFiScan.instance.canStartScan();
        if (canScan == CanStartScan.yes) {
          await WiFiScan.instance.startScan();
          final list = await WiFiScan.instance.getScannedResults();
          bool found = false;
          for (var net in list) {
            if (net.ssid == widget.wifiModel.ssid) {
              found = true;
              break;
            }
          }
          if (mounted) {
            setState(() {
              _isInRange = found;
              _isScanning = false;
            });
          }
        } else {
          // If we can't scan (e.g. WiFi disabled), fallback to checking connection status or just stop
          if (mounted) {
            setState(() {
              _isScanning = false;
            });
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _isScanning = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error scanning: $e');
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
    }
  }

  Future<void> _connectToWifi() async {
    setState(() => _isConnecting = true);

    try {
      // Check if WiFi is enabled
      final isEnabled = await WiFiForIoTPlugin.isEnabled();
      if (!isEnabled) {
        await WiFiForIoTPlugin.setEnabled(true, shouldOpenSettings: true);
      }

      // Map security type to wifi_iot NetworkSecurity
      NetworkSecurity security = NetworkSecurity.NONE;
      switch (widget.wifiModel.securityType) {
        case WifiSecurityType.wpa:
          security = NetworkSecurity.WPA;
          break;
        case WifiSecurityType.wep:
          security = NetworkSecurity.WEP;
          break;
        case WifiSecurityType.nopass:
          security = NetworkSecurity.NONE;
          break;
        case WifiSecurityType.unknown:
          security = NetworkSecurity.NONE;
          break;
      }

      final success = await WiFiForIoTPlugin.connect(
        widget.wifiModel.ssid,
        password: widget.wifiModel.password,
        security: security,
        joinOnce: false,
        withInternet: true,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Connecting to ${widget.wifiModel.ssid}...'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Failed to connect. Please check signal or password.',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isConnecting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Result'),
        actions: [
          IconButton(
            onPressed: () {
              Share.share(
                'WiFi Name: ${widget.wifiModel.ssid}\n'
                'Password: ${widget.wifiModel.password}\n'
                'Security: ${widget.wifiModel.securityTypeString}',
              );
            },
            icon: const Icon(Icons.share_outlined),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primaryContainer.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.wifi,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  if (_isScanning)
                    const SizedBox(
                      width: 90,
                      height: 90,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
            ),
            if (_isInRange != null) ...[
              const SizedBox(height: 12),
              Chip(
                avatar: Icon(
                  _isInRange! ? Icons.check_circle : Icons.warning,
                  color: _isInRange! ? Colors.green : Colors.orange,
                  size: 18,
                ),
                label: Text(
                  _isInRange! ? 'Network in Range' : 'Network Not Detected',
                  style: TextStyle(
                    color: _isInRange! ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: (_isInRange! ? Colors.green : Colors.orange)
                    .withValues(alpha: 0.1),
                side: BorderSide.none,
              ),
            ],
            const SizedBox(height: 24),
            _buildResultCard(
              context,
              label: 'WiFi Name (SSID)',
              value: widget.wifiModel.ssid,
              icon: Icons.ssid_chart,
            ),
            const SizedBox(height: 16),
            _buildResultCard(
              context,
              label: 'Password',
              value: widget.wifiModel.password,
              icon: Icons.password,
              isPassword: true,
            ),
            const SizedBox(height: 16),
            _buildResultCard(
              context,
              label: 'Security Type',
              value: widget.wifiModel.securityTypeString,
              icon: Icons.security,
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isConnecting ? null : _connectToWifi,
                icon: _isConnecting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.wifi),
                label: Flexible(
                  child: Text(
                    _isConnecting ? 'Connecting...' : 'Connect to Network',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Clipboard.setData(
                    ClipboardData(text: widget.wifiModel.password),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password copied to clipboard'),
                    ),
                  );
                },
                icon: const Icon(Icons.copy),
                label: const Flexible(
                  child: Text(
                    'Copy Password',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.home),
                label: const Flexible(
                  child: Text(
                    'Back to Home',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(
                      context,
                    ).textTheme.labelMedium?.copyWith(color: Colors.grey[600]),
                  ),
                  Text(
                    value.isEmpty ? 'N/A' : value,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
            if (value.isNotEmpty)
              IconButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: value));
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('$label copied')));
                },
                icon: const Icon(Icons.content_copy, size: 20),
              ),
          ],
        ),
      ),
    );
  }
}
