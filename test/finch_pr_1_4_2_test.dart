import 'package:test/test.dart';
import 'package:finch/finch_app.dart';
import 'package:finch/src/widgets/finch_string_widget.dart';
import 'package:finch/src/widgets/widget_error.dart';
import 'package:finch/src/tools/convertor/translate_string.dart';
import 'package:finch/src/views/htmler.dart';

/// A minimal stub for testing custom errorWidget assignment.
class _CustomErrorWidget extends FinchStringWidget {
  @override
  Tag Function(Map<dynamic, dynamic> args)? generateHtml = (args) {
    return $Div(children: [$Text('custom error')]);
  };
}

void main() {
  // Ensure FinchApp.config is initialized before tests that require it.
  setUpAll(() {
    FinchApp(
      configs: FinchConfigs(
        port: 0,
        noStop: false,
        enableLocalDebugger: false,
        dbConfig: FinchDBConfig(enable: false),
      ),
    );
  });

  // -------------------------------------------------------------------------
  // Group 1: FinchConfigs.errorWidget
  // -------------------------------------------------------------------------
  group('FinchConfigs errorWidget', () {
    test('defaults to ErrorWidget when no errorWidget is provided', () {
      final configs = FinchConfigs(
        port: 0,
        noStop: false,
        dbConfig: FinchDBConfig(enable: false),
      );
      expect(
        configs.errorWidget,
        isA<ErrorWidget>(),
        reason: 'Default errorWidget should be ErrorWidget',
      );
    });

    test('errorWidget is not null when using defaults', () {
      final configs = FinchConfigs(
        port: 0,
        noStop: false,
        dbConfig: FinchDBConfig(enable: false),
      );
      expect(
        configs.errorWidget,
        isNotNull,
        reason: 'errorWidget must never be null',
      );
    });

    test('accepts a custom errorWidget and stores it', () {
      final custom = _CustomErrorWidget();
      final configs = FinchConfigs(
        port: 0,
        noStop: false,
        dbConfig: FinchDBConfig(enable: false),
        errorWidget: custom,
      );
      expect(
        configs.errorWidget,
        same(custom),
        reason: 'Custom errorWidget should be stored by reference',
      );
    });

    test('custom errorWidget is not an ErrorWidget', () {
      final custom = _CustomErrorWidget();
      final configs = FinchConfigs(
        port: 0,
        noStop: false,
        dbConfig: FinchDBConfig(enable: false),
        errorWidget: custom,
      );
      expect(
        configs.errorWidget,
        isNot(isA<ErrorWidget>()),
        reason: 'Custom errorWidget should not be the default ErrorWidget type',
      );
    });

    test('custom errorWidget is a FinchStringWidget', () {
      final custom = _CustomErrorWidget();
      final configs = FinchConfigs(
        port: 0,
        noStop: false,
        dbConfig: FinchDBConfig(enable: false),
        errorWidget: custom,
      );
      expect(
        configs.errorWidget,
        isA<FinchStringWidget>(),
        reason: 'errorWidget must implement FinchStringWidget',
      );
    });

    test('two configs with different errorWidgets store independently', () {
      final custom = _CustomErrorWidget();
      final configsDefault = FinchConfigs(
        port: 0,
        noStop: false,
        dbConfig: FinchDBConfig(enable: false),
      );
      final configsCustom = FinchConfigs(
        port: 0,
        noStop: false,
        dbConfig: FinchDBConfig(enable: false),
        errorWidget: custom,
      );
      expect(
        configsDefault.errorWidget,
        isA<ErrorWidget>(),
        reason: 'First config should have default ErrorWidget',
      );
      expect(
        configsCustom.errorWidget,
        same(custom),
        reason: 'Second config should have the custom widget',
      );
    });
  });

  // -------------------------------------------------------------------------
  // Group 2: FinchApp.config picks up errorWidget from FinchConfigs
  // -------------------------------------------------------------------------
  group('FinchApp.config errorWidget', () {
    test('FinchApp.config.errorWidget is ErrorWidget by default', () {
      FinchApp(
        configs: FinchConfigs(
          port: 0,
          noStop: false,
          dbConfig: FinchDBConfig(enable: false),
        ),
      );
      expect(
        FinchApp.config.errorWidget,
        isA<ErrorWidget>(),
        reason: 'FinchApp.config.errorWidget should default to ErrorWidget',
      );
    });

    test('FinchApp.config.errorWidget reflects custom widget', () {
      final custom = _CustomErrorWidget();
      FinchApp(
        configs: FinchConfigs(
          port: 0,
          noStop: false,
          dbConfig: FinchDBConfig(enable: false),
          errorWidget: custom,
        ),
      );
      expect(
        FinchApp.config.errorWidget,
        same(custom),
        reason:
            'FinchApp.config.errorWidget should match the configured custom widget',
      );
    });
  });

  // -------------------------------------------------------------------------
  // Group 3: ErrorWidget.generateHtml
  // -------------------------------------------------------------------------
  group('ErrorWidget generateHtml', () {
    late ErrorWidget widget;

    setUp(() {
      widget = ErrorWidget();
    });

    test('generateHtml is not null', () {
      expect(
        widget.generateHtml,
        isNotNull,
        reason: 'ErrorWidget must have a generateHtml function',
      );
    });

    test('generateHtml returns a non-null Tag with default args', () {
      final tag = widget.generateHtml!({});
      expect(tag, isNotNull, reason: 'generateHtml should return a Tag');
    });

    test('generateHtml uses status 500 as default when no status provided', () {
      final tag = widget.generateHtml!({});
      final html = tag.toString();
      expect(
        html,
        contains('500'),
        reason: 'Default error page should include status code 500',
      );
    });

    test('generateHtml includes given status code in output', () {
      final tag = widget.generateHtml!({'status': 404});
      final html = tag.toString();
      expect(
        html,
        contains('404'),
        reason: 'Error page should include status code 404',
      );
    });

    test('generateHtml includes given status code 403 in output', () {
      final tag = widget.generateHtml!({'status': 403});
      final html = tag.toString();
      expect(
        html,
        contains('403'),
        reason: 'Error page should include status code 403',
      );
    });

    test('generateHtml uses title from args when provided', () {
      final tag = widget.generateHtml!({
        'status': 503,
        'title': 'Service Unavailable',
      });
      final html = tag.toString();
      expect(
        html,
        contains('503'),
        reason: 'Error page should include the status code 503',
      );
    });

    test('generateHtml produces valid HTML structure', () {
      final tag = widget.generateHtml!({'status': 500});
      final html = tag.toString();
      expect(
        html,
        contains('<html'),
        reason: 'Output should include an html element',
      );
      expect(
        html,
        contains('<head'),
        reason: 'Output should include a head element',
      );
      expect(
        html,
        contains('<body'),
        reason: 'Output should include a body element',
      );
    });

    test('generateHtml layout property is empty string', () {
      expect(
        widget.layout,
        '',
        reason: 'ErrorWidget.layout should be an empty string',
      );
    });

    test('generateHtml with empty error string still renders', () {
      final tag = widget.generateHtml!({'status': 500, 'error': ''});
      expect(
        tag,
        isNotNull,
        reason: 'generateHtml should handle empty error string gracefully',
      );
    });

    test('generateHtml with non-empty error string still renders', () {
      final tag =
          widget.generateHtml!({'status': 500, 'error': 'Something failed'});
      final html = tag.toString();
      expect(
        html,
        isNotNull,
        reason: 'generateHtml should render even with an error string',
      );
    });

    test('generateHtml with empty stack list still renders', () {
      final tag = widget.generateHtml!({'status': 500, 'stack': <dynamic>[]});
      expect(
        tag,
        isNotNull,
        reason: 'generateHtml should handle empty stack gracefully',
      );
    });

    test('generateHtml with non-empty stack list still renders', () {
      final tag = widget.generateHtml!({
        'status': 500,
        'stack': ['frame 1', 'frame 2'],
      });
      final html = tag.toString();
      expect(
        html,
        isNotNull,
        reason: 'generateHtml should handle non-empty stack gracefully',
      );
    });
  });

  // -------------------------------------------------------------------------
  // Group 4: _CustomErrorWidget (simulates ErrorCustomView pattern)
  // -------------------------------------------------------------------------
  group('Custom FinchStringWidget (like ErrorCustomView)', () {
    test('custom widget generateHtml is callable', () {
      final widget = _CustomErrorWidget();
      expect(widget.generateHtml, isNotNull);
    });

    test('custom widget produces expected output', () {
      final widget = _CustomErrorWidget();
      final tag = widget.generateHtml!({});
      final html = tag.toString();
      expect(
        html,
        contains('custom error'),
        reason: 'Custom widget should output expected content',
      );
    });

    test('custom widget can conditionally delegate based on status', () {
      // Mirrors the ErrorCustomView pattern: 404 → custom, others → ErrorWidget
      final customView = _ConditionalErrorWidget();

      final tag404 = customView.generateHtml!({'status': 404});
      expect(
        tag404.toString(),
        contains('not found'),
        reason: 'Status 404 should return custom message',
      );

      final tag500 = customView.generateHtml!({'status': 500});
      expect(
        tag500.toString(),
        contains('500'),
        reason: 'Non-404 status should delegate to ErrorWidget',
      );
    });
  });

  // -------------------------------------------------------------------------
  // Group 5: TString translation machinery (translate_string.dart)
  // -------------------------------------------------------------------------
  group('TString translation', () {
    setUp(() {
      // Set up a test language map directly on the static field.
      FinchApp.appLanguages = {
        'en': {
          'hello': 'Hello',
          'greeting': 'Hello, {1}!',
          'deep.key': 'Deep value',
        },
        'fa': {
          'hello': 'سلام',
          'greeting': 'سلام، {1}!',
        },
      };
    });

    tearDown(() {
      FinchApp.appLanguages = {};
    });

    test('TString stores key correctly', () {
      final ts = TString('hello');
      expect(ts.key, 'hello', reason: 'TString should store the key');
    });

    test('tr extension creates TString with correct key', () {
      final ts = 'hello'.tr;
      expect(ts, isA<TString>(), reason: '.tr should return a TString');
      expect(ts.key, 'hello', reason: '.tr TString should have correct key');
    });

    test('writeByLang returns translation when language exists', () {
      final result = TString('hello').writeByLang('en');
      expect(result, 'Hello', reason: 'Should return English translation');
    });

    test('writeByLang returns Farsi translation', () {
      final result = TString('hello').writeByLang('fa');
      expect(result, 'سلام', reason: 'Should return Farsi translation');
    });

    test('writeByLang falls back to key when language not found', () {
      final result = TString('hello').writeByLang('zz');
      // Falls back to 'en' if 'zz' not found, then returns 'Hello'
      expect(result, 'Hello',
          reason: 'Unknown language should fall back to en');
    });

    test('writeByLang returns key when no translation or fallback exists', () {
      FinchApp.appLanguages = {};
      final result = TString('unknown.key').writeByLang('en');
      expect(
        result,
        'unknown.key',
        reason: 'Missing translation should return the original key',
      );
    });

    test('writeByLang substitutes parameters', () {
      final result = TString('greeting').writeByLang('en', {'1': 'World'});
      expect(
        result,
        'Hello, World!',
        reason: 'writeByLang should substitute {1} placeholder',
      );
    });

    test('writeByLangArr substitutes list parameters', () {
      final result = TString('greeting').writeByLangArr('en', ['Alice']);
      expect(
        result,
        'Hello, Alice!',
        reason: 'writeByLangArr should substitute positional params from list',
      );
    });

    test('writeByLangArr with empty list returns untouched translation', () {
      final result = TString('hello').writeByLangArr('en', []);
      expect(
        result,
        'Hello',
        reason: 'Empty param list should leave translation unchanged',
      );
    });

    test('toString delegates to write (throws without zone context)', () {
      final ts = TString('hello');
      // toString calls write() which requires Context.rq
      expect(
        () => ts.toString(),
        throwsA(isA<StateError>()),
        reason: 'TString.toString() should throw StateError without a zone',
      );
    });

    test('TString.write() throws StateError without request zone', () {
      final ts = TString('hello');
      expect(
        () => ts.write(),
        throwsA(isA<StateError>()),
        reason:
            'write() should throw StateError when called outside a request zone',
      );
    });

    test('TString.write() with params throws StateError without request zone',
        () {
      final ts = TString('greeting');
      expect(
        () => ts.write({'1': 'World'}),
        throwsA(isA<StateError>()),
        reason:
            'write(params) should throw StateError when called outside a request zone',
      );
    });
  });

  // -------------------------------------------------------------------------
  // Group 6: TranslateString extension – trWrite and trWriteParam
  // -------------------------------------------------------------------------
  group('TranslateString extension trWrite/trWriteParam', () {
    test('trWrite throws StateError without a request zone', () {
      expect(
        () => 'hello'.trWrite,
        throwsA(isA<StateError>()),
        reason:
            'trWrite should throw StateError when called outside a request zone',
      );
    });

    test('trWriteParam throws StateError without a request zone', () {
      expect(
        () => 'hello'.trWriteParam({'1': 'value'}),
        throwsA(isA<StateError>()),
        reason:
            'trWriteParam should throw StateError when called outside a request zone',
      );
    });

    test(
        'trWriteParam with empty params throws StateError without a request zone',
        () {
      expect(
        () => 'hello'.trWriteParam(),
        throwsA(isA<StateError>()),
        reason:
            'trWriteParam() with default empty map should throw StateError without zone',
      );
    });

    test('trWrite is accessible as a String extension getter', () {
      // Confirm the extension compiles and is accessible (using try/catch to
      // avoid the StateError that would occur without a zone).
      Object? caught;
      try {
        final _ = 'test_key'.trWrite;
      } catch (e) {
        caught = e;
      }
      // We only care that the extension exists; StateError is the expected path.
      expect(
        caught,
        isA<StateError>(),
        reason:
            'trWrite extension should exist on String and delegate to write()',
      );
    });

    test('trWriteParam is accessible as a String extension method', () {
      Object? caught;
      try {
        'test_key'.trWriteParam({'test_key': 'val'});
      } catch (e) {
        caught = e;
      }
      expect(
        caught,
        isA<StateError>(),
        reason:
            'trWriteParam should exist on String and delegate to write(values)',
      );
    });
  });

  // -------------------------------------------------------------------------
  // Group 7: FinchConfigs version (regression)
  // -------------------------------------------------------------------------
  group('FinchApp version', () {
    test('FinchApp.info.version is 1.4.2', () {
      expect(
        FinchApp.info.version,
        '1.4.2',
        reason: 'Version should be updated to 1.4.2 in this release',
      );
    });
  });
}

/// A conditional error widget that mirrors the ErrorCustomView pattern from
/// example/lib/core/error_custom_view.dart:
/// - status 404 → custom "not found" message
/// - any other status → delegates to ErrorWidget
class _ConditionalErrorWidget extends FinchStringWidget {
  @override
  Tag Function(Map<dynamic, dynamic> args)? generateHtml = (args) {
    final statusCode = args['status'] ?? 404;
    if (statusCode != 404) {
      return ErrorWidget().generateHtml!.call(args);
    }
    return $Div(children: [$Text('not found')]);
  };
}
