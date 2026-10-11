
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:foap/helper/imports/common_import.dart';
import '../../components/search_bar.dart';
import '../../components/sm_tab_bar.dart';
import '../../controllers/misc/explore_controller.dart';
import '../../controllers/post/post_controller.dart';
import '../../segmentAndMenu/horizontal_menu.dart';
import '../home_feed/quick_links.dart';
import '../reuseable_widgets/club_listing.dart';
import '../reuseable_widgets/hashtags.dart';
import '../reuseable_widgets/post_list.dart';
import '../reuseable_widgets/users_list.dart';
import '../marketplace/marketplace_screen.dart';

class Explore extends StatefulWidget {
  const Explore({Key? key}) : super(key: key);

  @override
  State<Explore> createState() => _ExploreState();
}

class _ExploreState extends State<Explore> {
  final ExploreController exploreController = ExploreController();
  final PostController postController = Get.find();

  List<String> segments = [
    postsString.tr,
    accountString.tr,
    hashTagsString.tr,
    clubsString.tr,
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(covariant Explore oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    exploreController.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      top: false,
      bottom: false,
      child: Scaffold(
        backgroundColor: AppColorConstants.backgroundColor,
        body: KeyboardDismissOnTap(
          child: Column(
            children: [
              const SizedBox(height: 40),
              Row(
                children: [
                  Expanded(
                    child: SFSearchBar(
                      showSearchIcon: true,
                      iconColor: AppColorConstants.themeColor,
                      onSearchChanged: (value) {
                        exploreController.searchTextChanged(value);
                      },
                      onSearchStarted: () {
                        // Existing search behavior retained.
                      },
                      onSearchCompleted: (searchTerm) {},
                    ),
                  ),
                  Obx(
                    () => exploreController.searchText.isNotEmpty
                        ? Row(
                            children: [
                              const SizedBox(width: 10),
                              Container(
                                height: 50,
                                width: 50,
                                color: AppColorConstants.themeColor,
                                child: ThemeIconWidget(
                                  ThemeIcon.close,
                                  color:
                                      AppColorConstants.backgroundColor,
                                  size: 25,
                                ),
                              ).round(20).ripple(() {
                                exploreController.closeSearch();
                              }),
                            ],
                          )
                        : Container(),
                  ),
                ],
              ).setPadding(
                left: DesignConstants.horizontalPadding,
                right: DesignConstants.horizontalPadding,
                top: 25,
              ),

              Expanded(
                child: DefaultTabController(
                  length: segments.length,
                  child: Obx(
                    () => exploreController.searchText.isNotEmpty
                        ? Column(
                            children: [
                              SMTabBar(
                                tabs: segments,
                                canScroll: true,
                              ),
                              Expanded(
                                child: TabBarView(
                                  children: [
                                    PostList(
                                      postSource: PostSource.posts,
                                    ),
                                    UsersList(),
                                    HashTagsList(),
                                    ClubListing(),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              // Marketplace button appears only
                              // when Explore search is empty.
                              Padding(
                                padding: EdgeInsets.only(
                                  left: DesignConstants.horizontalPadding,
                                  right: DesignConstants.horizontalPadding,
                                  top: 12,
                                  bottom: 4,
                                ),
                                child: Material(
                                  color: AppColorConstants.cardColor,
                                  borderRadius: BorderRadius.circular(16),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(16),
                                    onTap: () {
                                      Get.to(
                                        () => const MarketplaceScreen(),
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 14,
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.storefront_rounded,
                                            size: 32,
                                            color:
                                                AppColorConstants.themeColor,
                                          ),
                                          const SizedBox(width: 14),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Marketplace',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                    color: colorScheme
                                                        .onSurface,
                                                  ),
                                                ),
                                                const SizedBox(height: 3),
                                                Text(
                                                  'Shop products online',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: colorScheme
                                                        .onSurfaceVariant,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Icon(
                                            Icons.arrow_forward_ios_rounded,
                                            size: 18,
                                            color:
                                                AppColorConstants.themeColor,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // Existing Explore quick links retained.
                              Expanded(
                                child: QuickLinkWidget(
                                  callback: () {},
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget segmentView() {
    return HorizontalSegmentBar(
      width: Get.width,
      onSegmentChange: (segment) {
        exploreController.segmentChanged(segment);
      },
      segments: [
        topString.tr,
        accountString.tr,
        hashTagsString.tr,
        // locations,
      ],
    );
  }
}
