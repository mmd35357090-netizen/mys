import 'package:get/get.dart';
import 'languages/en.dart';
import 'languages/fr.dart';
import 'languages/tr.dart';
import 'languages/hi.dart';
import 'languages/ar.dart';
import 'languages/es.dart';
import 'languages/ru.dart';

class Languages extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'ar': Arabic.data,
    // 'en': English.data,
    'tr': Turkish.data,
    'hi': Hindi.data,
    'ru': Russian.data,
    'es': Spanish.data,
    'fr': French.data,
  };
}
