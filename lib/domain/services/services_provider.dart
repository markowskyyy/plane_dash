import 'package:plane_dash/domain/services/progress_service.dart';
import 'package:plane_dash/domain/services/settings_service.dart';
import 'package:riverpod/riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';


final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});


final progressServiceProvider = Provider<ProgressService>((ref) {
  return ProgressService();
});

final settingsServiceProvider = Provider<SettingsService>((ref) {
  return SettingsService();
});