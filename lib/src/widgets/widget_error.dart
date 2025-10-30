import 'package:finch/src/views/htmler.dart';
import 'package:finch/finch_app.dart';
import 'package:finch/src/widgets/finch_string_widget.dart';

/// A widget that provides an HTML layout for displaying error messages.
/// The [ErrorWidget] class implements [FinchStringWidget] and provides a predefined
/// HTML structure to be used for rendering error messages in the application.
/// It includes styles and structure for displaying error details and stack traces.
class ErrorWidget implements FinchStringWidget {
  @override
  final String layout = '';

  @override
  Tag Function(Map args)? generateHtml = (Map args) {
    int statusCode = args['status'] ?? 500;
    String title = args['title'] ?? 'Error $statusCode';
    String error = (args['error'] ?? '').toString();
    List stack = args['stack'] ?? [];

    return ArrayTag(
      children: [
        $Doctype(),
        $Html(
          children: [
            $Head(children: [
              $Meta(attrs: {'charset': 'utf-8'}),
              $Meta(attrs: {
                'http-equiv': 'X-UA-Compatible',
                'content': 'IE=edge'
              }),
              $Meta(attrs: {
                'name': 'viewport',
                'content': 'width=device-width, initial-scale=1'
              }),
              $Title(children: [$Text(title)]),
              $Style(children: [
                $Raw("""
            /* ---------- Modern Error Page Styles ---------- */
            :root {
              --color-bg: #0f1115;
              --color-bg-alt: #181b21;
              --color-surface: #1f242c;
              --color-border: #2c333d;
              --color-accent: #3da9fc;
              --color-accent-glow: 75, 170, 255;
              --color-error: #ff4c60;
              --color-error-soft: #ff4c6030;
              --color-warn: #ffc861;
              --color-text: #e6ebf1;
              --color-text-dim: #9aa4b1;
              --row-alt: #1b2026;
              --row-hover: #242b33;
              --bg-global: radial-gradient(circle at 25% 15%, #1d2430, #0f1115 60%) fixed;
              --table-head-bg: linear-gradient(90deg, #252c34, #20252c);
              --table-head-text: var(--color-text-dim);
              --error-box-bg: linear-gradient(135deg, #2a1217, #361a1f 55%, #331319);
              --error-box-border: rgba(255,76,96,.45);
              --error-box-text: #ffd9de;
              --radius-sm: 6px;
              --radius-md: 12px;
              --radius-lg: 18px;
              --shadow-sm: 0 2px 4px -1px rgba(0,0,0,.4),0 1px 1px rgba(0,0,0,.25);
              --shadow-md: 0 4px 18px -2px rgba(0,0,0,.55),0 2px 4px rgba(0,0,0,.35);
              --gradient-accent: linear-gradient(135deg,#3da9fc,#6d67ff 60%,#b44cff);
              font-family: 'Courier New', Courier, 'Inter', system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Fira Sans', 'Droid Sans', 'Helvetica Neue', Arial, sans-serif;
            }

            /* Light theme overrides */
            body[data-theme='light'] {
              --color-bg: #fafbfc;
              --color-bg-alt: #ffffff;
              --color-surface: #ffffff;
              --color-border: #e1e8f0;
              --color-accent: #6366f1;
              --color-accent-glow: 99, 102, 241;
              --color-error: #ef4444;
              --color-error-soft: #fef2f2;
              --color-warn: #f59e0b;
              --color-text: #1f2937;
              --color-text-dim: #6b7280;
              --row-alt: #f8fafc;
              --row-hover: #f1f5f9;
              --bg-global: linear-gradient(135deg, #ffffff 0%, #f8fafc 25%, #f1f5f9 100%);
              --table-head-bg: linear-gradient(135deg, #f8fafc, #f1f5f9);
              --table-head-text: #374151;
              --error-box-bg: linear-gradient(135deg, #fef2f2, #fef7f7);
              --error-box-border: #fecaca;
              --error-box-text: #b91c1c;
              --gradient-accent: linear-gradient(135deg, #6366f1, #8b5cf6 60%, #ec4899);
              --shadow-sm: 0 1px 3px rgba(0,0,0,.08), 0 1px 2px rgba(0,0,0,.04);
              --shadow-md: 0 4px 16px rgba(0,0,0,.06), 0 2px 8px rgba(0,0,0,.04);
            }

            * { box-sizing: border-box; }

            body {
              margin: 0;
              padding: clamp(16px, 3vw, 40px);
              background: var(--bg-global);
              color: var(--color-text);
              -webkit-font-smoothing: antialiased;
              line-height: 1.45;
              transition: background .4s ease, color .25s ease;
            }

            h3 {
              margin: 0 0 .75rem;
              font-size: 2.3rem;
              font-weight: 600;
              letter-spacing: -1px;
              background: var(--gradient-accent);
              -webkit-background-clip: text;
              color: transparent;
              filter: drop-shadow(0 3px 8px rgba(var(--color-accent-glow), .35));
            }

            p { margin: 0 0 1.2rem; font-size: 1.05rem; color: var(--color-text-dim); }

            code, pre { font-family: 'Fira Mono', 'Source Code Pro', monospace; }

            .error-alert {
              display: block;
              background: var(--color-error-soft);
              border: 1px solid var(--color-error);
              border-radius: var(--radius-md);
              padding: 12px 16px;
              color: var(--color-error);
              font-size: .9rem;
              line-height: 1.4;
              margin: 0 0 1.5rem;
              overflow: auto;
              max-height: 260px;
              transition: background .4s ease, color .25s ease, border-color .4s ease;
            }

            .error-shell {
              max-width: 900px;
              margin: 0 auto;
              background: linear-gradient(145deg, var(--color-bg-alt), var(--color-surface));
              border: 1px solid var(--color-border);
              border-radius: var(--radius-lg);
              padding: clamp(24px, 3vw, 42px);
              box-shadow: var(--shadow-md);
              position: relative;
              overflow: hidden;
            }
            .error-shell::before, .error-shell::after {
              content: '';
              position: absolute;
              width: 420px; height: 420px;
              background: radial-gradient(circle at center, rgba(var(--color-accent-glow), .18), transparent 70%);
              top: -160px; right: -160px;
              pointer-events: none;
              mix-blend-mode: screen;
              filter: blur(8px);
            }
            .error-shell::after { top: auto; bottom: -180px; right: auto; left: -180px; }

            .badge-code {
              display: inline-flex;
              align-items: center;
              gap: .5ch;
              background: var(--color-error-soft);
              color: var(--color-error);
              border: 1px solid var(--color-error);
              font-weight: 600;
              padding: 4px 10px 4px 8px;
              border-radius: 100px;
              font-size: .85rem;
              letter-spacing: .5px;
              box-shadow: 0 0 0 1px rgba(255,76,96,.15), 0 0 0 4px rgba(255,76,96,.07);
              margin: 0 0 1.25rem;
            }

            .error-box {
              background: var(--error-box-bg);
              border: 1px solid var(--error-box-border);
              border-radius: var(--radius-md);
              padding: 16px 18px 14px;
              color: var(--error-box-text);
              font-size: .9rem;
              line-height: 1.4;
              margin: 0 0 1.5rem;
              position: relative;
              overflow: auto;
              max-height: 260px;
              transition: background .4s ease, color .25s ease, border-color .4s ease;
            }
            .error-box::-webkit-scrollbar { width: 10px; }
            .error-box::-webkit-scrollbar-track { background: #00000022; border-radius: 10px; }
            .error-box::-webkit-scrollbar-thumb { background: #ff4c60a8; border-radius: 10px; box-shadow: inset 0 0 0 2px #2b1219; }

            table {
              width: 100%;
              border-collapse: collapse;
              margin: 1.25rem 0 0;
              font-size: .83rem;
              background: var(--color-bg-alt);
              border: 1px solid var(--color-border);
              border-radius: var(--radius-md);
              overflow: hidden;
            }
            thead th {
              background: var(--table-head-bg);
              padding: 12px 14px;
              font-size: .78rem;
              letter-spacing: .15ch;
              font-weight: 600;
              text-transform: uppercase;
              color: var(--table-head-text);
              border-bottom: 1px solid var(--color-border);
              transition: background .4s ease, color .25s ease;
            }
            tbody th, tbody td { padding: 9px 12px; border-bottom: 1px solid var(--color-border); }
            tbody tr:last-child th, tbody tr:last-child td { border-bottom: none; }
            tbody tr:nth-child(even) { background: var(--row-alt); }
            tbody tr:hover { background: var(--row-hover); }

            .flag { text-align: center; width: 42px; font-size: 1.05rem; }
            .flag[style] { box-shadow: inset 0 0 0 1px #ff4c60aa; border-radius: var(--radius-sm); transition: background .4s ease; }
            
            /* Light mode specific overrides */
            body[data-theme='light'] .flag[style] { box-shadow: inset 0 0 0 1px #ef4444cc; }
            body[data-theme='light'] .flag[style*="#361a1f"] { background: #fef2f2 !important; }
            body[data-theme='light'] td[style*='#ff6f7f'] { color: #dc2626 !important; }
            body[data-theme='light'] .error-shell::before, 
            body[data-theme='light'] .error-shell::after { display: none; }
            body[data-theme='light'] h3 { 
              filter: none; 
              background: var(--gradient-accent);
              -webkit-background-clip: text;
              color: transparent;
            }
            body[data-theme='light'] .badge-code { 
              background: var(--color-error-soft);
              border-color: #fecaca;
              box-shadow: 0 1px 3px rgba(239, 68, 68, 0.1);
            }
            body[data-theme='light'] .error-shell {
              background: var(--color-bg-alt);
              box-shadow: 0 10px 25px rgba(0,0,0,.04), 0 4px 10px rgba(0,0,0,.06);
            }

            td code.vscode { color: var(--color-accent); font-weight: 500; }

            a { color: var(--color-accent); text-decoration: none; position: relative; }
            a::after { content:''; position:absolute; left:0; bottom:-2px; height:2px; width:100%; background: var(--gradient-accent); opacity:.35; transition:opacity .25s, transform .25s; transform:translateY(3px); }
            a:hover::after { opacity:.9; transform:translateY(0); }

            /* Theme toggle (icon) */
            .theme-toggle { position:absolute; top:14px; right:14px; z-index:5; }
            .theme-toggle button#themeToggleBtn { 
              width:32px; height:32px; 
              border-radius:50%; 
              border:1px solid var(--color-border); 
              background: var(--color-bg-alt); 
              cursor:pointer; 
              display:flex; 
              align-items:center; 
              justify-content:center; 
              font-size:1.0rem; 
              color: var(--color-text-dim); 
              box-shadow: var(--shadow-sm); 
              transition: all .3s ease; 
              user-select: none;
            }
            .theme-toggle button#themeToggleBtn:hover { 
              color: var(--color-text); 
              border-color: var(--color-accent); 
              transform: rotate(15deg) scale(1.05); 
            }
            .theme-toggle button#themeToggleBtn:active { 
              transform: scale(0.95); 
            }
            body[data-theme='light'] .theme-toggle button#themeToggleBtn { 
              background: rgba(255,255,255,0.9); 
              backdrop-filter: blur(8px); 
            }

            /* Fast shake animation */
            .error-shell, h3, .badge-code, table, .error-box { 
              animation: shakeIn .4s ease-out; 
            }
            @keyframes shakeIn { 
              0% { opacity: 0; transform: translateX(-8px); }
              25% { opacity: 0.7; transform: translateX(4px); }
              50% { opacity: 0.9; transform: translateX(-2px); }
              75% { opacity: 1; transform: translateX(1px); }
              100% { opacity: 1; transform: translateX(0); }
            }
          """)
              ])
            ]),
            $Body(
              attrs: {'style': 'max-width: 100%;', 'data-theme': 'dark'},
              children: [
                $Div(classes: [
                  'error-shell'
                ], children: [
                  $Div(classes: [
                    'theme-toggle'
                  ], children: [
                    $Button(attrs: {
                      'id': 'themeToggleBtn',
                      'type': 'button',
                      'title': 'Toggle theme',
                      'aria-label': 'Switch between dark and light theme'
                    }, children: [
                      $Text('🌙')
                    ]),
                  ]),
                  $H3(children: [$Text("< Error $statusCode />")]),
                  $P(children: [
                    $Text(
                        "Oops! Something went wrong. Please try again later."),
                  ]),
                  if (FinchApp.config.isLocalDebug) ...[
                    if (error.isNotEmpty) ...[
                      $Div(
                        attrs: {},
                        children: [
                          $Code(
                            classes: ['error-alert'],
                            children: [$Text(error.toString())],
                          )
                        ],
                      ),
                    ],
                    if (stack.isNotEmpty) ...[
                      $Table(
                        attrs: {},
                        children: [
                          $Thead(children: [
                            $Tr(children: [
                              $Th(
                                attrs: {'colspan': '3'},
                                classes: ['text-align:center'],
                                children: [$Text('Error details')],
                              )
                            ]),
                          ]),
                          $Tbody(
                            children: [
                              for (var stackItem in stack)
                                if (stackItem.toString().isNotEmpty) ...[
                                  $Tr(
                                    children: [
                                      $Th(
                                        classes: ['flag'],
                                        attrs: {
                                          if (stackItem
                                              .toString()
                                              .contains('file://'))
                                            'style': 'background-color:#361a1f'
                                        },
                                        children: [
                                          if (stackItem
                                              .toString()
                                              .contains('file://'))
                                            $A(
                                              classes: ['vscode'],
                                              attrs: {
                                                'href': 'javascript:void(0);'
                                              },
                                              children: [
                                                $Text('⛔'),
                                              ],
                                            )
                                          else if (stackItem
                                              .toString()
                                              .contains('package:finch'))
                                            $A(
                                              attrs: {
                                                'target': '_blank',
                                                'title':
                                                    'Report to Finch Developers',
                                                'href':
                                                    'https://github.com/uproid/finch/issues'
                                              },
                                              children: [$Text('🐛')],
                                            )
                                          else
                                            $Text('⚪')
                                        ],
                                      ),
                                      if (stackItem
                                          .toString()
                                          .contains('file://')) ...[
                                        $Td(
                                          attrs: {
                                            'style':
                                                'color:#ff6f7f; font-weight:500;'
                                          },
                                          children: [
                                            $Code(
                                              classes: ['vscode'],
                                              attrs: {
                                                'style':
                                                    'word-break: break-all;'
                                              },
                                              children: [
                                                $Text(stackItem.toString())
                                              ],
                                            ),
                                          ],
                                        )
                                      ] else ...[
                                        $Td(
                                          attrs: {
                                            'style':
                                                'color: var(--color-text-dim);'
                                          },
                                          children: [
                                            $Text(stackItem.toString())
                                          ],
                                        )
                                      ]
                                    ],
                                  ),
                                ]
                            ],
                          ),
                        ],
                      ),
                    ],
                  ],
                  $Script(children: [
                    $Raw("""
                (function(){
                  const STORAGE_KEY = 'errorTheme';
                  const root = document.body;
                  const btn = document.getElementById('themeToggleBtn');
                  
                  function applyTheme(theme){
                    root.setAttribute('data-theme', theme);
                    try { localStorage.setItem(STORAGE_KEY, theme); } catch(e) {}
                    if(btn){ 
                      btn.textContent = theme === 'dark' ? '🌙' : '☀️'; 
                      btn.title = theme === 'dark' ? 'Switch to light theme' : 'Switch to dark theme';
                    }
                  }
                  
                  // Load saved theme or default to dark
                  const saved = (function(){ try { return localStorage.getItem(STORAGE_KEY);} catch(e){ return null; } })();
                  const initialTheme = (saved === 'light' || saved === 'dark') ? saved : (root.getAttribute('data-theme')||'dark');
                  applyTheme(initialTheme);
                  
                  // Handle toggle click
                  if(btn){
                    btn.addEventListener('click', function(){
                      const current = root.getAttribute('data-theme');
                      const next = current === 'dark' ? 'light' : 'dark';
                      applyTheme(next);
                    });
                  }
                  
                  // Linkify stack vscode paths
                  document.querySelectorAll('.vscode').forEach(function(element){
                    var text = element.textContent || '';
                    var regExp = "///([^)*]+)/";
                    var match = text.match(regExp);
                    if(match && match[1]) {
                      element.innerHTML = '<a href="vscode://file/' + match[1] + '">' + text + '</a>';
                    } else {
                      element.textContent = text;
                    }
                  });
                })();
              """)
                  ])
                ])
              ],
            ),
          ],
        ),
      ],
    );
  };
}
