import 'dart:io';

import 'package:path/path.dart' as p;

/// Normalizes and joins a given [path] with the application base directory path.
/// This function normalizes the input [path], formats it as a URI, applies
/// additional path normalization, and finally joins it with the application
/// directory path obtained from [pathApp].
/// Example usage:
/// ```dart
/// String fullPath = pathTo('assets/images');
/// ```
String pathTo(String path) {
  path = p.normalize(path);
  path = p.prettyUri(path);
  path = pathNorm(path);
  return p.normalize(p.join(pathApp, path));
}

/// Joins a list of paths into a single normalized path string.
/// The first element in [paths] is joined as-is, while subsequent elements
/// are normalized using [pathNorm] to ensure consistency.
/// Example usage:
/// ```dart
/// String fullPath = joinPaths(['assets', 'images', 'logo.png']);
/// ```
String joinPaths(List<String> paths) {
  var pathsNorm = <String>[];
  var isNotFirst = false;
  for (var element in paths) {
    if (isNotFirst) {
      element = pathNorm(element);
    } else {
      isNotFirst = true;
    }
    pathsNorm.add(element);
  }
  return p.joinAll(pathsNorm);
}

/// Normalizes a given [path] by removing leading slashes and optionally converting
/// backslashes to forward slashes.
/// The [normSlashs] parameter, if set to `true`, replaces all backslashes (`\`)
/// with forward slashes (`/`) in the normalized path.
/// Example usage:
/// ```dart
/// String normalizedPath = pathNorm('C:\\User\\Documents\\file.txt', normSlashs: true);
/// ```
String pathNorm(String path, {bool? normSlashs, endWithSlash = false}) {
  path = p.normalize(path);
  if (path.startsWith('/') || path.startsWith("\\")) path = path.substring(1);
  if (normSlashs != null && normSlashs) {
    path = path.replaceAll('\\', '/');
  }

  if (endWithSlash && !path.endsWith('/')) {
    path += '/';
  }
  return path;
}

/// Normalizes endpoint paths for URL routing with customizable formatting options.
/// This function takes a list of path segments and combines them into a normalized
/// endpoint path suitable for web routing. It provides fine-grained control over
/// the formatting including slash handling and path structure.
/// [normSlashs] If true, converts backslashes to forward slashes (default: true)
/// [endWithSlash] If true, ensures the path ends with a forward slash (default: true)
/// [startWithSlash] If true, ensures the path starts with a forward slash (default: true)
/// The function also handles double slashes by replacing them with single slashes
/// Example usage:
/// ```dart
/// // Result: '/api/users/profile/'
/// String apiPath = endpointNorm(['v1', 'data'], endWithSlash: false);
/// // Result: '/v1/data'
/// ```
String endpointNorm(
  List<String> paths, {
  bool normSlashs = true,
  endWithSlash = true,
  startWithSlash = true,
}) {
  var path = joinPaths(paths);
  if (endWithSlash && !path.endsWith('/')) {
    path += '/';
  }

  if (startWithSlash && !path.startsWith('/')) {
    path = '/$path';
  }

  if (normSlashs) {
    path = path.replaceAll('\\', '/');
  }
  path = path.replaceAll('//', '/');
  return path;
}

/// Compares multiple paths for equality after normalization.
/// This function normalizes all provided paths using the same formatting options
/// and then compares them to determine if they represent the same endpoint.
/// This is useful for route matching and path comparison in web applications.
/// [paths] List of path strings to compare for equality
/// [normSlashs] If true, converts backslashes to forward slashes (default: true)
/// [endWithSlash] If true, ensures paths end with a forward slash (default: true)
/// [startWithSlash] If true, ensures paths start with a forward slash (default: true)
/// Returns `true` if all paths are equivalent after normalization, `false` otherwise.
/// Returns `true` if the paths list is empty.
/// Example usage:
/// ```dart
/// bool isEqual = pathsEqual(['/api/users/', 'api\\users', '/api/users']);
/// // Result: true (all represent the same path)
/// bool isDifferent = pathsEqual(['/api/users', '/api/posts']);
/// // Result: false (different endpoints)
/// ```
bool pathsEqual(
  List<String> paths, {
  bool normSlashs = true,
  endWithSlash = true,
  startWithSlash = true,
}) {
  if (paths.isEmpty) {
    return true;
  }
  var path1 = endpointNorm(
    [paths[0]],
    normSlashs: normSlashs,
    endWithSlash: endWithSlash,
    startWithSlash: startWithSlash,
  );
  for (var path in paths) {
    var path2 = endpointNorm(
      [path],
      normSlashs: normSlashs,
      endWithSlash: endWithSlash,
      startWithSlash: startWithSlash,
    );

    if (path1 != path2) {
      return false;
    }
  }
  return true;
}

/// Retrieves the base directory path of the application.
/// This getter uses the script path from [Platform.script] and navigates up two levels
/// to return the root application path.
/// Example usage:
/// ```dart
/// String appPath = pathApp;
/// ```
String get pathApp {
  var scriptPath = Platform.script.toFilePath();
  return Directory(scriptPath).parent.parent.path;
}
