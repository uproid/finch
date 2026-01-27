import 'package:finch/src/views/htmler.dart';
import 'package:finch/finch_ui.dart';

class WidgetSwagger extends FinchStringWidget {
  @override
  Tag Function(Map<dynamic, dynamic>)? get generateHtml => (Map args) {
        final String url = args['url'] ?? '/api/docs';
        final String cssUrl = args['cssUrl'] ??
            'https://unpkg.com/swagger-ui-dist@5.31.0/swagger-ui.css';
        final String jsUrl = args['jsUrl'] ??
            'https://unpkg.com/swagger-ui-dist@5.31.0/swagger-ui-bundle.js';
        final String presetUrl = args['presetUrl'] ??
            'https://unpkg.com/swagger-ui-dist@5.31.0/swagger-ui-standalone-preset.js';

        Tag html = ArrayTag(
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
                $Link(attrs: {'rel': 'stylesheet', 'href': cssUrl}),
              ]),
              $Body(children: [
                $Main(attrs: {
                  'class': 'swagger-main'
                }, children: [
                  $Div(attrs: {
                    'id': 'swagger-ui',
                    'class': 'swagger-ui-container'
                  })
                ]),

                // Scripts
                $Script(attrs: {'src': jsUrl}),
                $Script(attrs: {'src': presetUrl}),
                $Script(children: [$Raw(_getSwaggerInitJS(url))])
              ])
            ])
          ],
        );

        return html;
      };

  String _getSwaggerInitJS(String url) {
    return '''
      // Hide loading after a minimum time
      window.addEventListener('load', function() {
        try {
          SwaggerUIBundle({
            url: '$url',
            dom_id: '#swagger-ui',
            deepLinking: true,
            presets: [
              SwaggerUIBundle.presets.apis,
              SwaggerUIStandalonePreset
            ],
            plugins: [
              SwaggerUIBundle.plugins.DownloadUrl
            ],
            layout: "StandaloneLayout",
            validatorUrl: null,
            docExpansion: "list",
            operationsSorter: "alpha",
            tagsSorter: "alpha",
            filter: true,
            showExtensions: true,
            showCommonExtensions: true,
            defaultModelsExpandDepth: 1,
            defaultModelExpandDepth: 1,
            displayOperationId: false,
            displayRequestDuration: true,
            tryItOutEnabled: true,
            onComplete: function() {
              console.log('Swagger UI loaded successfully');
            },
            onFailure: function(error) {
              console.error('Swagger UI error:', error);
            }
          });
        } catch (error) {
          console.error('Error initializing Swagger UI:', error);
          document.getElementById('swagger-ui').innerHTML = 
            '<div style="padding: 20px; text-align: center; color: #d32f2f;"><h3>Error loading API documentation</h3><p>' + 
            error.message + '</p></div>';
        }
      });
    ''';
  }
}
