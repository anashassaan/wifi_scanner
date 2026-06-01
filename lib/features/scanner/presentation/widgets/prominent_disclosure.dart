import 'package:flutter/material.dart';

class ProminentDisclosure extends StatelessWidget {
  final VoidCallback onAccept;
  final VoidCallback onDeny;

  const ProminentDisclosure({
    super.key,
    required this.onAccept,
    required this.onDeny,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      icon: const Icon(Icons.location_on, size: 48, color: Colors.blue),
      title: const Text(
        'Location Transparency Disclosure',
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'WiFi Scanner requires your precise location data even when the app is in the foreground to discover, parse, and measure the signal strength of ambient wireless network hardware around you.',
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 12),
            Text(
              'This data is processed locally on-device and is never shared or stored.',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.primary,
              ),
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: onDeny,
          child: const Text('Deny', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: onAccept,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('Accept & Continue'),
        ),
      ],
    );
  }
}
