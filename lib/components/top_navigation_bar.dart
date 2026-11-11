import 'package:foap/helper/imports/common_import.dart';

Widget backNavigationBar({required String title}) {
  return Container(
    height: 100,
    decoration: BoxDecoration(
      color: AppColorConstants.cardColor,
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(22)),
      boxShadow: [
        BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4))
      ],
    ),
    child: Stack(
      alignment: Alignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 38,
              width: 38,
              color: AppColorConstants.themeColor.withValues(alpha: 0.1),
              child: Center(child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 17,
                color: AppColorConstants.iconColor,
              )),
            ).round(19).ripple(() {
              Get.back();
            }),
            const SizedBox(
              width: 40,
            )
          ],
        ),
        BodyLargeText(title.tr, maxLines: 1, weight: TextWeight.bold)
      ],
    ).setPadding(
        left: DesignConstants.horizontalPadding,
        right: DesignConstants.horizontalPadding,
        top: 40),
  );
}

Widget backNavigationBarWithTrailingWidget(
    {required String title, required Widget widget}) {
  return Container(
    height: 100,
    decoration: BoxDecoration(
      color: AppColorConstants.cardColor,
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(22)),
      boxShadow: [
        BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4))
      ],
    ),
    width: double.infinity,
    child: Stack(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
              height: 38,
              width: 38,
              color: AppColorConstants.themeColor.withValues(alpha: 0.1),
              child: Center(child: ThemeIconWidget(
                ThemeIcon.backArrow,
                size: 17,
                color: AppColorConstants.iconColor,
              )),
            ).round(19),
            ).ripple(() {
              Get.back();
            }),
            widget,
          ],
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          top: 0,
          child: Center(
            child: BodyLargeText(
              title,
              weight: TextWeight.bold,
            ),
          ),
        )
      ],
    ).setPadding(
        left: DesignConstants.horizontalPadding,
        right: DesignConstants.horizontalPadding,
        top: 40),
  );
}

Widget profileScreensNavigationBar(
    {required String title,
    String? rightBtnTitle,
    required VoidCallback completion}) {
  return Stack(
    alignment: AlignmentDirectional.center,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
              height: 38,
              width: 38,
              color: AppColorConstants.themeColor.withValues(alpha: 0.1),
              child: Center(child: ThemeIconWidget(
            ThemeIcon.backArrow,
            size: 17,
            color: AppColorConstants.iconColor,
          )),
            ).round(19).ripple(() {
            Get.back();
          }),
          if (rightBtnTitle != null)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  AppColorConstants.themeColor,
                  AppColorConstants.themeColor.withValues(alpha: 0.75)
                ]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: BodyMediumText(rightBtnTitle.tr,
                  color: Colors.white, weight: TextWeight.semiBold),
            ).ripple(() {
              completion();
            }),
        ],
      ).setPadding(
          left: DesignConstants.horizontalPadding,
          right: DesignConstants.horizontalPadding),
      Positioned(
        left: 0,
        right: 0,
        child: Center(
          child: BodyLargeText(title.tr, weight: TextWeight.bold),
        ),
      )
    ],
  ).bP16;
}

Widget titleNavigationBarWithIcon(
    {required String title,
    required ThemeIcon icon,
    Color? iconColor,
    required VoidCallback completion}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      const SizedBox(
        width: 25,
      ),
      BodyLargeText(title.tr, weight: TextWeight.medium),
      ThemeIconWidget(
        icon,
        color: iconColor ?? AppColorConstants.iconColor,
        size: 25,
      ).ripple(() {
        completion();
      }),
    ],
  ).setPadding(
      left: DesignConstants.horizontalPadding,
      right: DesignConstants.horizontalPadding,
      top: 8,
      bottom: 16);
}

Widget titleNavigationBarWithWidget(
    {required String title,
    required Widget widget,
    required VoidCallback completion}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      const SizedBox(
        width: 25,
      ),
      BodyLargeText(title.tr, weight: TextWeight.medium),
      widget,
    ],
  ).setPadding(
      left: DesignConstants.horizontalPadding,
      right: DesignConstants.horizontalPadding,
      top: 8,
      bottom: 16);
}

Widget titleNavigationBar({required String title}) {
  return Container(
    height: 100,
    width: Get.width,
    color: AppColorConstants.cardColor,
    child: Center(
      child: BodyLargeText(title.tr, weight: TextWeight.medium)
          .setPadding(top: 40),
    ),
  );
}

Widget customNavigationBar(
    {required String title, VoidCallback? action, Widget? trailing}) {
  return Container(
    height: 100,
    color: AppColorConstants.cardColor,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ThemeIconWidget(
          ThemeIcon.backArrow,
          size: 18,
          color: AppColorConstants.iconColor,
        ).ripple(() {
          if (action != null) {
            action();
          } else {
            Get.back();
          }
        }),
        Heading4Text(title, weight: TextWeight.bold),
        trailing ?? const SizedBox(width: 20),
      ],
    ).setPadding(
        left: DesignConstants.horizontalPadding,
        right: DesignConstants.horizontalPadding,
        top: 8,
        bottom: 16),
  );
}
