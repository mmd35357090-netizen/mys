/// True when the app is built for Google Play:
///   flutter build appbundle --dart-define=PLAY_STORE=true
/// In that build digital features (post boost) are paid with coins only.
/// The normal build (APK / website) keeps the USD wallet, Stripe and manual deposit.
const bool kPlayStoreBuild = bool.fromEnvironment('PLAY_STORE', defaultValue: false);
