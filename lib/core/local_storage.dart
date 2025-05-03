import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const String isLogin = 'isLogin';

  static Future<bool> getIsLogin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(isLogin) ?? false;
  }

  static Future<void> setIsLogin(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(isLogin, value);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
