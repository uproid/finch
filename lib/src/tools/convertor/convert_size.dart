/// A utility class for converting file sizes from bytes to human-readable format.
/// The [ConvertSize] class provides a static method for converting a file size in bytes
/// into a more understandable string format, including bytes (B), kilobytes (KB), megabytes (MB),
/// and gigabytes (GB). The conversion takes into account the size of the file and returns the
/// size in the appropriate units with two decimal places for precision.
class ConvertSize {
  /// Converts a file size in bytes to a human-readable string format.
  ///
  /// This method converts the file size from bytes to the largest appropriate unit (KB, MB, GB)
  /// and formats the size to two decimal places. The returned string includes the unit of measurement.
  ///
  /// For example:
  /// - `500` bytes will be converted to `'500 B'`
  /// - `1500` bytes will be converted to `'1.46 KB'`
  /// - `1,500,000` bytes will be converted to `'1.43 MB'`
  /// - `1,500,000,000` bytes will be converted to `'1.40 GB'`
  ///
  /// [fileSizeInBytes] is the file size in bytes to be converted.
  ///
  /// Returns a [String] representing the file size in a human-readable format.
  static String toLogicSizeString(int fileSizeInBytes) {
    if (fileSizeInBytes < 1024) {
      return '$fileSizeInBytes B';
    } else if (fileSizeInBytes < 1024 * 1024) {
      double fileSizeInKB = fileSizeInBytes / 1024;
      return '${fileSizeInKB.toStringAsFixed(2)} KB';
    } else if (fileSizeInBytes < 1024 * 1024 * 1024) {
      double fileSizeInMB = fileSizeInBytes / (1024 * 1024);
      return '${fileSizeInMB.toStringAsFixed(2)} MB';
    } else {
      double fileSizeInGB = fileSizeInBytes / (1024 * 1024 * 1024);
      return '${fileSizeInGB.toStringAsFixed(2)} GB';
    }
  }
}
