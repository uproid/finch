import 'package:finch/src/widgets/widget_swagger.dart';
import 'package:finch/finch_route.dart';

class SwaggerController extends Controller {
  final String urlApiDocs;
  SwaggerController(this.urlApiDocs);

  @override
  Future<String> index() async {
    return rq.renderTag(
        tag: WidgetSwagger().generateHtml!({
      'url': urlApiDocs,
    }));
  }
}
