import 'package:madfu_demo/package/models/view360chatprefs.dart';
import 'package:shared_preferences/shared_preferences.dart';


class View360ChatPrefs {
  static String chatIdKey = 'CHAT_ID_KEY';
  static String isBot = 'IS_BOT';
  static String botId = 'BOT_ID';

  static String customerIdKey = 'CUSTOMER_ID_KEY';
  static String customerNameKey = 'CUSTOMER_NAME_KEY';
  static String customerEmailKey = 'CUSTOMER_EMAIL_KEY';
  static String customerPhoneKey = 'CUSTOMER_PHONE_KEY';
  static String customerCondentIdKey = 'CUSTOMER_CONDENT_ID_KEY';
  static String isInQueue = 'IS_INQUEUE';

  static Future<void> saveString(
      {required String chatIdKeyValue,
      required String customerIdKeyValue,
      required String customerNameKeyValue,
      required String customerEmailKeyValue,
      required String customerPhoneKeyValue,
      required String customerCondentIdValue,
      required String botIdValue,
      required bool isBotValue,
      required bool isInQueueValue}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(chatIdKey, chatIdKeyValue);
    await prefs.setString(botId, botIdValue);
    await prefs.setString(botId, botIdValue);
    await prefs.setBool(isInQueue, isInQueueValue);
    await prefs.setString(customerIdKey, customerIdKeyValue);
    await prefs.setString(customerNameKey, customerNameKeyValue);
    await prefs.setString(customerEmailKey, customerEmailKeyValue);
    await prefs.setString(customerPhoneKey, customerPhoneKeyValue);
    await prefs.setString(customerCondentIdKey, customerCondentIdValue);
    await prefs.setBool(isBot, isBotValue);
  }

  static Future<bool> isBotChat()async{
     final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(isBot)??false;
  }

  static Future<void> saveIsBotValue(bool isBotValue)async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(isBot, isBotValue);
  }

  static Future<View360ChatPrefsModel> getString() async {
    final prefs = await SharedPreferences.getInstance();
    return View360ChatPrefsModel(
      chatId: prefs.getString(chatIdKey) ?? '',
      customerId: prefs.getString(customerIdKey) ?? '',
      customerName: prefs.getString(customerNameKey) ?? '',
      isInQueue: prefs.getBool(isInQueue) ?? false,
      customerEmail: prefs.getString(customerEmailKey) ?? '',
      customerPhone: prefs.getString(customerPhoneKey) ?? '',
      customerContentId: prefs.getString(customerCondentIdKey) ?? 'false',
    );
  }

  static Future<void> remove() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(chatIdKey);
    await prefs.remove(customerIdKey);
    await prefs.remove(customerNameKey);
    await prefs.remove(customerEmailKey);
    await prefs.remove(customerPhoneKey);
    await prefs.remove(isInQueue);
    await prefs.remove(customerCondentIdKey);
  }

  static Future<String?> getCustomerId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(customerIdKey);
  }

  static Future<bool> removeCustomerId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove(customerIdKey);
  }

  static Future<void> changeQueueStatus(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(isInQueue, value);
  }

  static Future<void> condentIdInQueue(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(customerCondentIdKey, value);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<void> saveCustomerId(String value)async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(customerIdKey, value);
    
  }

  static Future<bool?> getIsSBot() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(isBot);
  }

    static Future<String?> getBotId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(botId);
  }
}
