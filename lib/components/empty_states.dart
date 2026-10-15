import 'package:foap/helper/imports/common_import.dart';

Widget noUserFound(BuildContext context) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      ThemeIconWidget(
        ThemeIcon.noData,
        size: 200,
      ),
      const SizedBox(
        height: 20,
      ),
      Heading5Text(
        noUserFoundString.tr,
        weight: TextWeight.medium,
      )
    ],
  );
}

Widget emptyPost({
  required String title,
  required String subTitle,
}) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      ThemeIconWidget(
        ThemeIcon.noData,
        size: 200,
      ),
      const SizedBox(
        height: 20,
      ),
      Heading6Text(
        title,
        weight: TextWeight.medium,
      ),
      const SizedBox(
        height: 10,
      ),
      BodyLargeText(
        subTitle,
      ),
    ],
  );
}

Widget emptyUser({
  required String title,
  required String subTitle,
}) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      ThemeIconWidget(
        ThemeIcon.noData,
        size: 200,
      ),
      const SizedBox(
        height: 20,
      ),
      Heading6Text(title, weight: TextWeight.medium),
      const SizedBox(
        height: 10,
      ),
      BodyLargeText(
        subTitle,
      ),
    ],
  );
}

Widget emptyData({required String title, required String subTitle}) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      ThemeIconWidget(
        ThemeIcon.noData,
        size: 200,
      ),
      const SizedBox(
        height: 20,
      ),
      Heading6Text(title, weight: TextWeight.medium),
      const SizedBox(
        height: 10,
      ),
      BodyLargeText(
        subTitle,
      ),
    ],
  );
}
