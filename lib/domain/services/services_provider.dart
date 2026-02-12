import 'package:plane_dash/domain/services/progress_service.dart';
import 'package:plane_dash/domain/services/settings_service.dart';
import 'package:riverpod/riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';


// Провайдер для SharedPreferences (один раз инициализируем)
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

// ProgressService – зависит от sharedPreferences
final progressServiceProvider = Provider<ProgressService>((ref) {
  // Мы не ждём здесь Future, а получаем его через ref.watch.
  // В самом сервисе методы асинхронные, они будут вызывать ref.read(sharedPreferencesProvider.future) или await
  return ProgressService();
});

// SettingsService
final settingsServiceProvider = Provider<SettingsService>((ref) {
  return SettingsService();
});