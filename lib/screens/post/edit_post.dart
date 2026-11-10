import 'package:foap/helper/imports/models.dart';
import 'package:foap/screens/post/tag_hashtag_view.dart';
import 'package:foap/screens/post/tag_users_view.dart';
import 'package:foap/helper/imports/common_import.dart';
import '../../components/smart_text_field.dart';
import '../../controllers/post/add_post_controller.dart';

class EditPostScreen extends StatefulWidget {
  final PostModel post;

  const EditPostScreen({
    super.key,
    required this.post,
  });

  @override
  EditPostScreenState createState() => EditPostScreenState();
}

class EditPostScreenState extends State<EditPostScreen> {
  TextEditingController descriptionText = TextEditingController();
  final AddPostController addPostController = Get.find();
  final SmartTextFieldController _smartTextFieldController = Get.find();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _smartTextFieldController.textChanged(
          widget.post.postTitle, widget.post.postTitle.length);
      descriptionText.text = widget.post.postTitle;
      addPostController.enableComments.value = widget.post.commentsEnabled;
    });

    super.initState();
  }

  @override
  void dispose() {
    descriptionText.text = '';
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: GetBuilder<AddPostController>(
          init: addPostController,
          builder: (ctx) {
            return Stack(
              children: [
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(
                        height: 55,
                      ),
                      Row(
                        children: [
                          InkWell(
                              onTap: () {
                                Get.back();
                                addPostController.clear();
                              },
                              child: ThemeIconWidget(ThemeIcon.backArrow)),
                          Expanded(
                              child: Center(
                                  child: BodyLargeText('Edit post',
                                      weight: TextWeight.bold))),
                          Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: LinearGradient(colors: [
                                  AppColorConstants.themeColor,
                                  AppColorConstants.themeColor
                                      .withValues(alpha: 0.78)
                                ]),
                              ),
                              child: BodyLargeText(
                                updateString.tr,
                                weight: TextWeight.bold,
                                color: Colors.white,
                              ))
                              .ripple(() {
                            if (descriptionText.text.isNotEmpty) {
                              addPostController.updatePost(
                                  allowComments:
                                      addPostController.enableComments.value,
                                  title: descriptionText.text,
                                  postId: widget.post.id);
                            }
                          }),
                        ],
                      ).hp(DesignConstants.horizontalPadding),
                      const SizedBox(
                        height: 30,
                      ),
                      addDescriptionView()
                          .hp(DesignConstants.horizontalPadding),
                      const SizedBox(
                        height: 30,
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(
                            horizontal: DesignConstants.horizontalPadding),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: _cardDecoration(),
                        child: Row(
                          children: [
                            Container(
                              height: 34,
                              width: 34,
                              decoration: BoxDecoration(
                                  color: AppColorConstants.themeColor
                                      .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(11)),
                              child: Icon(Icons.chat_bubble_outline_rounded,
                                  size: 19,
                                  color: AppColorConstants.themeColor),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                                child: BodyMediumText(allowCommentsString.tr,
                                    weight: TextWeight.medium)),
                            Obx(() => Switch(
                                  value:
                                      addPostController.enableComments.value,
                                  activeColor: AppColorConstants.themeColor,
                                  onChanged: (_) => addPostController
                                      .toggleEnableComments(),
                                )),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Expanded(
                        child: Obx(() => Container(
                              width: double.infinity,
                              color: AppColorConstants.disabledColor
                                  .withValues(alpha: 0.1),
                              child: _smartTextFieldController
                                      .currentHashtag.isNotEmpty
                                  ? TagHashtagView()
                                  : _smartTextFieldController
                                          .currentUserTag.isNotEmpty
                                      ? TagUsersView()
                                      : Container().ripple(() {
                                          FocusManager.instance.primaryFocus
                                              ?.unfocus();
                                        }),
                            )),
                      ),
                      Obx(() => _smartTextFieldController.isEditing.value == 0
                          ? const Spacer()
                          : Container()),
                    ]),
              ],
            );
          }),
    );
  }

  BoxDecoration _cardDecoration() => BoxDecoration(
        color: AppColorConstants.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: AppColorConstants.dividerColor.withValues(alpha: 0.5),
            width: 0.6),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 5))
        ],
      );

  Widget addDescriptionView() {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(12),
      decoration: _cardDecoration(),
      child: Obx(() {
        descriptionText.value = TextEditingValue(
            text: _smartTextFieldController.searchText.value,
            selection: TextSelection.fromPosition(TextPosition(
                offset: _smartTextFieldController.position.value)));

        return Container(
          color: Colors.transparent,
          child: SmartTextField(
            maxLine: 5,
              controller: descriptionText,
              onTextChangeActionHandler: (text, offset) {
                _smartTextFieldController.textChanged(text, offset);
              },
              onFocusChangeActionHandler: (status) {
                if (status == true) {
                  _smartTextFieldController.startedEditing();
                } else {
                  _smartTextFieldController.stoppedEditing();
                }
              }),
        );
      }),
    );
  }
}
