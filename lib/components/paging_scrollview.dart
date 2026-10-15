import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../helper/imports/common_import.dart';

//ignore: must_be_immutable
class PagingScrollView extends StatelessWidget {
  final Widget child;
  final Function(RefreshController) loadMoreCallback;
  RefreshController refreshController =
      RefreshController(initialRefresh: false);

  PagingScrollView(
      {super.key, required this.child, required this.loadMoreCallback})
      ;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: child,
    ).addPullToRefresh(
      refreshController: refreshController,
      onRefresh: () {},
      onLoading: () {
        loadMoreCallback(refreshController);
      },
      enablePullUp: true,
      enablePullDown: false,
    );
  }
}
