import 'dart:convert';
import 'dart:io';
import 'package:finch/finch_console.dart';
import 'package:finch/finch_route.dart';
import 'package:finch/tools.dart';

class Cache {
  String render;
  ContentType? contentType;
  DateTime createdAt;

  Cache({
    required this.render,
    required this.contentType,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

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

  String toJsonString() {
    return jsonEncode({
      'render': render,
      'contentType': contentType?.toString(),
      'createdAt': createdAt.toIso8601String(),
    });
  }
}

enum CacheParam { path, method, query, data }

enum CacheSource {
  memory,
  file,
  // redis,
}

class RouteCache extends FinchRoute {
  Future<String> Function() handle;
  Duration cacheDuration;
  static final Map<String, Cache?> _cacheMemory = {};
  List<CacheParam> cacheType;
  CacheSource cacheSource;
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

  bool existCache(String key) {
    switch (cacheSource) {
      case CacheSource.memory:
        return _cacheMemory.containsKey(key);
      case CacheSource.file:
        return File("./cache/cache_$key.json").existsSync();
    }
  }

  Cache? readCache(String key) {
    switch (cacheSource) {
      case CacheSource.memory:
        return _cacheMemory[key];
      case CacheSource.file:
        try {
          var file = File("./cache/cache_$key.json");
          var content = file.readAsStringSync();
          var jsonContent = jsonDecode(content);
          return Cache.fromJson(jsonContent);
        } catch (e) {
          return null;
        }
    }
  }

  void setCache(String key, Cache cache) {
    switch (cacheSource) {
      case CacheSource.memory:
        _cacheMemory[key] = cache;
        break;
      case CacheSource.file:
        var file = File("./cache/cache_$key.json");
        file.createSync(recursive: true);
        file.writeAsStringSync(cache.toJsonString());
        break;
    }
  }

  void removeCache(String key) {
    switch (cacheSource) {
      case CacheSource.memory:
        _cacheMemory.remove(key);
        break;
      case CacheSource.file:
        try {
          var file = File("./cache/cache_$key.json");
          if (file.existsSync()) {
            file.deleteSync();
          }
        } catch (e) {
          Print.warning('Error deleting cache file: $e');
        }
        break;
    }
  }

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

extension FinchRouteExtension on FinchRoute {
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
