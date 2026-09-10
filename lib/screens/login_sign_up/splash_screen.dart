import 'package:carousel_slider/carousel_slider.dart';
import 'package:foap/helper/imports/common_import.dart';
import '../dashboard/loading.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // 🧹 অপ্রয়োজনীয় বায়োমেট্রিক ভেরিয়েবলগুলো এখান থেকে বাদ দেওয়া হয়েছে কারণ এগুলো LoadingScreen-এ আছে।
  
  List<String> bgImages = [
    'assets/tutorial1.jpg',
    'assets/tutorial2.jpg',
    'assets/tutorial3.jpg',
    'assets/tutorial4.jpg'
  ];

  @override
  void initState() {
    super.initState();
    
    // ⏰ ৪ সেকেন্ড অনেক বেশি সময়। এটিকে ৩ সেকেন্ড (বা ২ সেকেন্ড) করে দেওয়া হলো 
    // যাতে ইউজার দ্রুত মেইন অ্যাপে ঢুকতে পারে।
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Get.offAll(() => const LoadingScreen());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColorConstants.backgroundColor,
        body: Stack(
          children: [
            // ব্যাকগ্রাউন্ড ইমেজ ক্যারোজেল স্লাইডার
            CarouselSlider(
              items: [
                for (String image in bgImages)
                  Image.asset(
                    image,
                    fit: BoxFit.cover,
                    height: double.infinity,
                    width: double.infinity,
                  )
              ],
              options: CarouselOptions(
                autoPlayInterval: const Duration(seconds: 1),
                autoPlay: true,
                enlargeCenterPage: false,
                enableInfiniteScroll: true,
                height: double.infinity,
                viewportFraction: 1,
                onPageChanged: (index, reason) {},
              ),
            ),
            // গ্রেডিয়েন্ট ওভারলে
            Container(
              height: double.infinity,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  stops: const [0.1, 0.3, 0.6, 0.9],
                  colors: [
                    AppColorConstants.backgroundColor.withOpacity(0.9),
                    AppColorConstants.backgroundColor.lighten().withOpacity(0.9),
                    AppColorConstants.backgroundColor.lighten().withOpacity(0.5),
                    AppColorConstants.themeColor.withOpacity(0.5),
                  ],
                ),
              ),
            ),
            // লোগো এবং অ্যাপের নাম
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/spash_logo.png',
                    height: 120,
                    width: 120,
                  ),
                  const SizedBox(height: 10),
                  BodyLargeText(
                    AppConfigConstants.appName,
                    weight: TextWeight.medium
                  ),
                  Heading6Text(
                    AppConfigConstants.appTagline.tr,
                  ),
                ],
              ).bp(200),
            ),
          ],
        ));
  }
}
