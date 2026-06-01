import 'package:hive/hive.dart';

@HiveType(typeId: 0)
enum WifiSecurityType {
  @HiveField(0)
  wpa,
  @HiveField(1)
  wep,
  @HiveField(2)
  nopass,
  @HiveField(3)
  unknown,
}

@HiveType(typeId: 1)
class WifiModel extends HiveObject {
  @HiveField(0)
  final String ssid;

  @HiveField(1)
  final String password;

  @HiveField(2)
  final WifiSecurityType securityType;

  @HiveField(3)
  final DateTime scanDate;

  WifiModel({
    required this.ssid,
    required this.password,
    required this.securityType,
    required this.scanDate,
  });

  factory WifiModel.fromQrString(String qrString) {
    // Expected format: WIFI:T:WPA;S:MyWifi;P:password123;;
    final cleanString = qrString.replaceAll('WIFI:', '');
    final parts = cleanString.split(';');

    String ssid = '';
    String password = '';
    WifiSecurityType securityType = WifiSecurityType.unknown;

    for (var part in parts) {
      if (part.startsWith('S:')) {
        ssid = part.substring(2);
      } else if (part.startsWith('P:')) {
        password = part.substring(2);
      } else if (part.startsWith('T:')) {
        final type = part.substring(2).toUpperCase();
        if (type == 'WPA' || type == 'WPA2') {
          securityType = WifiSecurityType.wpa;
        } else if (type == 'WEP') {
          securityType = WifiSecurityType.wep;
        } else if (type == 'NOPASS') {
          securityType = WifiSecurityType.nopass;
        }
      }
    }

    return WifiModel(
      ssid: ssid,
      password: password,
      securityType: securityType,
      scanDate: DateTime.now(),
    );
  }

  String get securityTypeString {
    switch (securityType) {
      case WifiSecurityType.wpa:
        return 'WPA/WPA2';
      case WifiSecurityType.wep:
        return 'WEP';
      case WifiSecurityType.nopass:
        return 'Open';
      case WifiSecurityType.unknown:
        return 'Unknown';
    }
  }
}

class WifiSecurityTypeAdapter extends TypeAdapter<WifiSecurityType> {
  @override
  final int typeId = 0;

  @override
  WifiSecurityType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return WifiSecurityType.wpa;
      case 1:
        return WifiSecurityType.wep;
      case 2:
        return WifiSecurityType.nopass;
      case 3:
        return WifiSecurityType.unknown;
      default:
        return WifiSecurityType.unknown;
    }
  }

  @override
  void write(BinaryWriter writer, WifiSecurityType obj) {
    switch (obj) {
      case WifiSecurityType.wpa:
        writer.writeByte(0);
        break;
      case WifiSecurityType.wep:
        writer.writeByte(1);
        break;
      case WifiSecurityType.nopass:
        writer.writeByte(2);
        break;
      case WifiSecurityType.unknown:
        writer.writeByte(3);
        break;
    }
  }
}

class WifiModelAdapter extends TypeAdapter<WifiModel> {
  @override
  final int typeId = 1;

  @override
  WifiModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WifiModel(
      ssid: fields[0] as String,
      password: fields[1] as String,
      securityType: fields[2] as WifiSecurityType,
      scanDate: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, WifiModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.ssid)
      ..writeByte(1)
      ..write(obj.password)
      ..writeByte(2)
      ..write(obj.securityType)
      ..writeByte(3)
      ..write(obj.scanDate);
  }
}
