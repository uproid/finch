/// A utility class for formatting HTML strings with proper indentation and line breaks.
/// This formatter preserves the exact HTML content and functionality while making
/// it more readable by adding appropriate formatting.
class HtmlFormatter {
  static const String _defaultIndent = ' ';

  /// Formats an HTML string with proper indentation and line breaks.
  ///
  /// [html] - The HTML string to format
  /// [indent] - The indentation string to use (default: two spaces)
  /// [preserveWhitespace] - Whether to preserve existing whitespace in text content
  ///
  /// Returns a formatted HTML string that maintains the same output when rendered.
  static String format(String html,
      {String indent = _defaultIndent, bool preserveWhitespace = false}) {
    if (html.trim().isEmpty) return html;

    final formatter = HtmlFormatter._internal(indent, preserveWhitespace);
    return formatter._formatHtml(html);
  }

  final String _indent;
  final bool _preserveWhitespace;

  HtmlFormatter._internal(this._indent, this._preserveWhitespace);

  String _formatHtml(String html) {
    final buffer = StringBuffer();
    int level = 0;
    int i = 0;

    while (i < html.length) {
      if (html[i] == '<') {
        // Found start of a tag
        final tagEnd = _findTagEnd(html, i);
        if (tagEnd == -1) {
          buffer.write(html[i]);
          i++;
          continue;
        }

        final tag = html.substring(i, tagEnd + 1);

        // Handle special cases first
        if (_isSpecialTag(tag)) {
          _addIndentation(buffer, level);
          buffer.write(tag);
          buffer.write('\n');
          i = tagEnd + 1;
          continue;
        }

        final tagInfo = _parseTag(tag);

        if (tagInfo.isClosing) {
          level--;
          _addIndentation(buffer, level);
          buffer.write(tag);
          buffer.write('\n');
        } else if (tagInfo.isSelfClosing || _isSelfClosingTag(tagInfo.name)) {
          _addIndentation(buffer, level);
          buffer.write(tag);
          buffer.write('\n');
        } else {
          // Check if this is a simple text-only tag
          final simpleTagInfo = _checkIfSimpleTextTag(html, i);
          if (simpleTagInfo != null) {
            _addIndentation(buffer, level);
            buffer.write(simpleTagInfo.fullTag);
            buffer.write('\n');
            i = simpleTagInfo.endIndex;
            continue;
          } else {
            _addIndentation(buffer, level);
            buffer.write(tag);
            buffer.write('\n');
            level++;
          }
        }

        i = tagEnd + 1;
      } else {
        // Found text content
        final textEnd = _findNextTag(html, i);
        final text = html.substring(i, textEnd).trim();

        if (text.isNotEmpty) {
          if (_preserveWhitespace) {
            _addIndentation(buffer, level);
            buffer.write(html.substring(i, textEnd));
            buffer.write('\n');
          } else {
            _addIndentation(buffer, level);
            buffer.write(text);
            buffer.write('\n');
          }
        }

        i = textEnd;
      }
    }

    return buffer.toString().trim();
  }

  int _findTagEnd(String html, int start) {
    bool inQuotes = false;
    String? quoteChar;

    for (int i = start + 1; i < html.length; i++) {
      final char = html[i];

      if (!inQuotes && (char == '"' || char == "'")) {
        inQuotes = true;
        quoteChar = char;
      } else if (inQuotes && char == quoteChar) {
        inQuotes = false;
        quoteChar = null;
      } else if (!inQuotes && char == '>') {
        return i;
      }
    }

    return -1;
  }

  int _findNextTag(String html, int start) {
    for (int i = start; i < html.length; i++) {
      if (html[i] == '<') {
        return i;
      }
    }
    return html.length;
  }

  /// Checks if a tag contains only simple text (no nested tags) or is empty
  /// Returns null if it's not a simple text tag, otherwise returns the full tag info
  _SimpleTagInfo? _checkIfSimpleTextTag(String html, int startIndex) {
    final tagEnd = _findTagEnd(html, startIndex);
    if (tagEnd == -1) return null;

    final openTag = html.substring(startIndex, tagEnd + 1);
    final tagInfo = _parseTag(openTag);

    // Skip if it's already self-closing or a closing tag
    if (tagInfo.isSelfClosing ||
        tagInfo.isClosing ||
        _isSelfClosingTag(tagInfo.name)) {
      return null;
    }

    // Find the closing tag
    final closingTag = '</${tagInfo.name}>';
    final contentStart = tagEnd + 1;
    final closingTagIndex = html.indexOf(closingTag, contentStart);

    if (closingTagIndex == -1) return null;

    // Get the content between tags
    final content = html.substring(contentStart, closingTagIndex);

    // Check if content contains any HTML tags
    if (content.contains('<')) return null;

    // Check if content is empty OR simple text (not too long and no line breaks)
    final trimmedContent = content.trim();
    if (trimmedContent.isEmpty) {
      // Empty tag - keep on one line
      final fullTag = openTag + closingTag;
      final endIndex = closingTagIndex + closingTag.length;
      return _SimpleTagInfo(fullTag: fullTag, endIndex: endIndex);
    } else if (trimmedContent.length <= 100 && !trimmedContent.contains('\n')) {
      // Simple text tag - keep on one line
      final fullTag = openTag + trimmedContent + closingTag;
      final endIndex = closingTagIndex + closingTag.length;
      return _SimpleTagInfo(fullTag: fullTag, endIndex: endIndex);
    }

    return null;
  }

  _TagInfo _parseTag(String tag) {
    final trimmed = tag.substring(1, tag.length - 1).trim();

    if (trimmed.startsWith('/')) {
      return _TagInfo(
        name: trimmed.substring(1).trim().split(' ')[0],
        isClosing: true,
        isSelfClosing: false,
      );
    }

    if (trimmed.endsWith('/')) {
      return _TagInfo(
        name: trimmed.substring(0, trimmed.length - 1).trim().split(' ')[0],
        isClosing: false,
        isSelfClosing: true,
      );
    }

    return _TagInfo(
      name: trimmed.split(' ')[0],
      isClosing: false,
      isSelfClosing: false,
    );
  }

  bool _isSelfClosingTag(String tagName) {
    final selfClosingTags = {
      'area',
      'base',
      'br',
      'col',
      'embed',
      'hr',
      'img',
      'input',
      'link',
      'meta',
      'param',
      'source',
      'track',
      'wbr'
    };
    return selfClosingTags.contains(tagName.toLowerCase());
  }

  /// Checks if a tag is a special tag that should not be nested (DOCTYPE, comments, etc.)
  bool _isSpecialTag(String tag) {
    final trimmed = tag.trim().toLowerCase();

    // DOCTYPE declaration
    if (trimmed.startsWith('<!doctype')) {
      return true;
    }

    // HTML comments
    if (trimmed.startsWith('<!--')) {
      return true;
    }

    // XML declarations
    if (trimmed.startsWith('<?xml')) {
      return true;
    }

    // CDATA sections
    if (trimmed.startsWith('<![cdata[')) {
      return true;
    }

    return false;
  }

  void _addIndentation(StringBuffer buffer, int level) {
    for (int i = 0; i < level; i++) {
      buffer.write(_indent);
    }
  }
}

/// Helper class to hold tag information during parsing.
class _TagInfo {
  final String name;
  final bool isClosing;
  final bool isSelfClosing;

  const _TagInfo({
    required this.name,
    required this.isClosing,
    required this.isSelfClosing,
  });
}

/// Helper class to hold simple text tag information.
class _SimpleTagInfo {
  final String fullTag;
  final int endIndex;

  const _SimpleTagInfo({
    required this.fullTag,
    required this.endIndex,
  });
}

/// Extension methods for HtmlFormatter to provide additional formatting options.
extension HtmlFormatterExtension on String {
  /// Formats this HTML string with default settings.
  String formatHtml({String indent = '  ', bool preserveWhitespace = false}) {
    return HtmlFormatter.format(this,
        indent: indent, preserveWhitespace: preserveWhitespace);
  }

  /// Formats this HTML string with compact formatting (minimal whitespace).
  String formatHtmlCompact() {
    return HtmlFormatter.format(this, indent: '', preserveWhitespace: false);
  }

  /// Formats this HTML string with tab indentation.
  String formatHtmlWithTabs() {
    return HtmlFormatter.format(this, indent: '\t', preserveWhitespace: false);
  }
}
