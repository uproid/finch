import 'package:finch/src/views/htmler.dart';
import 'package:finch/src/widgets/finch_string_widget.dart';
import 'package:finch/finch_tools.dart';

/// A widget that provides an HTML layout for displaying error messages.
/// The [InlineDumpWidget] class implements [FinchStringWidget] and provides a predefined
/// HTML structure to be used for rendering error messages in the application.
/// It includes styles and structure for displaying error details and stack traces.
class InlineDumpWidget implements FinchStringWidget {
  @override
  final String layout = '';

  @override
  Tag Function(Map args)? generateHtml = (args) {
    String id = DateTime.now().millisecondsSinceEpoch.toString();
    dynamic variable = args['var'];
    int idCounter = 0;
    String jsonContent = FinchJson.jsonEncoder(variable);

    String generateJsonHtml(dynamic obj, {int level = 0, String key = ''}) {
      String indent = '  ' * level;
      String keyHtml =
          key.isNotEmpty ? '<span class="json-key">"$key"</span>: ' : '';

      if (obj == null) {
        return '$indent$keyHtml<span class="json-null">null</span>';
      } else if (obj is bool) {
        return '$indent$keyHtml<span class="json-boolean">$obj</span>';
      } else if (obj is num) {
        return '$indent$keyHtml<span class="json-number">$obj</span>';
      } else if (obj is String) {
        return '$indent$keyHtml<span class="json-string">"$obj"</span>';
      } else if (obj is List) {
        if (obj.isEmpty) {
          return '$indent$keyHtml<span class="json-bracket">[]</span>';
        }

        String collapseId = 'collapse-${++idCounter}';
        StringBuffer buffer = StringBuffer();

        // Add collapsible header for array
        buffer.write('$indent$keyHtml');
        buffer.write('<span class="json-collapsible-header">');
        buffer.write(
            '<span class="json-toggle" onclick="(function(){ const content = document.getElementById(\'$collapseId\'); if (content.classList.contains(\'collapsed\')) { content.classList.remove(\'collapsed\'); this.classList.remove(\'collapsed\'); this.textContent = \'▼\'; } else { content.classList.add(\'collapsed\'); this.classList.add(\'collapsed\'); this.textContent = \'▶\'; } }).call(this)">▼</span>');
        buffer.write('<span class="json-bracket">[</span>');
        buffer.write('<span class="json-preview"> ${obj.length} items</span>');
        buffer.write('</span>\n');

        // Add collapsible content
        buffer.write('<div id="$collapseId" class="json-collapsible-content">');
        for (int i = 0; i < obj.length; i++) {
          buffer.write(generateJsonHtml(obj[i], level: level + 1));
          if (i < obj.length - 1) buffer.write(',');
          buffer.write('\n');
        }
        buffer.write('</div>');
        buffer.write('$indent<span class="json-bracket">]</span>');
        return buffer.toString();
      } else if (obj is Map) {
        if (obj.isEmpty) {
          return '$indent$keyHtml<span class="json-bracket">{}</span>';
        }

        String collapseId = 'collapse-${++idCounter}';
        StringBuffer buffer = StringBuffer();
        List<String> keys = obj.keys.map((k) => k.toString()).toList();

        // Add collapsible header for object
        buffer.write('$indent$keyHtml');
        buffer.write('<span class="json-collapsible-header">');
        buffer.write(
            '<span class="json-toggle" onclick="(function(){ const content = document.getElementById(\'$collapseId\'); if (content.classList.contains(\'collapsed\')) { content.classList.remove(\'collapsed\'); this.classList.remove(\'collapsed\'); this.textContent = \'▼\'; } else { content.classList.add(\'collapsed\'); this.classList.add(\'collapsed\'); this.textContent = \'▶\'; } }).call(this)">▼</span>');
        buffer.write('<span class="json-bracket">{</span>');
        buffer.write(
            '<span class="json-preview"> ${keys.length} properties</span>');
        buffer.write('</span>\n');

        // Add collapsible content
        buffer.write('<div id="$collapseId" class="json-collapsible-content">');
        for (int i = 0; i < keys.length; i++) {
          String k = keys[i];
          buffer.write(generateJsonHtml(obj[k], level: level + 1, key: k));
          if (i < keys.length - 1) buffer.write(',');
          buffer.write('\n');
        }
        buffer.write('</div>');
        buffer.write('$indent<span class="json-bracket">}</span>');
        return buffer.toString();
      } else {
        // For other types, convert to string
        return '$indent$keyHtml<span class="json-string">"${obj.toString()}"</span>';
      }
    }

    String jsonHtml = generateJsonHtml(variable);

    var res = ArrayTag(children: [
      $Style().addChild(
        $Raw('''.wa-debug-dump { 
              direction: ltr;
              margin: 0; 
              padding: 10px; 
              background-color: #1e1e1e; 
              font-family: 'Consolas', 'Monaco', 'Courier New', monospace; 
              font-size: 12px;
              line-height: 1.4;
              border: 1px solid #404040;
              border-radius: 8px;
              color: #d4d4d4;
              overflow: auto;
              max-height: 600px;
            }
            .wa-debug-dump .json-viewer {
              white-space: pre;
              font-family: inherit;
            }
            .wa-debug-dump .json-key {
              color: #9cdcfe;
              font-weight: bold;
            }
            .wa-debug-dump .json-string {
              color: #ce9178;
            }
            .wa-debug-dump .json-number {
              color: #b5cea8;
            }
            .wa-debug-dump .json-boolean {
              color: #569cd6;
              font-weight: bold;
            }
            .wa-debug-dump .json-null {
              color: #569cd6;
              font-weight: bold;
              font-style: italic;
            }
            .wa-debug-dump .json-bracket {
              color: #ffd700;
              font-weight: bold;
            }
            .wa-debug-dump .json-collapsible-header {
              cursor: pointer;
              user-select: none;
            }
            .wa-debug-dump .json-toggle {
              color: #808080;
              margin-right: 4px;
              font-size: 10px;
              display: inline-block;
              width: 12px;
              text-align: center;
              transition: transform 0.2s ease;
            }
            .wa-debug-dump .json-toggle:hover {
              color: #ffffff;
            }
            .wa-debug-dump .json-toggle.collapsed {
              transform: rotate(-90deg);
            }
            .wa-debug-dump .json-collapsible-content {
              overflow: hidden;
              transition: max-height 0.3s ease;
            }
            .wa-debug-dump .json-collapsible-content.collapsed {
              max-height: 0;
              display: none;
            }
            .wa-debug-dump .json-preview {
              color: #808080;
              font-style: italic;
              font-size: 11px;
            }
            .wa-debug-dump .json-toolbar {
              float: right;
              padding: 2px;
              background-color: #2d2d30;
              border-radius: 4px;
              border: 1px solid #404040;
            }
            .wa-debug-dump .json-copy-btn {
              background: #0078d4;
              color: white;
              border: none;
              padding: 6px 6px;
              border-radius: 4px;
              cursor: pointer;
              font-size: 12px;
              font-family: inherit;
            }
            .wa-debug-dump .json-copy-btn:hover {
              background: #106ebe;
            }
            .wa-debug-dump .json-copy-btn:active {
              background: #005a9e;
            }
          '''),
      ),
      $Div(
        classes: ['wa-debug-dump'],
        children: [
          $Div(
            classes: ['json-toolbar'],
            children: [
              $Button(
                classes: ['json-copy-btn'],
                attrs: {
                  'onclick': '''copyJsonToClipboard$id(this)''',
                },
                children: [
                  $Raw(
                    '<svg width="14" height="14" viewBox="0 0 16 16"'
                    ' fill="currentColor"><path d="M4 1.5H3a2 2 0 0 '
                    '0-2 2V14a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2V3.5a2 2'
                    ' 0 0 0-2-2h-1v1h1a1 1 0 0 1 1 1V14a1 1 0 0 1-1 '
                    '1H3a1 1 0 0 1-1-1V3.5a1 1 0 0 1 1-1h1v-1z"/><pa'
                    'th d="M9.5 1a.5.5 0 0 1 .5.5v1a.5.5 0 0 1-.5.5h'
                    '-3a.5.5 0 0 1-.5-.5v-1a.5.5 0 0 1 .5-.5h3zm-3-1'
                    'A1.5 1.5 0 0 0 5 1.5v1A1.5 1.5 0 0 0 6.5 4h3A1.'
                    '5 1.5 0 0 0 11 2.5v-1A1.5 1.5 0 0 0 9.5 0h-3z"/'
                    '></svg>',
                  ),
                ],
              ),
            ],
          ),
          $Div(
            classes: ['json-viewer'],
            children: [
              $Raw(jsonHtml),
              $Script(children: [
                $Raw('''
                  function copyJsonToClipboard$id(btn) {
                    const jsonContent = `$jsonContent`;
                    navigator.clipboard.writeText(jsonContent).then(() => {
                      btn.style.background = '#107c10';
                      setTimeout(() => {
                        btn.style.background = '#0078d4';
                      }, 1500);
                    }).catch(() => {
                      alert('Failed to copy to clipboard');
                    });
                  }
      ''')
              ])
            ],
          ),
        ],
      ),
    ]);
    return res;
  };
}
