import '../../../controllers/post/add_post_controller.dart';
import '../../../helper/imports/common_import.dart';

class ProductCreatedSuccess extends StatelessWidget {
  final int productId;
  final AddPostController addPostController = Get.find();

  ProductCreatedSuccess({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BodyLargeText(productAddedSuccessfullyString.tr),
          const SizedBox(
            height: 40,
          ),
          AppThemeButton(
              text: shareToFeedString.tr,
              onPress: () {
                addPostController.shareToFeed(
                    productId: productId,
                    contentType: PostContentType.classified);
              }),
          const SizedBox(
            height: 20,
          ),
          AppThemeBorderButton(
              text: addMoreProductsString.tr,
              onPress: () {
                Get.close(6);
              })
        ],
      ).hp(DesignConstants.horizontalPadding),
    );
  }
}
