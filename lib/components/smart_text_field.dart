import 'package:foap/helper/list_extension.dart';
import 'package:foap/model/data_wrapper.dart';
import '../api_handler/apis/misc_api.dart';
import '../controllers/misc/users_controller.dart';
import '../helper/imports/common_import.dart';
import '../model/hash_tag.dart';

class SmartTextFieldController extends GetxController {
  Rx<TextEditingController> textField = TextEditingController().obs;

  RxInt isEditing = 0.obs;
  RxString currentHashtag = ''.obs;
  RxString currentUserTag = ''.obs;
  RxString searchText = ''.obs;
  RxInt position = 0.obs;
  RxList<Hashtag> hashTags = <Hashtag>[].obs;
  DataWrapper hashtagDataWrapper = DataWrapper();
  final UsersController _usersController = Get.find();

  clear() {
    isEditing.value = 0;
    currentHashtag.value = '';
    currentUserTag.value = '';
    hashTags.clear();

    searchText.value = '';
    position.value = 0;

    hashtagDataWrapper = DataWrapper();
    _usersController.clear();
    update();
  }

  startedEditing() {
    isEditing.value = 1;
    update();
  }

  stoppedEditing() {
    isEditing.value = 0;
    update();
  }

  textChanged(String text, int position) {
    clear();
    isEditing.value = 1;

    String value = textField.value.text;

    int cursorPosition = textField.value.selection.baseOffset;

    // Find the start and end of the current word
    int wordStart = value.lastIndexOf(' ', cursorPosition - 1) + 1;
    int wordEnd = value.indexOf(' ', cursorPosition);

    // If the cursor is at the end, set the wordEnd to the end of the string
    if (wordEnd == -1) {
      wordEnd = value.length;
    }

    // Extract the current word
    String currentWord = value.substring(wordStart, wordEnd);

    // Check if the current word starts with a hashtag
    bool isTypingHashtag = currentWord.startsWith('#');
    bool isTypingMention = currentWord.startsWith('@');

    if (isTypingHashtag) {
      currentHashtag.value = currentWord;
      hashTags.clear();
      searchHashTags(text: currentWord);
    } else {
      currentHashtag.value = '';
      hashTags.clear();
    }

    if (isTypingMention) {
      _usersController.clear();
      currentUserTag.value = currentWord;
      _usersController.setSearchTextFilter(
          currentWord.replaceAll('@', ''), () {});
    } else {
      currentUserTag.value = '';
      _usersController.clear();
    }
  }

  searchHashTags({required String text, VoidCallback? callBackHandler}) {
    if (hashtagDataWrapper.haveMoreData.value) {
      hashtagDataWrapper.isLoading.value = true;

      MiscApi.searchHashtag(
          page: hashtagDataWrapper.page,
          hashtag: text.replaceAll('#', ''),
          resultCallback: (result, metadata) {
            hashTags.addAll(result);
            hashTags.unique((e) => e.name);

            hashtagDataWrapper.processCompletedWithData(metadata);

            update();
            if (callBackHandler != null) {
              callBackHandler();
            }
          });
    } else {
      if (callBackHandler != null) {
        callBackHandler();
      }
    }
  }

  addUserTag(String user) {
    replaceTextInString(user, false);
  }

  addHashTag(String hashtag) {
    replaceTextInString(hashtag, true);
  }

  replaceTextInString(String text, bool isHashtag) {
    String currentText = textField.value.text;

    // Find the position of the last '#' before the cursor
    int cursorPosition = textField.value.selection.baseOffset;
    int index = isHashtag
        ? currentText.lastIndexOf('#', cursorPosition - 1)
        : currentText.lastIndexOf('@', cursorPosition - 1);

    // Find the end position of the current hashtag (i.e., space or end of the string)
    int endIndex = currentText.indexOf(' ', index);

    // If endIndex is -1, it means the current hashtag is at the end of the string
    endIndex = endIndex == -1 ? currentText.length : endIndex;

    // Replace the incomplete hashtag with the selected hashtag
    String newText = '';
    if (isHashtag) {
      newText =
      '${currentText.substring(0, index)}#$text${currentText.substring(endIndex)}';
    } else {
      newText =
      '${currentText.substring(0, index)}@$text${currentText.substring(endIndex)}';
    }
    // Update the text field
    textField.value.text = newText;

    // Set the cursor position after the replaced hashtag
    textField.value.selection =
        TextSelection.collapsed(offset: index + text.length + 1);

    currentHashtag.value = '';
    currentUserTag.value = '';

    update();
  }
}

class SmartTextField extends StatelessWidget {
  final int? maxLine;
  final TextEditingController controller;
  final Function(String, int) onTextChangeActionHandler;
  final Function(bool) onFocusChangeActionHandler;
  final int? maxChar;

  const SmartTextField(
      {Key? key,
        required this.controller,
        this.maxLine,
        this.maxChar,
        required this.onTextChangeActionHandler,
        required this.onFocusChangeActionHandler})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Focus(
      child: TextField(
        controller: controller,
        textAlign: TextAlign.left,
        maxLength: maxChar,
        style: TextStyle(
            fontSize: FontSizes.b3, color: AppColorConstants.mainTextColor),
        maxLines: maxLine ?? 1,
        onChanged: (text) {
          onTextChangeActionHandler(text, controller.selection.baseOffset);
        },
        decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: const EdgeInsets.only(top: 10, left: 10, right: 10),
            counterText: "",
            hintStyle: TextStyle(
                fontSize: FontSizes.b3, color: AppColorConstants.mainTextColor),
            hintText: titleString.tr),
      ).round(10),
      onFocusChange: (hasFocus) {
        onFocusChangeActionHandler(hasFocus);
      },
    );
  }
}
