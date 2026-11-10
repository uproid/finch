import 'dart:io';

import 'package:finch/finch_tools.dart';

class EnvReader {
  final bool useEnvOs;

  final _envOs = <String, String>{};
  final _envFile = <String, String>{};

  EnvReader({
    this.useEnvOs = true,
    Iterable<String> files = const ['.env'],
  }) {
    if (useEnvOs) _envOs.addAll(Platform.environment);
    for (var filePath in files) {
      var file = File.fromUri(Uri.file(filePath));
      var lines = file.existsSync() ? file.readAsLinesSync() : <String>[];
      _envFile.addAll(EnvParser().parse(lines));
    }
  }

  Map<String, String> get map => {
        ..._envOs,
        ..._envFile,
      };

  String get(String key, [String def = '']) => map[key] ?? def;
  int getInt(String key, [int def = -1]) => get(key).toInt(def: def);
  bool getBool(String key, [bool def = false]) =>
      has(key) ? get(key).toBool : def;
  bool has(String key) => get(key, '').isNotEmpty;
}

/// Parses `.env`-style files into a `Map<String, String>`.
///
/// Supports:
/// - `export KEY=value` and `KEY=value`
/// - single quotes (`'...'`)  → literal, no interpolation (like bash)
/// - double quotes (`"..."`)  → interpolation + `\"` / `\\` escapes
/// - unquoted values          → interpolation, trimmed
/// - `# comment`               → only when the `#` is outside any quotes
///   and preceded by whitespace/start-of-line (so URLs like
///   `http://x#frag` aren't mistaken for comments)
/// - `$VAR`, `${VAR}`, and escaped `\$VAR` (kept literal)
/// - fallback to `Platform.environment` when a var isn't already defined
class EnvParser {
  static const _exportKeyword = 'export';

  static final _validKey = RegExp(r'^[a-zA-Z_]\w*$');

  // $VAR or ${VAR}; group(1) = optional escaping backslash,
  // group(2) = braced name, group(3) = bare name.
  static final _variableRef =
      RegExp(r'(\\)?\$(?:\{([a-zA-Z_]\w*)\}|([a-zA-Z_]\w*))');

  static final _surroundingQuotes = RegExp(r'''^(['"])(.*)\1$''');

  const EnvParser();

  /// Parses every line, feeding already-parsed keys forward so later
  /// lines can reference earlier ones (same as before).
  Map<String, String> parse(Iterable<String> lines) {
    final result = <String, String>{};
    for (final rawLine in lines) {
      final entry = parseLine(rawLine, knownVars: result);
      if (entry != null) result[entry.key] = entry.value;
    }
    return result;
  }

  /// Parses one line. Returns `null` for blank lines, comments, or
  /// malformed input (no `=`, empty/invalid key).
  MapEntry<String, String>? parseLine(
    String rawLine, {
    Map<String, String> knownVars = const {},
  }) {
    final line = _stripComment(rawLine).trim();
    if (line.isEmpty) return null;

    final sep = line.indexOf('=');
    if (sep <= 0) return null;

    final key = _stripExportKeyword(line.substring(0, sep).trim());
    if (!_validKey.hasMatch(key)) return null;

    final rawValue = line.substring(sep + 1).trim();
    final quote = _quoteChar(rawValue);
    final value = _unquote(rawValue, quote);

    // single quotes => literal, exactly like a real shell
    final resolved = quote == "'" ? value : interpolate(value, knownVars);
    return MapEntry(key, resolved);
  }

  /// Replaces `$VAR` / `${VAR}` using [env], then `Platform.environment`,
  /// then `''`. A backslash-escaped `\$VAR` is left as the literal text.
  String interpolate(String value, Map<String, String> env) {
    return value.replaceAllMapped(_variableRef, (m) {
      final escaped = m.group(1) != null;
      final name = m.group(2) ?? m.group(3)!;
      if (escaped) return '\$$name';
      return env[name] ?? Platform.environment[name] ?? '';
    });
  }

  String _stripExportKeyword(String lhs) {
    if (lhs.startsWith('$_exportKeyword ') ||
        lhs.startsWith('$_exportKeyword\t')) {
      return lhs.substring(_exportKeyword.length).trim();
    }
    return lhs; // don't touch keys that merely *contain* "export"
  }

  /// Quote-aware comment stripper: scans char by char instead of relying
  /// on a fragile end-of-line regex, so a `#` inside a quoted value is
  /// never mistaken for a comment.
  String _stripComment(String line) {
    String? openQuote;
    for (var i = 0; i < line.length; i++) {
      final ch = line[i];
      if (openQuote != null) {
        final escaped = openQuote == '"' && i > 0 && line[i - 1] == r'\';
        if (ch == openQuote && !escaped) openQuote = null;
        continue;
      }
      if (ch == "'" || ch == '"') {
        openQuote = ch;
      } else if (ch == '#' &&
          (i == 0 || line[i - 1] == ' ' || line[i - 1] == '\t')) {
        return line.substring(0, i);
      }
    }
    return line;
  }

  String? _quoteChar(String value) =>
      _surroundingQuotes.firstMatch(value)?.group(1);

  String _unquote(String value, String? quote) {
    final match = _surroundingQuotes.firstMatch(value);
    if (match == null) return value;
    final inner = match.group(2)!;
    if (quote == '"') {
      return inner.replaceAll(r'\"', '"').replaceAll(r'\\', r'\');
    }
    return inner;
  }
}
