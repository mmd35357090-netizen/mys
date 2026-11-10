import 'package:foap/helper/imports/common_import.dart';
import '../../controllers/misc/faq_controller.dart';

class FaqList extends StatefulWidget {
  const FaqList({super.key});

  @override
  State<FaqList> createState() => _FaqListState();
}

class _FaqListState extends State<FaqList> {
  final FAQController _faqController = FAQController();

  @override
  void initState() {
    _faqController.loadFAQs();
    super.initState();
  }

  @override
  void dispose() {
    // _faqController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        children: [
          backNavigationBar(title: faqString.tr),

          Expanded(
              child: Obx(
            () => ListView.builder(
                padding: EdgeInsets.fromLTRB(DesignConstants.horizontalPadding,
                    12, DesignConstants.horizontalPadding, 50),
                itemCount: _faqController.faqs.length,
                itemBuilder: (ctx, index) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: AppColorConstants.cardColor,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                          color: AppColorConstants.dividerColor
                              .withValues(alpha: 0.5),
                          width: 0.6),
                    ),
                    child: Theme(
                      data: Theme.of(context)
                          .copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        tilePadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 2),
                        childrenPadding:
                            const EdgeInsets.fromLTRB(16, 0, 16, 14),
                        expandedCrossAxisAlignment: CrossAxisAlignment.start,
                        iconColor: AppColorConstants.themeColor,
                        title: BodyLargeText(
                          _faqController.faqs[index].question,
                          weight: TextWeight.semiBold,
                        ),
                        children: <Widget>[
                          BodyLargeText(
                            _faqController.faqs[index].answer,
                            color: AppColorConstants.subHeadingTextColor,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
          ))
        ],
      ),
    );
  }
}
