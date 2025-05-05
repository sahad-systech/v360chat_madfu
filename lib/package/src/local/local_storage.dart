import 'package:shared_preferences/shared_preferences.dart';

import '../model/storage_pre_model.dart';

class View360ChatPrefs {
  static String chatIdKey = 'CHAT_ID_KEY';
  static String customerIdKey = 'CUSTOMER_ID_KEY';
  static String customerNameKey = 'CUSTOMER_NAME_KEY';
  static String customerEmailKey = 'CUSTOMER_EMAIL_KEY';
  static String customerPhoneKey = 'CUSTOMER_PHONE_KEY';

  static Future<void> saveString(
      {required String chatIdKeyValue,
      required String customerIdKeyValue,
      required String customerNameKeyValue,
      required String customerEmailKeyValue,
      required String customerPhoneKeyValue}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(chatIdKey, chatIdKeyValue);
    await prefs.setString(customerIdKey, customerIdKeyValue);
    await prefs.setString(customerNameKey, customerNameKeyValue);
    await prefs.setString(customerEmailKey, customerEmailKeyValue);
    await prefs.setString(customerPhoneKey, customerPhoneKeyValue);
  }

  static Future<View360ChatPrefsModel> getString() async {
    final prefs = await SharedPreferences.getInstance();
    return View360ChatPrefsModel(
      chatId: prefs.getString(chatIdKey) ?? '',
      customerId: prefs.getString(customerIdKey) ?? '',
      customerName: prefs.getString(customerNameKey) ?? '',
      customerEmail: prefs.getString(customerEmailKey) ?? '',
      customerPhone: prefs.getString(customerPhoneKey) ?? '',
    );
  }

  static Future<void> remove() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(chatIdKey);
    await prefs.remove(customerIdKey);
    await prefs.remove(customerNameKey);
    await prefs.remove(customerEmailKey);
    await prefs.remove(customerPhoneKey);
  }

  Future<String> getCustomerId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(customerIdKey) ?? '';
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
