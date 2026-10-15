import 'dart:io';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/screens/login_sign_up/phone_login.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:foap/helper/imports/login_signup_imports.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../util/constant_util.dart';
import '../../util/shared_prefs.dart';

/// Returns the sha256 hash of [input] in hex notation.
String sha256ofString(String input) {
  final bytes = utf8.encode(input);
  final digest = sha256.convert(bytes);
  return digest.toString();
}

class SocialLogin extends StatefulWidget {
  final bool hidePhoneLogin;

  const SocialLogin({super.key, required this.hidePhoneLogin});

  @override
  State<SocialLogin> createState() => _SocialLoginState();
}

class _SocialLoginState extends State<SocialLogin> {
  final LoginController _loginController = Get.find();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>[
      'email',
    ],
  );

  @override
  void initState() {
    _googleSignIn.onCurrentUserChanged
        .listen((GoogleSignInAccount? account) {
      if (account != null) {
        _loginController.socialLogin('google', account.id,
            account.displayName ?? '', account.email);
        _googleSignIn.signOut();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        widget.hidePhoneLogin == false
            ? Container(
                height: 40,
                width: 40,
                color: AppColorConstants.themeColor.withValues(alpha: 0.2),
                child: Center(
                    child: Image.asset(
                  'assets/phone.png',
                  height: 20,
                  width: 20,
                  color: isDarkMode
                      ? Colors.white
                      : AppColorConstants.mainTextColor,
                ))).round(10).ripple(() {
                Get.offAll(() => const PhoneLoginScreen());
              })
            : Container(
                height: 40,
                width: 40,
                color: AppColorConstants.themeColor.withValues(alpha: 0.2),
                child: Center(
                    child: Image.asset(
                  'assets/email.png',
                  height: 20,
                  width: 20,
                  color: isDarkMode
                      ? Colors.white
                      : AppColorConstants.mainTextColor,
                ))).round(10).ripple(() {
                Get.offAll(() => const LoginScreen());
              }),
        Container(
            height: 40,
            width: 40,
            color: AppColorConstants.themeColor.withValues(alpha: 0.2),
            child: Center(
                child: Image.asset(
              'assets/google.png',
              height: 20,
              width: 20,
            ))).round(10).ripple(() {
          signInWithGoogle();
        }),
        if (Platform.isIOS)
          Container(
              height: 40,
              width: 40,
              color: AppColorConstants.themeColor.withValues(alpha: 0.2),
              child: Center(
                  child: Image.asset(
                'assets/apple.png',
                height: 20,
                width: 20,
                color: isDarkMode
                    ? Colors.white
                    : AppColorConstants.mainTextColor,
              ))).round(10).ripple(() {
            //signInWithGoogle();
            _handleAppleSignIn();
            // Get.to(() => const InstagramView());
          }),
        Container(
            height: 40,
            width: 40,
            color: AppColorConstants.themeColor.withValues(alpha: 0.2),
            child: Center(
                child: Image.asset(
              'assets/facebook.png',
              height: 20,
              width: 20,
            ))).round(10).ripple(() {
          fbSignInAction();
        }),
      ],
    );
  }

  void signInWithGoogle() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      AppUtil.showToast(message: errorMessageString.tr, isSuccess: false);
    }
  }

  void fbSignInAction() async {
    FocusScope.of(context).requestFocus(FocusNode());
    final facebookLogin = FacebookLogin();
    facebookLogin.logOut();
    final result = await facebookLogin.logIn(permissions: [
      FacebookPermission.publicProfile,
      FacebookPermission.email,
    ]);

    switch (result.status) {
      case FacebookLoginStatus.success:
        // Get profile data
        final profile = await facebookLogin.getUserProfile();
        String name = profile?.name ?? '';
        String socialId = profile?.userId ?? '';
        final email = await facebookLogin.getUserEmail();

        _loginController.socialLogin('fb', socialId, name, email!);

        break;
      case FacebookLoginStatus.cancel:
        AppUtil.showToast(
            message: cancelledByUserString.tr, isSuccess: false);
        break;
      case FacebookLoginStatus.error:
        AppUtil.showToast(
            message: result.error!.localizedDescription!,
            isSuccess: false);
        break;
    }
  }

  Future<void> _handleAppleSignIn() async {
    Loader.show(status: 'loading...');

    final rawNonce = generateNonce();
    final nonce = sha256ofString(rawNonce);

    // Request credential for the currently signed in Apple account.
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonce,
    );

    if (appleCredential.givenName != null) {
      SharedPrefs().setAppleIdName(
          forAppleId: '${appleCredential.userIdentifier}',
          email: appleCredential.givenName!);
    }
    if (appleCredential.email != null) {
      SharedPrefs().setAppleIdEmail(
          forAppleId: '${appleCredential.userIdentifier}',
          email: appleCredential.email!);
    }

    if (appleCredential.userIdentifier != null) {
      _loginController.socialLogin(
          'apple', appleCredential.userIdentifier!, '', '');
    }
  }
}
