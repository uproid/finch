import 'package:finch/finch_htmler.dart';
import 'package:finch/finch_route.dart';

class HtmlerController extends Controller {
  HtmlerController();

  @override
  Future<String> index() async {
    return exampleHtmler();
  }

  Future<String> exampleHtmler() async {
    rq.addParam('language', rq.getLanguage());
    rq.addParam('year', DateTime.now().year);

    Tag htmlTag = $Cache(children: [
      $Doctype(),
      $Html(attrs: {
        'lang': rq.getLanguage(),
        'dir': JJ.$var('\$t("dir")'),
        'class': 'scroll-smooth',
      }, children: [
        $Head(children: _head()),
        $Body(attrs: {
          'class': 'min-h-screen bg-slate-50 text-slate-800 antialiased',
        }, children: [
          _hero(),
          _navbar(),
          $Main(attrs: {
            'class': 'mx-auto max-w-7xl px-4 sm:px-6 lg:px-8 py-12 space-y-16',
          }, children: [
            _typography(),
            _lists(),
            _forms(),
            _tables(),
            _media(),
            _codeExamples(),
            _jinjaIntegration(),
          ]),
          _footer(),
          $Comment($Text(
              'Generated entirely with Finch Htmler — type-safe HTML from Dart.')),
        ]),
      ]),
    ]);

    return rq.renderTag(tag: htmlTag, pretty: false);
  }

  // ─────────────────────────────────────────────
  //  HEAD
  // ─────────────────────────────────────────────
  List<Tag> _head() => [
        $Meta(attrs: {'charset': 'UTF-8'}),
        $Meta(attrs: {
          'name': 'viewport',
          'content': 'width=device-width, initial-scale=1.0',
        }),
        $Title(children: [$Text('Htmler · Type-safe HTML from Dart')]),
        $Link(attrs: {
          'rel': 'stylesheet',
          'href':
              'https://cdn.jsdelivr.net/npm/@fortawesome/fontawesome-free@6.5.2/css/all.min.css',
        }),
        $Script(attrs: {
          'src': 'https://cdn.tailwindcss.com',
        }, children: []),
        $Script(children: [
          $Raw('''
            tailwind.config = {
              theme: {
                extend: {
                  fontFamily: {
                    sans: ['Inter', 'ui-sans-serif', 'system-ui', 'sans-serif'],
                    mono: ['"JetBrains Mono"', 'ui-monospace', 'monospace'],
                  },
                  boxShadow: {
                    soft: '0 10px 30px -12px rgba(0,0,0,0.12), 0 4px 12px -6px rgba(0,0,0,0.08)',
                    'soft-lg': '0 25px 50px -12px rgba(0,0,0,0.18)',
                  },
                  animation: {
                    'blob': 'blob 18s infinite',
                  },
                  keyframes: {
                    blob: {
                      '0%,100%': { transform: 'translate(0,0) scale(1)' },
                      '33%': { transform: 'translate(20px,-30px) scale(1.05)' },
                      '66%': { transform: 'translate(-20px,20px) scale(0.95)' },
                    }
                  }
                }
              }
            };
          '''),
        ]),
        $Link(attrs: {
          'rel': 'preconnect',
          'href': 'https://fonts.googleapis.com',
        }),
        $Link(attrs: {
          'rel': 'stylesheet',
          'href':
              'https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&family=JetBrains+Mono:wght@400;500&display=swap',
        }),
      ];

  // ─────────────────────────────────────────────
  //  HERO
  // ─────────────────────────────────────────────
  Tag _hero() => $Section(attrs: {
        'class':
            'relative overflow-hidden bg-gradient-to-br from-slate-950 via-violet-950 to-indigo-950',
      }, children: [
        // blobs
        $Div(attrs: {
          'class':
              'pointer-events-none absolute -top-32 -end-32 h-96 w-96 rounded-full bg-fuchsia-500/20 blur-3xl animate-blob',
        }, children: []),
        $Div(attrs: {
          'class':
              'pointer-events-none absolute -bottom-32 -start-32 h-96 w-96 rounded-full bg-indigo-500/25 blur-3xl animate-blob',
        }, children: []),
        // grid overlay
        $Div(attrs: {
          'class':
              'pointer-events-none absolute inset-0 opacity-[0.05] bg-[linear-gradient(rgba(255,255,255,.5)_1px,transparent_1px),linear-gradient(90deg,rgba(255,255,255,.5)_1px,transparent_1px)] bg-[size:32px_32px]',
        }, children: []),

        $Div(attrs: {
          'class':
              'relative mx-auto max-w-7xl px-4 sm:px-6 lg:px-8 py-16 sm:py-24 lg:py-28',
        }, children: [
          $Div(attrs: {
            'class': 'grid lg:grid-cols-12 gap-10 items-center',
          }, children: [
            // ── left ──
            $Div(attrs: {
              'class': 'lg:col-span-7 text-center lg:text-start',
            }, children: [
              $Div(attrs: {
                'class':
                    'inline-flex items-center gap-2 rounded-full bg-white/10 ring-1 ring-white/20 px-3 py-1.5 backdrop-blur',
              }, children: [
                $Span(attrs: {
                  'class':
                      'inline-flex h-2 w-2 rounded-full bg-emerald-400 animate-pulse',
                }, children: []),
                $Span(attrs: {
                  'class':
                      'text-[11px] font-semibold uppercase tracking-[0.18em] text-zinc-200',
                }, children: [
                  $Text('Finch · Htmler'),
                ]),
              ]),
              $H1(attrs: {
                'class':
                    'mt-5 text-4xl sm:text-5xl lg:text-6xl font-extrabold tracking-tight text-white leading-[1.05]',
              }, children: [
                $Text('Type-safe HTML, '),
                $Span(attrs: {
                  'class':
                      'bg-gradient-to-r from-fuchsia-300 via-violet-300 to-indigo-300 bg-clip-text text-transparent',
                }, children: [
                  $Text('written in Dart.'),
                ]),
              ]),
              $P(attrs: {
                'class':
                    'mt-5 max-w-2xl mx-auto lg:mx-0 text-lg text-zinc-300 leading-relaxed',
              }, children: [
                $Text('Build entire web pages with composable '),
                $Code(attrs: {
                  'class':
                      'rounded bg-white/10 px-1.5 py-0.5 text-violet-200 font-mono text-[15px]',
                }, children: [
                  $Text('\$Tag()'),
                ]),
                $Text(
                    ' builders — clean syntax, IDE autocomplete, and seamless Jinja interop.'),
              ]),
              $Div(attrs: {
                'class':
                    'mt-8 flex flex-wrap gap-3 justify-center lg:justify-start',
              }, children: [
                $A(attrs: {
                  'href': '#typography',
                  'class':
                      'inline-flex items-center gap-2 rounded-xl bg-gradient-to-r from-violet-500 to-indigo-600 px-5 py-3 text-sm font-semibold text-white shadow-soft hover:shadow-soft-lg hover:from-violet-400 hover:to-indigo-500 transition',
                }, children: [
                  $I(attrs: {'class': 'fa-solid fa-rocket'}, children: []),
                  $Text('Get started'),
                ])
                  ..addAttr('data-language', JJ.$var('language')),
                $A(attrs: {
                  'href': '#code',
                  'class':
                      'inline-flex items-center gap-2 rounded-xl bg-white/10 ring-1 ring-white/15 px-5 py-3 text-sm font-semibold text-white backdrop-blur hover:bg-white/15 transition',
                }, children: [
                  $I(attrs: {'class': 'fa-solid fa-code'}, children: []),
                  $Text('See the code'),
                ]),
              ]),
            ]),
            // ── right (stat grid) ──
            $Div(attrs: {
              'class': 'lg:col-span-5',
            }, children: [
              $Div(attrs: {
                'class': 'grid grid-cols-2 gap-3 sm:gap-4',
              }, children: [
                _statCard('40+', 'HTML tags', 'fa-cubes', 'fuchsia'),
                _statCard('100%', 'Type-safe', 'fa-shield-halved', 'violet'),
                _statCard('0', 'Dependencies', 'fa-feather', 'indigo'),
                _statCard('∞', 'Composable', 'fa-infinity', 'sky'),
              ]),
            ]),
          ]),
        ]),
      ]);

  Tag _statCard(String value, String label, String icon, String color) =>
      $Div(attrs: {
        'class':
            'group rounded-2xl border border-white/10 bg-white/5 p-5 backdrop-blur transition hover:bg-white/10',
      }, children: [
        $Div(attrs: {
          'class':
              'inline-flex h-10 w-10 items-center justify-center rounded-xl bg-$color-500/15 text-$color-300 ring-1 ring-$color-400/30',
        }, children: [
          $I(attrs: {'class': 'fa-solid $icon'}, children: []),
        ]),
        $Div(attrs: {
          'class': 'mt-3 text-3xl font-bold text-white',
        }, children: [
          $Text(value),
        ]),
        $P(attrs: {
          'class': 'mt-1 text-xs uppercase tracking-wider text-zinc-400',
        }, children: [
          $Text(label),
        ]),
      ]);

  // ─────────────────────────────────────────────
  //  NAVBAR (sticky)
  // ─────────────────────────────────────────────
  Tag _navbar() => $Nav(attrs: {
        'class':
            'sticky top-0 z-30 border-b border-slate-200/70 bg-white/80 backdrop-blur',
      }, children: [
        $Div(attrs: {
          'class':
              'mx-auto max-w-7xl px-4 sm:px-6 lg:px-8 flex h-14 items-center justify-between',
        }, children: [
          $A(attrs: {
            'href': '#',
            'class': 'flex items-center gap-2 font-bold text-slate-900',
          }, children: [
            $Span(attrs: {
              'class':
                  'grid h-8 w-8 place-items-center rounded-lg bg-gradient-to-br from-violet-500 to-indigo-600 text-white shadow-sm',
            }, children: [
              $I(attrs: {'class': 'fa-solid fa-code text-xs'}, children: []),
            ]),
            $Span(attrs: {
              'class': 'tracking-tight'
            }, children: [
              $Text('Htmler'),
            ]),
          ]),
          $Div(attrs: {
            'class': 'hidden md:flex items-center gap-1 text-sm',
          }, children: [
            _navLink('#typography', 'Typography'),
            _navLink('#lists', 'Lists'),
            _navLink('#forms', 'Forms'),
            _navLink('#tables', 'Tables'),
            _navLink('#media', 'Media'),
            _navLink('#code', 'Code'),
          ]),
        ]),
      ]);

  Tag _navLink(String href, String label) => $A(attrs: {
        'href': href,
        'class':
            'rounded-lg px-3 py-1.5 font-medium text-slate-600 hover:bg-violet-50 hover:text-violet-700 transition',
      }, children: [
        $Text(label),
      ]);

  // ─────────────────────────────────────────────
  //  SECTION HEADER (reusable)
  // ─────────────────────────────────────────────
  Tag _sectionHeader(String eyebrow, String title, String subtitle) =>
      $Div(attrs: {
        'class': 'mb-8'
      }, children: [
        $Div(attrs: {
          'class':
              'inline-flex items-center gap-2 rounded-full bg-violet-50 ring-1 ring-violet-200 px-3 py-1 text-[10px] font-bold uppercase tracking-[0.18em] text-violet-700',
        }, children: [
          $I(
              attrs: {'class': 'fa-solid fa-sparkles text-[10px]'},
              children: []),
          $Text(eyebrow),
        ]),
        $H2(attrs: {
          'class':
              'mt-3 text-3xl sm:text-4xl font-bold tracking-tight text-slate-900',
        }, children: [
          $Text(title),
        ]),
        $P(
            attrs: {'class': 'mt-2 max-w-2xl text-slate-600'},
            children: [$Text(subtitle)]),
      ]);

  // ─────────────────────────────────────────────
  //  TYPOGRAPHY
  // ─────────────────────────────────────────────
  Tag _typography() => $Section(attrs: {
        'id': 'typography',
        'class': 'scroll-mt-20'
      }, children: [
        _sectionHeader('01 · Text', 'Typography elements',
            'Headings, formatting, inline code, and accent text — all composed as Dart tags.'),
        $Div(attrs: {
          'class': 'grid gap-5 lg:grid-cols-3',
        }, children: [
          _card('fa-heading', 'violet', 'Heading hierarchy', [
            $H3(
                attrs: {'class': 'text-xl font-bold text-slate-900'},
                children: [$Text('H1 — Main title')]),
            $H4(
                attrs: {'class': 'text-lg font-semibold text-slate-800'},
                children: [$Text('H2 — Section')]),
            $H5(
                attrs: {'class': 'text-base font-semibold text-slate-700'},
                children: [$Text('H3 — Subsection')]),
            $H6(
                attrs: {'class': 'text-sm font-semibold text-slate-600'},
                children: [$Text('H4 — Minor')]),
            $Hr(attrs: {'class': 'my-2 border-slate-200'}),
            $Small(attrs: {
              'class': 'text-slate-500'
            }, children: [
              $Text('Perfect semantics for SEO & accessibility.'),
            ]),
          ]),
          _card('fa-text-height', 'fuchsia', 'Text formatting', [
            $P(attrs: {
              'class': 'text-sm text-slate-700'
            }, children: [
              $Text('Mix '),
              $B(attrs: {'class': 'text-slate-900'}, children: [$Text('bold')]),
              $Text(', '),
              $I(
                  attrs: {'class': 'text-violet-700'},
                  children: [$Text('italic')]),
              $Text(', and '),
              $U(
                  attrs: {'class': 'decoration-fuchsia-400'},
                  children: [$Text('underlined')]),
              $Text(' freely.'),
            ]),
            $P(attrs: {
              'class': 'text-sm text-slate-700'
            }, children: [
              $Text('Inline code: '),
              $Code(attrs: {
                'class':
                    'rounded bg-slate-100 px-1.5 py-0.5 font-mono text-[12px] text-fuchsia-700 ring-1 ring-slate-200',
              }, children: [
                $Text('htmler.render()'),
              ]),
            ]),
            $Small(attrs: {
              'class': 'block text-slate-500'
            }, children: [
              $Text('Small text adds footnote-level context.'),
            ]),
          ]),
          _card('fa-wand-magic-sparkles', 'indigo', 'Accents & badges', [
            $P(attrs: {
              'class': 'text-sm text-slate-700'
            }, children: [
              $Text('Use '),
              $Code(attrs: {
                'class':
                    'rounded bg-slate-100 px-1.5 py-0.5 font-mono text-[12px] text-indigo-700 ring-1 ring-slate-200',
              }, children: [
                $Text('\$Span'),
              ]),
              $Text(' for '),
              $Span(attrs: {
                'class':
                    'rounded-md bg-gradient-to-r from-fuchsia-500 to-violet-600 px-2 py-0.5 text-xs font-semibold text-white',
              }, children: [
                $Text('highlighted text'),
              ]),
              $Text(' or '),
              $Span(attrs: {
                'class':
                    'rounded-md border border-indigo-300 px-2 py-0.5 text-xs font-semibold text-indigo-700',
              }, children: [
                $Text('outlined badges'),
              ]),
              $Text('.'),
            ]),
            $P(attrs: {
              'class': 'text-sm text-slate-700'
            }, children: [
              $Text('Typography is the '),
              $B(
                  attrs: {'class': 'text-indigo-700'},
                  children: [$Text('foundation')]),
              $Text(' of great design.'),
            ]),
          ]),
        ]),
        _proTip(
            'All these elements are pure Dart — instant type-safety and full IDE autocomplete.'),
      ]);

  // ─────────────────────────────────────────────
  //  LISTS
  // ─────────────────────────────────────────────
  Tag _lists() => $Section(attrs: {
        'id': 'lists',
        'class': 'scroll-mt-20'
      }, children: [
        _sectionHeader('02 · Collections', 'Lists & navigation',
            'Ordered, unordered, and richly styled list items with badges and pills.'),
        $Div(attrs: {
          'class': 'grid gap-5 lg:grid-cols-2'
        }, children: [
          _card('fa-list', 'violet', 'Unordered list', [
            $Ul(attrs: {
              'class':
                  'divide-y divide-slate-200 rounded-xl ring-1 ring-slate-200 overflow-hidden',
            }, children: [
              _listItem('First item', '1', 'violet'),
              _listItem('Second item', '2', 'violet'),
              _listItem('Third item', 'NEW', 'fuchsia'),
              _listItem('Fourth item', '4', 'violet'),
            ]),
          ]),
          _card('fa-list-ol', 'indigo', 'Ordered list', [
            $Ol(attrs: {
              'class':
                  'space-y-2 list-decimal list-inside marker:text-indigo-500 marker:font-bold text-slate-700',
            }, children: [
              $Li(children: [$Text('Setup your environment')]),
              $Li(children: [$Text('Import Htmler library')]),
              $Li(children: [$Text('Compose your tags')]),
              $Li(children: [$Text('Render beautiful HTML')]),
            ]),
          ]),
        ]),
      ]);

  Tag _listItem(String label, String badge, String color) => $Li(attrs: {
        'class':
            'flex items-center justify-between gap-3 bg-white px-4 py-3 text-sm text-slate-700 hover:bg-violet-50/40 transition',
      }, children: [
        $Span(attrs: {
          'class': 'flex items-center gap-2',
        }, children: [
          $I(attrs: {
            'class': 'fa-solid fa-circle-dot text-[10px] text-$color-500',
          }, children: []),
          $Text(label),
        ]),
        $Span(attrs: {
          'class':
              'inline-flex h-6 min-w-6 items-center justify-center rounded-full bg-$color-100 px-2 text-[11px] font-bold text-$color-700 ring-1 ring-$color-200',
        }, children: [
          $Text(badge),
        ]),
      ]);

  // ─────────────────────────────────────────────
  //  FORMS
  // ─────────────────────────────────────────────
  Tag _forms() => $Section(attrs: {
        'id': 'forms',
        'class': 'scroll-mt-20'
      }, children: [
        _sectionHeader('03 · Inputs', 'Interactive form elements',
            'Inputs, selects, textareas, range sliders — every form widget you need.'),
        $Form(attrs: {
          'method': 'post',
          'action': '#',
          'class': 'grid gap-5 lg:grid-cols-3',
        }, children: [
          _card('fa-user', 'violet', 'User information', [
            _input(
                'name', 'Full name', 'text', 'Enter your full name', 'fa-user'),
            _input('email', 'Email address', 'email', 'your.email@example.com',
                'fa-envelope'),
            _input('password', 'Password', 'password',
                'Enter a secure password', 'fa-lock'),
            _input('phone', 'Phone number', 'tel', '+1 (555) 123-4567',
                'fa-phone'),
          ]),
          _card('fa-sliders', 'fuchsia', 'Preferences', [
            $Div(attrs: {
              'class': 'space-y-1.5'
            }, children: [
              $Label(attrs: {
                'for': 'country',
                'class': 'block text-xs font-semibold text-slate-700',
              }, children: [
                $Text('Country'),
              ]),
              $Select(attrs: {
                'id': 'country',
                'name': 'country',
                'class':
                    'w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-sm text-slate-800 focus:border-violet-500 focus:outline-none focus:ring-2 focus:ring-violet-500/20',
              }, children: [
                $Option(
                    attrs: {'value': ''},
                    children: [$Text('Select your country')]),
                $Option(
                    attrs: {'value': 'us'}, children: [$Text('United States')]),
                $Option(attrs: {'value': 'ca'}, children: [$Text('Canada')]),
                $Option(
                    attrs: {'value': 'uk'},
                    children: [$Text('United Kingdom')]),
                $Option(attrs: {'value': 'de'}, children: [$Text('Germany')]),
              ]),
            ]),
            $Div(attrs: {
              'class': 'space-y-1.5'
            }, children: [
              $Label(attrs: {
                'for': 'interests',
                'class': 'block text-xs font-semibold text-slate-700',
              }, children: [
                $Text('Interests'),
              ]),
              $Select(attrs: {
                'id': 'interests',
                'name': 'interests',
                'multiple': 'true',
                'size': '4',
                'class':
                    'w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-sm text-slate-800 focus:border-fuchsia-500 focus:outline-none focus:ring-2 focus:ring-fuchsia-500/20',
              }, children: [
                $Option(
                    attrs: {'value': 'web-dev'},
                    children: [$Text('Web development')]),
                $Option(
                    attrs: {'value': 'mobile-dev'},
                    children: [$Text('Mobile development')]),
                $Option(
                    attrs: {'value': 'design'},
                    children: [$Text('UI/UX design')]),
                $Option(
                    attrs: {'value': 'data-science'},
                    children: [$Text('Data science')]),
              ]),
            ]),
            $Div(attrs: {
              'class': 'space-y-1.5'
            }, children: [
              $Label(attrs: {
                'for': 'message',
                'class': 'block text-xs font-semibold text-slate-700',
              }, children: [
                $Text('About you'),
              ]),
              $TextArea(attrs: {
                'id': 'message',
                'name': 'message',
                'rows': '3',
                'placeholder':
                    'Share your experience, goals, or anything you\'d like us to know…',
                'class':
                    'w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-sm text-slate-800 focus:border-fuchsia-500 focus:outline-none focus:ring-2 focus:ring-fuchsia-500/20',
              }, children: []),
            ]),
          ]),
          _card('fa-circle-plus', 'indigo', 'Additional options', [
            _input('birthdate', 'Birth date', 'date', '', 'fa-calendar-days'),
            _input('website', 'Website URL', 'url', 'https://yourwebsite.com',
                'fa-globe'),
            $Div(attrs: {
              'class': 'space-y-1.5'
            }, children: [
              $Label(attrs: {
                'for': 'experience',
                'class':
                    'flex items-center justify-between text-xs font-semibold text-slate-700',
              }, children: [
                $Span(children: [$Text('Years of experience')]),
                $Span(attrs: {
                  'id': 'experienceValue',
                  'class':
                      'rounded-md bg-indigo-100 px-2 py-0.5 font-mono text-[11px] text-indigo-700 ring-1 ring-indigo-200',
                }, children: [
                  $Text('5')
                ]),
              ]),
              $Input(attrs: {
                'type': 'range',
                'id': 'experience',
                'name': 'experience',
                'min': '0',
                'max': '20',
                'value': '5',
                'class': 'w-full accent-indigo-500 cursor-pointer',
              }),
            ]),
            $Div(attrs: {
              'class':
                  'rounded-lg border border-slate-200 bg-slate-50 p-3 space-y-2',
            }, children: [
              _check('newsletter', 'Subscribe to newsletter', true),
              _check('terms', 'I agree to the terms', false),
            ]),
            $Button(attrs: {
              'type': 'submit',
              'class':
                  'mt-2 inline-flex w-full items-center justify-center gap-2 rounded-xl bg-gradient-to-r from-violet-500 to-indigo-600 px-4 py-2.5 text-sm font-semibold text-white shadow-soft hover:from-violet-400 hover:to-indigo-500 transition',
            }, children: [
              $I(attrs: {'class': 'fa-solid fa-paper-plane'}, children: []),
              $Text('Submit'),
            ]),
          ]),
        ]),
        _proTip(
            'Required, pattern, and type attributes give you HTML5 validation for free.'),
      ]);

  Tag _input(String name, String label, String type, String placeholder,
          String icon) =>
      $Div(attrs: {
        'class': 'space-y-1.5'
      }, children: [
        $Label(attrs: {
          'for': name,
          'class': 'block text-xs font-semibold text-slate-700',
        }, children: [
          $Text(label),
        ]),
        $Div(attrs: {
          'class': 'relative'
        }, children: [
          $Span(attrs: {
            'class':
                'pointer-events-none absolute inset-y-0 start-0 grid w-9 place-items-center text-slate-400',
          }, children: [
            $I(attrs: {'class': 'fa-solid $icon text-xs'}, children: []),
          ]),
          $Input(attrs: {
            'type': type,
            'id': name,
            'name': name,
            'placeholder': placeholder,
            'class':
                'w-full rounded-lg border border-slate-300 bg-white ps-9 pe-3 py-2 text-sm text-slate-800 placeholder:text-slate-400 focus:border-violet-500 focus:outline-none focus:ring-2 focus:ring-violet-500/20',
          }),
        ]),
      ]);

  Tag _check(String name, String label, bool checked) => $Label(attrs: {
        'class':
            'flex items-center gap-2 cursor-pointer text-sm text-slate-700',
      }, children: [
        $Input(attrs: {
          'type': 'checkbox',
          'name': name,
          'class':
              'h-4 w-4 rounded border-slate-300 text-violet-600 focus:ring-violet-500',
          if (checked) 'checked': 'true',
        }),
        $Text(label),
      ]);

  // ─────────────────────────────────────────────
  //  TABLES
  // ─────────────────────────────────────────────
  Tag _tables() => $Section(attrs: {
        'id': 'tables',
        'class': 'scroll-mt-20'
      }, children: [
        _sectionHeader('04 · Data', 'Tables',
            'Sortable, striped, responsive tables — straight from \$Table builders.'),
        $Div(attrs: {
          'class':
              'overflow-hidden rounded-2xl bg-white shadow-soft ring-1 ring-slate-200',
        }, children: [
          $Div(attrs: {
            'class':
                'flex items-center gap-3 border-b border-slate-200 bg-gradient-to-r from-violet-50 to-indigo-50 px-5 py-4',
          }, children: [
            $Span(attrs: {
              'class':
                  'grid h-10 w-10 place-items-center rounded-xl bg-gradient-to-br from-violet-500 to-indigo-600 text-white shadow-sm',
            }, children: [
              $I(attrs: {'class': 'fa-solid fa-table'}, children: []),
            ]),
            $Div(children: [
              $H3(attrs: {
                'class': 'text-base font-bold text-slate-900'
              }, children: [
                $Text('Popular programming languages, 2024'),
              ]),
              $P(attrs: {
                'class': 'text-xs text-slate-500'
              }, children: [
                $Text('Source: Stack Overflow Developer Survey'),
              ]),
            ]),
          ]),
          $Div(attrs: {
            'class': 'overflow-x-auto'
          }, children: [
            $Table(attrs: {
              'class': 'min-w-full text-sm',
            }, children: [
              $Thead(attrs: {
                'class':
                    'bg-slate-50 text-[11px] uppercase tracking-wider text-slate-600',
              }, children: [
                $Tr(children: [
                  $Th(
                      attrs: {'class': 'px-5 py-3 text-start'},
                      children: [$Text('#')]),
                  $Th(
                      attrs: {'class': 'px-5 py-3 text-start'},
                      children: [$Text('Language')]),
                  $Th(
                      attrs: {'class': 'px-5 py-3 text-start'},
                      children: [$Text('Popularity')]),
                  $Th(
                      attrs: {'class': 'px-5 py-3 text-start'},
                      children: [$Text('Primary use')]),
                  $Th(
                      attrs: {'class': 'px-5 py-3 text-start'},
                      children: [$Text('Year')]),
                ]),
              ]),
              $Tbody(attrs: {
                'class': 'divide-y divide-slate-100'
              }, children: [
                _tableRow('1', 'JavaScript', 69.7, 'Web development', '1995'),
                _tableRow('2', 'Python', 51.8, 'Data science, AI', '1991'),
                _tableRow('3', 'Dart', 6.02, 'Flutter, web apps', '2011'),
                _tableRow('4', 'Java', 40.2, 'Enterprise, Android', '1995'),
              ]),
            ]),
          ]),
        ]),
      ]);

  Tag _tableRow(String rank, String name, double pct, String use, String year) {
    final pctStr = pct.toStringAsFixed(pct == pct.roundToDouble() ? 1 : 2);
    return $Tr(attrs: {
      'class': 'hover:bg-violet-50/40 transition'
    }, children: [
      $Td(attrs: {
        'class': 'px-5 py-3'
      }, children: [
        $Span(attrs: {
          'class':
              'inline-flex h-7 w-7 items-center justify-center rounded-full bg-gradient-to-br from-violet-500 to-indigo-600 text-xs font-bold text-white shadow-sm',
        }, children: [
          $Text(rank),
        ]),
      ]),
      $Td(
          attrs: {'class': 'px-5 py-3 font-semibold text-slate-900'},
          children: [$Text(name)]),
      $Td(attrs: {
        'class': 'px-5 py-3'
      }, children: [
        $Div(attrs: {
          'class': 'flex items-center gap-2'
        }, children: [
          $Div(attrs: {
            'class': 'h-2 w-32 overflow-hidden rounded-full bg-slate-100',
          }, children: [
            $Div(attrs: {
              'class': 'h-full bg-gradient-to-r from-violet-500 to-indigo-600',
              'style': 'width: ${pct.clamp(0, 100)}%',
            }, children: []),
          ]),
          $Span(
              attrs: {'class': 'font-mono text-xs text-slate-600'},
              children: [$Text('$pctStr%')]),
        ]),
      ]),
      $Td(attrs: {'class': 'px-5 py-3 text-slate-700'}, children: [$Text(use)]),
      $Td(
          attrs: {'class': 'px-5 py-3 text-slate-500 font-mono text-xs'},
          children: [$Text(year)]),
    ]);
  }

  // ─────────────────────────────────────────────
  //  MEDIA — progress + details
  // ─────────────────────────────────────────────
  Tag _media() => $Section(attrs: {
        'id': 'media',
        'class': 'scroll-mt-20'
      }, children: [
        _sectionHeader('05 · Visual', 'Media & visual elements',
            'Progress bars, collapsible details, and interactive widgets.'),
        $Div(attrs: {
          'class': 'grid gap-5 lg:grid-cols-3'
        }, children: [
          _card('fa-chart-simple', 'violet', 'Skill levels', [
            _progress('HTML', 90, 'violet'),
            _progress('CSS', 85, 'fuchsia'),
            _progress('Dart', 95, 'indigo'),
          ]),
          _cardSpan2('fa-chevron-down', 'indigo', 'Disclosure widgets', [
            $Details(attrs: {
              'class':
                  'group rounded-xl border border-slate-200 bg-white p-4 open:bg-violet-50/30 open:border-violet-200 transition',
              'open': 'true',
            }, children: [
              $Summary(attrs: {
                'class':
                    'flex cursor-pointer list-none items-center justify-between gap-3 text-sm font-semibold text-slate-800',
              }, children: [
                $Span(attrs: {
                  'class': 'flex items-center gap-2'
                }, children: [
                  $I(attrs: {
                    'class': 'fa-solid fa-circle-question text-violet-500',
                  }, children: []),
                  $Text('What is Htmler?'),
                ]),
                $I(attrs: {
                  'class':
                      'fa-solid fa-chevron-down text-xs text-slate-400 transition-transform group-open:rotate-180',
                }, children: []),
              ]),
              $Div(attrs: {
                'class':
                    'mt-3 pt-3 border-t border-slate-200 text-sm text-slate-600 space-y-2',
              }, children: [
                $P(children: [
                  $Text(
                      'Htmler lets you build entire HTML documents with composable Dart tag builders — no string templates, full type safety, perfect IDE support.'),
                ]),
                $Ul(attrs: {
                  'class': 'space-y-1 text-sm'
                }, children: [
                  _checkLine('Semantic HTML by default'),
                  _checkLine('Accessibility-friendly'),
                  _checkLine('Zero runtime dependencies'),
                ]),
              ]),
            ]),
            $Details(attrs: {
              'class':
                  'group rounded-xl border border-slate-200 bg-white p-4 open:bg-indigo-50/30 open:border-indigo-200 transition',
            }, children: [
              $Summary(attrs: {
                'class':
                    'flex cursor-pointer list-none items-center justify-between gap-3 text-sm font-semibold text-slate-800',
              }, children: [
                $Span(attrs: {
                  'class': 'flex items-center gap-2'
                }, children: [
                  $I(attrs: {
                    'class': 'fa-solid fa-bolt text-indigo-500',
                  }, children: []),
                  $Text('Why type-safe HTML?'),
                ]),
                $I(attrs: {
                  'class':
                      'fa-solid fa-chevron-down text-xs text-slate-400 transition-transform group-open:rotate-180',
                }, children: []),
              ]),
              $Div(attrs: {
                'class':
                    'mt-3 pt-3 border-t border-slate-200 text-sm text-slate-600',
              }, children: [
                $P(children: [
                  $Text(
                      'Catch typos at compile-time, refactor with confidence, and let your IDE autocomplete the entire HTML5 vocabulary.'),
                ]),
              ]),
            ]),
          ]),
        ]),
      ]);

  Tag _progress(String label, int value, String color) => $Div(attrs: {
        'class': 'space-y-1'
      }, children: [
        $Div(attrs: {
          'class': 'flex justify-between text-xs font-medium text-slate-600',
        }, children: [
          $Span(children: [$Text(label)]),
          $Span(attrs: {'class': 'font-mono'}, children: [$Text('$value%')]),
        ]),
        $Div(attrs: {
          'class': 'h-2 overflow-hidden rounded-full bg-slate-100',
        }, children: [
          $Div(attrs: {
            'class':
                'h-full bg-gradient-to-r from-$color-500 to-$color-600 transition-all',
            'style': 'width: $value%',
          }, children: []),
        ]),
      ]);

  Tag _checkLine(String text) => $Li(attrs: {
        'class': 'flex items-center gap-2',
      }, children: [
        $I(attrs: {
          'class': 'fa-solid fa-circle-check text-emerald-500 text-[11px]'
        }, children: []),
        $Text(text),
      ]);

  // ─────────────────────────────────────────────
  //  CODE EXAMPLES
  // ─────────────────────────────────────────────
  Tag _codeExamples() => $Section(attrs: {
        'id': 'code',
        'class': 'scroll-mt-20'
      }, children: [
        _sectionHeader('06 · Snippets', 'Code examples',
            'How to compose Htmler tags into reusable Dart UI.'),
        $Div(attrs: {
          'class':
              'overflow-hidden rounded-2xl ring-1 ring-slate-200 shadow-soft',
        }, children: [
          $Div(attrs: {
            'class':
                'flex items-center justify-between gap-3 bg-slate-950 px-5 py-3',
          }, children: [
            $Div(attrs: {
              'class': 'flex items-center gap-2'
            }, children: [
              $Span(attrs: {
                'class': 'h-2.5 w-2.5 rounded-full bg-rose-500/80',
              }, children: []),
              $Span(attrs: {
                'class': 'h-2.5 w-2.5 rounded-full bg-amber-400/80',
              }, children: []),
              $Span(attrs: {
                'class': 'h-2.5 w-2.5 rounded-full bg-emerald-400/80',
              }, children: []),
            ]),
            $Span(attrs: {
              'class': 'font-mono text-[11px] text-slate-400',
            }, children: [
              $Text('htmler_controller.dart'),
            ]),
          ]),
          $Div(attrs: {
            'class':
                'overflow-x-auto bg-slate-950 px-5 py-5 font-mono text-[13px] leading-relaxed text-slate-200 whitespace-pre',
          }, children: [
            $Code(children: [
              $Raw(
                  '''<span class="text-slate-500">// Creating a button with Htmler</span>
<span class="text-fuchsia-400">\$Button</span>(attrs: {
  <span class="text-emerald-300">'type'</span>: <span class="text-emerald-300">'submit'</span>,
  <span class="text-emerald-300">'class'</span>: <span class="text-emerald-300">'btn btn-primary'</span>,
}, children: [
  <span class="text-fuchsia-400">\$Text</span>(<span class="text-emerald-300">'Click me!'</span>)
])

<span class="text-slate-500">// Creating a card layout</span>
<span class="text-fuchsia-400">\$Div</span>(attrs: {<span class="text-emerald-300">'class'</span>: <span class="text-emerald-300">'card'</span>}, children: [
  <span class="text-fuchsia-400">\$Div</span>(attrs: {<span class="text-emerald-300">'class'</span>: <span class="text-emerald-300">'card-body'</span>}, children: [
    <span class="text-fuchsia-400">\$H5</span>(children: [<span class="text-fuchsia-400">\$Text</span>(<span class="text-emerald-300">'Card title'</span>)]),
    <span class="text-fuchsia-400">\$P</span>(children: [<span class="text-fuchsia-400">\$Text</span>(<span class="text-emerald-300">'Card content goes here…'</span>)]),
  ]),
])'''),
            ]),
          ]),
        ]),
      ]);

  // ─────────────────────────────────────────────
  //  JINJA INTEGRATION
  // ─────────────────────────────────────────────
  Tag _jinjaIntegration() => $Section(attrs: {
        'id': 'jinja',
        'class': 'scroll-mt-20'
      }, children: [
        _sectionHeader('07 · Dynamic', 'Jinja integration',
            'Mix server-side variables and conditionals into your Dart-built HTML.'),
        $Div(attrs: {
          'class': 'grid gap-5 lg:grid-cols-2'
        }, children: [
          _card('fa-code-branch', 'violet', 'Server variables', [
            $Div(attrs: {
              'class':
                  'rounded-lg border border-slate-200 bg-slate-50 p-4 space-y-2 font-mono text-sm',
            }, children: [
              $Div(children: [
                $Span(
                    attrs: {'class': 'text-slate-500'},
                    children: [$Text('language → ')]),
                $Span(attrs: {
                  'class':
                      'rounded bg-violet-100 px-2 py-0.5 text-violet-700 ring-1 ring-violet-200',
                }, children: [
                  JJ.$var('language'),
                ]),
              ]),
              $Div(children: [
                $Span(
                    attrs: {'class': 'text-slate-500'},
                    children: [$Text('year     → ')]),
                $Span(attrs: {
                  'class':
                      'rounded bg-indigo-100 px-2 py-0.5 text-indigo-700 ring-1 ring-indigo-200',
                }, children: [
                  JJ.$var('year'),
                ]),
              ]),
            ]),
          ]),
          _card('fa-shuffle', 'indigo', 'Conditional rendering', [
            JJ.$if('user', then: [
              $Div(attrs: {
                'class':
                    'flex items-start gap-3 rounded-xl border border-emerald-200 bg-emerald-50 p-4',
              }, children: [
                $I(attrs: {
                  'class': 'fa-solid fa-circle-check mt-0.5 text-emerald-500',
                }, children: []),
                $Div(children: [
                  $P(attrs: {
                    'class': 'text-sm text-emerald-900'
                  }, children: [
                    $Text('Welcome back, '),
                    $B(children: [JJ.$var('user.name')]),
                    $Text('!'),
                  ]),
                  $P(attrs: {
                    'class': 'text-xs text-emerald-700/80'
                  }, children: [
                    $Text('You\'re signed in.'),
                  ]),
                ]),
              ]),
            ], otherwise: [
              $Div(attrs: {
                'class':
                    'flex items-start gap-3 rounded-xl border border-sky-200 bg-sky-50 p-4',
              }, children: [
                $I(attrs: {
                  'class': 'fa-solid fa-circle-info mt-0.5 text-sky-500',
                }, children: []),
                $Div(children: [
                  $P(attrs: {
                    'class': 'text-sm text-sky-900'
                  }, children: [
                    $Text('Please '),
                    $A(attrs: {
                      'href': '/login',
                      'class': 'font-semibold underline',
                    }, children: [
                      $Text('log in'),
                    ]),
                    $Text(' to continue.'),
                  ]),
                ]),
              ]),
            ]),
          ]),
        ]),
      ]);

  // ─────────────────────────────────────────────
  //  FOOTER
  // ─────────────────────────────────────────────
  Tag _footer() => $Footer(attrs: {
        'class':
            'relative mt-16 overflow-hidden bg-gradient-to-br from-slate-950 via-violet-950 to-indigo-950 text-zinc-300',
      }, children: [
        $Div(attrs: {
          'class':
              'pointer-events-none absolute -top-32 left-1/2 -translate-x-1/2 h-72 w-[90%] rounded-full bg-violet-500/10 blur-3xl',
        }, children: []),
        $Div(attrs: {
          'class': 'relative mx-auto max-w-7xl px-4 sm:px-6 lg:px-8 py-12',
        }, children: [
          $Div(attrs: {
            'class': 'flex flex-col items-center text-center gap-5',
          }, children: [
            $Div(attrs: {
              'class': 'flex items-center gap-2'
            }, children: [
              $Span(attrs: {
                'class':
                    'grid h-10 w-10 place-items-center rounded-xl bg-gradient-to-br from-violet-500 to-indigo-600 text-white shadow-soft',
              }, children: [
                $I(attrs: {'class': 'fa-solid fa-code'}, children: []),
              ]),
              $Span(attrs: {
                'class': 'text-xl font-bold text-white tracking-tight',
              }, children: [
                $Text('Htmler'),
              ]),
            ]),
            $P(attrs: {
              'class': 'max-w-xl text-sm leading-relaxed'
            }, children: [
              $Text('Building the future of web development with '),
              $Span(
                  attrs: {'class': 'font-semibold text-white'},
                  children: [$Text('Finch')]),
              $Text(' & '),
              $Span(
                  attrs: {'class': 'font-semibold text-white'},
                  children: [$Text('Htmler')]),
              $Text('.'),
            ]),
            $Div(attrs: {
              'class': 'flex flex-wrap justify-center gap-2'
            }, children: [
              _footerLink('Documentation', 'fa-book'),
              _footerLink('GitHub', 'fa-brands fa-github'),
              _footerLink('Community', 'fa-users'),
            ]),
            $Div(attrs: {
              'class': 'h-px w-full max-w-md bg-white/10',
            }, children: []),
            $P(attrs: {
              'class': 'text-xs text-zinc-400'
            }, children: [
              $Text(
                  '© ${DateTime.now().year} Finch Framework · made with ♥ for developers'),
            ]),
          ]),
        ]),
        $Script(children: [
          $Raw('''
            document.addEventListener('DOMContentLoaded', function() {
              const r = document.getElementById('experience');
              const v = document.getElementById('experienceValue');
              if (r && v) r.addEventListener('input', () => v.textContent = r.value);
            });
          ''')
        ]),
      ]);

  Tag _footerLink(String label, String icon) => $A(attrs: {
        'href': '#',
        'class':
            'inline-flex items-center gap-2 rounded-xl bg-white/5 ring-1 ring-white/10 px-4 py-2 text-sm font-medium text-zinc-200 backdrop-blur hover:bg-white/10 transition',
      }, children: [
        $I(attrs: {'class': '$icon text-xs'}, children: []),
        $Text(label),
      ]);

  // ─────────────────────────────────────────────
  //  GENERIC CARD
  // ─────────────────────────────────────────────
  Tag _card(String icon, String color, String title, List<Tag> body) =>
      $Div(attrs: {
        'class':
            'group overflow-hidden rounded-2xl bg-white ring-1 ring-slate-200 shadow-soft hover:shadow-soft-lg hover:-translate-y-0.5 transition',
      }, children: [
        $Div(attrs: {
          'class':
              'flex items-center gap-3 border-b border-slate-200 bg-gradient-to-r from-$color-50 to-white px-5 py-4',
        }, children: [
          $Span(attrs: {
            'class':
                'grid h-10 w-10 place-items-center rounded-xl bg-gradient-to-br from-$color-500 to-$color-600 text-white shadow-sm ring-1 ring-$color-300/50',
          }, children: [
            $I(attrs: {'class': 'fa-solid $icon text-sm'}, children: []),
          ]),
          $H3(
              attrs: {'class': 'text-base font-bold text-slate-900'},
              children: [$Text(title)]),
        ]),
        $Div(attrs: {'class': 'p-5 space-y-3'}, children: body),
      ]);

  Tag _cardSpan2(String icon, String color, String title, List<Tag> body) =>
      $Div(attrs: {
        'class': 'lg:col-span-2'
      }, children: [
        _card(icon, color, title, body),
      ]);

  // ─────────────────────────────────────────────
  //  PRO TIP
  // ─────────────────────────────────────────────
  Tag _proTip(String text) => $Div(attrs: {
        'class':
            'mt-6 flex items-start gap-3 rounded-xl border border-violet-200 bg-violet-50/60 p-4',
      }, children: [
        $Span(attrs: {
          'class':
              'grid h-8 w-8 shrink-0 place-items-center rounded-lg bg-violet-500 text-white shadow-sm',
        }, children: [
          $I(attrs: {'class': 'fa-solid fa-lightbulb text-xs'}, children: []),
        ]),
        $P(attrs: {
          'class': 'text-sm text-violet-900'
        }, children: [
          $B(
              attrs: {'class': 'text-violet-700'},
              children: [$Text('Pro tip: ')]),
          $Text(text),
        ]),
      ]);
}
