import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/string_extension.dart';
import 'package:foap/screens/add_on/controller/dating/dating_controller.dart';

class DatingCard extends StatefulWidget {
  const DatingCard({super.key}) ;

  @override
  State<DatingCard> createState() => DatingCardState();
}

class DatingCardState extends State<DatingCard> {
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        children: [
          backNavigationBar(
            title: datingString.tr,
          ),
          const Expanded(child: CardsStackWidget()),
        ],
      ),
    );
  }
}

class CardsStackWidget extends StatefulWidget {
  const CardsStackWidget({super.key}) ;

  @override
  State<CardsStackWidget> createState() => _CardsStackWidgetState();
}

class _CardsStackWidgetState extends State<CardsStackWidget>
    with SingleTickerProviderStateMixin {
  final DatingController datingController = DatingController();

  ValueNotifier<Swipe> swipeNotifier = ValueNotifier(Swipe.none);
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    datingController.getDatingProfiles();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          datingController.datingUsers.removeLast();
        });
        _animationController.reset();
        swipeNotifier.value = Swipe.none;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => datingController.isLoading.value
        ? const CardsStackShimmerWidget()
        : datingController.datingUsers.isEmpty
            ? emptyData(
                title: noDatingProfilesFoundString.tr,
                subTitle: datingExploreString.tr,
              )
            : Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: 100,
                    child: ValueListenableBuilder(
                      valueListenable: swipeNotifier,
                      builder: (context, swipe, _) => Stack(
                        clipBehavior: Clip.none,
                        children: List.generate(
                            datingController.datingUsers.length, (index) {
                          if (index ==
                              datingController.datingUsers.length - 1) {
                            return PositionedTransition(
                              rect: RelativeRectTween(
                                begin: RelativeRect.fromSize(
                                    const Rect.fromLTWH(0, 0, 580, 340),
                                    const Size(580, 340)),
                                end: RelativeRect.fromSize(
                                    Rect.fromLTWH(
                                        swipe != Swipe.none
                                            ? swipe == Swipe.left
                                                ? -300
                                                : 300
                                            : 0,
                                        0,
                                        580,
                                        340),
                                    const Size(580, 340)),
                              ).animate(CurvedAnimation(
                                parent: _animationController,
                                curve: Curves.easeInOut,
                              )),
                              child: RotationTransition(
                                turns: Tween<double>(
                                        begin: 0,
                                        end: swipe != Swipe.none
                                            ? swipe == Swipe.left
                                                ? -0.1 * 0.3
                                                : 0.1 * 0.3
                                            : 0.0)
                                    .animate(
                                  CurvedAnimation(
                                    parent: _animationController,
                                    curve: const Interval(0, 0.4,
                                        curve: Curves.easeInOut),
                                  ),
                                ),
                                child: DragWidget(
                                  profile: datingController.datingUsers[index],
                                  index: index,
                                  swipeNotifier: swipeNotifier,
                                  isLastCard: true,
                                ),
                              ),
                            );
                          } else {
                            return DragWidget(
                              profile: datingController.datingUsers[index],
                              index: index,
                              swipeNotifier: swipeNotifier,
                            );
                          }
                        }),
                      ),
                    ).round(10),
                  ),
                  Positioned(
                    left: 0,
                    child: DragTarget<int>(
                      builder: (
                        BuildContext context,
                        List<dynamic> accepted,
                        List<dynamic> rejected,
                      ) {
                        return IgnorePointer(
                          child: Container(
                            height: 700,
                            width: 80.0,
                            color: Colors.transparent,
                          ),
                        );
                      },
                      onAccept: (int index) {
                        setState(() {
                          //dislike
                          datingController.likeUnlikeProfile(
                              DatingActions.rejected,
                              datingController.datingUsers[index].id
                                  .toString());
                          datingController.datingUsers.removeAt(index);
                        });
                      },
                    ),
                  ),
                  if (datingController.datingUsers.isNotEmpty)
                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ActionButtonWidget(
                            onPressed: () {
                              int index =
                                  datingController.datingUsers.length - 1;
                              datingController.likeUnlikeProfile(
                                  DatingActions.rejected,
                                  datingController.datingUsers[index].id
                                      .toString());
                              swipeNotifier.value = Swipe.right;
                              _animationController.forward();
                              swipeNotifier.value = Swipe.left;
                              _animationController.forward();
                            },
                            icon: const Icon(
                              Icons.close,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 20),
                          ActionButtonWidget(
                            onPressed: () {
                              //like
                              int index =
                                  datingController.datingUsers.length - 1;
                              datingController.likeUnlikeProfile(
                                  DatingActions.liked,
                                  datingController.datingUsers[index].id
                                      .toString());
                              swipeNotifier.value = Swipe.right;
                              _animationController.forward();
                            },
                            icon: const Icon(
                              Icons.favorite,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Positioned(
                    right: 0,
                    child: DragTarget<int>(
                      builder: (
                        BuildContext context,
                        List<dynamic> accepted,
                        List<dynamic> rejected,
                      ) {
                        return IgnorePointer(
                          child: Container(
                            height: 700,
                            width: 80.0,
                            color: Colors.transparent,
                          ),
                        );
                      },
                      onAccept: (int index) {
                        setState(() {
                          //like
                          datingController.likeUnlikeProfile(
                              DatingActions.liked,
                              datingController.datingUsers[index].id
                                  .toString());
                          datingController.datingUsers.removeAt(index);
                        });
                      },
                    ),
                  ),
                ],
              ));
  }
}

class DragWidget extends StatefulWidget {
  const DragWidget(
      {super.key,
      required this.profile,
      required this.index,
      required this.swipeNotifier,
      this.isLastCard = false})
      ;
  final UserModel profile;
  final int index;
  final ValueNotifier<Swipe> swipeNotifier;
  final bool isLastCard;

  @override
  State<DragWidget> createState() => _DragWidgetState();
}

class _DragWidgetState extends State<DragWidget> {
  ValueNotifier<Swipe> swipeNotifier = ValueNotifier(Swipe.none);

  @override
  Widget build(BuildContext context) {
    return Draggable<int>(
      // Data is the value this Draggable stores.
      data: widget.index,
      feedback: Material(
        color: Colors.transparent,
        child: ValueListenableBuilder(
          valueListenable: swipeNotifier,
          builder: (context, swipe, _) {
            return RotationTransition(
              turns: swipe != Swipe.none
                  ? swipe == Swipe.left
                      ? const AlwaysStoppedAnimation(-15 / 360)
                      : const AlwaysStoppedAnimation(15 / 360)
                  : const AlwaysStoppedAnimation(0),
              child: Stack(
                children: [
                  ProfileCard(profile: widget.profile),
                  swipe != Swipe.none
                      ? swipe == Swipe.right
                          ? Positioned(
                              top: 40,
                              left: 20,
                              child: Transform.rotate(
                                angle: 12,
                                child: TagWidget(
                                  text: likeString.tr.toLowerCase(),
                                  color: Colors.green[400]!,
                                ),
                              ),
                            )
                          : Positioned(
                              top: 50,
                              right: 24,
                              child: Transform.rotate(
                                angle: -12,
                                child: TagWidget(
                                  text: disLikeString.tr.toUpperCase(),
                                  color: Colors.red[400]!,
                                ),
                              ),
                            )
                      : const SizedBox.shrink(),
                ],
              ),
            );
          },
        ),
      ),
      onDragUpdate: (DragUpdateDetails dragUpdateDetails) {
        // When Draggable widget is dragged right
        if (dragUpdateDetails.delta.dx > 0 &&
            dragUpdateDetails.globalPosition.dx >
                Get.width / 2) {
          swipeNotifier.value = Swipe.right;
        }
        // When Draggable widget is dragged left
        if (dragUpdateDetails.delta.dx < 0 &&
            dragUpdateDetails.globalPosition.dx <
                Get.width / 2) {
          swipeNotifier.value = Swipe.left;
        }
      },
      onDragEnd: (drag) {
        swipeNotifier.value = Swipe.none;
      },

      childWhenDragging: Container(
        color: Colors.transparent,
      ),

      child: ValueListenableBuilder(
          valueListenable: widget.swipeNotifier,
          builder: (BuildContext context, Swipe swipe, Widget? child) {
            return Stack(
              children: [
                ProfileCard(profile: widget.profile),
                // heck if this is the last card and Swipe is not equal to Swipe.none
                swipe != Swipe.none && widget.isLastCard
                    ? swipe == Swipe.right
                        ? Positioned(
                            top: 40,
                            left: 20,
                            child: Transform.rotate(
                              angle: 12,
                              child: TagWidget(
                                text: likeString.tr.toUpperCase(),
                                color: Colors.green[400]!,
                              ),
                            ),
                          )
                        : Positioned(
                            top: 50,
                            right: 24,
                            child: Transform.rotate(
                              angle: -12,
                              child: TagWidget(
                                text: disLikeString.tr.toUpperCase(),
                                color: Colors.red[400]!,
                              ),
                            ),
                          )
                    : const SizedBox.shrink(),
              ],
            );
          }),
    ).setPadding(top: 15);
  }
}

class TagWidget extends StatelessWidget {
  const TagWidget({
    super.key,
    required this.text,
    required this.color,
  }) ;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: color,
            width: 4,
          ),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 36,
        ),
      ),
    );
  }
}

class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key, required this.profile}) ;
  final UserModel profile;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Get.height - 270,
      width: Get.width - 40,
      child: Stack(
        children: [
          Positioned.fill(
            child: profile.picture != null
                ? CachedNetworkImage(
                    imageUrl: profile.picture!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => SizedBox(
                        height: 20,
                        width: 20,
                        child: const CircularProgressIndicator().p16),
                    errorWidget: (context, url, error) => const SizedBox(
                        child: Icon(
                      Icons.error,
                      // size: size / 2,
                    )),
                  ).round(10)
                : Image.asset(
                    'assets/images/avatar_1.jpg',
                    fit: BoxFit.cover,
                  ).round(10),
          ),
          Positioned(
            bottom: 0,
            child: Container(
              height: 80,
              width: Get.width - 40,
              decoration: ShapeDecoration(
                color: AppColorConstants.cardColor.darken(),
                shape: const RoundedRectangleBorder(
                    // borderRadius: BorderRadius.circular(10),
                    ),
                shadows: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Heading4Text(
                        profile.name == null
                            ? profile.userName
                            : profile.name ?? '',
                        color: AppColorConstants.mainTextColor,
                        weight: TextWeight.semiBold,
                        maxLines: 1,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      BodyLargeText(
                        ', ${profile.dob!.calculateAge} ${yearString.tr}',
                        color: AppColorConstants.themeColor,
                        weight: TextWeight.semiBold,
                      ),
                    ],
                  ),
                  if (profile.city != null)
                    BodyMediumText(
                      profile.city!,
                      color: AppColorConstants.subHeadingTextColor,
                    ),
                  BodySmallText(
                    profile.genderType == GenderType.female
                        ? femaleString.tr
                        : profile.genderType == GenderType.other
                            ? otherString.tr
                            : maleString.tr,
                    color: AppColorConstants.subHeadingTextColor,
                  ),
                ],
              ).setPadding(left: 20),
            ),
          ),
        ],
      ),
    ).setPadding(left: 20, right: 20);
  }
}

class ActionButtonWidget extends StatelessWidget {
  const ActionButtonWidget(
      {super.key, required this.onPressed, required this.icon})
      ;
  final VoidCallback onPressed;
  final Icon icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      shape: const CircleBorder(),
      child: Card(
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(35.0),
        ),
        child: IconButton(onPressed: onPressed, icon: icon),
      ),
    );
  }
}

enum Swipe { left, right, none }
