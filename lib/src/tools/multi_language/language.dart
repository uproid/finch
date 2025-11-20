import 'dart:convert';
import 'dart:io';
import 'package:finch/src/tools/console.dart';
import 'package:path/path.dart' as p;

/// A class that manages the loading and parsing of multi-language JSON files
/// from a specified directory path.
/// The [MultiLanguage] class provides functionality to load, read, and parse
/// JSON files to create a map structure representing different language data.
/// Example usage:
/// ```dart
/// final multiLanguage = MultiLanguage('/path/to/languages');
/// final translations = await multiLanguage.init();
/// ```
class MultiLanguage {
  /// The directory path where the language JSON files are stored.
  String languagePath;
  LanguageSource source;
  Map<String, Map<String, String>> dartLanguages = {};

  /// Creates an instance of [MultiLanguage] with the given [languagePath].
  MultiLanguage({
    this.languagePath = '',
    this.source = LanguageSource.json,
    this.dartLanguages = const {},
  }) {
    if (languagePath.isEmpty && source == LanguageSource.json) {
      throw Exception(
        'Language path must be provided when using JSON source.',
      );
    }
  }

  /// Initializes the multi-language system by reading all JSON files from
  /// the directory and subdirectories specified in [languagePath].
  ///
  /// Returns a `Map<String, Map<String, String>>` where the keys are the
  /// filenames (without extensions) and the values are the language
  /// key-value pairs from the JSON files.
  Future<Map<String, Map<String, String>>> init() async {
    if (source == LanguageSource.dart) {
      return dartLanguages;
    }

    final directory = Directory(languagePath);
    Map<String, Map<String, String>> result = await _findFiles(directory, {});
    return result;
  }

  /// Recursively searches the specified [dir] for JSON files and reads them.
  ///
  /// This method processes both files and subdirectories. For each JSON file found,
  /// it calls [readFile] to extract the data and merges the results into [result].
  ///
  /// [dir] is the directory to search.
  /// [result] is the accumulated map of language data.
  ///
  /// Returns a `Map<String, Map<String, String>>` representing the combined
  /// language data from all the found JSON files.
  Future<Map<String, Map<String, String>>> _findFiles(
    Directory dir,
    Map<String, Map<String, String>> result,
  ) async {
    if (!dir.existsSync()) {
      Console.e(
        {'error': 'Directory of languages does not exist: ${dir.path}'},
      );
      return {};
    }
    var entities = dir.listSync();
    for (var entry in entities) {
      if (entry is File) {
        var ext = p.extension(entry.path).toLowerCase();

        if (ext == '.json') {
          var fileData = await readFile(entry.path, result);
          result = {...result, ...fileData};
        }
      } else if (entry is Directory) {
        var fileData = await _findFiles(entry, result);
        result = {...result, ...fileData};
      }
    }

    return result;
  }

  /// Reads and parses a JSON file at the given [path] and merges its data
  /// into [result].
  ///
  /// The [path] is the file path of the JSON file.
  /// [result] is the current map that accumulates language data.
  ///
  /// The method extracts the filename without extension and uses it as the key
  /// in the result map. The parsed JSON data is stored as a map of key-value
  /// pairs (both as strings) within this key.
  ///
  /// Returns a `Map<String, Map<String, String>>` containing the updated
  /// language data.
  Future<Map<String, Map<String, String>>> readFile(
    String path,
    Map<String, Map<String, String>> result,
  ) async {
    try {
      File file = File(path);
      String filename = p.basenameWithoutExtension(path);
      String jsonString = await file.readAsString();

      Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      Map<String, String> map = jsonMap.map(
        (key, value) => MapEntry(key, value.toString()),
      );
      result[filename] = map;
      return result;
    } catch (e) {
      Console.e({'error': e});
    }

    return {};
  }
}

enum LanguageSource {
  json,
  dart,
}
