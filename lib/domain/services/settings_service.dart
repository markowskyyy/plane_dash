import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _soundKey = 'sound_enabled';
  static const String _vibrationKey = 'vibration_enabled';
  static const String _sensitivityKey = 'sensitivity';

  // Звук
  Future<bool> getSoundEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_soundKey) ?? true;
  }

  Future<void> setSoundEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_soundKey, value);
  }

  // Вибрация
  Future<bool> getVibrationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_vibrationKey) ?? true;
  }

  Future<void> setVibrationEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_vibrationKey, value);
  }

  // Чувствительность (0.0 - 1.0)
  Future<double> getSensitivity() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_sensitivityKey) ?? 0.5;
  }

  Future<void> setSensitivity(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_sensitivityKey, value);
  }
}