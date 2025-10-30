import 'package:finch/finch_route.dart';
import 'package:finch/finch_app.dart';

/// Extension on [String] to provide translation functionality.
extension TranslateString on String {
  /// Converts the string to a [TString] for translation.
  ///
  /// This extension method wraps the original string in a [TString] instance,
  /// which can be used to retrieve translations based on the current or specified language.
  ///
  /// Example:
  /// ```dart
  /// String greeting = 'hello';
  /// var translatedGreeting = greeting.tr;
  /// ```
  ///
  /// Returns a [TString] instance containing the original string as the translation key.
  TString get tr {
    return TString(this);
  }
}

/// Class representing a translatable string.
/// Use this class to handle translations of a string based on the current or specified language.
class TString {
  /// The translation key for this string.
  String key;

  /// Creates an instance of [TString] with the given translation key.
  ///
  /// [key] The translation key for this string.
  TString(this.key);

  /// Retrieves the translated string based on the current language from the [Request].
  ///
  /// This method uses the current language from the [Request] and looks up the translation
  /// in the application's language settings. If no translation is found, it returns the original key.
  ///
  /// Example:
  /// ```dart
  /// WebRequest request = ...; // Your web request object
  /// TString welcomeMessage = 'welcome'.tr;
  /// String translatedMessage = welcomeMessage.write(request);
  /// ```
  ///
  ///
  /// Returns the translated string if found, otherwise returns the original key.
  String write([Map values = const {}]) {
    var params = {...values};
    var key = this.key;
    if (key.contains('#')) {
      final valuesKey = key.split('#');
      key = valuesKey[0];

      if (valuesKey.length > 1) {
        for (var i = 1; i < valuesKey.length; i++) {
          var val = valuesKey[i].toString();
          val = val.replaceAll('{', '').replaceAll('}', '');
          params[(i - 1).toString()] = val;
        }
      }
    }
    final ln = Context.rq.getLanguage();
    var language = FinchApp.appLanguages[ln] ?? FinchApp.appLanguages['en'];
    if (language != null && language[key] != null) {
      var res = _repliceParams(language[key]!, params);
      return res;
    }
    return key;
  }

  String _repliceParams(String res, Map values) {
    values.forEach((key, value) {
      res = res.replaceAll('{$key}', value.toString());
    });
    return res;
  }

  /// Retrieves the translated string based on a specified language code.
  ///
  /// This method allows specifying a language code to retrieve the translation from the
  /// application's language settings. If no translation is found, it returns the original key.
  ///
  /// Example:
  /// ```dart
  /// TString farewellMessage = 'goodbye'.tr;
  /// String translatedMessage = farewellMessage.writeByLang('fr');
  /// ```
  ///
  /// [ln] The language code (e.g., 'en', 'fr') to look up the translation.
  ///
  /// Returns the translated string if found, otherwise returns the original key.
  String writeByLang(String ln, [Map values = const {}]) {
    var language = FinchApp.appLanguages[ln] ?? FinchApp.appLanguages['en'];
    var res = key;
    if (language != null && language[key] != null) {
      res = language[key]!;
    }
    res = _repliceParams(res, values);
    return res;
  }

  String writeByLangArr(String ln, [List values = const []]) {
    var valueMap = <String, Object?>{};
    for (var i = 1; i <= values.length; i++) {
      valueMap[i.toString()] = values[i - 1];
    }
    return writeByLang(ln, valueMap);
  }

  @override
  String toString([Map values = const {}]) {
    return write(values);
  }
}
