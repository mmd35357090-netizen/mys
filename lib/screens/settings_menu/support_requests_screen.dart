import 'package:foap/screens/settings_menu/help_support_contorller.dart';
import 'package:foap/screens/settings_menu/support_request_view.dart';

import 'package:foap/helper/imports/common_import.dart';

class SupportRequestsScreen extends StatefulWidget {
  const SupportRequestsScreen({super.key});

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

  String _subjectLabel(String key) {
    const m = {
      'account': 'Account & login',
      'payment': 'Payment, wallet & coins',
      'deposit': 'Deposit / withdraw',
      'subscription': 'Subscription & VIP',
      'event': 'Events & tickets',
      'dating': 'Dating',
      'chat_call': 'Chat & calls',
      'content': 'Posts, reels & stories',
      'report': 'Report a user or content',
      'bug': 'App problem / bug',
      'suggestion': 'Suggestion',
      'other': 'Other',
    };
    return m[key] ?? key;
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        children: [

          backNavigationBar(
               title: supportRequestsString.tr),

          Expanded(
            child: Obx(
              () => ListView.builder(
                  padding: const EdgeInsets.only(bottom: 50),
                  itemCount: helpSupportController.list.length,
                  itemBuilder: (ctx, index) {
                    final item = helpSupportController.list[index];
                    return ListTile(
                        title: BodyLargeText(
                          item.requestMessage.toString(),
                        ),
                        subtitle: Row(children: [
                          if ((item.subject ?? '').isNotEmpty)
                            Text(_subjectLabel(item.subject!),
                                style: const TextStyle(fontSize: 12, color: Colors.black54)),
                          if ((item.priority ?? 0) == 1) ...[
                            const SizedBox(width: 8),
                            const Icon(Icons.workspace_premium_rounded,
                                size: 14, color: Color(0xFFE0A100)),
                            const Text(' VIP priority',
                                style: TextStyle(fontSize: 12, color: Color(0xFFB07F00))),
                          ],
                        ])).ripple(() {
                      Get.to(() => const SupportRequestView(), arguments: item);
                    });
                  }),
            ),
          ),
        ],
      ),
    );
  }
}
