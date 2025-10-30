import 'dart:io';
import 'package:path/path.dart' as p;

/// Extension methods for [File] to provide convenient path and name utilities.
/// [FinchFile] adds helpful methods to the [File] class for extracting different
/// parts of file paths and names. This extension simplifies common file
/// operations by providing direct access to file components without manually
/// parsing paths.
/// Example usage:
/// ```dart
/// final file = File('/path/to/document.pdf');
/// print(file.fileName);     // 'document'
/// print(file.fileExtension); // '.pdf'
/// print(file.filePath);     // '/path/to'
/// print(file.fileFullName); // 'document.pdf'
/// ```
extension FinchFile on File {
  /// Gets the file name without the extension.
  ///
  /// Returns the base name of the file without its extension.
  /// For example, if the file path is '/home/user/document.pdf',
  /// this returns 'document'.
  ///
  /// Example:
  /// ```dart
  /// final file = File('/downloads/report.xlsx');
  /// print(file.fileName); // 'report'
  /// ```
  String get fileName {
    return p.basenameWithoutExtension(path);
  }

  /// Gets the file extension including the dot.
  ///
  /// Returns the file extension with the leading dot.
  /// For example, if the file path is '/home/user/document.pdf',
  /// this returns '.pdf'.
  ///
  /// Example:
  /// ```dart
  /// final file = File('/downloads/image.png');
  /// print(file.fileExtension); // '.png'
  /// ```
  String get fileExtension {
    return p.extension(path);
  }

  /// Gets the directory path containing the file.
  ///
  /// Returns the directory path where the file is located, without
  /// the file name itself. For example, if the file path is
  /// '/home/user/documents/file.txt', this returns '/home/user/documents'.
  ///
  /// Example:
  /// ```dart
  /// final file = File('/var/www/html/index.html');
  /// print(file.filePath); // '/var/www/html'
  /// ```
  String get filePath {
    return p.dirname(path);
  }

  /// Gets the complete file name including the extension.
  ///
  /// Returns the full file name with its extension.
  /// For example, if the file path is '/home/user/document.pdf',
  /// this returns 'document.pdf'.
  ///
  /// Example:
  /// ```dart
  /// final file = File('/uploads/avatar.jpg');
  /// print(file.fileFullName); // 'avatar.jpg'
  /// ```
  String get fileFullName {
    return p.basename(path);
  }
}
