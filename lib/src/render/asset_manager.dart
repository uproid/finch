import 'dart:convert';

import 'package:finch/src/core/context.dart';
import 'package:finch/src/render/request.dart';
import 'package:finch/src/tools/console.dart';
import 'package:path/path.dart' as p;
import 'package:finch/finch_app.dart';

/// Manages the assets for a web request, including JavaScript, CSS, and data.
/// The [AssetManager] class is responsible for handling various assets (like JS and CSS files) and
/// the data to be included in a web response. It provides methods for adding assets, managing cache settings,
/// and generating the necessary HTML for including assets in the frontend.
class AssetManager {
  /// The list of assets (JS, CSS) to be included in the request.
  List<Asset> includes = [];

  /// The map of additional data to be passed to the frontend.
  Map<String, Object?> data = {};

  /// Creates an instance of [AssetManager] and adds a default JS include.
  ///
  /// The constructor adds a default include for the file `/app/includes.js`
  /// with `AssetCache.never` cache policy using the current request context.
  AssetManager() {
    includes.insert(
      0,
      Asset(
        path: '/app/includes.js',
        cache: AssetCache.never,
      ),
    );
  }

  /// Generates a script tag with data as a JSON object.
  ///
  /// Merges all data from the included JS assets and additional data, then encodes it into
  /// a JSON object. This is useful for passing dynamic data to the frontend.
  ///
  /// Returns an HTML script tag containing the JSON-encoded data.
  String getDataJs() {
    try {
      var allData = {};
      for (var asset in js) {
        allData.addAll(asset.data);
      }

      allData.addAll(data);
      var json = jsonEncode(allData);
      return '<script type="text/javascript">;var request = $json;</script>';
    } catch (e) {
      Console.e(e);
    }

    return '';
  }

  /// Returns the list of JS assets.
  List<Asset> get js {
    return getByType(AssetType.js);
  }

  /// Returns the list of CSS assets.
  List<Asset> get css {
    return getByType(AssetType.css);
  }

  /// Filters assets by their type (JS or CSS).
  ///
  /// The [type] parameter specifies which type of assets to return.
  List<Asset> getByType(AssetType type) {
    return includes.where((asset) => asset.type == type).toList();
  }

  /// Adds multiple assets to the manager.
  ///
  /// The [assets] parameter is a list of [Asset] instances to be added.
  AssetManager addAssets(List<Asset> assets) {
    includes.addAll(assets);
    return this;
  }

  /// Adds a single asset to the manager.
  ///
  /// The [asset] parameter is the [Asset] instance to be added.
  AssetManager addAsset(Asset asset) {
    includes.add(asset);
    return this;
  }

  /// Adds additional data to be passed to the frontend.
  ///
  /// The [params] parameter is a map of key-value pairs to be added to the existing data.
  AssetManager addData(Map<String, Object?> params) {
    data.addAll(params);
    return this;
  }

  /// Adds a notification message to the data map.
  ///
  /// The [text] parameter is the notification message text.
  /// The [type] parameter specifies the type of the notification (e.g., success, error).
  ///
  /// Example:
  /// ```dart
  /// addNotify(text: 'Operation successful', type: 'success');
  /// ```
  AssetManager addNotify({required String text, String type = 'success'}) {
    var notify = (data['notify'] ?? []) as List;
    notify.add({
      'text': text,
      'type': type,
    });
    data['notify'] = notify;
    return this;
  }

  /// Generates the HTML for including CSS assets in the frontend.
  ///
  /// Returns a string containing the `<link>` tags for each CSS asset.
  String getCssUI() {
    List<String> result = [];

    for (var c in css) {
      result.add('<link rel="stylesheet" href="${c.url}" />');
    }

    return result.join('\n');
  }

  /// Generates the HTML for including JS assets in the frontend.
  ///
  /// Returns a string containing the `<script>` tags for each JS asset.
  String getJsUI() {
    List<String> result = [];

    for (var j in js) {
      String attrs = '';
      j.attrs.forEach((key, value) {
        attrs = '$attrs $key="$value"';
      });
      result.add('<script $attrs src="${j.url}"></script>');
    }

    return result.join('\n');
  }
}

/// Represents an asset (like JS or CSS) in the web application.
/// The [Asset] class is used to manage individual assets, including their path, type, and cache settings.
/// It provides methods for constructing the correct URL for the asset, considering cache policies.
class Asset {
  late String _path;
  AssetType type;
  AssetCache cache = AssetCache.appVersion;
  Map<String, Object> data;
  Map<String, Object> attrs;

  /// Gets the current web request from RequestContext.
  Request get rq => Context.rq;

  /// Creates an instance of [Asset].
  ///
  /// The [path] parameter is the path to the asset.
  /// The [type] parameter specifies the type of the asset (JS or CSS).
  /// The [cache] parameter controls the cache policy for the asset.
  Asset({
    required String path,
    this.type = AssetType.none,
    this.cache = AssetCache.appVersion,
    this.data = const {},
    this.attrs = const {},
  }) {
    _path = path;
    if (type == AssetType.none) {
      final extention = p.extension(path).toLowerCase();
      switch (extention) {
        case '.js':
          type = AssetType.js;
          break;
        case '.css':
          type = AssetType.css;
          break;
      }
    }
  }

  /// Adds additional data to the asset's data map.
  ///
  /// The [params] parameter is a map of key-value pairs to be added.
  Asset addData(Map<String, String> params) {
    data.addAll(params);
    return this;
  }

  /// Returns the URL of the asset, considering cache settings.
  ///
  /// The cache policy determines how the URL is constructed:
  /// - [AssetCache.never]: Adds a version based on the current timestamp.
  /// - [AssetCache.appVersion]: Adds the application version from the configuration.
  String get url {
    if (cache == AssetCache.never) {
      return rq.url(
        _path,
        params: {
          'vr': "v1.${DateTime.now().millisecondsSinceEpoch}",
        },
      );
    } else if (cache == AssetCache.appVersion) {
      return rq.url(
        _path,
        params: {
          'vr': "v${FinchApp.config.version}",
        },
      );
    } else {
      return rq.url(_path);
    }
  }

  @override
  String toString() {
    return url;
  }
}

/// Enum representing the type of asset (JS, CSS, or none).
enum AssetType { css, js, none }

/// Enum representing the cache policy for assets.
enum AssetCache { never, cache, appVersion }
