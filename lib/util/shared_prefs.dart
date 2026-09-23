import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  // ------------------------------------------------------------
  // Tutorial
  // ------------------------------------------------------------

  Future<void> setTutorialSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tutorialSeen', true);
  }

  Future<bool> getTutorialSeen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('tutorialSeen') ?? false;
  }

  // ------------------------------------------------------------
  // Dark Mode
  // ------------------------------------------------------------

  Future<bool> isDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('darkMode') ?? false;
  }

  Future<void> setDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', value);
  }

  // ------------------------------------------------------------
  // Authorization / Login
  // ------------------------------------------------------------

  Future<void> setAuthorizationKey(String authKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('authKey', authKey);
  }

  Future<String?> getAuthorizationKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authKey');
  }

  Future<void> clearPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('authKey');
  }

  // ------------------------------------------------------------
  // FCM Token
  // ------------------------------------------------------------

  Future<void> setFCMToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('FCMToken', token);
  }

  Future<String?> getFCMToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('FCMToken');
  }

  // ------------------------------------------------------------
  // VoIP Token
  // ------------------------------------------------------------

  Future<void> setVoipToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('VOIPToken', token);
  }

  Future<String?> getVoipToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('VOIPToken');
  }

  // ------------------------------------------------------------
  // Wallpaper
  // ------------------------------------------------------------

  Future<void> setWallpaper({
    required int roomId,
    required String wallpaper,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      roomId.toString(),
      wallpaper,
    );
  }

  Future<String> getWallpaper({
    required int roomId,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(roomId.toString()) ??
        'assets/chatbg/chatbg3.jpg';
  }

  // ------------------------------------------------------------
  // Language
  // ------------------------------------------------------------

  Future<String> getLanguageCode() async {
    return 'en';
  }

  Future<void> setLanguage(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', lang);
  }

  Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString('language') ?? 'en';
  }

  Future<Locale> getLocale() async {
    return WidgetsBinding.instance.platformDispatcher.locale;
  }

  // ------------------------------------------------------------
  // Call Notification Data
  // ------------------------------------------------------------

  Future<void> setCallNotificationData(dynamic data) async {
    final prefs = await SharedPreferences.getInstance();

    if (data != null) {
      await prefs.setString(
        'notificationData',
        jsonEncode(data),
      );
    } else {
      await prefs.remove('notificationData');
    }
  }

  Future<dynamic> getCallNotificationData() async {
    final prefs = await SharedPreferences.getInstance();

    final String? jsonData =
        prefs.getString('notificationData');

    if (jsonData != null && jsonData.isNotEmpty) {
      try {
        return jsonDecode(jsonData) as Map<String, dynamic>;
      } catch (e) {
        return null;
      }
    }

    return null;
  }

  // ------------------------------------------------------------
  // Apple ID
  // ------------------------------------------------------------

  Future<void> setAppleIdEmail({
    required String forAppleId,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      '${forAppleId}_email',
      email,
    );
  }

  Future<String?> getAppleIdEmail({
    required String forAppleId,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(
      '${forAppleId}_email',
    );
  }

  Future<void> setAppleIdName({
    required String forAppleId,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      '${forAppleId}_name',
      email,
    );
  }

  Future<String?> getAppleIdName({
    required String forAppleId,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(
      '${forAppleId}_name',
    );
  }

  // ------------------------------------------------------------
  // API Response Cache
  // ------------------------------------------------------------

  Future<void> setApiResponse({
    required String url,
    required String response,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      url,
      response,
    );
  }

  Future<String?> getCachedApiResponse({
    required String url,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(url);
  }
}