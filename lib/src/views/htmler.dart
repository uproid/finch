import 'dart:convert';
import 'package:finch/finch_app.dart';

/// Enumeration defining the types of HTML tags.
/// This enum distinguishes between different HTML tag structures:
/// - [single]: Self-closing tags that don't have content (e.g., `<br/>`, `<img/>`)
/// - [double]: Container tags with opening and closing parts (e.g., `<div></div>`, `<p></p>`)
enum TagType {
  /// Self-closing HTML tags like `<br/>`, `<img/>`, `<input/>`
  single,

  /// Container HTML tags with opening and closing parts like `<div></div>`, `<span></span>`
  double,
}

/// Abstract base class for creating and manipulating HTML elements programmatically.
/// [Tag] provides a foundation for building HTML structures in Dart code with
/// support for attributes, child elements, CSS classes, and inline styles.
/// It offers a fluent API for chaining operations and maintains the hierarchical
/// structure of HTML documents.
/// Key features:
/// - Dynamic attribute management
/// - CSS class manipulation
/// - Inline style handling
/// - Child element management
/// - HTML string generation
/// - Fluent method chaining
/// Example usage:
/// ```dart
/// final div = CustomTag('div')
///   .addClass('container')
///   .addAttr('data-id', '123')
///   .addStyle('background-color', 'blue')
///   .addChild(CustomTag('p').addChild(TextTag('Hello World')));
/// String html = div.toHtml();
/// // Result: <div class="container" data-id="123" style="background-color: blue; "><p>Hello World</p></div>
/// ```
abstract class Tag {
  TagType type = TagType.double;
  String _tag = "html";
  String get tagName => _tag;
  late Map<dynamic, dynamic> attrs;
  late List<Tag> children;
  List<dynamic> classes;

  @override
  String toString({bool pretty = false}) {
    return toHtml();
  }

  Tag({
    Map<dynamic, dynamic>? attrs,
    List<Tag>? children,
    this.classes = const [],
  }) {
    this.attrs = attrs ?? {};
    if (classes.isNotEmpty) {
      this.attrs['class'] = classes.join(' ');
    }
    this.children = children ?? [];
  }

  Tag addChild(Tag child) {
    children.add(child);
    return this;
  }

  Tag removeChild(Tag child) {
    children.remove(child);
    return this;
  }

  Tag addAttr(String key, dynamic value) {
    attrs[key] = value;
    return this;
  }

  Tag removeAttr(String key) {
    attrs.remove(key);
    return this;
  }

  Tag clearChildren() {
    children.clear();
    return this;
  }

  Tag addClass(dynamic className) {
    List existingClasses = attrs['class']?.split(' ') ?? [];
    existingClasses.add(className.toString());
    attrs['class'] = existingClasses.join(' ');
    return this;
  }

  Tag removeClass(String className) {
    final existingClasses = attrs['class']?.split(' ') ?? [];
    existingClasses.remove(className);
    attrs['class'] = existingClasses.join(' ');
    return this;
  }

  Tag clearClasses() {
    attrs.remove('class');
    return this;
  }

  Tag addStyle(String property, String value) {
    attrs['style'] = '${attrs['style'] ?? ''}$property: $value; ';
    return this;
  }

  Tag removeStyle(String property) {
    final style = attrs['style'] ?? '';
    final newStyle =
        style.split('; ').where((s) => !s.startsWith('$property:')).join('; ');
    attrs['style'] = newStyle;
    return this;
  }

  Tag clearStyles() {
    attrs.remove('style');
    return this;
  }

  Tag setId(String id) {
    attrs['id'] = id;
    return this;
  }

  Tag setClass(String className) {
    attrs['class'] = className;
    return this;
  }

  Tag setStyle(String property, String value) {
    attrs['style'] = '${attrs['style'] ?? ''}$property: $value; ';
    return this;
  }

  String attrKey(dynamic key) {
    if (key is Symbol) {
      var res = key.toString().split('"')[1].replaceFirst('_', '');
      return res;
    }
    return key.toString();
  }

  String toHtml() {
    final buffer = StringBuffer();
    var attr = "";
    if (attrs.isNotEmpty) {
      attr = attrs.entries
          .map((e) => '${attrKey(e.key)}="${e.value.toString()}"')
          .join(' ');
      attr = ' $attr';
    }

    buffer.write('<$_tag$attr');
    if (type == TagType.single) {
      return '$buffer/>';
    } else {
      buffer.write('>');
    }
    for (var child in children) {
      buffer.write(child.toHtml());
    }
    buffer.write('</$_tag>');
    var res = buffer.toString();
    return res;
  }
}

/// Abstract base class for Jinja template engine tags.
/// [JinjaTag] extends [Tag] to provide specialized support for Jinja2-style
/// template syntax within the HTML generation system. These tags generate
/// template directives that are processed by the template engine rather
/// than rendered as standard HTML elements.
abstract class JinjaTag extends Tag {
  JinjaTag({super.attrs, super.children, super.classes});
}

/// Represents a single Jinja command block for template logic.
/// [$Jinja] generates template blocks using the configured block delimiters
/// (typically `<? command ?>`). These blocks contain template logic such as
/// variable assignments, conditionals, loops, and other Jinja directives.
/// Example usage:
/// ```dart
/// final ifBlock = $Jinja('if user.is_authenticated');
/// // Generates: <? if user.is_authenticated ?>
/// final setVar = $Jinja('set title = "Welcome"');
/// // Generates: <? set title = "Welcome" ?>
/// ```
class $Jinja extends JinjaTag {
  String command;

  $Jinja(this.command);

  @override
  String toHtml() {
    return '${FinchApp.config.blockStart}'
        ' $command '
        '${FinchApp.config.blockEnd}';
  }
}

/// Represents a Jinja template block with opening and closing commands.
/// [$JinjaBody] creates template structures that have both opening and closing
/// directives with content in between. This is useful for control structures
/// like loops, conditionals, and custom blocks that wrap other content.
/// Example usage:
/// ```dart
/// final forLoop = $JinjaBody(
///   commandUp: 'for item in items',
///   commandDown: 'endfor',
///   children: [
///     CustomTag('li').addChild(TextTag('{{ item.name }}')),
///   ],
/// );
/// // Generates: <? for item in items ?><li>{{ item.name }}</li><? endfor ?>
/// ```
class $JinjaBody extends JinjaTag {
  String commandUp;
  String commandDown;
  $JinjaBody({
    required this.commandUp,
    required super.children,
    required this.commandDown,
  });
  @override
  String toHtml() {
    var res = "${FinchApp.config.blockStart}"
        " $commandUp "
        "${FinchApp.config.blockEnd}";
    for (var child in children) {
      res += child.toHtml();
    }
    res += "${FinchApp.config.blockStart}"
        " $commandDown "
        "${FinchApp.config.blockEnd}";
    return res;
  }
}

/// Represents a Jinja template block definition.
/// [$JinjaBlock] creates named template blocks that can be extended or overridden
/// in child templates. This is a fundamental feature of Jinja's template inheritance
/// system, allowing for modular and reusable template structures.
/// Example usage:
/// ```dart
/// final contentBlock = $JinjaBlock(
///   blockName: 'content',
///   children: [
///     CustomTag('h1').addChild(TextTag('Default Content')),
///     CustomTag('p').addChild(TextTag('This can be overridden')),
///   ],
/// );
/// // Generates: <? block content ?><h1>Default Content</h1><p>This can be overridden</p><? endblock ?>
/// ```
class $JinjaBlock extends $JinjaBody {
  $JinjaBlock({
    required String blockName,
    super.children,
  }) : super(
          commandUp: 'block $blockName',
          commandDown: 'endblock',
        );
}

/// Represents a Jinja template include directive.
/// [$JinjaInclude] generates template include statements that insert the contents
/// of another template file at the current location. This enables template
/// composition and code reuse across multiple template files.
/// Example usage:
/// ```dart
/// final header = $JinjaInclude('header.html');
/// // Generates: <? include 'header.html' ?>
/// final sidebar = $JinjaInclude('components/sidebar.html');
/// // Generates: <? include 'components/sidebar.html' ?>
/// ```
class $JinjaInclude extends $Jinja {
  $JinjaInclude(String template) : super("include '$template'");
}

/// Represents a Jinja variable output expression.
/// [$JinjaVar] generates variable output expressions using the configured
/// variable delimiters (typically `<?= variable ?>`). These expressions
/// are evaluated by the template engine and their values are inserted
/// into the final HTML output.
/// Example usage:
/// ```dart
/// final userName = $JinjaVar('user.name');
/// // Generates: <?= user.name ?>
/// final greeting = $JinjaVar('greeting | upper');
/// // Generates: <?= greeting | upper ?>
/// ```
class $JinjaVar extends JinjaTag {
  String command;
  $JinjaVar(this.command);

  @override
  String toHtml() {
    return '${FinchApp.config.variableStart} $command ${FinchApp.config.variableEnd}';
  }
}

/// Represents a Jinja template comment.
/// [$JinjaComment] generates template comments using the configured comment
/// delimiters (typically `<?# comment ?>`). These comments are processed
/// by the template engine and do not appear in the final HTML output,
/// making them useful for template documentation and debugging.
/// Example usage:
/// ```dart
/// final note = $JinjaComment('This section renders user profile information');
/// // Generates: <?# This section renders user profile information ?>
/// final todo = $JinjaComment('TODO: Add pagination support');
/// // Generates: <?# Add pagination support ?>
/// ```
class $JinjaComment extends JinjaTag {
  String content;
  $JinjaComment(this.content);

  @override
  String toHtml() {
    return "${FinchApp.config.commentStart} $content ${FinchApp.config.commentEnd}";
  }
}

class $CustomTag extends Tag {
  @override
  $CustomTag(
    String tag, {
    super.attrs,
    super.children,
    var type = TagType.double,
    super.classes,
  }) {
    _tag = tag;
    this.type = type;
  }
}

abstract class SingleTag extends Tag {
  @override
  get type => TagType.single;
  SingleTag({super.attrs, super.classes});
}

class ArrayTag extends Tag {
  @override
  get _tag => "block";
  ArrayTag({super.children});

  @override
  String toHtml() {
    final buffer = StringBuffer();
    for (var child in children) {
      buffer.write(child.toHtml());
    }
    return buffer.toString();
  }
}

class $Html extends Tag {
  @override
  get _tag => "html";
  $Html({super.attrs, super.children, super.classes});
}

class $Doctype extends SingleTag {
  List<String> params = <String>[];
  @override
  $Doctype([this.params = const ['html']]);

  @override
  String toHtml() {
    return '<!DOCTYPE ${params.join(" ")}>';
  }
}

class $Head extends Tag {
  @override
  get _tag => "head";
  $Head({super.attrs, super.children, super.classes});
}

class $Raw extends Tag {
  String content;

  $Raw(
    this.content, {
    super.classes,
  });

  @override
  String toHtml() {
    return content;
  }
}

class $Text extends Tag {
  String content;

  $Text(this.content, {super.classes});

  @override
  String toHtml() {
    return htmlEscape.convert(content);
  }
}

class $Div extends Tag {
  @override
  get _tag => "div";
  $Div({super.attrs, super.children, super.classes});
}

class $Code extends Tag {
  @override
  get _tag => "code";
  $Code({super.attrs, super.children, super.classes});
}

class $Body extends Tag {
  @override
  get _tag => "body";
  $Body({super.attrs, super.children, super.classes});
}

class $Span extends Tag {
  @override
  get _tag => "span";
  $Span({super.attrs, super.children, super.classes});
}

class $A extends Tag {
  @override
  get _tag => "a";
  $A({super.attrs, super.children, super.classes});
}

class $B extends Tag {
  @override
  get _tag => "b";
  $B({super.attrs, super.children, super.classes});
}

class $I extends Tag {
  @override
  get _tag => "i";
  $I({super.attrs, super.children, super.classes});
}

class $U extends Tag {
  @override
  get _tag => "u";
  $U({super.attrs, super.children, super.classes});
}

class $P extends Tag {
  @override
  get _tag => "p";
  $P({super.attrs, super.children, super.classes});
}

class $Br extends SingleTag {
  @override
  get _tag => "br";
  $Br({super.attrs, super.classes});
}

class $Hr extends SingleTag {
  @override
  get _tag => "hr";
  $Hr({super.attrs, super.classes});
}

class $Wbr extends SingleTag {
  @override
  get _tag => "wbr";
  $Wbr({super.attrs, super.classes});
}

class $Button extends Tag {
  @override
  get _tag => "button";
  $Button({super.attrs, super.children, super.classes});
}

class $Input extends SingleTag {
  @override
  get _tag => "input";
  $Input({super.attrs, super.classes});
}

class $TextArea extends Tag {
  @override
  get _tag => "textarea";
  $TextArea({super.attrs, super.children, super.classes});
}

class $Label extends Tag {
  @override
  get _tag => "label";
  $Label({super.attrs, super.children, super.classes});
}

class $Form extends Tag {
  @override
  get _tag => "form";
  $Form({super.attrs, super.children, super.classes});
}

class $Select extends Tag {
  @override
  get _tag => "select";
  $Select({super.attrs, super.children, super.classes});
}

class $Option extends Tag {
  @override
  get _tag => "option";
  $Option({super.attrs, super.children, super.classes});
}

class $Ul extends Tag {
  @override
  get _tag => "ul";
  $Ul({super.attrs, super.children, super.classes});
}

class $Li extends Tag {
  @override
  get _tag => "li";
  $Li({super.attrs, super.children, super.classes});
}

class $Center extends Tag {
  @override
  get _tag => "center";
  $Center({super.attrs, super.children, super.classes});
}

class $Main extends Tag {
  @override
  get _tag => "main";
  $Main({super.attrs, super.children, super.classes});
}

class $Footer extends Tag {
  @override
  get _tag => "footer";
  $Footer({super.attrs, super.children, super.classes});
}

class $Header extends Tag {
  @override
  get _tag => "header";
  $Header({super.attrs, super.children, super.classes});
}

class $Nav extends Tag {
  @override
  get _tag => "nav";
  $Nav({super.attrs, super.children, super.classes});
}

class $Section extends Tag {
  @override
  get _tag => "section";
  $Section({super.attrs, super.children, super.classes});
}

class $Article extends Tag {
  @override
  get _tag => "article";
  $Article({super.attrs, super.children, super.classes});
}

class $Template extends Tag {
  @override
  get _tag => "template";
  $Template({super.attrs, super.children, super.classes});
}

class $Aside extends Tag {
  @override
  get _tag => "aside";
  $Aside({super.attrs, super.children, super.classes});
}

class $Ol extends Tag {
  @override
  get _tag => "ol";
  $Ol({super.attrs, super.children, super.classes});
}

class $H1 extends Tag {
  @override
  get _tag => "h1";
  $H1({super.attrs, super.children, super.classes});
}

class $H2 extends Tag {
  @override
  get _tag => "h2";
  $H2({super.attrs, super.children, super.classes});
}

class $H3 extends Tag {
  @override
  get _tag => "h3";
  $H3({super.attrs, super.children, super.classes});
}

class $H4 extends Tag {
  @override
  get _tag => "h4";
  $H4({super.attrs, super.children, super.classes});
}

class $H5 extends Tag {
  @override
  get _tag => "h5";
  $H5({super.attrs, super.children, super.classes});
}

class $H6 extends Tag {
  @override
  get _tag => "h6";
  $H6({super.attrs, super.children, super.classes});
}

class $H7 extends Tag {
  @override
  get _tag => "h7";
  $H7({super.attrs, super.children, super.classes});
}

class $Small extends Tag {
  @override
  get _tag => "small";
  $Small({super.attrs, super.children, super.classes});
}

class $Meta extends SingleTag {
  @override
  get _tag => "meta";
  $Meta({super.attrs, super.classes});
}

class $Link extends SingleTag {
  @override
  get _tag => "link";
  $Link({super.attrs, super.classes});
}

class $Script extends Tag {
  @override
  get _tag => "script";
  $Script({super.attrs, super.children, super.classes});
}

class $Noscript extends Tag {
  @override
  get _tag => "noscript";
  $Noscript({super.attrs, super.classes});
}

class $Title extends Tag {
  @override
  get _tag => "title";
  $Title({super.attrs, super.children, super.classes});
}

class $Style extends Tag {
  @override
  get _tag => "style";
  $Style({super.attrs, super.children, super.classes});
}

class $Table extends Tag {
  @override
  get _tag => "table";
  $Table({super.attrs, super.children, super.classes});
}

class $Thead extends Tag {
  @override
  get _tag => "thead";
  $Thead({super.attrs, super.children, super.classes});
}

class $Tbody extends Tag {
  @override
  get _tag => "tbody";
  $Tbody({super.attrs, super.children, super.classes});
}

class $Tr extends Tag {
  @override
  get _tag => "tr";
  $Tr({super.attrs, super.children, super.classes});
}

class $Th extends Tag {
  @override
  get _tag => "th";
  $Th({super.attrs, super.children, super.classes});
}

class $Td extends Tag {
  @override
  get _tag => "td";
  $Td({super.attrs, super.children, super.classes});
}

class $Caption extends Tag {
  @override
  get _tag => "caption";
  $Caption({super.attrs, super.children, super.classes});
}

class $Tfoot extends Tag {
  @override
  get _tag => "tfoot";
  $Tfoot({super.attrs, super.children, super.classes});
}

class $Comment extends Tag {
  Tag content;

  $Comment(this.content)
      : super(
          children: [],
          classes: const [],
        );

  @override
  String toHtml() {
    return '<!-- ${content.toHtml()} -->';
  }
}

class $Svg extends Tag {
  @override
  get _tag => "svg";
  $Svg({super.attrs, super.children, super.classes});
}

class $Path extends Tag {
  @override
  get _tag => "path";
  $Path({super.attrs, super.children, super.classes});
}

class $Details extends Tag {
  @override
  get _tag => "details";
  $Details({super.attrs, super.children, super.classes});
}

class $Summary extends Tag {
  @override
  get _tag => "summary";
  $Summary({super.attrs, super.children, super.classes});
}

class $Video extends Tag {
  @override
  get _tag => "video";
  $Video({super.attrs, super.children, super.classes});
}

class $Img extends SingleTag {
  @override
  get _tag => "img";
  $Img({super.attrs, super.classes});
}

class $Cache extends ArrayTag {
  String _html = '';
  bool get isCached => _html.isNotEmpty;
  String get cachedHtml => _html;

  $Cache({super.children});

  @override
  String toHtml() {
    if (_html.isNotEmpty) return _html;
    _html = super.toHtml();
    return _html;
  }
}

/// Helper class for Jinja tags
/// With this class, you can create Jinja tags easily.
/// Usage:
///   JJ.$include('template.html')
///   JJ.$var('variable_name')
///   JJ.$if('condition', then: [JJ.$var('then_var')], otherwise: [JJ.$var('else_var')])
///   JJ.$for(item: 'item', inList: 'items', body: [JJ.$var('item')])
/// etc.
class JJ {
  static Tag $include(String template) => $JinjaInclude(template);
  static Tag $var(String name) => $JinjaVar(name);
  static Tag $comment(String content) => $JinjaComment(content);

  static Tag $if(
    String condition, {
    List<Tag> then = const [],
    List<Tag> otherwise = const [],
  }) {
    return $JinjaBody(
      commandUp: 'if $condition',
      children: [
        ...then,
        if (otherwise.isNotEmpty) ...[
          $Jinja('else'),
          ...otherwise,
        ]
      ],
      commandDown: 'endif',
    );
  }

  static Tag $shortIf(String condition, String then, [String otherwise = '']) {
    return $JinjaVar(
        '$then if $condition ${otherwise.isEmpty ? '' : 'else $otherwise'}');
  }

  static Tag $for(
      {required String item,
      required String inList,
      List<Tag> body = const []}) {
    return $JinjaBody(
      commandUp: 'for $item in $inList',
      children: body,
      commandDown: 'endfor',
    );
  }
}
