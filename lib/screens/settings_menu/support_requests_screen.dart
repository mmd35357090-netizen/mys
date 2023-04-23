import 'package:foap/screens/settings_menu/help_support_contorller.dart';
import 'package:foap/screens/settings_menu/support_request_view.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../../helper/common_import.dart';

class SupportRequestsScreen extends StatefulWidget {
  const SupportRequestsScreen({Key? key}) : super(key: key);

  @override
  State<SupportRequestsScreen> createState() => _SupportRequestsScreenState();
}

class _SupportRequestsScreenState extends State<SupportRequestsScreen> {

  HelpSupportController helpSupportController = Get.find();

  @override
  void initState() {
    helpSupportController.getSupportRequests();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Column(
        children: [
          const SizedBox(
            height: 50,
          ),
          backNavigationBar(context:context, title:LocalizationString.supportRequests),
          divider(context: context).tP8,
          Expanded(
              child: Obx(()=>ListView.builder(
                    padding: const EdgeInsets.only(bottom: 50),
                    itemCount: helpSupportController.list.length,
                    itemBuilder: (ctx, index) {
                      final item = helpSupportController.list[index];
                      return ListTile(title: Text(item.requestMessage.toString(), style: Theme.of(context).textTheme.bodyLarge)).ripple((){
                        Get.to(()=>const SupportRequestView(),arguments: item);
                      });
                    }),
              ),
              ),

        ],
      ),
    );

  }
}
