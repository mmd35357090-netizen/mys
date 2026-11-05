import 'package:foap/helper/imports/common_import.dart';

import '../controllers/misc/subscription_packages_controller.dart';
import '../model/package_model.dart';

class PackageTile extends StatelessWidget {
  final PackageModel package;
  final int index;
  final SubscriptionPackageController packageController = Get.find();
  final VoidCallback buyPackageHandler;

  /// Price as Google Play shows it (local currency); falls back to the server price.
  final String? storePrice;

  PackageTile(
      {super.key,
      required this.package,
      required this.index,
      this.storePrice,
      required this.buyPackageHandler})
      ;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Heading6Text(package.name,
                weight: TextWeight.semiBold, color: AppColorConstants.themeColor),
            const SizedBox(
              height: 5,
            ),
            BodySmallText(
              '${package.coin} ${coinsString.tr}',
              weight: TextWeight.medium,
            ),
          ],
        ),
        const Spacer(),
        BodyLargeText(
          (storePrice != null && storePrice!.isNotEmpty)
              ? '${buyInString.tr} $storePrice'
              : '${buyInString.tr} \$${package.price}',
          weight: TextWeight.semiBold,
        )
        // SizedBox(
        //   height: 40,
        //   width: 110,
        //   child: AppThemeBorderButton(
        //     text:,
        //     onPress: () {
        //
        //     },
        //   ),
        // )
      ],
    ).ripple(() {
      buyPackageHandler();
    });
  }
}
