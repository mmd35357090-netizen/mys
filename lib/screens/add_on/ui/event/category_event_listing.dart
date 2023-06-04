import 'package:foap/components/top_navigation_bar.dart';
import 'package:foap/util/app_config_constants.dart';
import 'package:foap/helper/imports/event_imports.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../components/event/events_list.dart';

class CategoryEventsListing extends StatefulWidget {
  final EventCategoryModel category;

  const CategoryEventsListing({Key? key, required this.category})
      : super(key: key);

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
    return Scaffold(
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
