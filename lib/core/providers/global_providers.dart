import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/services/hive_service.dart';

final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService();
});

final themeModeProvider = StateProvider<ThemeMode>((ref) {
  final hive = ref.watch(hiveServiceProvider);
  final isDarkMode = hive.settingsBox.get('dark_mode', defaultValue: false);
  return isDarkMode ? ThemeMode.dark : ThemeMode.light;
});
