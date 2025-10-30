import 'package:finch/src/views/htmler.dart';
import 'package:finch/finch_ui.dart';

class WidgetSwagger extends FinchStringWidget {
  @override
  Tag Function(Map<dynamic, dynamic>)? get generateHtml => (Map args) {
        final String url = args['url'] ?? '/api/docs';
        final String cssUrl = args['cssUrl'] ??
            'https://unpkg.com/swagger-ui-dist@5.0.0/swagger-ui.css';
        final String jsUrl = args['jsUrl'] ??
            'https://unpkg.com/swagger-ui-dist@5.0.0/swagger-ui-bundle.js';
        final String presetUrl = args['presetUrl'] ??
            'https://unpkg.com/swagger-ui-dist@5.0.0/swagger-ui-standalone-preset.js';

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
                // Google Fonts for modern look
                $Link(attrs: {
                  'rel': 'stylesheet',
                  'href':
                      'https://fonts.googleapis.com/css2?family=Inter:wght@400;600&display=swap'
                }),
                $Link(attrs: {'rel': 'stylesheet', 'href': cssUrl}),
                $Style(children: [$Raw(_getMotherLayoutCSS())]),
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

  String _getMotherLayoutCSS() {
    return '''
    body {
      font-family: 'Inter', Arial, sans-serif;
      background: #f8fafc;
      color: #334155;
      margin: 0;
      padding: 0;
      min-height: 100vh;
      transition: all 0.3s ease;
    }
    .swagger-ui .copy-to-clipboard {
      background-color: #CCCCCC;
    }
    .swagger-main {
      max-width: 1200px;
      margin: 2rem auto;
      padding: 2rem;
      background: #ffffff;
      border-radius: 16px;
      box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1), 0 1px 2px rgba(0, 0, 0, 0.06);
      min-height: 70vh;
      border: 1px solid #e2e8f0;
    }
    .swagger-ui-container {
      min-height: 60vh;
    }
    
    @keyframes spin {
      0% { transform: rotate(0deg); }
      100% { transform: rotate(360deg); }
    }
    
    /* Clean Swagger UI styling */
    .swagger-ui {
      color: #334155;
    }
    .swagger-ui .topbar {
      background: #ffffff;
      padding: 1rem 0;
      border-bottom: 1px solid #e2e8f0;
    }
    .swagger-ui .info {
      background: transparent;
      padding: 2rem;
      border-radius: 0;
      color: #334155;
      margin-bottom: 2rem;
      border: none;
    }
    .swagger-ui .info .title {
      color: #1e293b;
      font-weight: 600;
    }
    .swagger-ui .scheme-container {
      background: #f1f5f9;
      border-radius: 8px;
      padding: 1rem;
      margin-bottom: 1.5rem;
      border: 1px solid #e2e8f0;
    }
    .swagger-ui .opblock {
      border-radius: 8px;
      border: 1px solid #e2e8f0;
      margin-bottom: 1rem;
      box-shadow: none;
      overflow: hidden;
      background: #ffffff;
    }
    .swagger-ui .opblock.opblock-get {
      border-left: 4px solid #10b981;
    }
    .swagger-ui .opblock.opblock-get .opblock-summary {
      background: #ecfdf5;
    }
    .swagger-ui .opblock.opblock-post {
      border-left: 4px solid #3b82f6;
    }
    .swagger-ui .opblock.opblock-post .opblock-summary {
      background: #eff6ff;
    }
    .swagger-ui .opblock.opblock-put {
      border-left: 4px solid #f59e0b;
    }
    .swagger-ui .opblock.opblock-put .opblock-summary {
      background: #fffbeb;
    }
    .swagger-ui .opblock.opblock-delete {
      border-left: 4px solid #ef4444;
    }
    .swagger-ui .opblock.opblock-delete .opblock-summary {
      background: #fef2f2;
    }

    .opblock-summary button:focus {
      outline: none !important;
      box-shadow: none !important;
    }
    
    /* Clean button styles */
    .swagger-ui .btn {
      background: #3b82f6;
      border: none;
      border-radius: 6px;
      color: white;
      font-weight: 500;
      padding: 8px 16px;
      transition: all 0.2s ease;
      font-size: 0.875rem;
      cursor: pointer;
    }
    .swagger-ui .btn:hover {
      background: #2563eb;
      transform: translateY(-1px);
      box-shadow: 0 4px 8px rgba(0, 0, 0, 0.12);
    }
    .swagger-ui .btn.execute {
      background: #10b981;
      color: white;
    }
    .swagger-ui .btn.execute:hover {
      background: #059669;
    }
    .swagger-ui .btn.cancel {
      background: #ef4444;
      color: white;
    }
    .swagger-ui .btn.cancel:hover {
      background: #dc2626;
    }
    .swagger-ui .btn.try-out__btn {
      background: #3b82f6;
      color: white;
    }
    .swagger-ui .btn.try-out__btn:hover {
      background: #2563eb;
    }
    
    /* Response styling */
    .swagger-ui .responses-inner {
      background: #f8fafc;
      border-radius: 8px;
      padding: 1rem;
      border: 1px solid #e2e8f0;
    }
    .swagger-ui .response-col_status {
      color: #10b981;
      font-weight: 600;
    }
    
    /* Parameter styling */
    .swagger-ui .parameters-col_description input[type=text],
    .swagger-ui .parameters-col_description textarea {
      border: 1px solid #d1d5db;
      border-radius: 6px;
      padding: 8px 12px;
      transition: border-color 0.2s ease;
      background: #ffffff;
    }
    .swagger-ui .parameters-col_description input[type=text]:focus,
    .swagger-ui .parameters-col_description textarea:focus {
      border-color: #3b82f6;
      box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
      outline: none;
    }
    
    /* Method labels */
    .swagger-ui .opblock-summary-method {
      border-radius: 3px !important;
    }

    .swagger-ui .opblock.opblock-get .opblock-summary-method {
      background: #10b981 !important;
      border-color: #10b981 !important;
    }

    .swagger-ui .opblock.opblock-post .opblock-summary-method {
      background: #3b82f6 !important;
      border-color: #3b82f6 !important;
    }

    .swagger-ui .opblock-post .opblock-summary-method {
      background: #3b82f6;
    }
    .swagger-ui .opblock-put .opblock-summary-method {
      background: #f59e0b;
    }
    .swagger-ui .opblock-delete .opblock-summary-method {
      background: #ef4444;
    }
    
    /* Dark mode */
    body.dark-mode {
      --bg: #181a1b;
      --fg: #f4f4f4;
      --header-bg: #181a1b;
      --header-fg: #ffb300;
      --main-bg: #23272e;
      color: var(--fg);
      background: var(--bg);
    }
    body.dark-mode .swagger-header {
      background: var(--header-bg);
      color: var(--header-fg);
    }
    body.dark-mode .swagger-main {
      background: var(--main-bg);
      color: var(--fg);
    }
    body.dark-mode .swagger-title {
      color: var(--header-fg);
    }
    /* Responsive */
    @media (max-width: 700px) {
      .swagger-header-content, .swagger-main {
        padding: 0.5rem;
      }
      .swagger-title {
        font-size: 1.1rem;
      }
    }
    ''';
  }

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
