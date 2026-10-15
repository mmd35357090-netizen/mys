import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:foap/helper/imports/common_import.dart';

import '../model/account.dart';

class SharedPrefs {
  Future<Locale> getLocale() async {
    String selectedLanguage = await SharedPrefs().getLanguage();
    var locale = Locale(selectedLanguage);
    return locale;
  }

  //Set/Get UserLoggedIn Status
  void setTutorialSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('tutorialSeen', true);
  }

  Future<bool> getTutorialSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('tutorialSeen') ?? false;
  }

  Future<bool> isDarkMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.get('darkMode') as bool? ?? false;
  }

  setDarkMode(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('darkMode', value);
  }

  void setBioMetricAuthStatus(bool status) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('bioMetricAuthStatus', status);
  }

  Future<bool> getBioMetricAuthStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('bioMetricAuthStatus') ?? false;
  }

  Future<bool> isUserLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  //Set/Get UserLoggedIn Status
  Future setAuthorizationKey(String authKey) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('authKey', authKey);
  }

  Future<String?> getAuthorizationKey() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.get('authKey') as String?;
  }

  void setFCMToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('FCMToken', token);
  }

  Future<String?> getFCMToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.get('FCMToken') as String?;
  }

  void setVoipToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('VOIPToken', token);
  }

  Future<String?> getVoipToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.get('VOIPToken') as String?;
  }

  void setWallpaper(
      {required int roomId, required String wallpaper}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(roomId.toString(), wallpaper);
  }

  Future<String> getWallpaper({required int roomId}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.get(roomId.toString()) as String? ??
        "assets/chatbg/chatbg3.jpg";
  }

  //Set/Get UserLoggedIn Status
  // Future<bool> setLanguageCode(String code) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   return await prefs.setString('language', code);
  // }

  Future<String> getLanguageCode() async {
    return 'en';
  }

  void clearPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('authKey');
  }

  void setLanguage(String lang) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('language', lang);
  }

  Future<String> getLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.get('language') as String? ?? 'en';
  }

  void setCallNotificationData(dynamic data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (data != null) {
      prefs.setString('notificationData', jsonEncode(data));
    } else {
      prefs.remove('notificationData');
    }
  }

  Future<dynamic> getCallNotificationData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonData = prefs.getString('notificationData');

    if (jsonData != null) {
      return jsonDecode(jsonData) as Map<String, dynamic>;
    }

    // If no data is found, return an empty map or null, depending on your requirements
    return null; // or return null;
  }

  void setAppleIdEmail(
      {required String forAppleId, required String email}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('${forAppleId}_email', email);
  }

  Future<String?> getAppleIdEmail({required String forAppleId}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.get('${forAppleId}_email') as String?;
  }

  void setAppleIdName(
      {required String forAppleId, required String email}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('${forAppleId}_name', email);
  }

  Future<String?> getAppleIdName({required String forAppleId}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.get('${forAppleId}_name') as String?;
  }

  void setApiResponse(
      {required String url, required String response}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(url, response);
  }

  Future<String?> getCachedApiResponse({required String url}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.get(url) as String?;
  }

  // manage accounts

  Future<void> saveAccount(SayHiAppAccount account) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> accounts = prefs.getStringList('accounts') ?? [];

    // Check if account already exists and update if found
    int index = accounts.indexWhere((acc) =>
        SayHiAppAccount.fromMap(jsonDecode(acc)).userId == account.userId);
    if (index != -1) {
      accounts[index] = jsonEncode(account.toMap());
    } else {
      accounts.add(jsonEncode(account.toMap()));
    }

    await prefs.setStringList('accounts', accounts);
  }

  Future<List<SayHiAppAccount>> getAccounts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> accounts = prefs.getStringList('accounts') ?? [];

    return accounts
        .map((acc) => SayHiAppAccount.fromMap(jsonDecode(acc)))
        .toList();
  }

  Future<SayHiAppAccount?> getAccount(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> accounts = prefs.getStringList('accounts') ?? [];

    List<SayHiAppAccount> accountObjs = accounts
        .map((acc) => SayHiAppAccount.fromMap(jsonDecode(acc)))
        .toList();
    if (accountObjs.where((e) => e.userId == id).isNotEmpty) {
      return accountObjs.where((e) => e.userId == id).first;
    } else {
      return null;
    }
  }

  Future<SayHiAppAccount?> getCurrentAccount(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> accounts = prefs.getStringList('accounts') ?? [];

    List<SayHiAppAccount> accountObjs = accounts
        .map((acc) => SayHiAppAccount.fromMap(jsonDecode(acc)))
        .toList();
    if (accountObjs.where((e) => e.userId == id).isNotEmpty) {
      return accountObjs.where((e) => e.userId == id).first;
    } else {
      return null;
    }
  }
}
