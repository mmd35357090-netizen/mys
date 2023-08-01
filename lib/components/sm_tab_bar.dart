import 'package:foap/helper/imports/common_import.dart';

class SMTabBar extends StatelessWidget {
  final TabController? controller;
  final List<String> tabs;

  const SMTabBar({Key? key, required this.tabs, this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 2,
              color: AppColorConstants.dividerColor,
            ).round(5)),
        getTextTabBar(tabs: tabs, controller: controller)
      ],
    );
  }
}

class SMIconTabBar extends StatelessWidget {
  final List<ThemeIcon> tabs;
  final TabController? controller;
  final int selectedTab;

  const SMIconTabBar(
      {Key? key,
      required this.tabs,
      this.controller,
      required this.selectedTab})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned(
          left: DesignConstants.horizontalPadding,
          right: DesignConstants.horizontalPadding,
          bottom: 0,
          child: Container(
            height: 2,
            color: AppColorConstants.dividerColor,
          ).round(5)),
    ]);
  }
}

class SMIconAndTextTabBar extends StatelessWidget {
  final List<ThemeIcon> icons;
  final List<String> texts;

  final TabController? controller;
  final int selectedTab;

  const SMIconAndTextTabBar(
      {Key? key,
      required this.icons,
      required this.texts,
      this.controller,
      required this.selectedTab})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned(
          left: DesignConstants.horizontalPadding,
          right: DesignConstants.horizontalPadding,
          bottom: 0,
          child: Container(
            height: 2,
            color: AppColorConstants.dividerColor,
          ).round(5)),
      getIconAndTexTabBar(icons: icons, texts: texts, selectedTab: selectedTab)
    ]);
  }
}

TabBar getTextTabBar({
  TabController? controller,
  required List<String> tabs,
}) {
  return TabBar(
    controller: controller,
    indicator: UnderlineTabIndicator(
      borderSide: BorderSide(width: 3.0, color: AppColorConstants.themeColor),
      insets: const EdgeInsets.symmetric(horizontal: 16.0),
    ),
    onTap: (status) {
      FocusScope.of(Get.context!).requestFocus(FocusNode());
    },
    labelStyle: TextStyle(
        fontSize: FontSizes.h6,
        color: AppColorConstants.themeColor,
        fontWeight: TextWeight.semiBold),
    labelColor: AppColorConstants.themeColor,
    unselectedLabelColor: AppColorConstants.grayscale500,
    tabs: List.generate(tabs.length, (int index) {
      return Tab(
        text: tabs[index],
      );
    }),
  );
}

TabBar getIconTabBar(
    {TabController? controller,
    required List<ThemeIcon> icons,
    required int selectedTab}) {
  return TabBar(
    controller: controller,
    indicator: UnderlineTabIndicator(
      borderSide: BorderSide(width: 3.0, color: AppColorConstants.themeColor),
      insets: const EdgeInsets.symmetric(horizontal: 16.0),
    ),
    labelColor: AppColorConstants.themeColor,
    unselectedLabelColor: AppColorConstants.grayscale500,
    tabs: List.generate(icons.length, (int index) {
      return Tab(
        icon: ThemeIconWidget(
          icons[index],
          color: index == selectedTab
              ? AppColorConstants.themeColor
              : AppColorConstants.grayscale900,
        ),
        // text: tabs[index],
      );
    }),
  );
}

TabBar getIconAndTexTabBar(
    {TabController? controller,
    required List<ThemeIcon> icons,
    required List<String> texts,
    required int selectedTab}) {
  return TabBar(
    controller: controller,
    indicator: UnderlineTabIndicator(
      borderSide: BorderSide(width: 3.0, color: AppColorConstants.themeColor),
      insets: const EdgeInsets.symmetric(horizontal: 16.0),
    ),
    labelColor: AppColorConstants.themeColor,
    unselectedLabelColor: AppColorConstants.grayscale500,
    tabs: List.generate(icons.length, (int index) {
      return Tab(
        icon: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ThemeIconWidget(
              icons[index],
              color: index == selectedTab
                  ? AppColorConstants.themeColor
                  : AppColorConstants.grayscale900,
            ),
            const SizedBox(
              width: 5,
            ),
            BodyLargeText(
              texts[index],
              color: index == selectedTab
                  ? AppColorConstants.themeColor
                  : AppColorConstants.grayscale900,
              weight: TextWeight.semiBold,
            )
          ],
        ),
        // text: tabs[index],
      );
    }),
  );
}
