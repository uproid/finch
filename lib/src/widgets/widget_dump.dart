import 'package:finch/src/views/htmler.dart';
import 'package:finch/src/widgets/finch_string_widget.dart';
import 'package:finch/src/widgets/widget_inline_dump.dart';
import 'package:finch/finch_route.dart';

/// A widget that provides an HTML layout for displaying error messages.
/// The [DumpWodget] class implements [FinchStringWidget] and provides a predefined
/// HTML structure to be used for rendering error messages in the application.
/// It includes styles and structure for displaying error details and stack traces.
class DumpWodget implements FinchStringWidget {
  @override
  final String layout = '';

  @override
  Tag Function(Map args)? generateHtml = (args) {
    var res = $Html(
      children: [
        $JinjaBody(
          commandUp: 'if output',
          children: [
            $Head(
              children: [
                $Style().addChild(
                  $Raw(
                    '''body { 
                        margin: 0; padding: 0; background-color: #151515; 
                      }
                      .wa-debug-dump {
                        height: 100% !important;
                        min-height: 100% !important;
                        border-radius: 0 !important;
                        border: none !important;
                        box-shadow: none !important;
                      }
                    ''',
                  ),
                ),
              ],
            ),
            $Body(
              children: [
                InlineDumpWidget().generateHtml!(
                  {
                    'var': Context.rq.getParam('output'),
                  },
                ),
              ],
            ),
          ],
          commandDown: 'endif',
        ),
      ],
    );
    return res;
  };
}
