import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/setting_imports.dart';
import 'package:foap/screens/wallet/coin_history.dart';
import 'package:foap/screens/wallet/creator_dashboard.dart';
import 'package:foap/screens/wallet/creator_earnings.dart';
import '../../universal_components/menu_tiles.dart';

class PaymentAndCoins extends StatefulWidget {
  const PaymentAndCoins({super.key});

  @override
  State<PaymentAndCoins> createState() => _PaymentAndCoinsState();
}

class _PaymentAndCoinsState extends State<PaymentAndCoins> {
  final SettingsController settingsController = Get.find();
  final UserProfileManager _userProfileManager = Get.find();

  int coin = 0;

  @override
  void initState() {
    super.initState();
    coin = _userProfileManager.user.value!.coins;
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        children: [
          backNavigationBar(title: paymentAndCoinsString.tr),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(DesignConstants.horizontalPadding,
                  16, DesignConstants.horizontalPadding, 40),
              children: [
                MenuSection(tiles: [
                  MenuTile(
                    icon: Icons.monetization_on_outlined,
                    color: const Color(0xFFF59E0B),
                    title: '${coinsString.tr} ($coin)',
                    subtitle: 'Buy coin packages',
                    onTap: () {
                      Get.to(() => const PackagesScreen());
                    },
                  ),
                  MenuTile(
                    icon: Icons.history_rounded,
                    color: const Color(0xFF3B82F6),
                    title: coinHistoryString.tr,
                    onTap: () {
                      Get.to(() => const CoinHistoryScreen());
                    },
                  ),
                ]),
                const SizedBox(height: 16),
                MenuSection(tiles: [
                  MenuTile(
                    icon: Icons.insights_rounded,
                    color: const Color(0xFF8B5CF6),
                    title: 'Creator dashboard',
                    subtitle: 'Earnings, gifts and ad revenue',
                    onTap: () {
                      Get.to(() => const CreatorDashboardScreen());
                    },
                  ),
                  MenuTile(
                    icon: Icons.ads_click_rounded,
                    color: const Color(0xFF10B981),
                    title: 'Ad earnings',
                    subtitle: 'Your share of ad revenue',
                    onTap: () {
                      Get.to(() => const CreatorEarningsScreen());
                    },
                  ),
                ]),
                const SizedBox(height: 16),
                MenuSection(tiles: [
                  MenuTile(
                    icon: Icons.receipt_long_outlined,
                    color: const Color(0xFF64748B),
                    title: transactionHistoryString.tr,
                    onTap: () {
                      Get.to(() => const Transactions());
                    },
                  ),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
