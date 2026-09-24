import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NoInternetScreen extends StatefulWidget {
  const NoInternetScreen({Key? key}) : super(key: key);

  @override
  State<NoInternetScreen> createState() => _NoInternetScreenState();
}

class _NoInternetScreenState extends State<NoInternetScreen>
    with WidgetsBindingObserver {
  static const MethodChannel _settingsChannel =
      MethodChannel('facehub/settings');

  bool _checking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkInternet();
    }
  }

  Future<void> _openSettings() async {
    try {
      await _settingsChannel.invokeMethod('openNetworkSettings');
    } catch (e) {
      debugPrint('Could not open network settings: $e');

      // Fallback for Android.
      if (Platform.isAndroid) {
        try {
          await _settingsChannel.invokeMethod('openSettings');
        } catch (e) {
          debugPrint('Settings fallback failed: $e');
        }
      }
    }
  }

  Future<void> _checkInternet() async {
    if (_checking) return;

    _checking = true;

    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));

      if (result.isNotEmpty && result.first.rawAddress.isNotEmpty) {
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      }
    } catch (e) {
      debugPrint('Internet still unavailable: $e');
    } finally {
      _checking = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 86,
                  height: 86,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.wifi_off_rounded,
                    size: 42,
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 28),

                const Text(
                  'Oops!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  'No internet connection',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  'Try turning on your mobile data or Wi-Fi.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _openSettings,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Open Settings',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                TextButton(
                  onPressed: _checkInternet,
                  child: const Text(
                    'Try Again',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}