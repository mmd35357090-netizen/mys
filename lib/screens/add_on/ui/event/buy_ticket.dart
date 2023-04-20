import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/screens/add_on/controller/event/buy_ticket_controller.dart';
import 'package:foap/screens/add_on/controller/event/event_detail_controller.dart';
import 'package:foap/screens/settings_menu/settings_controller.dart';
import 'package:get/get.dart';
import 'package:foap/helper/imports/event_imports.dart';

import 'event_checkout.dart';

class BuyTicket extends StatefulWidget {
  final EventModel event;
  final UserModel? giftToUser;

  const BuyTicket({Key? key, required this.event, this.giftToUser})
      : super(key: key);

  @override
  State<BuyTicket> createState() => _BuyTicketState();
}

class _BuyTicketState extends State<BuyTicket> {
  final BuyTicketController _buyTicketController = BuyTicketController();
  final EventDetailController _eventDetailController = EventDetailController();
  final SettingsController _settingsController = Get.find();

  TextEditingController couponCode = TextEditingController();

  @override
  void initState() {
    _buyTicketController.setData(
        event: widget.event, giftToUser: widget.giftToUser);
    _eventDetailController.loadEventCoupons(widget.event.id);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: SizedBox(
        height: Get.height,
        child: Column(
          children: [
            const SizedBox(
              height: 50,
            ),
            backNavigationBar(
                context: context, title: LocalizationString.buyTicket),
            divider(context: context).tP8,
            Expanded(
              child: Obx(() => Stack(
                    children: [
                      SingleChildScrollView(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 25,
                              ),
                              if (widget.giftToUser != null) giftTo().bP25,
                              ticketType(),
                              const SizedBox(
                                height: 25,
                              ),
                              _buyTicketController.selectedTicketType.value !=
                                      null
                                  ? Column(
                                      children: [
                                        eventDetail().hP16,
                                        const SizedBox(
                                          height: 25,
                                        ),
                                        couponsList(),
                                        // const SizedBox(
                                        //   height: 25,
                                        // ),
                                        divider(context: context).tP8,
                                        const SizedBox(
                                          height: 25,
                                        ),
                                        orderSummary().hP16,
                                        const SizedBox(
                                          height: 150,
                                        ),
                                      ],
                                    )
                                  : Container(),
                            ]),
                      ),
                      Obx(() =>
                          _buyTicketController.ticketOrder.eventTicketTypeId !=
                                  null
                              ? Positioned(
                                  bottom: 20,
                                  left: 25,
                                  right: 25,
                                  child: checkoutButton())
                              : Container())
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Widget eventDetail() {
    return Container(
      height: 120,
      color: AppColorConstants.cardColor.withOpacity(0.4),
      child: Row(
        children: [
          CachedNetworkImage(
            imageUrl: widget.event.image,
            fit: BoxFit.cover,
            width: 80,
            height: 80,
          ).round(15),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    BodySmallText(widget.event.startAtFullDate.toUpperCase(),
                        maxLines: 1, weight: TextWeight.regular),
                    const SizedBox(
                      height: 5,
                    ),
                    BodyLargeText(widget.event.name,
                        maxLines: 1, weight: TextWeight.bold),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Container(
                          height: 30,
                          width: 30,
                          color: AppColorConstants.cardColor.darken(),
                          child: const ThemeIconWidget(ThemeIcon.minus),
                        ).round(5).ripple(() {
                          _buyTicketController.removeTicket();
                        }),
                        Obx(() => SizedBox(
                              width: 25,
                              child: Center(
                                child: Text(_buyTicketController.numberOfTickets
                                    .toString()),
                              ),
                            )).hP16,
                        Container(
                          height: 30,
                          width: 30,
                          color: AppColorConstants.cardColor.darken(),
                          child: const ThemeIconWidget(ThemeIcon.plus),
                        ).round(5).ripple(() {
                          _buyTicketController.addTicket();
                        }),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ).p8,
    ).round(15);
  }

  Widget giftTo() {
    return Container(
      color: AppColorConstants.cardColor.withOpacity(0.4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BodyLargeText(
            LocalizationString.giftingTo,
            weight: TextWeight.semiBold,
          ),
          const SizedBox(
            height: 15,
          ),
          Row(
            children: [
              UserAvatarView(
                user: widget.giftToUser!,
                size: 50,
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BodyLargeText(widget.giftToUser!.userName,
                      weight: TextWeight.medium),
                  BodySmallText(
                      '${widget.giftToUser!.city} ${widget.giftToUser!.country}',
                      weight: TextWeight.regular),
                ],
              )
            ],
          )
        ],
      ).p16,
    ).round(10).hP16;
  }

  Widget ticketType() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BodyLargeText(LocalizationString.ticketType,
                weight: TextWeight.semiBold)
            .hP16,
        const SizedBox(
          height: 25,
        ),
        SizedBox(
          height: 150,
          child: ListView.separated(
            padding: const EdgeInsets.only(left: 16, right: 16),
            scrollDirection: Axis.horizontal,
            itemCount: widget.event.tickets.length,
            itemBuilder: (context, index) {
              return Obx(() => ticketTypeWidget(
                          ticket: widget.event.tickets[index],
                          isSelected: _buyTicketController
                                  .selectedTicketType.value?.id ==
                              widget.event.tickets[index].id)
                      .ripple(() {
                    if (widget.event.tickets[index].availableTicket > 0) {
                      _buyTicketController
                          .selectTicketType(widget.event.tickets[index]);
                    }
                  }));
            },
            separatorBuilder: (context, index) {
              return const SizedBox(
                width: 20,
              );
            },
          ),
        )
      ],
    );
  }

  Widget ticketTypeWidget(
      {required EventTicketType ticket, required bool isSelected}) {
    return Container(
      color: AppColorConstants.cardColor,
      width: Get.width * 0.6,
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                      color: Theme.of(context)
                          .primaryColor
                          .darken()
                          .withOpacity(0.2),
                      child: Heading4Text(ticket.name,
                              weight: TextWeight.medium)
                          .setPadding(left: 16, right: 16, top: 4, bottom: 4))
                  .round(5),
              const SizedBox(
                height: 15,
              ),
              BodyLargeText('\$${ticket.price}', weight: TextWeight.bold),
              const SizedBox(
                height: 5,
              ),
              Row(
                children: [
                  Text(
                    LocalizationString.totalSeats,
                    style: TextStyle(
                        fontSize: FontSizes.b2,
                        fontWeight: TextWeight.medium,
                        color: AppColorConstants.themeColor),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  BodyLargeText('${ticket.limit}', weight: TextWeight.regular),
                ],
              ),
              const SizedBox(
                height: 5,
              ),
              Row(
                children: [
                  Text(
                    LocalizationString.availableSeats,
                    style: TextStyle(
                        fontSize: FontSizes.b2,
                        fontWeight: TextWeight.medium,
                        color: AppColorConstants.themeColor),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  BodyLargeText('${ticket.availableTicket}',
                      weight: TextWeight.regular),
                ],
              )
            ],
          ),
        ],
      ).p16,
    ).borderWithRadius(
        value: isSelected == true ? 2 : 1,
        radius: 20,
        color: isSelected == true ? AppColorConstants.themeColor : null);
  }

  Widget couponsList() {
    return Obx(() => _eventDetailController.coupons.isNotEmpty
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Heading5Text(LocalizationString.applyCoupon,
                      weight: TextWeight.medium)
                  .hP16,
              const SizedBox(
                height: 40,
              ),
              SizedBox(
                height: 150,
                child: ListView.separated(
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: _eventDetailController.coupons.length,
                  itemBuilder: (context, index) {
                    return Obx(() => couponWidget(
                                coupon: _eventDetailController.coupons[index],
                                isSelected: _buyTicketController
                                        .selectedCoupon.value?.id ==
                                    _eventDetailController.coupons[index].id)
                            .ripple(() {
                          if (_buyTicketController
                                  .selectedTicketType.value!.availableTicket >
                              0) {
                            _buyTicketController.selectEventCoupon(
                                _eventDetailController.coupons[index]);
                          }
                        }));
                  },
                  separatorBuilder: (context, index) {
                    return const SizedBox(
                      width: 20,
                    );
                  },
                ),
              )
            ],
          )
        : Container());
  }

  Widget couponWidget({required EventCoupon coupon, required bool isSelected}) {
    return Container(
      color: AppColorConstants.cardColor,
      width: Get.width * 0.7,
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Heading4Text('${LocalizationString.code} :',
                      weight: TextWeight.medium),
                  const SizedBox(
                    width: 5,
                  ),
                  Heading4Text(
                    coupon.code,
                    weight: TextWeight.medium,
                    color: AppColorConstants.themeColor,
                  ),
                ],
              ),
              divider(context: context, color: AppColorConstants.themeColor).vP8,
              Row(
                children: [
                  BodyMediumText('${LocalizationString.discount} :',
                      weight: TextWeight.medium),
                  const SizedBox(
                    width: 5,
                  ),
                  BodyMediumText(
                    '\$${coupon.discount}',
                    weight: TextWeight.medium,
                    color: AppColorConstants.themeColor,
                  ),
                ],
              ),
              const SizedBox(
                height: 5,
              ),
              Row(
                children: [
                  BodyMediumText('${LocalizationString.minimumOrderPrice} :',
                      weight: TextWeight.medium),
                  const SizedBox(
                    width: 5,
                  ),
                  BodyMediumText(
                    '\$${coupon.minimumOrderPrice}',
                    weight: TextWeight.medium,
                    color: AppColorConstants.themeColor,
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          // const ThemeIconWidget(ThemeIcon.checkMarkWithCircle, size: 28),
        ],
      ).p25,
    ).borderWithRadius(
        value: isSelected == true ? 4 : 1,
        radius: 20,
        color: isSelected == true ? AppColorConstants.themeColor : null);
  }

  Widget orderSummary() {
    return Container(
      color: AppColorConstants.cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Heading5Text(LocalizationString.orderSummary,
              weight: TextWeight.medium),
          const SizedBox(
            height: 10,
          ),
          divider(context: context).tP8,
          const SizedBox(
            height: 20,
          ),
          Row(
            children: [
              BodySmallText(LocalizationString.subTotal,
                  weight: TextWeight.regular),
              const Spacer(),
              BodySmallText(
                  '\$${_buyTicketController.selectedTicketType.value!.price * _buyTicketController.numberOfTickets.value}',
                  weight: TextWeight.medium),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              BodySmallText(LocalizationString.serviceFee,
                  weight: TextWeight.regular),
              const Spacer(),
              BodySmallText(
                  '\$${_settingsController.setting.value!.serviceFee}',
                  weight: TextWeight.medium),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          if (_buyTicketController.selectedCoupon.value != null)
            Row(
              children: [
                BodySmallText(
                  '${LocalizationString.couponCode} (${_buyTicketController.selectedCoupon.value!.code})',
                  weight: TextWeight.semiBold,
                  color: AppColorConstants.themeColor,
                ),
                const Spacer(),
                BodySmallText(
                    '-\$${_buyTicketController.selectedCoupon.value!.discount}',
                    weight: TextWeight.medium),
              ],
            ),
          const SizedBox(
            height: 25,
          ),
          divider(context: context),
          const SizedBox(
            height: 25,
          ),
          Row(
            children: [
              BodyLargeText(LocalizationString.total,
                  weight: TextWeight.regular),
              const Spacer(),
              BodyLargeText('\$${_buyTicketController.amountToBePaid}',
                  weight: TextWeight.medium),
            ],
          )
        ],
      ).p16,
    ).round(20);
  }

  Widget checkoutButton() {
    return Container(
      height: 50,
      color: AppColorConstants.themeColor,
      child: Center(
        child:
            Heading6Text(LocalizationString.checkout, weight: TextWeight.medium)
                .hP16,
      ),
    ).round(20).ripple(() {
      Get.to(() => EventCheckout(
            ticketOrder: _buyTicketController.ticketOrder,
          ));
    });
  }
}
