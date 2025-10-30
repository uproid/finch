import 'dart:convert';
import 'package:finch/finch_route.dart';
import 'package:finch/finch_tools.dart';

var localEvents = <String, Object>{
  'route': (String key) {
    return FinchRoute.getByKey(key)?.getUrl() ?? '';
  },
  'hasFlash': () {
    return Context.rq.get('flash') != null;
  },
  'getFlashs': () {
    var flash = Context.rq.session['flashes'];
    Context.rq.session.remove('flashes');
    return flash ?? [];
  },
  'updateUrlQuery': ([Object? updates]) {
    if (updates is String) {
      updates = jsonDecode(updates);
    }

    var newParams = <String, String>{};
    if (updates is Map) {
      for (var key in updates.keys) {
        newParams[key] = updates[key].toString();
      }
    }

    var queryParams = Context.rq.uri.queryParameters
        .map((key, value) => MapEntry(key, value));

    var newUrl = Uri(
      queryParameters: {
        ...queryParams,
        ...newParams,
      },
    );

    return newUrl.toString();
  },
  'removeUrlQuery': (dynamic keys) {
    var queryParams = Context.rq.uri.queryParameters
        .map((key, value) => MapEntry(key, value));

    for (var key in keys) {
      queryParams.remove(key);
    }

    var newUrl = Uri(
      queryParameters: queryParams,
    );

    return newUrl.toString();
  },
  'existUrlQuery': (dynamic keys) {
    for (var key in keys) {
      if (Context.rq.uri.queryParameters.containsKey(key) &&
          Context.rq.uri.queryParameters[key] != null &&
          Context.rq.uri.queryParameters[key]!.isNotEmpty) {
        return true;
      }
    }
    return false;
  },
};

var localLayoutFilters = <String, Function>{
  'json': (Object? value) {
    return FinchJson.jsonEncoder(value!);
  },
  'fix': (Object? value) {
    return value;
  },
  's': (Object? value) {
    return value == null ? '' : value.toString();
  },
  'if': (Object? value, Object? t, Object? f) {
    return value.toString().toBool ? t : f;
  },
};
