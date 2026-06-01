import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../features/scanner/domain/models/wifi_model.dart';

class HiveService {
  static const String historyBoxName = 'wifi_history';
  static const String settingsBoxName = 'settings';

  Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(WifiSecurityTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(WifiModelAdapter());
    }

    // Securely generate/retrieve encryption key
    const secureStorage = FlutterSecureStorage();
    String? encryptionKey =
        await secureStorage.read(key: 'hive_encryption_key');
    if (encryptionKey == null) {
      final key = Hive.generateSecureKey();
      await secureStorage.write(
        key: 'hive_encryption_key',
        value: base64UrlEncode(key),
      );
      encryptionKey = base64UrlEncode(key);
    }
    final keyBytes = base64Url.decode(encryptionKey);

    // Open boxes with encryption
    await Hive.openBox<WifiModel>(
      historyBoxName,
      encryptionCipher: HiveAesCipher(keyBytes),
    );
    await Hive.openBox(
      settingsBoxName,
      encryptionCipher: HiveAesCipher(keyBytes),
    );
  }

  Box<WifiModel> get historyBox => Hive.box<WifiModel>(historyBoxName);
  Box get settingsBox => Hive.box(settingsBoxName);

  Future<void> saveWifiScan(WifiModel model) async {
    await historyBox.add(model);
  }

  List<WifiModel> getHistory() {
    return historyBox.values.toList().reversed.toList();
  }

  Future<void> deleteScan(int index) async {
    await historyBox.deleteAt(index);
  }

  Future<void> clearHistory() async {
    await historyBox.clear();
  }
}
