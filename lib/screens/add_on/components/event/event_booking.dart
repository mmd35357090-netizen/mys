import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/event_imports.dart';
import 'package:foap/screens/profile/other_user_profile.dart';
import 'package:get/get.dart';

class EventBookingCard extends StatelessWidget {
  final EventBookingModel bookingModel;

  const EventBookingCard({Key? key, required this.bookingModel})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Heading6Text(bookingModel.event.name,
                      weight: TextWeight.semiBold),
                  bookingModel.giftedToUser != null
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                BodyLargeText(
                                  giftedToString.tr,
                                  weight: TextWeight.semiBold,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  bookingModel.giftedByUser!.userName,
                                  style: TextStyle(fontSize: FontSizes.b2),
                                ),
                                const ThemeIconWidget(
                                  ThemeIcon.nextArrow,
                                  size: 15,
                                )
                              ],
                            ),
                            Container(
                              height: 2,
                              width: 60,
                              color: AppColorConstants.themeColor,
                            ).vP4,
                          ],
                        ).tP8.ripple(() {
                          Get.to(() => OtherUserProfile(
                              userId: bookingModel.giftedByUser!.id));
                        })
                      : Container(),
                  bookingModel.giftedByUser != null &&
                          bookingModel.giftedByUser?.isMe == false
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                BodyLargeText(giftedByString.tr,
                                    weight: TextWeight.semiBold),
                                const SizedBox(width: 5),
                                Text(
                                  bookingModel.giftedByUser!.userName,
                                  style: TextStyle(fontSize: FontSizes.b2),
                                ),
                                const ThemeIconWidget(
                                  ThemeIcon.nextArrow,
                                  size: 15,
                                )
                              ],
                            ),
                            Container(
                              height: 2,
                              width: 60,
                              color: AppColorConstants.themeColor,
                            ).vP4,
                          ],
                        ).tP8.ripple(() {
                          Get.to(() => OtherUserProfile(
                              userId: bookingModel.giftedByUser!.id));
                        })
                      : Container(),
                ],
              ),
            ),
            CachedNetworkImage(
              imageUrl: bookingModel.event.image,
              height: 50,
              width: 50,
              fit: BoxFit.cover,
            ).round(10)
          ],
        ).p16,
        divider().vP8,
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BodyMediumText(
                  dateString.tr,
                ),
                const SizedBox(
                  height: 5,
                ),
                Container(
                  height: 2,
                  width: 30,
                  color: AppColorConstants.themeColor,
                ),
                const SizedBox(
                  height: 5,
                ),
                BodyLargeText(bookingModel.event.startAtDate,
                    weight: TextWeight.semiBold)
              ],
            ),
            const SizedBox(
              width: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BodyMediumText(
                  timeString.tr,
                ),
                const SizedBox(
                  height: 5,
                ),
                Container(
                  height: 2,
                  width: 30,
                  color: AppColorConstants.themeColor,
                ),
                const SizedBox(
                  height: 5,
                ),
                BodyLargeText(bookingModel.event.startAtTime,
                    weight: TextWeight.semiBold)
              ],
            ),
            const Spacer(),
            Container(
              color: AppColorConstants.backgroundColor,
              child: BodyMediumText(
                bookingModel.ticketType.name,
              ).setPadding(left: 16, right: 16, top: 8, bottom: 8),
            ).round(10)
          ],
        ).p16
      ],
    ).backgroundCard(radius: 15);
  }
}
