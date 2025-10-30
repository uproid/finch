import 'package:test/test.dart';
import 'package:finch/src/views/htmler.dart';
import 'package:finch/finch_app.dart';

void main() {
  var template = ArrayTag(
    children: [
      $Doctype(),
      $Html(attrs: {
        'lang': 'en'
      }, children: [
        $Head(children: [
          $Meta(attrs: {'charset': 'UTF-8'}),
          $Meta(attrs: {
            'name': 'viewport',
            'content': 'width=device-width, initial-scale=1.0'
          }),
          $Title(children: [$Text('Test Page')]),
        ]),
        $Body(children: [
          $H1(children: [$Text('Hello, World!')]),
          $P(children: [$Text('This is a test page.')]),
          $A(
            attrs: {'href': 'https://example.com'},
            children: [$Text('Click here to visit example.com')],
          ),
        ]),
      ]),
    ],
  );

  group("HTML Renderer Tests", () {
    test("Render simple HTML", () async {
      var html = template.toHtml();
      expect(html, isNotNull);
      expect(
        html,
        '<!DOCTYPE html><html lang="en"><head><meta charset="UTF-8"/>'
        '<meta name="viewport" content="width=device-width, initial-s'
        'cale=1.0"/><title>Test Page</title></head><body><h1>Hello, W'
        'orld!</h1><p>This is a test page.</p><a href="https://exampl'
        'e.com">Click here to visit example.com</a></body></html>',
      );
    });

    test('test for jinja', () async {
      template.children[1].children[1].addChild($JinjaVar('test'));
      FinchApp.config = FinchConfigs();

      var html = template.toHtml();
      expect(html, isNotNull);
      expect(
        html,
        '<!DOCTYPE html><html lang="en"><head><meta charset="UTF-8"/>'
        '<meta name="viewport" content="width=device-width, initial-s'
        'cale=1.0"/><title>Test Page</title></head><body><h1>Hello, W'
        'orld!</h1><p>This is a test page.</p><a href="https://exampl'
        'e.com">Click here to visit example.com</a><?= test ?></body>'
        '</html>',
      );
    });

    test("Test no cache", () async {
      $Html template = $Html(
        children: List.generate(
          5,
          (index) => $P(
            children: [
              $Text('Hello World $index'),
            ],
          ),
        ),
      );

      var firstHtml = template.toHtml();
      template.addChild($Text('Hello World'));
      var secondHtml = template.toHtml();
      expect(firstHtml, isNotNull);
      expect(secondHtml, isNotNull);
      expect(firstHtml, isNot(equals(secondHtml)));
    });

    test("Test cache", () async {
      List<Tag> children = List.generate(
        5,
        (index) => $P(
          children: [
            $Text('Hello World $index'),
          ],
        ),
      );

      var template = $Html(
        children: [
          $Cache(
            children: children,
          ),
        ],
      );

      var firstHtml = template.toHtml();
      children.add($Text('Added Text'));
      var secondHtml = template.toHtml();
      template.addChild($Text('Hello World'));
      var thirdHtml = template.toHtml();
      expect(firstHtml, isNotNull);
      expect(secondHtml, isNotNull);
      expect(firstHtml, secondHtml);
      expect(secondHtml, isNot(thirdHtml));
      expect(firstHtml, isNot(thirdHtml));
    });
  });
}
