import 'dart:convert';
import 'package:aescryptojs/aescryptojs.dart';
import 'package:intl/intl.dart';
import 'imports/common_import.dart';

extension StringExtension on String {
  DateTime toDateInFormat(String format) {
    return DateFormat(format).parse(this);
  }

  bool get isValidUrl {
    String pattern =
        r'(http|https)://[\w-]+(\.[\w-]+)+([\w.,@?^=%&amp;:/~+#-]*[\w@?^=%&amp;/~+#-])?';
    RegExp regExp = RegExp(pattern);
    if (isEmpty) {
      return false;
    } else if (!regExp.hasMatch(this)) {
      return false;
    }
    return true;
  }

  List<String> getHashtags() {
    List<String> hashtags = [];
    RegExp exp = RegExp(r"\B#\w\w+");
    exp.allMatches(this).forEach((match) {
      if (match.group(0) != null) {
        hashtags.add(match.group(0)!.replaceAll("#", ""));
      }
    });
    return hashtags;
  }

  List<String> getMentions() {
    List<String> mentions = [];
    RegExp exp = RegExp(r"\B@\w\w+");
    exp.allMatches(this).forEach((match) {
      if (match.group(0) != null) {
        mentions.add(match.group(0)!.replaceAll("@", ""));
      }
    });
    return mentions;
  }

  String encrypted() {
    if (isEmpty) {
      return '';
    }
    if (AppConfigConstants.enableEncryption == 1) {
      return encryptAESCryptoJS(this, AppConfigConstants.encryptionKey);
    } else {
      return this;
    }
  }

  String decrypted() {
    if (isEmpty) {
      return '';
    }
    try {
      return decryptAESCryptoJS(this, AppConfigConstants.encryptionKey);
    } catch (error) {
      return this;
    }
  }

  String get getInitials {
    List<String> nameParts = trim().split(' ');
    if (nameParts.length > 1) {
      return nameParts[0].substring(0, 1).toUpperCase() +
          nameParts[1].substring(0, 1).toUpperCase();
    } else {
      return nameParts[0].substring(0, 1).toUpperCase();
    }
  }

  Color get generateColorFromText {
    // Convert the name to a UTF-8 encoded string
    List<int> bytes = utf8.encode(toLowerCase());

    // Use a hash function to generate a unique integer value from the name
    int hash = 0;
    for (int i = 0; i < bytes.length; i++) {
      hash = (31 * hash + bytes[i]) % 0xFFFFFFFF;
    }

    // Use the generated hash value to generate a color
    return Color(hash).darken(0.3).withValues(alpha: 1.0);
  }

  bool get isNetworkPath {
    return startsWith('http://') || startsWith('https://');
  }

}

extension AgeCalculator on String {
  String get calculateAge {
    DateTime now = DateTime.now();
    DateTime dob = DateTime.parse(this); // Parse the date string
    int age = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age.toString();
  }
}
