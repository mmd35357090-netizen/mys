import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/setting_imports.dart';
import 'package:foap/screens/wallet/coin_history.dart';
import '../../universal_components/menu_tiles.dart';
import '../profile/change_paypal_id.dart';
import '../../api_handler/apis/payout_api.dart';

class PaymentAndCoins extends StatefulWidget {
  const PaymentAndCoins({super.key});

  @override
  State<PaymentAndCoins> createState() => _PaymentAndCoinsState();
}

class _PaymentAndCoinsState extends State<PaymentAndCoins> {
  final SettingsController settingsController = Get.find();
  final UserProfileManager _userProfileManager = Get.find();

  int coin = 0;
  String _accountText = 'PayPal, bKash, Nagad, USDT, Binance';

  // shows only the masked default account (never the full email / number)
  Future<void> _loadAccount() async {
    final o = await PayoutApi.overview();
    if (!mounted || o == null) return;
    final defs = o.methods.where((m) => m.isDefault).toList();
    if (defs.isNotEmpty) {
      setState(() => _accountText = '${defs.first.label} • ${defs.first.accountMasked}');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadAccount();
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
                    icon: Icons.account_balance_wallet_outlined,
                    color: const Color(0xFF10B981),
                    title: 'Payment account',
                    subtitle: _accountText,
                    onTap: () async {
                      await Get.to(() => const ChangePaypalId());
                      _loadAccount();
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
