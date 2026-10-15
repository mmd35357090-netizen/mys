import 'package:foap/helper/imports/common_import.dart';
import '../../components/sm_tab_bar.dart';
import '../../controllers/misc/explore_controller.dart';
import '../../controllers/post/post_controller.dart';
import '../../segmentAndMenu/horizontal_menu.dart';
import '../add_on/components/event/events_list.dart';
import '../home_feed/quick_links.dart';
import '../reuseable_widgets/club_listing.dart';
import '../reuseable_widgets/hashtags.dart';
import '../reuseable_widgets/post_list.dart';
import '../reuseable_widgets/users_list.dart';

class Explore extends StatefulWidget {
  const Explore({super.key});

  @override
  State<Explore> createState() => _ExploreState();
}

class _ExploreState extends State<Explore> {
  final ExploreController exploreController = ExploreController();
  final PostController postController = Get.find();

  List<String> segments = [
    postsString,
    accountString,
    hashTagsString,
    eventsString,
    clubsString,
  ];

  @override
  void initState() {
    exploreController.defaultData();
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
    return SafeArea(
      top: false,
      bottom: false,
      child: AppScaffold(
        backgroundColor: AppColorConstants.backgroundColor,
        body: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: Column(
              children: [
                const SizedBox(
                  height: 40,
                ),
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
                            //controller.startSearch();
                          },
                          onSearchCompleted: (searchTerm) {}),
                    ),
                  ],
                ).setPadding(
                    left: DesignConstants.horizontalPadding,
                    right: DesignConstants.horizontalPadding,
                    top: 25),
                Expanded(
                    child: DefaultTabController(
                        length: segments.length,
                        child: Obx(() => exploreController.searchText.isNotEmpty
                            ? Column(
                                children: [
                                  SMTabBar(tabs: segments, canScroll: true),
                                  Expanded(
                                    child: TabBarView(children: [
                                      PostList(
                                        postSource: TimelineType.posts,
                                      ),
                                      UsersList(),
                                      HashTagsList(),
                                      EventsList(),
                                      ClubListing(),
                                    ]),
                                  )
                                ],
                              )
                            : QuickLinkWidget(
                                callback: () {},
                              )))),
              ],
            )),
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
        ]);
  }
}
