import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wifi_scan/wifi_scan.dart';
import '../widgets/prominent_disclosure.dart';

class WifiScanScreen extends StatefulWidget {
  const WifiScanScreen({super.key});

  @override
  State<WifiScanScreen> createState() => _WifiScanScreenState();
}

class _WifiScanScreenState extends State<WifiScanScreen> {
  List<WiFiAccessPoint> accessPoints = [];
  bool isScanning = false;
  StreamSubscription<List<WiFiAccessPoint>>? subscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkPermissions());
  }

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }

  Future<void> _checkPermissions() async {
    final status = await Permission.location.status;
    if (status.isPermanentlyDenied) {
      _showErrorState();
      return;
    }

    if (!status.isGranted) {
      if (!mounted) return;
      _showDisclosure();
    } else {
      _startScan();
    }
  }

  void _showDisclosure() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ProminentDisclosure(
        onAccept: () async {
          Navigator.pop(context);
          final result = await Permission.location.request();
          if (result.isGranted) {
            _startScan();
          } else {
            _showErrorState();
          }
        },
        onDeny: () {
          Navigator.pop(context);
          _showErrorState();
        },
      ),
    );
  }

  Future<void> _startScan() async {
    setState(() => isScanning = true);
    final canScan = await WiFiScan.instance.canStartScan();
    if (canScan == CanStartScan.yes) {
      await WiFiScan.instance.startScan();
      subscription =
          WiFiScan.instance.onScannedResultsAvailable.listen((results) {
        if (!mounted) return;
        setState(() {
          accessPoints = results;
          isScanning = false;
        });
      });
    } else {
      if (!mounted) return;
      setState(() => isScanning = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cannot start scan: $canScan')),
      );
    }
  }

  void _showErrorState() {
    setState(() {
      isScanning = false;
      accessPoints = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).viewPadding;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Networks'),
        actions: [
          if (isScanning)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _startScan,
            ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.only(
            bottom: padding.bottom), // Android 15 Nav bar padding
        child: accessPoints.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.location_off_outlined,
                        size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      'Location permission required to scan WiFi.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: openAppSettings,
                      child: const Text('Open System Settings'),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                itemCount: accessPoints.length,
                itemBuilder: (context, index) {
                  final ap = accessPoints[index];
                  return ListTile(
                    leading: Icon(_getWifiIcon(ap.level)),
                    title: Text(ap.ssid.isEmpty ? '[Hidden Network]' : ap.ssid),
                    subtitle:
                        Text('CH: ${ap.frequency} MHz | ${ap.capabilities}'),
                    trailing: Text('${ap.level} dBm'),
                  );
                },
              ),
      ),
    );
  }

  IconData _getWifiIcon(int level) {
    if (level > -50) return Icons.wifi_sharp;
    if (level > -70) return Icons.network_wifi_3_bar;
    return Icons.network_wifi_1_bar;
  }
}
