import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wifi_scanner/l10n/app_localizations.dart';
import '../../../../core/providers/global_providers.dart';
import '../../domain/models/wifi_model.dart';
import '../widgets/scanner_overlay.dart';

class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen> {
  late MobileScannerController controller;
  bool isScanned = false;
  bool _isTorchOn = false;

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (isScanned) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        final qrContent = barcode.rawValue!;
        _processQrContent(qrContent);
        break;
      }
    }
  }

  void _processQrContent(String qrContent) async {
    if (qrContent.startsWith('WIFI:')) {
      setState(() => isScanned = true);

      final wifiModel = WifiModel.fromQrString(qrContent);
      await ref.read(hiveServiceProvider).saveWifiScan(wifiModel);

      if (mounted) {
        context.replace('/result', extra: wifiModel);
      }
    } else {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.invalidQrCode)),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      try {
        final BarcodeCapture? capture =
            await controller.analyzeImage(image.path);
        if (capture != null && capture.barcodes.isNotEmpty) {
          final qrContent = capture.barcodes.first.rawValue;
          if (qrContent != null) {
            _processQrContent(qrContent);
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No QR Code found')),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(l10n.scanQrCode),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _isTorchOn = !_isTorchOn;
                controller.toggleTorch();
              });
            },
            icon: Icon(
              _isTorchOn ? Icons.flash_on : Icons.flash_off,
            ),
            tooltip: 'Flashlight',
          ),
          IconButton(
            onPressed: _pickImage,
            icon: const Icon(Icons.image_outlined),
            tooltip: 'Gallery',
          ),
        ],
      ),
      body: Semantics(
        label: 'QR Scanner Viewport',
        hint: 'Align a WiFi QR code inside the frame to scan',
        child: Stack(
          children: [
            MobileScanner(
              controller: controller,
              onDetect: _onDetect,
              errorBuilder: (context, error, child) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          l10n.cameraPermissionDenied,
                          style: const TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const ScannerOverlay(),
          ],
        ),
      ),
    );
  }
}
