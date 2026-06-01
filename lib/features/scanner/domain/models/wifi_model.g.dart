// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

import 'package:hive/hive.dart';
import 'wifi_model.dart';

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

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WifiSecurityTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
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

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WifiModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
