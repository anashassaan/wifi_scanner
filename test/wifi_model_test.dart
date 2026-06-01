import 'package:flutter_test/flutter_test.dart';
import 'package:wifi_scanner/features/scanner/domain/models/wifi_model.dart';

void main() {
  group('WifiModel Tests', () {
    test('Parsed WPA WiFi QR correctly', () {
      const qr = 'WIFI:T:WPA;S:MyWifi;P:password123;;';
      final model = WifiModel.fromQrString(qr);

      expect(model.ssid, 'MyWifi');
      expect(model.password, 'password123');
      expect(model.securityType, WifiSecurityType.wpa);
    });

    test('Parsed WEP WiFi QR correctly', () {
      const qr = 'WIFI:T:WEP;S:OfficeWifi;P:12345678;;';
      final model = WifiModel.fromQrString(qr);

      expect(model.ssid, 'OfficeWifi');
      expect(model.password, '12345678');
      expect(model.securityType, WifiSecurityType.wep);
    });

    test('Parsed Open WiFi QR correctly', () {
      const qr = 'WIFI:T:nopass;S:GuestWifi;;';
      final model = WifiModel.fromQrString(qr);

      expect(model.ssid, 'GuestWifi');
      expect(model.password, '');
      expect(model.securityType, WifiSecurityType.nopass);
    });

    test('Handle malformed QR gracefully', () {
      const qr = 'INVALID_DATA';
      final model = WifiModel.fromQrString(qr);

      expect(model.ssid, '');
      expect(model.password, '');
      expect(model.securityType, WifiSecurityType.unknown);
    });
  });
}
