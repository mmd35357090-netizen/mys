import 'package:foap/helper/imports/event_imports.dart';
import '../../components/event/events_list.dart';
import 'package:foap/helper/imports/common_import.dart';

class SearchEventListing extends StatefulWidget {
  const SearchEventListing({super.key}) ;

  @override
  SearchEventListingState createState() => SearchEventListingState();
}

class SearchEventListingState extends State<SearchEventListing> {
  final EventsController _eventsController = Get.find();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _eventsController.clear();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        children: [
          const SizedBox(
            height: 40,
          ),
          Row(
            children: [
              ThemeIconWidget(
                ThemeIcon.backArrow,
                size: 25,
              ).ripple(() {
                Get.back();
              }),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: SFSearchBar(
                    hintText: searchString.tr,
                    showSearchIcon: true,
                    iconColor: AppColorConstants.themeColor,
                    onSearchChanged: (value) {
                      _eventsController.searchEvents(value);
                    },
                    onSearchStarted: () {},
                    onSearchCompleted: (searchTerm) {}),
              ),
            ],
          ).setPadding(left: DesignConstants.horizontalPadding, right: DesignConstants.horizontalPadding, top: 25, bottom: 20),
          divider().tP8,
          Expanded(
            child: EventsList(),
          ),
        ],
      ),
    );
  }
}
