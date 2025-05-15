import 'package:shared_preferences/shared_preferences.dart';

class AppLocalStore {
  static String isLogined = "ISLOGINED";
  static Future<bool> setLoging(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setBool(isLogined, value);
  }

  static Future<bool> getLogin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(isLogined) ?? false;
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
