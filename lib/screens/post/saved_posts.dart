import 'package:foap/screens/reuseable_widgets/post_list.dart';
import '../../helper/imports/common_import.dart';
import 'package:foap/controllers/post/saved_post_controller.dart';

class SavedPosts extends StatefulWidget {
  const SavedPosts({super.key});

  @override
  State<SavedPosts> createState() => _SavedPostsState();
}

class _SavedPostsState extends State<SavedPosts> {
  final SavedPostController _postController = Get.find();

  @override
  void initState() {
    _postController.getPosts(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        children: [
          backNavigationBar(title: savedPostsString),
          Expanded(
            child: PostList(
              postSource: TimelineType.saved,
            ),
          ),
        ],
      ),
    );
  }
}
