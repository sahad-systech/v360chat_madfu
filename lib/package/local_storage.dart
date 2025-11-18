import 'package:madfu_demo/package/models/view360chatprefs.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// View360ChatPrefs manages local storage for chat session data
/// All methods are static for easy access throughout the app
class View360ChatPrefs {
  /// Storage keys for SharedPreferences
  /// These constants define the keys used to store and retrieve data
  static String chatIdKey = 'CHAT_ID_KEY';
  static String isBot = 'IS_BOT';
  static String botId = 'BOT_ID';

  static String customerIdKey = 'CUSTOMER_ID_KEY';
  static String customerNameKey = 'CUSTOMER_NAME_KEY';
  static String customerEmailKey = 'CUSTOMER_EMAIL_KEY';
  static String customerPhoneKey = 'CUSTOMER_PHONE_KEY';
  static String customerCondentIdKey = 'CUSTOMER_CONDENT_ID_KEY';
  static String isInQueue = 'IS_INQUEUE';

  /// Called when a new chat session is created
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

  /// Checks if the current chat is with a bot
  static Future<bool> isBotChat()async{
     final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(isBot)??false;
  }

  /// Updates the bot status for the current chat session
  static Future<void> saveIsBotValue(bool isBotValue)async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(isBot, isBotValue);
  }

  /// Retrieves all stored chat session data as a View360ChatPrefsModel object
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

  /// Removes all stored chat session data from local storage
  /// Called when ending a chat session
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

  /// Retrieves the customer ID from local storage
  static Future<String?> getCustomerId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(customerIdKey);
  }

  /// Typically called when the chat session ends
  static Future<bool> removeCustomerId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove(customerIdKey);
  }

  /// Indicates whether the customer is waiting in a queue for an agent
  static Future<void> changeQueueStatus(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(isInQueue, value);
  }

  /// Stores the ID of the chat session in the queue
  static Future<void> condentIdInQueue(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(customerCondentIdKey, value);
  }

  /// Clears all data from local storage
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  /// Saves the customer ID to local storage
  static Future<void> saveCustomerId(String value)async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(customerIdKey, value);
    
  }

  /// Checks if the current chat is with a bot
  static Future<bool?> getIsSBot() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(isBot);
  }

    /// Retrieves the bot ID if the chat is with a bot
    static Future<String?> getBotId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(botId);
  }
}
