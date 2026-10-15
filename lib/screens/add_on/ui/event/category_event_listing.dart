import 'package:foap/helper/imports/event_imports.dart';
import 'package:foap/helper/imports/common_import.dart';
import '../../components/event/events_list.dart';

class CategoryEventsListing extends StatefulWidget {
  final EventCategoryModel category;

  const CategoryEventsListing({super.key, required this.category});

  @override
  CategoryEventsListingState createState() => CategoryEventsListingState();
}

class CategoryEventsListingState extends State<CategoryEventsListing> {
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
          backNavigationBar(
            title: widget.category.name,
          ),
          Expanded(
            child: EventsList(),
          ),
        ],
      ),
    );
  }
}
