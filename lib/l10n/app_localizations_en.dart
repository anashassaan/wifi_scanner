// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'WiFi QR Password Scanner';

  @override
  String get scanQrCode => 'Scan QR Code';

  @override
  String get scanDescription => 'Point your camera at a WiFi QR code';

  @override
  String get scanHistory => 'Scan History';

  @override
  String get historyDescription => 'View and manage your saved credentials';

  @override
  String get recentScan => 'Recent Scan';

  @override
  String get noScansYet => 'No scans yet';

  @override
  String get scanNow => 'Scan Now';

  @override
  String get history => 'History';

  @override
  String get settings => 'Settings';

  @override
  String get invalidQrCode => 'Invalid WiFi QR Code';

  @override
  String get connectToNetwork => 'Connect to Network';

  @override
  String get backToHome => 'Back to Home';

  @override
  String get copyPassword => 'Copy Password';

  @override
  String get networkInRange => 'Network in Range';

  @override
  String get networkNotDetected => 'Network Not Detected';

  @override
  String get themeSettings => 'Theme Settings';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get security => 'Security';

  @override
  String get exportHistory => 'Export History';

  @override
  String get deleteHistory => 'Delete All History';

  @override
  String get cameraPermissionDenied => 'Camera permission was denied';

  @override
  String get grantPermission => 'Grant Permission';

  @override
  String get appearance => 'Appearance';

  @override
  String get enableDarkMode => 'Enable dark theme across the app';

  @override
  String get dataManagement => 'Data Management';

  @override
  String get clearHistory => 'Clear History';

  @override
  String get clearHistoryDescription =>
      'Permanently delete all scanned WiFi records';

  @override
  String get clearHistoryConfirm => 'Clear All History?';

  @override
  String get clearHistoryWarning =>
      'This action cannot be undone. All saved WiFi credentials will be removed.';

  @override
  String get cancel => 'Cancel';

  @override
  String get clearAll => 'Clear All';

  @override
  String get historyCleared => 'History cleared successfully';

  @override
  String get aboutApp => 'About App';

  @override
  String get version => 'Version';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get licenses => 'Licenses';

  @override
  String get madeWithLove => 'Made with ❤️ by Anas Hassaan';
}
