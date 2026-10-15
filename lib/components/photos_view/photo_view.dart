import 'package:foap/components/image1.dart';
import 'package:foap/helper/imports/common_import.dart';

class PhotoView extends StatefulWidget {
  final int startPosition;
  final List<String> photos;

  const PhotoView(
      {super.key, required this.photos, required this.startPosition});

  @override
  State<PhotoView> createState() => _PhotoViewState();
}

class _PhotoViewState extends State<PhotoView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      appBar: const BackNavigationBar(),
      body: photos(),
    );
  }

  Widget photos() {
    return WKCarouselSlider(
      items: photosList(),
      initialPage: widget.startPosition,
      enlargeCenterPage: false,
      enableInfiniteScroll: true,
      autoPlay: true,
      height: double.infinity,
      viewportFraction: 1,
      onPageChanged: (index) {},
    );
  }

  List<Widget> photosList() {
    return [
      for (String photo in widget.photos)
        WKImage1(
          path: photo,
          width: Get.width,
          height: double.infinity,
          fit: BoxFit.contain,
        ),
    ];
  }
}

class BackNavigationBar extends StatelessWidget
    implements PreferredSizeWidget {
  @override
  final Size preferredSize;
  final String? title;
  final bool? showDivider;
  final bool? centerTitle;

  const BackNavigationBar(
      {super.key, this.title, this.showDivider, this.centerTitle})
      : preferredSize = const Size.fromHeight(60.0);

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
        preferredSize: preferredSize,
        child: Container(
          color: AppColorConstants.backgroundColor,
          child: Column(
            children: [
              Row(
                children: [
                  ThemeIconWidget(ThemeIcon.backArrow,
                          size: 20, color: AppColorConstants.iconColor)
                      .ripple(() {
                    Get.back();
                  }),
                  centerTitle == true ? const Spacer() : Container(),
                  centerTitle != true ? Container(width: 20) : Container(),
                  title != null
                      ? Text(title!,
                              style: TextStyle(
                                  color: AppColorConstants.mainTextColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16))
                          .ripple(() {
                          Get.back();
                        })
                      : Container(),
                  centerTitle == true ? const Spacer() : Container(),
                  Container(width: 20)
                ],
              ).tp(60).hp(DesignConstants.horizontalPadding),
              const Spacer(),
              showDivider == true ? divider(height: 0.2) : Container()
            ],
          ),
        ));
  }
}
