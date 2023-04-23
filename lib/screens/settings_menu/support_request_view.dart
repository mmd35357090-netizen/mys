import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../helper/common_import.dart';
import '../../model/support_request_response.dart';

class SupportRequestView extends StatefulWidget {
  const SupportRequestView({Key? key}) : super(key: key);

  @override
  State<SupportRequestView> createState() => _SupportRequestViewState();
}

class _SupportRequestViewState extends State<SupportRequestView> {

  final item = Get.arguments as Items;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 50,
            ),
            backNavigationBar(context: context, title: LocalizationString.supportRequests),
            divider(context: context).tP8,
            SingleChildScrollView(
              child: GestureDetector(
                onTap: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.02,
                    ),
                    const Text('Your Message'),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.015,
                    ),
                    InputField(
                      maxLines: 12,
                      isEnable: false,
                      isDisabled: true,
                      showBorder: true,
                      showDivider: false,
                      textStyle: Theme.of(context).textTheme.titleSmall,
                      hintText: item.requestMessage,
                      cornerRadius: 5,
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.025,
                    ),
                    const Text('Admin Message'),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.015,
                    ),
                    InputField(
                      isEnable: false,
                      isDisabled: true,
                      maxLines: 12,
                      showBorder: true,
                      showDivider: false,
                      textStyle: Theme.of(context).textTheme.titleSmall,
                      hintText: item.replyMessage!=null?item.replyMessage:'',
                      cornerRadius: 5,
                    ),
                  ],
                ).extended,
              ),
            ).p25
          ],
        ),
      ),
    );
  }
}
