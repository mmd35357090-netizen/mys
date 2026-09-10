import 'dart:io';
import 'package:auto_orientation/auto_orientation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:foap/screens/login_sign_up/splash_screen.dart';
import 'package:foap/util/shared_prefs.dart';
import 'package:camera/camera.dart';

// ক্যামেরা ইনিশিয়ালি খালি রাখুন
List<CameraDescription> cameras = []; 
bool isLaunchedFromCallNotification = false;
bool isAnyPageInStack = false;

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

Future<void> main() async {
  // নিশ্চিত করুন বাইন্ডিং হয়েছে
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();
  AutoOrientation.portraitAutoMode();

  // থিম সেটআপ (খুব দ্রুত হয়)
  isDarkMode = await SharedPrefs().isDarkMode();
  Get.changeThemeMode(isDarkMode ? ThemeMode.dark : ThemeMode.light);

  // ⚡ [ম্যাজিক লাইন]: কোনো ভারী কাজের জন্য অপেক্ষা না করে সরাসরি অ্যাপ রান করে দিন!
  // এর ফলে নেটিভ লোগো স্ক্রিনটি চোখের পলকে চলে গিয়ে ফ্লাটার স্ক্রিন চলে আসবে।
  runApp(Phoenix(
    child: const SocialifiedApp(
      startScreen: SplashScreen(),
    ),
  ));
}

class SocialifiedApp extends StatefulWidget {
  final Widget startScreen;
  const SocialifiedApp({Key? key, required this.startScreen}) : super(key: key);

  @override
  State<SocialifiedApp> createState() => _SocialifiedAppState();
}

class _SocialifiedAppState extends State<SocialifiedApp> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  Widget build(BuildContext context) {
    return OverlaySupport.global(
      child: FutureBuilder<Locale>(
        future: SharedPrefs().getLocale(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return GetMaterialApp(
              translations: Languages(),
              locale: snapshot.data!,
              home: widget.startScreen,
            );
          }
          return const Container(); // বা একটি সাধারণ ডিফল্ট কন্টেইনার
        },
      ),
    );
  }
}
