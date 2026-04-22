import 'dart:convert';
import 'dart:io';
import 'package:finch/app.dart';
import 'package:finch/finch_console.dart';
import 'package:finch/finch_route.dart';
import 'package:finch/tools.dart';

/// Represents a cached response.
///
/// Stores the rendered content, content type, and creation time to
/// manage cache validity and response headers.
class Cache {
  /// The rendered string content of the response.
  String render;

  /// The [ContentType] of the cached response.
  ContentType? contentType;

  /// The time when this cache entry was created.
  DateTime createdAt;

  /// Creates a [Cache] instance.
  ///
  /// If [createdAt] is not provided, it defaults to the current time.
  Cache({
    required this.render,
    required this.contentType,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Creates a [Cache] instance from a JSON map.
  factory Cache.fromJson(Map<String, dynamic> json) {
    return Cache(
      render: json['render'].toString(),
      contentType: json['contentType'] != null
          ? ContentType.parse(json['contentType'])
          : null,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  /// Converts the [Cache] instance into a JSON string.
  String toJsonString() {
    return jsonEncode({
      'render': render,
      'contentType': contentType?.toString(),
      'createdAt': createdAt.toIso8601String(),
    });
  }
}

/// Parameters used to generate a unique cache key for requests.
enum CacheParam {
  /// Includes the request path in the cache key.
  path,

  /// Includes the request HTTP method in the cache key.
  method,

  /// Includes the request query string in the cache key.
  query,

  /// Includes the request body data in the cache key.
  data,
}

/// The storage medium used for caching.
enum CacheSource {
  /// Stores cache in the application's RAM.
  memory,

  /// Stores cache on the local file system.
  file,
  // redis,
}

/// A specialized route that handles caching of HTTP responses.
///
/// It extends [FinchRoute] to intercept the route handling and serve
/// cached responses if they exist and are not expired.
class RouteCache extends FinchRoute {
  /// The asynchronous handler function that generates the response.
  Future<String> Function() handle;

  /// The duration for which a cache entry remains valid.
  Duration cacheDuration;

  /// In-memory storage for cached responses.
  static final Map<String, Cache?> _cacheMemory = {};

  /// A list of [CacheParam]s used to build the unique cache key.
  List<CacheParam> cacheType;

  /// The storage medium where cache will be saved.
  CacheSource cacheSource;

  /// Creates a new [RouteCache] instance.
  ///
  /// The [cacheType] must at least contain [CacheParam.path].
  /// By default, responses are cached in memory for 10 minutes.
  RouteCache({
    required super.path,
    required this.handle,
    this.cacheDuration = const Duration(minutes: 10),
    this.cacheType = const [CacheParam.method, CacheParam.path],
    this.cacheSource = CacheSource.memory,
    super.key,
    super.extraPath,
    super.methods,
    super.controller,
    super.widget,
    super.auth,
    super.children,
    super.params,
    super.title,
    super.excludePaths,
    super.apiDoc,
    super.permissions,
    super.hosts,
    super.ports,
    super.middlewares,
  }) {
    super.index = _handle;
    if (!cacheType.contains(CacheParam.path)) {
      Print.error('CacheParam.path is required in cacheType, route: $path');
      cacheType.add(CacheParam.path);
    }
  }

  /// Clears all existing cache entries from both memory and file system.
  static Future<void> clearAllCache() async {
    _cacheMemory.clear();
    var cacheDir = Directory(FinchApp.config.pathCache);
    if (cacheDir.existsSync()) {
      cacheDir.list().forEach((file) {
        if (file is File && file.path.endsWith('.json')) {
          try {
            file.delete();
          } catch (e) {
            Print.warning('Error deleting cache file: $e');
          }
        }
      });
    }
  }

  /// Checks if a cache entry exists for the given [key].
  bool existCache(String key) {
    switch (cacheSource) {
      case CacheSource.memory:
        return _cacheMemory.containsKey(key);
      case CacheSource.file:
        return File(
          joinPaths([FinchApp.config.pathCache, "cache_$key.json"]),
        ).existsSync();
    }
  }

  /// Retrieves the cached response for the given [key].
  ///
  /// Returns `null` if the cache entry does not exist or fails to load.
  Cache? readCache(String key) {
    switch (cacheSource) {
      case CacheSource.memory:
        return _cacheMemory[key];
      case CacheSource.file:
        try {
          var file = File(
            joinPaths([FinchApp.config.pathCache, "cache_$key.json"]),
          );
          var content = file.readAsStringSync();
          var jsonContent = jsonDecode(content);
          return Cache.fromJson(jsonContent);
        } catch (e) {
          return null;
        }
    }
  }

  /// Stores a [cache] entry for the specified [key].
  void setCache(String key, Cache cache) {
    switch (cacheSource) {
      case CacheSource.memory:
        _cacheMemory[key] = cache;
        break;
      case CacheSource.file:
        var file = File(
          joinPaths([FinchApp.config.pathCache, "cache_$key.json"]),
        );
        file.createSync(recursive: true);
        file.writeAsStringSync(cache.toJsonString());
        break;
    }
  }

  /// Removes the cache entry associated with the given [key].
  void removeCache(String key) {
    switch (cacheSource) {
      case CacheSource.memory:
        _cacheMemory.remove(key);
        break;
      case CacheSource.file:
        try {
          var file = File(
            joinPaths([FinchApp.config.pathCache, "cache_$key.json"]),
          );
          if (file.existsSync()) {
            file.deleteSync();
          }
        } catch (e) {
          Print.warning('Error deleting cache file: $e');
        }
        break;
    }
  }

  /// Internal handler that manages the caching logic.
  ///
  /// Generates the cache key, checks for existing and valid cache,
  /// executes the underlying handle if necessary, and returns the response.
  Future<String> _handle() async {
    final rq = Context.rq;
    final cacheKey = cacheType
        .map((param) {
          switch (param) {
            case CacheParam.path:
              return rq.uri.path;
            case CacheParam.method:
              return rq.method;
            case CacheParam.query:
              return rq.uri.query;
            case CacheParam.data:
              return rq.getAllData();
          }
        })
        .join(':')
        .toMd5();

    final response = rq.response;

    var cached = readCache(cacheKey);
    final isExpired = cached != null &&
        DateTime.now().difference(cached.createdAt) > cacheDuration;

    if (isExpired) {
      removeCache(cacheKey);
      cached = null;
    }

    if (cached == null) {
      final res = await handle();
      if (response.statusCode != HttpStatus.ok) {
        return res;
      }

      final headers = <String, List<String>>{};
      response.headers.forEach((name, values) {
        headers[name] = values;
      });

      setCache(
        cacheKey,
        Cache(
          render: res,
          contentType: response.headers.contentType,
        ),
      );

      return res;
    }

    // content type
    if (cached.contentType != null) {
      response.headers.contentType = cached.contentType!;
    }

    response.write(cached.render);
    await response.close();
    return cached.render;
  }
}

/// Extension on [FinchRoute] to provide an easy way to wrap routes with caching.
extension FinchRouteExtension on FinchRoute {
  /// Wraps the current [FinchRoute] with a [RouteCache] to enable response caching.
  ///
  /// [cacheDuration] defines how long the cache should live (default 10 minutes).
  /// [cacheType] defines what parts of the request form the cache key.
  /// [cacheSource] defines where the cache is stored.
  RouteCache cache({
    Duration cacheDuration = const Duration(minutes: 10),
    List<CacheParam> cacheType = const [CacheParam.method, CacheParam.path],
    CacheSource cacheSource = CacheSource.memory,
  }) {
    return RouteCache(
      apiDoc: apiDoc,
      auth: auth,
      cacheDuration: cacheDuration,
      cacheSource: cacheSource,
      cacheType: cacheType,
      controller: controller,
      extraPath: extraPath,
      key: key,
      methods: methods,
      handle: index ??
          () async {
            throw Exception(
                'Index is required in this route for cache functionality: $path');
          },
      path: path,
      permissions: permissions,
      ports: ports,
      hosts: hosts,
      title: title,
      middlewares: middlewares,
      children: children,
      params: params,
      excludePaths: excludePaths,
      widget: widget,
    );
  }
}
