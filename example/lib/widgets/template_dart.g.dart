var mapTemplates = {
	r"example/person.j2.html": r"""{% extends 'template/template.j2.html' %}
{% block title %}
  {{ $t('Example Free model DB') }}
{% endblock %}

{% block content %}
<div class="space-y-6">
  <!-- Page Header -->
  <div class="flex items-center gap-3">
    <div class="flex h-12 w-12 items-center justify-center rounded-xl bg-gradient-to-br from-purple-500 to-purple-600 text-white shadow-lg">
      <svg class="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z"></path>
      </svg>
    </div>
    <div>
      <h1 class="text-2xl font-bold text-gray-800">{{ $t('person.example.title') }}</h1>
      <p class="text-sm text-gray-600">{{ $t('Free model database example') }}</p>
    </div>
  </div>

  {% if data._id == null %}
  <!-- Person List Table Card -->
  <div class="overflow-hidden rounded-xl border border-gray-200 bg-white shadow-lg">
    <div class="overflow-x-auto">
      <table class="min-w-full text-xs md:text-sm divide-y divide-gray-200">
        <thead class="bg-gradient-to-r from-gray-50 to-white">
          <tr class="text-left">
            <th class="px-4 py-4 text-xs font-bold uppercase tracking-wider text-gray-700">{{ $t('person.table.header.name') }}</th>
            <th class="px-4 py-4 text-xs font-bold uppercase tracking-wider text-gray-700">{{ $t('person.table.header.age') }}</th>
            <th class="px-4 py-4 text-xs font-bold uppercase tracking-wider text-gray-700">{{ $t('person.table.header.married') }}</th>
            <th class="px-4 py-4 text-xs font-bold uppercase tracking-wider text-gray-700">{{ $t('person.table.header.email') }}</th>
            <th class="px-4 py-4 text-xs font-bold uppercase tracking-wider text-gray-700">{{ $t('person.table.header.height') }}</th>
            <th class="px-4 py-4 text-xs font-bold uppercase tracking-wider text-gray-700">{{ $t('person.table.header.birthday') }}</th>
            <th class="px-4 py-4 text-xs font-bold uppercase tracking-wider text-gray-700">{{ $t('person.table.header.job') }}</th>
            <th class="px-4 py-4 text-xs font-bold uppercase tracking-wider text-gray-700">{{ $t('person.table.header.skills') }}</th>
            <th class="px-4 py-4 text-center text-xs font-bold uppercase tracking-wider text-gray-700">{{ $t('person.table.header.action') }}</th>
          </tr>
        </thead>
        <tbody class="divide-y divide-gray-100 bg-white">
          {% for person in allPerson %}
          <tr class="group transition-colors duration-150 hover:bg-blue-50">
            <td class="px-4 py-3 font-semibold text-gray-800">
              <div class="flex items-center gap-2">
                <span style="background-color: {{ person.color }};" class="inline-block h-3 w-3 rounded-full shadow-sm"></span>
                <span>{{ person.name }}</span>
              </div>
            </td>
            <td class="px-4 py-3 text-gray-700">{{ person.age }}</td>
            <td class="px-4 py-3 text-gray-700">{{ person.married }}</td>
            <td class="px-4 py-3 text-gray-700">{{ person.email }}</td>
            <td class="px-4 py-3 text-gray-700">{{ person.height }}</td>
            <td class="px-4 py-3 text-gray-700">{{ person.birthday | dateFormat('dd/MM/yyyy, HH:mm') }}</td>
            <td class="px-4 py-3 text-gray-700">{{ person.job.title | default('Unknown') }}</td>
            <td class="px-4 py-3 text-gray-700">{{ person.jobs|length }}</td>
            <td class="px-4 py-3">
              <div class="flex items-center justify-center gap-2">
                <form onsubmit="return confirm('{{ $t('Are you sure to delete') }} `{{ person.name }}`?')" action="/example/person/delete/{{ person._id }}" method="POST">
                  <input type="hidden" name="action" value="DELETE" />
                  <button type="submit" class="wave inline-flex h-8 w-8 items-center justify-center rounded-lg border border-rose-200 text-rose-600 transition-all duration-150 hover:bg-rose-50 hover:border-rose-300 hover:shadow-md focus:outline-none focus:ring-2 focus:ring-rose-500/30" title="{{ $t('Delete') }}">
                    <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path>
                    </svg>
                  </button>
                </form>
                <a href="/example/person/{{ person._id }}" class="wave inline-flex h-8 w-8 items-center justify-center rounded-lg border border-blue-200 text-blue-600 transition-all duration-150 hover:bg-blue-50 hover:border-blue-300 hover:shadow-md focus:outline-none focus:ring-2 focus:ring-blue-500/30" title="{{ $t('Edit') }}">
                  <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"></path>
                  </svg>
                </a>
              </div>
            </td>
          </tr>
          {% endfor %}
          {% if not allPerson ?? allPerson|length == 0 %}
          <tr>
            <td colspan="100%" class="px-4 py-12 text-center">
              <div class="flex flex-col items-center gap-3">
                <div class="flex h-16 w-16 items-center justify-center rounded-xl bg-gray-100">
                  <svg class="h-8 w-8 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 13V6a2 2 0 00-2-2H6a2 2 0 00-2 2v7m16 0v5a2 2 0 01-2 2H6a2 2 0 01-2-2v-5m16 0h-2.586a1 1 0 00-.707.293l-2.414 2.414a1 1 0 01-.707.293h-3.172a1 1 0 01-.707-.293l-2.414-2.414A1 1 0 006.586 13H4"></path>
                  </svg>
                </div>
                <p class="text-sm text-gray-500">{{ $t('person.table.empty') }}</p>
              </div>
            </td>
          </tr>
          {% endif %}
        </tbody>
        <tfoot class="border-t border-gray-200 bg-gradient-to-r from-gray-50 to-white">
          <tr>
            <td colspan="100%" class="px-4 py-4 text-sm text-gray-700">
              {{ paging }}
            </td>
          </tr>
        </tfoot>
      </table>
    </div>
  </div>
  {% endif %}

  <!-- Person Form Card -->
  <div class="rounded-xl border border-gray-200 bg-white p-6 shadow-lg">
    {% include $e.widgetPath('example/forms/form_person') %}
  </div>
</div>
{% endblock %}""",
	r"example/i18n.j2.html": r"""{% extends 'template/template.j2.html' %}
{% block title %}
    {{ $t('sidebar.languageExample') }}
{% endblock %}

{% block content %}
<div class="space-y-6">
  <!-- Page Header with Language Selector -->
  <div class="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
    <div class="flex items-center gap-3">
      <div class="flex h-12 w-12 items-center justify-center rounded-xl bg-gradient-to-br from-blue-500 to-blue-600 text-white shadow-lg">
        <svg class="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 5h12M9 3v2m1.048 9.5A18.022 18.022 0 016.412 9m6.088 9h7M11 21l5-10 5 10M12.751 5C11.783 10.77 8.07 15.61 3 18.129"></path>
        </svg>
      </div>
      <div>
        <h1 class="text-2xl font-bold text-gray-800">{{ $t('i18n.title') }}</h1>
        <p class="text-sm text-gray-600">{{ $t('Localization and internationalization') }}</p>
      </div>
    </div>
    <details class="group relative">
      <summary class="list-none inline-flex cursor-pointer select-none items-center gap-2 rounded-lg border border-gray-300 bg-white px-4 py-2.5 text-sm font-semibold text-gray-700 shadow-sm transition-all duration-200 hover:bg-gray-50 hover:border-gray-400 focus:outline-none focus:ring-4 focus:ring-blue-500/20">
        <span class="font-mono text-xs uppercase">{{ $e.ln }}</span>
        <svg class="h-4 w-4 text-gray-500 transition-transform duration-200 group-open:rotate-180" viewBox="0 0 10 6" fill="none" stroke="currentColor" stroke-width="1.5"><path d="M1 1l4 4 4-4" stroke-linecap="round" stroke-linejoin="round"/></svg>
      </summary>
      <ul class="absolute end-0 z-20 mt-2 w-64 max-h-80 overflow-y-auto rounded-lg border border-gray-200 bg-white p-1.5 shadow-xl">
        {% for key, language in languages %}
        <li>
          <a href="{{ $e.urlToLanguage(key) }}" class="wave flex items-center gap-3 rounded-lg px-3 py-2.5 text-sm transition-all duration-150 {{ 'bg-gradient-to-r from-blue-600 to-blue-700 text-white shadow-md' if $e.ln == key else 'text-gray-700 hover:bg-blue-50' }}">
            <img src="{{ language.flag }}" class="inline-flex w-6 items-center justify-center text-base"/>
            <span class="font-medium truncate">{{ language.name }}</span>
          </a>
        </li>
        {% endfor %}
      </ul>
    </details>
  </div>

  <!-- Translation Examples Card -->
  <div class="rounded-xl border border-gray-200 bg-white p-6 shadow-lg">
    <div class="space-y-3">
      <div class="flex items-start gap-3 rounded-lg border-l-4 border-emerald-500 bg-gradient-to-r from-emerald-50 to-emerald-100/50 px-4 py-3">
        <svg class="h-5 w-5 shrink-0 text-emerald-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path>
        </svg>
        <span class="text-sm font-medium text-emerald-800">{{ $t('i18n.exampleTString') }}</span>
      </div>
      <div class="flex items-start gap-3 rounded-lg border-l-4 border-emerald-500 bg-gradient-to-r from-emerald-50 to-emerald-100/50 px-4 py-3">
        <svg class="h-5 w-5 shrink-0 text-emerald-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path>
        </svg>
        <span class="text-sm font-medium text-emerald-800">{{ $t('i18n.examplePath') }}</span>
      </div>
      <div class="flex items-start gap-3 rounded-lg border-l-4 border-emerald-500 bg-gradient-to-r from-emerald-50 to-emerald-100/50 px-4 py-3">
        <svg class="h-5 w-5 shrink-0 text-emerald-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path>
        </svg>
        <span class="text-sm font-medium text-emerald-800">{{ $t('i18n.examplePathString') }}</span>
      </div>
      <div class="flex items-start gap-3 rounded-lg border-l-4 border-emerald-500 bg-gradient-to-r from-emerald-50 to-emerald-100/50 px-4 py-3">
        <svg class="h-5 w-5 shrink-0 text-emerald-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path>
        </svg>
        <span class="text-sm font-medium text-emerald-800">{{ $t('example.params') }}</span>
      </div>
      <div class="flex items-start gap-3 rounded-lg border-l-4 border-emerald-500 bg-gradient-to-r from-emerald-50 to-emerald-100/50 px-4 py-3">
        <svg class="h-5 w-5 shrink-0 text-emerald-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path>
        </svg>
        <span class="text-sm font-medium text-emerald-800">{{ $t('i18n.exampleParams', {'name': 'Jack', 'age': 20}) }}</span>
      </div>
      <div class="flex items-start gap-3 rounded-lg border-l-4 border-emerald-500 bg-gradient-to-r from-emerald-50 to-emerald-100/50 px-4 py-3">
        <svg class="h-5 w-5 shrink-0 text-emerald-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path>
        </svg>
        <span class="text-sm font-medium text-emerald-800">{{ $t(exampleTranslateDynamic) }}</span>
      </div>
    </div>
  </div>

  <!-- File References Card -->
  <div class="rounded-xl border border-gray-200 bg-white shadow-lg">
    <div class="divide-y divide-gray-100">
      <div class="flex items-center gap-4 px-6 py-4 transition-colors duration-150 hover:bg-blue-50">
        <div class="flex h-10 w-10 shrink-0 items-center justify-center rounded-lg bg-blue-100 text-blue-600">
          <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path>
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"></path>
          </svg>
        </div>
        <div class="flex-1 min-w-0">
          <p class="text-sm font-semibold text-gray-700">{{ $t('i18n.view') }}</p>
          <code class="text-xs text-blue-600 truncate block">example/lib/widgets/example/i18n.j2.html</code>
        </div>
      </div>
      <div class="flex items-center gap-4 px-6 py-4 transition-colors duration-150 hover:bg-blue-50">
        <div class="flex h-10 w-10 shrink-0 items-center justify-center rounded-lg bg-purple-100 text-purple-600">
          <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 20l4-16m4 4l4 4-4 4M6 16l-4-4 4-4"></path>
          </svg>
        </div>
        <div class="flex-1 min-w-0">
          <p class="text-sm font-semibold text-gray-700">{{ $t('i18n.controller') }}</p>
          <code class="text-xs text-purple-600 truncate block">example/lib/controllers/home_controller.dart</code>
        </div>
      </div>
      <div class="flex items-center gap-4 px-6 py-4 transition-colors duration-150 hover:bg-blue-50">
        <div class="flex h-10 w-10 shrink-0 items-center justify-center rounded-lg bg-amber-100 text-amber-600">
          <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 7v10a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2h-6l-2-2H5a2 2 0 00-2 2z"></path>
          </svg>
        </div>
        <div class="flex-1 min-w-0">
          <p class="text-sm font-semibold text-gray-700">{{ $t('i18n.languagesDirectory') }}</p>
          <code class="text-xs text-amber-600 truncate block">example/lib/languages</code>
        </div>
      </div>
    </div>
  </div>
</div>
{% endblock %}""",
	r"example/forms/form_person.j2.html": r"""<form method="POST" action="/example/person/{{ (data._id) if data._id else '' }}" class="space-y-6">
  <input type="hidden" name="action" value="{{ 'EDIT' if data._id else 'ADD' }}" />
  <input type="hidden" name="id" value="{{ data if data._id else '' }}" />

  <!-- Row 1: Name / Email -->
  <div class="grid gap-5 md:grid-cols-2">
    <div>
      <label for="name" class="mb-2 block text-sm font-semibold text-gray-700">{{ $t('person.form.label.name') }}</label>
      <div class="relative">
        <div class="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-3">
          <svg class="h-5 w-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"></path>
          </svg>
        </div>
        <input
          type="text"
          id="name"
          name="name"
          value="{{ $n('form/name/value') }}"
          placeholder="{{ $t('person.form.placeholder.name') }}"
          class="h-12 w-full rounded-lg border border-gray-300 bg-white pl-10 pr-4 text-sm shadow-sm transition-all duration-200 focus:border-blue-500 focus:ring-4 focus:ring-blue-500/20 {{ 'border-rose-500 ring-4 ring-rose-500/20 focus:border-rose-500 focus:ring-rose-500/20' if $n('form/name/failed') else '' }}"
        />
      </div>
      <div class="mt-1.5 flex items-center gap-1.5 text-xs text-rose-700 {{ '' if $n('form/name/failed') else 'hidden' }}">{{ $t($n('form/name/errors/0')) }}</div>
    </div>
    <div>
      <label for="email" class="mb-2 block text-sm font-semibold text-gray-700">{{ $t('person.form.label.email') }}</label>
      <div class="relative">
        <div class="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-3">
          <svg class="h-5 w-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"></path>
          </svg>
        </div>
        <input
          type="email"
          id="email"
          name="email"
          value="{{ $n('form/email/value') }}"
          placeholder="{{ $t('person.form.placeholder.email') }}"
          {% if data._id %}readonly disabled{% endif %}
          class="h-12 w-full rounded-lg border border-gray-300 bg-white pl-10 pr-4 text-sm shadow-sm transition-all duration-200 focus:border-blue-500 focus:ring-4 focus:ring-blue-500/20 {{ 'opacity-60 cursor-not-allowed' if data._id else '' }} {{ 'border-rose-500 ring-4 ring-rose-500/20 focus:border-rose-500 focus:ring-rose-500/20' if $n('form/email/failed') else '' }}"
        />
      </div>
      <div class="mt-1.5 flex items-center gap-1.5 text-xs text-rose-700 {{ '' if $n('form/email/failed') else 'hidden' }}">{{ $t($n('form/email/errors/0')) }}</div>
    </div>
  </div>

  <!-- Row 2: Age / Birthday -->
  <div class="grid gap-5 md:grid-cols-2">
    <div>
      <label for="age" class="mb-2 block text-sm font-semibold text-gray-700">{{ $t('person.form.label.age') }}</label>
      <div class="relative">
        <div class="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-3">
          <svg class="h-5 w-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 20l4-16m4 4l4 4-4 4M6 16l-4-4 4-4"></path>
          </svg>
        </div>
        <input
          type="number"
          id="age"
          name="age"
          value="{{ $n('form/age/value') }}"
          placeholder="{{ $t('person.form.placeholder.age') }}"
          class="h-12 w-full rounded-lg border border-gray-300 bg-white pl-10 pr-4 text-sm shadow-sm transition-all duration-200 focus:border-blue-500 focus:ring-4 focus:ring-blue-500/20 {{ 'border-rose-500 ring-4 ring-rose-500/20 focus:border-rose-500 focus:ring-rose-500/20' if $n('form/age/failed') else '' }}"
        />
      </div>
      <div class="mt-1.5 flex items-center gap-1.5 text-xs text-rose-700 {{ '' if $n('form/age/failed') else 'hidden' }}">{{ $t($n('form/age/errors/0')) }}</div>
    </div>
    <div>
      <label for="birthday" class="mb-2 block text-sm font-semibold text-gray-700">{{ $t('person.form.label.birthday') }}</label>
      <div class="relative">
        <div class="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-3">
          <svg class="h-5 w-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"></path>
          </svg>
        </div>
        <input
          type="datetime-local"
          id="birthday"
          name="birthday"
          value="{{ $n('form/birthday/value') | dateFormat('yyyy-MM-ddThh:mm') }}"
          {% if data._id %}readonly disabled{% endif %}
          class="h-12 w-full rounded-lg border border-gray-300 bg-white pl-10 pr-4 text-sm shadow-sm transition-all duration-200 focus:border-blue-500 focus:ring-4 focus:ring-blue-500/20 {{ 'opacity-60 cursor-not-allowed' if data._id else '' }} {{ 'border-rose-500 ring-4 ring-rose-500/20 focus:border-rose-500 focus:ring-rose-500/20' if $n('form/birthday/failed') else '' }}"
        />
      </div>
      <div class="mt-1.5 flex items-center gap-1.5 text-xs text-rose-700 {{ '' if $n('form/birthday/failed') else 'hidden' }}">{{ $t($n('form/birthday/errors/0')) }}</div>
    </div>
  </div>

  <!-- Row 3: Height / Job Title -->
  <div class="grid gap-5 md:grid-cols-2">
    <div>
      <label for="height" class="mb-2 block text-sm font-semibold text-gray-700">{{ $t('person.form.label.height') }}</label>
      <input
        type="number"
        step="0.1"
        id="height"
        name="height"
        value="{{ $n('form/height/value') }}"
        placeholder="{{ $t('person.form.placeholder.height') }}"
        class="h-12 w-full rounded-lg border border-gray-300 bg-white px-4 text-sm shadow-sm transition-all duration-200 focus:border-blue-500 focus:ring-4 focus:ring-blue-500/20 {{ 'border-rose-500 ring-4 ring-rose-500/20 focus:border-rose-500 focus:ring-rose-500/20' if $n('form/height/failed') else '' }}"
      />
      <div class="mt-1.5 flex items-center gap-1.5 text-xs text-rose-700 {{ '' if $n('form/height/failed') else 'hidden' }}">{{ $t($n('form/height/errors/0')) }}</div>
    </div>
    <div>
      <label for="job_id" class="mb-2 block text-sm font-semibold text-gray-700">{{ $t('person.form.label.job_title') }}</label>
      <select
        id="job_id"
        name="job_id"
        class="h-12 w-full rounded-lg border border-gray-300 bg-white px-4 text-sm shadow-sm transition-all duration-200 focus:border-blue-500 focus:ring-4 focus:ring-blue-500/20 {{ 'border-rose-500 ring-4 ring-rose-500/20 focus:border-rose-500 focus:ring-rose-500/20' if $n('form/job_id/failed') else '' }}"
      >
        <option value="">{{ $t('person.form.option.select_job') }}</option>
        {% for job in jobs %}
          <option {{ 'selected' if $n('form/job_id/value')|oid == job._id else '' }} value="{{ job._id }}">{{ job.title }}</option>
        {% endfor %}
      </select>
      <div class="mt-1.5 flex items-center gap-1.5 text-xs text-rose-700 {{ '' if $n('form/job_id/failed') else 'hidden' }}">{{ $t($n('form/job_id/errors/0')) }}</div>
    </div>
  </div>

  <!-- Row 4: Skills -->
  <div>
    <label class="mb-2 block text-sm font-semibold text-gray-700">{{ $t('person.form.label.skills') }}</label>
    {% set oids = $n('form/jobs/value') | oid %}
    <div class="grid gap-3 sm:grid-cols-2 md:grid-cols-3">
      {% for job in jobs %}
      <label for="jobs_{{ job._id }}" class="flex items-center gap-3 rounded-lg border border-gray-300 bg-white px-4 py-3 text-sm font-medium text-gray-700 shadow-sm transition-all duration-150 hover:border-blue-400 hover:bg-blue-50 cursor-pointer">
        <input
          type="checkbox"
          id="jobs_{{ job._id }}"
          name="jobs[]"
          value="{{ job._id | oid }}"
          class="h-5 w-5 rounded border-gray-300 text-blue-600 transition-all duration-200 focus:ring-4 focus:ring-blue-500/20"
          {{ 'checked' if ((job._id) in oids) else '' }}
        />
        <span class="truncate">{{ job.title }}</span>
      </label>
      {% endfor %}
    </div>
    <div class="mt-1.5 flex items-center gap-1.5 text-xs text-rose-700 {{ '' if $n('form/jobs/failed') else 'hidden' }}">{{ $t($n('form/jobs/errors/0')) }}</div>
  </div>

  <!-- Row 5: Password / Gender -->
  <div class="grid gap-5 md:grid-cols-2">
    <div>
      <label for="password" class="mb-2 block text-sm font-semibold text-gray-700">{{ $t('person.form.label.password') }}</label>
      <div class="relative">
        <div class="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-3">
          <svg class="h-5 w-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"></path>
          </svg>
        </div>
        <input
          type="password"
          id="password"
          name="password"
          value="{{ $n('form/password/value') }}"
          placeholder="{{ $t('person.form.placeholder.password') }}"
          {% if data._id %} readonly disabled{% endif %}
          class="h-12 w-full rounded-lg border border-gray-300 bg-white pl-10 pr-4 text-sm shadow-sm transition-all duration-200 focus:border-blue-500 focus:ring-4 focus:ring-blue-500/20 {{ 'opacity-60 cursor-not-allowed' if data._id else '' }} {{ 'border-rose-500 ring-4 ring-rose-500/20 focus:border-rose-500 focus:ring-rose-500/20' if $n('form/password/failed') else '' }}"
        />
      </div>
      <div class="mt-1.5 flex items-center gap-1.5 text-xs text-rose-700 {{ '' if $n('form/password/failed') else 'hidden' }}">{{ $t($n('form/password/errors/0')) }}</div>
    </div>
    <div>
      <label for="gender" class="mb-2 block text-sm font-semibold text-gray-700">{{ $t('person.form.label.gender') }}</label>
      <select
        id="gender"
        name="gender"
        class="h-12 w-full rounded-lg border border-gray-300 bg-white px-4 text-sm shadow-sm transition-all duration-200 focus:border-blue-500 focus:ring-4 focus:ring-blue-500/20 {{ 'border-rose-500 ring-4 ring-rose-500/20 focus:border-rose-500 focus:ring-rose-500/20' if $n('form/gender/failed') else '' }}"
      >
        <option {{ 'selected' if $n('form/gender/value') == 'none' else '' }} value="none">{{ $t('person.form.gender.dont_ask') }}</option>
        <option {{ 'selected' if $n('form/gender/value') == 'male' else '' }} value="male">{{ $t('person.form.gender.male') }}</option>
        <option {{ 'selected' if $n('form/gender/value') == 'female' else '' }} value="female">{{ $t('person.form.gender.female') }}</option>
        <option {{ 'selected' if $n('form/gender/value') == 'other' else '' }} value="other">{{ $t('person.form.gender.other') }}</option>
      </select>
      <div class="mt-1.5 flex items-center gap-1.5 text-xs text-rose-700 {{ '' if $n('form/gender/failed') else 'hidden' }}">{{ $t($n('form/gender/errors/0')) }}</div>
    </div>
  </div>

  <!-- Row 6: Married / Color -->
  <div class="grid gap-6 md:grid-cols-2">
    <div>
      <label for="married" class="mb-1 block text-sm font-medium text-slate-700">{{ $t('person.form.label.married') }}</label>
      <input name="married" type="hidden" value="false" />
      <label class="relative inline-flex cursor-pointer items-center">
        <input name="married" id="married" type="checkbox" value="true" class="peer sr-only" {{ 'checked' if $n('form/married/value') else '' }} />
        <div class="h-5 w-9 rounded-full bg-slate-300 transition peer-checked:bg-primary-600"></div>
        <div class="absolute left-0 top-0 h-5 w-5 translate-x-0 rounded-full bg-white shadow transition peer-checked:translate-x-4"></div>
      </label>
    </div>
    <div>
      <label for="color" class="mb-1 block text-sm font-medium text-slate-700">{{ $t('person.form.label.color') }}</label>
      <input type="color" id="color" name="color" value="{{ $n('form/color/value','#FF0055') }}" title="{{ $t('person.form.tooltip.color') }}" class="h-10 w-24 cursor-pointer rounded-md border border-slate-300 bg-white p-1 shadow-sm focus:border-primary-500 focus:ring-2 focus:ring-primary-500/30" />
    </div>
  </div>

  <!-- Actions -->
  <div class="flex flex-wrap gap-3 border-t border-slate-200 pt-4">
    <button type="submit" class="wave inline-flex items-center rounded-md bg-primary-600 px-5 py-2.5 text-sm font-medium text-white shadow-sm hover:bg-primary-700 focus:outline-none focus:ring-2 focus:ring-primary-500/30">{{ $t('person.form.button.submit') }}</button>
    {% if data._id %}
    <a href="{{ $e.url('/example/person') }}" class="wave inline-flex items-center rounded-md border border-slate-300 bg-white px-5 py-2.5 text-sm font-medium text-slate-700 shadow-sm hover:bg-slate-50 focus:outline-none focus:ring-2 focus:ring-primary-500/30">{{ $t('person.form.button.cancel') }}</a>
    {% endif %}
  </div>
</form>""",
	r"example/database.j2.html": r"""{% extends 'template/template.j2.html' %}
{% block title %}
  {{ $t('sidebar.mongo') }}
{% endblock %}

{% block content %}
<div class="space-y-6">
  <!-- Page Header -->
  <div class="flex items-center gap-3">
    <div class="flex h-12 w-12 items-center justify-center rounded-xl bg-gradient-to-br from-green-500 to-green-600 text-white shadow-lg">
      <svg class="h-6 w-6" fill="currentColor" viewBox="0 0 20 20">
        <path d="M10 2c-1.716 0-3.408.106-5.07.31C3.806 2.45 3 3.414 3 4.517V17.25c0 .966.784 1.75 1.75 1.75h10.5A1.75 1.75 0 0017 17.25V4.517c0-1.103-.806-2.068-1.93-2.207A41.403 41.403 0 0010 2z"></path>
      </svg>
    </div>
    <div>
      <h1 class="text-2xl font-bold text-gray-800">{{ $t('database.test.title') }}</h1>
      <p class="text-sm text-gray-600">{{ $t('MongoDB example with CRUD operations') }}</p>
    </div>
  </div>

  <!-- Table Card -->
  <div class="overflow-hidden rounded-xl border border-gray-200 bg-white shadow-lg">
    <div class="overflow-x-auto">
      <table class="min-w-full divide-y divide-gray-200 text-sm">
        <thead class="bg-gradient-to-r from-gray-50 to-white">
          <tr class="text-left">
            <th class="px-6 py-4 text-xs font-bold uppercase tracking-wider text-gray-700">{{ $t('database.table.header.title') }}</th>
            <th class="px-6 py-4 text-xs font-bold uppercase tracking-wider text-gray-700">{{ $t('database.table.header.slug') }}</th>
            <th class="px-6 py-4 text-center text-xs font-bold uppercase tracking-wider text-gray-700">{{ $t('database.table.header.action') }}</th>
          </tr>
        </thead>
        <tbody class="divide-y divide-gray-100 bg-white">
          {% for record in allRecords %}
          <tr class="group transition-colors duration-150 hover:bg-blue-50">
            <td class="px-6 py-4 align-top">
              <div class="flex items-center gap-2">
                <div class="h-2 w-2 rounded-full bg-blue-600"></div>
                <span class="font-semibold text-gray-800">{{ record.title }}</span>
              </div>
            </td>
            <td class="px-6 py-4 align-top">
              <code class="rounded-md bg-gray-100 px-2 py-1 text-xs text-gray-700">{{ record.slug }}</code>
            </td>
            <td class="px-6 py-4 text-center">
              <a
                href="/example/database?page={{ data.page if data.page else 1 }}&action=delete&id={{ record.id }}"
                class="inline-flex h-8 w-8 items-center justify-center rounded-lg border border-rose-200 text-rose-600 transition-all duration-150 hover:bg-rose-50 hover:border-rose-300 hover:shadow-md focus:outline-none focus:ring-2 focus:ring-rose-500/30"
                title="{{ $t('database.table.header.action') }}"
              >
                <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path>
                </svg>
              </a>
            </td>
          </tr>
          {% endfor %}
          {% if not allRecords ?? allRecords|length == 0 %}
          <tr>
            <td colspan="3" class="px-6 py-12 text-center">
              <div class="flex flex-col items-center gap-3">
                <div class="flex h-16 w-16 items-center justify-center rounded-full bg-gray-100">
                  <svg class="h-8 w-8 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 13V6a2 2 0 00-2-2H6a2 2 0 00-2 2v7m16 0v5a2 2 0 01-2 2H6a2 2 0 01-2-2v-5m16 0h-2.586a1 1 0 00-.707.293l-2.414 2.414a1 1 0 01-.707.293h-3.172a1 1 0 01-.707-.293l-2.414-2.414A1 1 0 006.586 13H4"></path>
                  </svg>
                </div>
                <p class="text-sm font-medium text-gray-500">{{ $t('database.table.empty') if $t('database.table.empty') else $t('No records found') }}</p>
              </div>
            </td>
          </tr>
          {% endif %}
        </tbody>
      </table>
    </div>
    
    <!-- Footer with Add Form and Pagination -->
    <div class="border-t border-gray-200 bg-gradient-to-r from-gray-50 to-white p-6 space-y-4">
      <form method="post" class="flex flex-col gap-3 sm:flex-row sm:items-center">
        <input type="hidden" name="action" value="add" />
        <div class="flex-1">
          <div class="relative">
            <div class="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-3">
              <svg class="h-5 w-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 20l4-16m2 16l4-16M6 9h14M4 15h14"></path>
              </svg>
            </div>
            <input
              type="text"
              name="title"
              placeholder="{{ $t('database.table.input.placeholder.title') }}"
              class="block h-11 w-full rounded-lg border border-gray-300 bg-white pl-10 pr-3 text-sm shadow-sm transition-all duration-200 focus:border-blue-500 focus:ring-4 focus:ring-blue-500/20"
            />
          </div>
        </div>
        <button
          type="submit"
          class="wave group inline-flex shrink-0 items-center justify-center gap-2 rounded-lg bg-gradient-to-r from-blue-600 to-blue-700 px-5 py-2.5 text-sm font-semibold text-white shadow-md transition-all duration-200 hover:from-blue-700 hover:to-blue-800 hover:shadow-lg focus:outline-none focus:ring-4 focus:ring-blue-500/30"
        >
          <svg class="h-5 w-5 transition-transform duration-200 group-hover:scale-110" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"></path>
          </svg>
          <span>{{ $t('database.table.button.add') }}</span>
        </button>
      </form>
      
      {% if pagination %}
      <div class="flex items-center justify-center border-t border-gray-200 pt-4">
        <div class="pagination-wrapper text-sm text-gray-600">
          {{ pagination }}
        </div>
      </div>
      {% endif %}
    </div>
  </div>
</div>
{% endblock %}""",
	r"example/socket.j2.html": r"""{% extends 'template/template.j2.html' %}

{% block title %}
    {{ $t('sidebar.socketExample') }}
{% endblock %}

{% block content %}
<div class="my-6">
  <h3 class="text-xl font-semibold text-slate-800">
    {{ $t('testWebSocket.title') }}
  </h3>
  <div class="my-3 overflow-hidden rounded-lg border border-slate-200 bg-white shadow-sm">
    <div class="p-5">
      <div class="grid grid-cols-1 gap-4 lg:grid-cols-[1fr,260px]">
        <div>
          <label for="socket-output" class="mb-1 block text-sm font-medium text-slate-700">
            {{ $t('testWebSocket.output') }}
          </label>
          <textarea class="h-[350px] w-full rounded-md border border-slate-300 bg-white p-3 text-sm shadow-sm focus:border-primary-500 focus:ring-2 focus:ring-primary-500/30" id="socket-output"></textarea>
        </div>
        <template id="btn-template-client">
          <button data-id="{id}" class="wave socket-client-send mt-1 inline-flex items-center rounded-md border border-primary-600 px-3 py-1.5 text-sm font-medium text-primary-700 hover:bg-primary-50 focus:outline-none focus:ring-2 focus:ring-primary-500/30 disable-wave">
            {text}
          </button>
        </template>
        <div id="client-list" class="pt-6 lg:pt-8">
          <div class="flex flex-col gap-2" data-client-list></div>
        </div>
      </div>
      <div class="mt-4 flex flex-wrap items-center gap-2">
        <button id="btn-socket-time" class="wave inline-flex items-center rounded-md border border-primary-600 px-3 py-1.5 text-sm font-medium text-primary-700 hover:bg-primary-50 focus:outline-none focus:ring-2 focus:ring-primary-500/30 disable-wave">
          {{ $t('testWebSocket.getTime') }}
        </button>
        <button id="btn-socket-fa" class="wave inline-flex items-center rounded-md border border-primary-600 px-3 py-1.5 text-sm font-medium text-primary-700 hover:bg-primary-50 focus:outline-none focus:ring-2 focus:ring-primary-500/30 disable-wave">
          {{ $t('testWebSocket.randomMessage') }}
        </button>
        <button id="btn-socket-clients" class="wave inline-flex items-center rounded-md border border-primary-600 px-3 py-1.5 text-sm font-medium text-primary-700 hover:bg-primary-50 focus:outline-none focus:ring-2 focus:ring-primary-500/30 disable-wave">
          {{ $t('testWebSocket.clientLists') }}
        </button>
        <button id="btn-socket-stream" class="wave inline-flex items-center rounded-md bg-emerald-600 px-3 py-1.5 text-sm font-medium text-white hover:bg-emerald-700 focus:outline-none focus:ring-2 focus:ring-emerald-500/30 disable-wave">
          {{ $t('testWebSocket.stream') }}
        </button>
        <div class="ml-auto">
          <button
            onclick="document.getElementById('socket-output').value='';document.getElementById('client-list').innerHTML=''"
            class="wave inline-flex items-center rounded-md border border-rose-600 px-3 py-1.5 text-sm font-medium text-rose-700 hover:bg-rose-50 focus:outline-none focus:ring-2 focus:ring-rose-500/30 disable-wave">
            {{ $t('testWebSocket.clear') }}
          </button>
        </div>
      </div>
    </div>
  <div class="hidden p-5" id="videoStream">
      <div class="grid grid-cols-1 gap-4 md:grid-cols-2">
        <video class="w-full rounded-md border border-slate-200" id="localVideo" autoplay muted></video>
        <video class="w-full rounded-md border border-slate-200" id="serverVideo" controls></video>
      </div>
      <div class="mt-3">
        <button id="wave btn-stop-stream" class="inline-flex items-center rounded-md bg-emerald-600 px-3 py-1.5 text-sm font-medium text-white hover:bg-emerald-700 focus:outline-none focus:ring-2 focus:ring-emerald-500/30 disable-wave">
          {{ $t('testWebSocket.stopStream') }}
        </button>
      </div>
    </div>
  </div>
</div>
{% endblock %}
""",
	r"example/dump.j2.html": r"""{% extends 'template/template.j2.html' %} {% block title %} {{
$t('sidebar.info') }} {% endblock %} {% block content %}
<div class="space-y-6">
  <!-- Page Header -->
  <div class="flex items-center gap-3">
    <div class="flex h-12 w-12 items-center justify-center rounded-xl bg-gradient-to-br from-purple-500 to-purple-600 text-white shadow-lg">
      <svg class="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 20l4-16m4 4l4 4-4 4M6 16l-4-4 4-4"></path>
      </svg>
    </div>
    <div>
      <h1 class="text-2xl font-bold text-gray-800">{{ $t('Variable Dump') }}</h1>
      <p class="text-sm text-gray-600">{{ $t('Debug variable output') }}</p>
    </div>
  </div>

  <!-- Dump Output Card -->
  <div class="rounded-xl border border-gray-200 bg-white p-6 shadow-lg">
    <div class="space-y-4">
      <div class="rounded-lg border border-purple-200 bg-gradient-to-r from-purple-50 to-purple-100/50 p-4">
        {{ dump(variable) }}
      </div>
      <div class="rounded-lg border border-gray-300 bg-gray-50 p-4">
        <code class="block text-sm font-mono text-purple-700">
          {% raw  %}
            {{ dump(variable) }}
          {% endraw %}
        </code>
      </div>
    </div>
  </div>
</div>
{% endblock %}
""",
	r"example/sqlite/_filtering.j2.html": r"""<form method="get" class="contents">
    <th class="p-1 align-top" style="max-width:80px;">
        <input
            class="h-8 w-full rounded border px-2 text-xs shadow-sm focus:border-primary-500 focus:ring-2 focus:ring-primary-500/30 {{ 'border-emerald-500 ring-2 ring-emerald-300' if $n('filter_books/filter_b.id/value') else '' }}"
            type="number"
            name="filter_b.id"
            placeholder="{{ $t('mysql.placeholder.id') }}"
            value="{{ $n('filter_books/filter_b.id/value') }}"
        />
    </th>
    <th class="p-1 align-top">
        <input
            class="h-8 w-full rounded border px-2 text-xs shadow-sm focus:border-primary-500 focus:ring-2 focus:ring-primary-500/30 {{ 'border-emerald-500 ring-2 ring-emerald-300' if $n('filter_books/filter_title/value') else '' }}"
            type="text"
            name="filter_title"
            placeholder="{{ $t('mysql.placeholder.title') }}"
            value="{{ $n('filter_books/filter_title/value') }}"
        />
    </th>
    <th class="p-1 align-top">
        <input
            class="h-8 w-full rounded border px-2 text-xs shadow-sm focus:border-primary-500 focus:ring-2 focus:ring-primary-500/30 {{ 'border-emerald-500 ring-2 ring-emerald-300' if $n('filter_books/filter_author/value') else '' }}"
            type="text"
            name="filter_author"
            placeholder="{{ $t('mysql.placeholder.author') }}"
            value="{{ $n('filter_books/filter_author/value') }}"
        />
    </th>
    <th class="p-1 align-top">
        <input
            class="h-8 w-full rounded border px-2 text-xs shadow-sm focus:border-primary-500 focus:ring-2 focus:ring-primary-500/30 {{ 'border-emerald-500 ring-2 ring-emerald-300' if $n('filter_books/filter_published_date/value') else '' }}"
            type="date"
            name="filter_published_date"
            placeholder="{{ $t('mysql.placeholder.publishedDate') }}"
            value="{{ $n('filter_books/filter_published_date/value') }}"
        />
    </th>
    <th class="p-1 align-top">
        <select
            class="h-8 w-full rounded border px-2 text-xs shadow-sm focus:border-primary-500 focus:ring-2 focus:ring-primary-500/30 {{ 'border-emerald-500 ring-2 ring-emerald-300' if $n('filter_books/filter_category_id/value') else '' }}"
            name="filter_category_id"
            aria-label="Filter Category ID"
        >
            {% set selected = $n('filter_books/filter_category_id/value')  %}
            <option value="">{{ $t('mysql.filter.allCategories') }}</option>
            {% for category in categories %}
                <option value="{{ category.id }}" {{ 'selected' if selected == category.id else '' }}>{{ category.title }}</option>
            {% endfor %}
        </select>
    </th>
    <th colspan="2" class="p-1 align-top text-end">
        {% set filterIsDirty = $l.existUrlQuery(['filter_b.id','filter_title', 'filter_author', 'filter_published_date', 'filter_category_id']) %}
        <a
            href="{{ $l.removeUrlQuery(['page','filter_b.id','filter_title', 'filter_author', 'filter_published_date', 'filter_category_id']) }}"
            class="wave inline-flex h-8 items-center rounded-md border px-3 text-xs font-medium shadow-sm {{ 'border-slate-300 bg-white text-slate-700 hover:bg-slate-50' if not filterIsDirty else 'border-slate-700 bg-slate-700 text-white hover:bg-slate-800' }}"
            type="reset"
        >{{ $t('mysql.button.reset') }}</a>
        <input
            class="wave ml-2 inline-flex h-8 cursor-pointer items-center rounded-md bg-primary-600 px-3 text-xs font-medium text-white shadow-sm hover:bg-primary-700 focus:outline-none focus:ring-2 focus:ring-primary-500/30"
            type="submit"
            value="{{ $t('mysql.button.filter') }}"
        />
    </th>
</form>""",
	r"example/sqlite/_form_edit.j2.html": r"""<form method="post" action="{{ $e.uriString }}" class="contents">
    <input type="hidden" name="action" value="{{ 'update' if(action == 'edit' ?? action == 'update') else 'add' }}" />
    <tr>
        <td colspan="7" class="p-2">
            <div class="flex flex-wrap items-start gap-2">
                <div class="flex min-w-[160px] flex-col">
                    <input
                        type="text"
                        name="title"
                        placeholder="{{ $t('mysql.placeholder.title') }}"
                        required
                        value="{{ $n('form_book/title/value') }}"
                        class="h-9 rounded-md border bg-white px-3 text-xs shadow-sm focus:border-primary-500 focus:ring-2 focus:ring-primary-500/30 {{ 'border-rose-500 ring-2 ring-rose-300' if $n('form_book/title/errors/0') else 'border-slate-300' }}"
                    />
                    <div class="mt-1 text-[10px] text-rose-600 {{ '' if $n('form_book/title/errors/0') else 'hidden' }}">{{ $n('form_book/title/errors/0') }}</div>
                </div>
                <div class="flex min-w-[140px] flex-col">
                    <input
                        type="text"
                        name="author"
                        placeholder="{{ $t('mysql.placeholder.author') }}"
                        required
                        value="{{ $n('form_book/author/value') }}"
                        class="h-9 rounded-md border bg-white px-3 text-xs shadow-sm focus:border-primary-500 focus:ring-2 focus:ring-primary-500/30 {{ 'border-rose-500 ring-2 ring-rose-300' if $n('form_book/author/errors/0') else 'border-slate-300' }}"
                    />
                    <div class="mt-1 text-[10px] text-rose-600 {{ '' if $n('form_book/author/errors/0') else 'hidden' }}">{{ $n('form_book/author/errors/0') }}</div>
                </div>
                <div class="flex min-w-[160px] flex-col">
                    <input
                        type="date"
                        name="published_date"
                        placeholder="{{ $t('mysql.placeholder.publishedDate') }}"
                        required
                        value="{{ $n('form_book/published_date/value') }}"
                        class="h-9 rounded-md border bg-white px-3 text-xs shadow-sm focus:border-primary-500 focus:ring-2 focus:ring-primary-500/30 {{ 'border-rose-500 ring-2 ring-rose-300' if $n('form_book/published_date/errors/0') else 'border-slate-300' }}"
                    />
                    <div class="mt-1 text-[10px] text-rose-600 {{ '' if $n('form_book/published_date/errors/0') else 'hidden' }}">{{ $n('form_book/published_date/errors/0') }}</div>
                </div>
                <div class="flex min-w-[140px] flex-col">
                    <select
                        name="category_id"
                        class="h-9 rounded-md border bg-white px-2 text-xs shadow-sm focus:border-primary-500 focus:ring-2 focus:ring-primary-500/30 {{ 'border-rose-500 ring-2 ring-rose-300' if $n('form_book/category_id/errors/0') else 'border-slate-300' }}"
                    >
                        <option value=""></option>
                        {% set selected = $n('form_book/category_id/value') %}
                        {% for category in $n('form_book/category_id/options') %}
                            <option value="{{ category.id }}" {{ 'selected' if selected == category.id else '' }}>{{ category.title }}</option>
                        {% endfor %}
                    </select>
                    <div class="mt-1 text-[10px] text-rose-600 {{ '' if $n('form_book/category_id/errors/0') else 'hidden' }}">{{ $n('form_book/category_id/errors/0') }}</div>
                </div>
                <!-- CSRF Token -->
                <input type="hidden" name="token" value="{{ $n('form_book/token/value') }}" />
                
                {% if(action == 'edit' ?? action == 'update') %}
                <input type="hidden" name="id" value="{{ id }}" />
                <button type="submit" class="wave inline-flex h-9 items-center rounded-md border border-primary-600 bg-primary-50 px-3 text-xs font-medium text-primary-700 hover:bg-primary-100 focus:outline-none focus:ring-2 focus:ring-primary-500/30">{{ $t('mysql.button.update') }}</button>
                {% else %}
                <button type="submit" class="wave inline-flex h-9 items-center rounded-md border border-primary-600 bg-primary-50 px-3 text-xs font-medium text-primary-700 hover:bg-primary-100 focus:outline-none focus:ring-2 focus:ring-primary-500/30">{{ $t('database.table.button.add') }}</button>
                {% endif %}

                <div class="mt-1 text-[10px] text-rose-600 {{ $n('form_book/token/errors/0') ? '' : 'hidden' }}">{{ $n('form_book/token/errors/0') }}</div>
            </div>
        </td>
    </tr>
    <tr>
        <td colspan="7" class="p-2 text-xs text-slate-600">{{ paging }}</td>
    </tr>
</form>""",
	r"example/sqlite/_categories.j2.html": r"""<div class="mt-8">
  <h3 class="text-base font-semibold text-slate-800">{{ $t('Example SQLite Categories') }}</h3>
  <div class="mt-4 overflow-x-auto rounded-md border border-slate-200 bg-white shadow-sm">
    <table class="min-w-full text-sm text-slate-700">
      <thead class="bg-slate-50 text-xs uppercase tracking-wide text-slate-600">
        <tr class="divide-x divide-slate-200">
          <th scope="col" class="w-16 px-3 py-2 text-left font-medium">{{ $t('mysql.table.header.id') }}</th>
          <th scope="col" class="px-3 py-2 text-left font-medium">{{ $t('mysql.table.header.title') }}</th>
          <th scope="col" class="w-32 px-3 py-2 text-center font-medium">{{ $t('mysql.table.header.booksCount') }}</th>
          <th scope="col" class="w-20 px-3 py-2 text-center font-medium">{{ $t('mysql.table.header.actions') }}</th>
        </tr>
      </thead>
      <tbody class="divide-y divide-slate-200">
        {% for category in categories|default([]) %}
        <tr class="hover:bg-slate-50">
          <td class="px-3 py-2 font-mono text-[13px] text-slate-500">{{ category.id }}</td>
            <td class="px-3 py-2">{{ category.title }}</td>
            <td class="px-3 py-2 text-center">
              <a
                class="wave inline-flex h-7 items-center rounded border border-cyan-600 bg-cyan-50 px-2 text-[11px] font-medium text-cyan-700 hover:bg-cyan-100 focus:outline-none focus:ring-2 focus:ring-cyan-500/30"
                href="{{ $l.updateUrlQuery( {'filter_category_id': category.id}) }}"
              >{{ category.count_books }}</a>
            </td>
            <td class="px-3 py-2 text-center">
              <a
                data-href="{{ $l.updateUrlQuery( {'id': category.id, 'action': 'delete_category'}) }}"
                data-message="{{ $t('mysql.message.deleteCategory') ~ ' (' ~ category.title ~ ')' }}"
                class="wave js-delete-links inline-flex h-7 w-7 items-center justify-center rounded border border-transparent text-rose-600 hover:border-rose-200 hover:bg-rose-50 hover:text-rose-700 focus:outline-none focus:ring-2 focus:ring-rose-500/30"
                aria-label="{{ $t('mysql.button.delete') }}"
              >
                <i class="fas fa-trash text-[13px]"></i>
              </a>
            </td>
        </tr>
        {% else %}
        <tr>
          <td colspan="4" class="px-3 py-6 text-center text-sm text-slate-500">{{ $t('mysql.message.noCategories') }}</td>
        </tr>
        {% endfor %}
      </tbody>
      <tfoot class="bg-slate-50/60">
        <tr>
          <td colspan="4" class="px-3 py-3">
            <form method="POST" action="{{ $l.updateUrlQuery( {'action': 'add_category'}) }}" class="flex flex-wrap items-start gap-2">
              <div class="flex flex-col">
                <input
                  type="text"
                  name="title"
                  placeholder="{{ $t('mysql.placeholder.title') }}"
                  required
                  value="{{ $n('form/title/value') }}"
                  class="h-9 w-56 rounded-md border bg-white px-3 text-xs shadow-sm focus:border-primary-500 focus:ring-2 focus:ring-primary-500/30 {{ 'border-rose-500 ring-2 ring-rose-300' if $n('form/title/errors/0') else 'border-slate-300' }}"
                />
                <div class="mt-1 text-[10px] text-rose-600 {{ '' if $n('form/title/errors/0') else 'hidden' }}">{{ $n('form/title/errors/0') }}</div>
              </div>
              <button type="submit" class="wave inline-flex h-9 items-center rounded-md border border-primary-600 bg-primary-50 px-3 text-xs font-medium text-primary-700 hover:bg-primary-100 focus:outline-none focus:ring-2 focus:ring-primary-500/30">
                {{ $t('database.table.button.add') }}
              </button>
            </form>
          </td>
        </tr>
      </tfoot>
    </table>
  </div>
</div>
""",
	r"example/sqlite/overview.j2.html": r"""{% extends 'template/template.j2.html' %}
{% block title %} {{ $t('Example SQLite') }} {% endblock %}

{% block content %}
<div class="my-6 space-y-6">
  <h3 class="text-xl font-semibold text-slate-800">{{ $t('Example SQLite') }}</h3>
  <div class="overflow-hidden rounded-lg border border-slate-200 bg-white shadow-sm">
    <div class="overflow-x-auto">
      <table class="min-w-full text-xs md:text-sm divide-y divide-slate-200">
        <thead class="bg-slate-50">
          <tr>
            <th colspan="6" class="px-3 py-2">
              {% set pageSize = data.pageSize | default("10") %}
              {% set randonString = $e.randomString() %}
              <div class="flex flex-wrap items-center justify-end gap-2">
                <button type="button" class="wave inline-flex h-8 items-center rounded-md border border-rose-600 bg-rose-50 px-3 text-[11px] font-medium text-rose-700 hover:bg-rose-100 focus:outline-none focus:ring-2 focus:ring-rose-500/30" onclick="deleteSelectedBooks_{{randonString}}()">{{ $t('mysql.button.deleteSelected') }}</button>
                <select name="pageSize" class="h-8 rounded-md border border-slate-300 bg-white px-2 text-[11px] shadow-sm focus:border-primary-500 focus:ring-2 focus:ring-primary-500/30" onchange="changePageSize_{{randonString}}(this.value)">
                  <option {{ 'selected' if pageSize == '10' else '' }}>10</option>
                  <option {{ 'selected' if pageSize == '20' else '' }}>20</option>
                  <option {{ 'selected' if pageSize == '50' else '' }}>50</option>
                  <option {{ 'selected' if pageSize == '100' else '' }}>100</option>
                </select>
              </div>
              <script>
                function changePageSize_{{randonString}}(value) {
                  var url = new URL(window.location.href);
                  url.searchParams.set('pageSize', value);
                  window.location.href = url.toString();
                }
                function deleteSelectedBooks_{{randonString}}() {
                  var selectedBooks = [];
                  document.querySelectorAll('input[name="selected_books"]:checked').forEach(function(el){selectedBooks.push(el.value);});
                  if (selectedBooks.length > 0) {
                    if (confirm("{{ $t('mysql.message.deleteSelectedBooks') }}")) {
                      var form = document.createElement('form');
                      form.method = 'POST';
                      form.style.display = 'none';
                      var actionInput = document.createElement('input');
                      actionInput.type = 'hidden';
                      actionInput.name = 'action';
                      actionInput.value = 'delete_all';
                      form.appendChild(actionInput);
                      var booksInput = document.createElement('input');
                      booksInput.type = 'hidden';
                      booksInput.name = 'selected_books';
                      booksInput.value = selectedBooks.join(',');
                      form.appendChild(booksInput);
                      document.body.appendChild(form);
                      form.submit();
                    }
                  } else {
                    alert("{{ $t('mysql.message.noBooksSelected') }}");
                  }
                }
              </script>
            </th>
          </tr>
          <tr class="text-left font-semibold text-slate-700">
            <th class="px-3 py-2">
              <div class="flex items-center gap-1">
                <input class="h-4 w-4 rounded border-slate-300 text-primary-600 focus:ring-primary-500" type="checkbox" id="select_all" onchange="document.querySelectorAll(`input[name='selected_books']`).forEach(cb=>cb.checked=this.checked);" />
                {{ $l.macro("/template/ui/sorting", {'sortby': 'b.id', 'title': 'mysql.table.header.id'} ) }}
              </div>
            </th>
            <th class="px-3 py-2">{{ $l.macro("/template/ui/sorting", {'sortby': 'title', 'title': 'mysql.table.header.title'} ) }}</th>
            <th class="px-3 py-2">{{ $l.macro("/template/ui/sorting", {'sortby': 'author', 'title': 'mysql.table.header.author'} ) }}</th>
            <th class="px-3 py-2">{{ $l.macro("/template/ui/sorting", {'sortby': 'published_date', 'title': 'mysql.table.header.publishedDate'} ) }}</th>
            <th class="px-3 py-2">{{ $l.macro("/template/ui/sorting", {'sortby': 'category_id', 'title': 'mysql.table.header.categoryId'} ) }}</th>
            <th class="px-3 py-2 text-end">{{ $t('database.table.header.action') }}</th>
          </tr>
          <tr>
            {% include 'example/sqlite/_filtering.j2.html' %}
          </tr>
        </thead>
        <tbody class="divide-y divide-slate-100">
          {% for book in books %}
          <tr class="hover:bg-slate-50">
            <td class="px-3 py-2 align-top"><input class="h-4 w-4 rounded border-slate-300 text-primary-600 focus:ring-primary-500" type="checkbox" name="selected_books" value="{{ book.id }}" /> <span class="ml-1 font-medium text-slate-800">{{ book.id }}</span></td>
            <td class="px-3 py-2 text-slate-700">{{ book.title }}</td>
            <td class="px-3 py-2 text-slate-600">{{ book.author }}</td>
            <td class="px-3 py-2 text-slate-600">{{ book.published_date | dateFormat('dd/MM/y') }}</td>
            <td class="px-3 py-2 text-slate-600"><em>{{ book.category_title }}</em></td>
            <td class="px-3 py-2 text-end">
              <div class="flex items-end justify-end gap-2">
                <a
                  data-href="{{ $l.updateUrlQuery( {'id':book.id|s, 'action': 'delete'|s}) }}"
                  data-message="{{ $t('mysql.message.deleteBook') ~ ' (' ~ book.title ~ ')' }}"
                  class="wave cursor-pointer js-delete-links inline-flex h-7 w-7 items-center justify-center rounded-full border border-rose-200 text-[11px] text-rose-600 hover:bg-rose-50 focus:outline-none focus:ring-2 focus:ring-rose-500/30"
                  title="{{ $t('mysql.button.delete') }}"
                >🗑️</a>
                <a
                  href="{{ $l.updateUrlQuery( {'id':book.id|s, 'action': 'edit'|s}) }}"
                  class="wave inline-flex h-7 w-7 items-center justify-center rounded-full border border-primary-200 text-[11px] text-primary-600 hover:bg-primary-50 focus:outline-none focus:ring-2 focus:ring-primary-500/30"
                  title="{{ $t('mysql.button.edit') }}"
                >✏️</a>
              </div>
            </td>
          </tr>
          {% else %}
          <tr>
            <td colspan="6" class="px-3 py-6 text-center text-slate-500">{{ $t('mysql.message.noRecords') }}</td>
          </tr>
          {% endfor %}
        </tbody>
        <tfoot class="bg-slate-50">
          {% include form_book.widget | unscape %}
        </tfoot>
      </table>
    </div>
    <div class="border-t border-slate-200 bg-slate-50 p-4 text-sm">
      {% include 'example/sqlite/_categories.j2.html' %}
    </div>
  </div>
</div>
{% endblock %}
""",
	r"example/email.j2.html": r"""{% extends 'template/template.j2.html' %}
{% block title %}
    {{ $t('sidebar.emailExample') }}
{% endblock %}

{% block content %}
<div class="space-y-6">
  <!-- Page Header -->
  <div class="flex items-center gap-3">
    <div class="flex h-12 w-12 items-center justify-center rounded-xl bg-gradient-to-br from-purple-500 to-purple-600 text-white shadow-lg">
      <svg class="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"></path>
      </svg>
    </div>
    <div>
      <h1 class="text-2xl font-bold text-gray-800">{{ $t('email.title') }}</h1>
      <p class="text-sm text-gray-600">{{ $t('Send test emails with SMTP configuration') }}</p>
    </div>
  </div>
  <div class="mt-4 overflow-hidden rounded-lg border border-slate-200 bg-white shadow-sm">
    <div class="p-5">
      <form method="post" action="{{ $e.routeUrl('root.email.post') }}" class="space-y-6">
        <div class="grid gap-4 md:grid-cols-2">
          <div>
            <label for="from" class="mb-1 block text-sm font-medium text-slate-700">{{ $t('email.from') }}</label>
            <input
              value="{{ $n('emailForm/from/value') }}"
              type="text"
              name="from"
              id="from"
              class="h-10 w-full rounded-md border border-slate-300 bg-white px-3 text-sm shadow-sm focus:border-primary-500 focus:ring-2 focus:ring-primary-500/30 {{ 'border-rose-500 ring-2 ring-rose-300 focus:border-rose-500 focus:ring-rose-300' if emailForm.from.failed else '' }}"
            />
            <div class="mt-1 text-sm text-rose-700 {{ '' if emailForm.from.failed else 'hidden' }}">
              {{ $t($n('emailForm/from/errors/0')) }}
            </div>
          </div>
          <div>
            <label for="fromName" class="mb-1 block text-sm font-medium text-slate-700">{{ $t('email.fromName') }}</label>
            <input
              value="{{ $n('emailForm/fromName/value') }}"
              type="text"
              name="fromName"
              id="fromName"
              placeholder="{{ $t('email.placeholder.name') }}"
              class="h-10 w-full rounded-md border border-slate-300 bg-white px-3 text-sm shadow-sm focus:border-primary-500 focus:ring-2 focus:ring-primary-500/30 {{ 'border-rose-500 ring-2 ring-rose-300 focus:border-rose-500 focus:ring-rose-300' if emailForm.fromName.failed else '' }}"
            />
            <div class="mt-1 text-sm text-rose-700 {{ '' if emailForm.fromName.failed else 'hidden' }}">
              {{ $t($n('emailForm/fromName/errors/0')) }}
            </div>
          </div>
        </div>

        <div>
          <label for="email" class="mb-1 block text-sm font-medium text-slate-700">{{ $t('email.to') }}</label>
          <input
            value="{{ emailForm.email.value }}"
            type="email"
            name="email"
            id="email"
            placeholder="{{ $t('email.placeholder.to') }}"
            class="h-10 w-full rounded-md border border-slate-300 bg-white px-3 text-sm shadow-sm focus:border-primary-500 focus:ring-2 focus:ring-primary-500/30 {{ 'border-rose-500 ring-2 ring-rose-300 focus:border-rose-500 focus:ring-rose-300' if emailForm.email.failed else '' }}"
          />
          <div class="mt-1 text-sm text-rose-700 {{ '' if emailForm.email.failed else 'hidden' }}">
            {{ $t($n('emailForm/email/errors/0')) }}
          </div>
        </div>

        <div>
          <label for="subject" class="mb-1 block text-sm font-medium text-slate-700">{{ $t('email.subject') }}</label>
            <input
              value="{{ emailForm.subject.value }}"
              type="text"
              name="subject"
              id="subject"
              placeholder="{{ $t('email.placeholder.subject') }}"
              class="h-10 w-full rounded-md border border-slate-300 bg-white px-3 text-sm shadow-sm focus:border-primary-500 focus:ring-2 focus:ring-primary-500/30 {{ 'border-rose-500 ring-2 ring-rose-300 focus:border-rose-500 focus:ring-rose-300' if emailForm.subject.failed else '' }}"
            />
          <div class="mt-1 text-sm text-rose-700 {{ '' if emailForm.subject.failed else 'hidden' }}">
            {{ $t($n('emailForm/subject/errors/0')) }}
          </div>
        </div>

        <div>
          <label for="message" class="mb-1 block text-sm font-medium text-slate-700">{{ $t('email.message') }}</label>
          <textarea
            name="message"
            id="message"
            placeholder="{{ $t('email.placeholder.message') }}"
            class="min-h-[140px] w-full rounded-md border border-slate-300 bg-white px-3 py-2 text-sm shadow-sm focus:border-primary-500 focus:ring-2 focus:ring-primary-500/30 {{ 'border-rose-500 ring-2 ring-rose-300 focus:border-rose-500 focus:ring-rose-300' if emailForm.message.failed else '' }}"
          >{{ emailForm.message.value }}</textarea>
          <div class="mt-1 text-sm text-rose-700 {{ '' if emailForm.message.failed else 'hidden' }}">
            {{ $t($n('emailForm/message/errors/0')) }}
          </div>
        </div>

        <div class="grid gap-4 md:grid-cols-[1fr,140px]">
          <div>
            <label for="host" class="mb-1 block text-sm font-medium text-slate-700">{{ $t('email.host') }}</label>
            <input
              value="{{ emailForm.host.value }}"
              type="text"
              name="host"
              id="host"
              placeholder="{{ $t('email.placeholder.host') }}"
              class="h-10 w-full rounded-md border border-slate-300 bg-white px-3 text-sm shadow-sm focus:border-primary-500 focus:ring-2 focus:ring-primary-500/30 {{ 'border-rose-500 ring-2 ring-rose-300 focus:border-rose-500 focus:ring-rose-300' if emailForm.host.failed else '' }}"
            />
            <div class="mt-1 text-sm text-rose-700 {{ '' if emailForm.host.failed else 'hidden' }}">
              {{ $t($n('emailForm/host/errors/0')) }}
            </div>
          </div>
          <div>
            <label for="port" class="mb-1 block text-sm font-medium text-slate-700">{{ $t('email.port') }}</label>
            <input
              value="{{ emailForm.port.value if emailForm.port.value else '1025' }}"
              type="number"
              name="port"
              id="port"
              placeholder="{{ $t('email.placeholder.port') }}"
              class="h-10 w-full rounded-md border border-slate-300 bg-white px-3 text-sm shadow-sm focus:border-primary-500 focus:ring-2 focus:ring-primary-500/30 {{ 'border-rose-500 ring-2 ring-rose-300 focus:border-rose-500 focus:ring-rose-300' if emailForm.port.failed else '' }}"
            />
            <div class="mt-1 text-sm text-rose-700 {{ '' if emailForm.port.failed else 'hidden' }}">
              {{ $t($n('emailForm/port/errors/0')) }}
            </div>
          </div>
        </div>

        <div class="grid gap-4 md:grid-cols-2">
          <div>
            <label for="username" class="mb-1 block text-sm font-medium text-slate-700">{{ $t('email.username') }}</label>
            <input
              value="{{ emailForm.username.value }}"
              type="text"
              name="username"
              id="username"
              placeholder="{{ $t('email.placeholder.username') }}"
              class="h-10 w-full rounded-md border border-slate-300 bg-white px-3 text-sm shadow-sm focus:border-primary-500 focus:ring-2 focus:ring-primary-500/30 {{ 'border-rose-500 ring-2 ring-rose-300 focus:border-rose-500 focus:ring-rose-300' if emailForm.username.failed else '' }}"
            />
            <div class="mt-1 text-sm text-rose-700 {{ '' if emailForm.username.failed else 'hidden' }}">
              {{ $t($n('emailForm/username/errors/0')) }}
            </div>
          </div>
          <div>
            <label for="password" class="mb-1 block text-sm font-medium text-slate-700">{{ $t('email.password') }}</label>
            <input
              value="{{ emailForm.password.value }}"
              type="password"
              name="password"
              id="password"
              placeholder="{{ $t('email.placeholder.password') }}"
              class="h-10 w-full rounded-md border border-slate-300 bg-white px-3 text-sm shadow-sm focus:border-primary-500 focus:ring-2 focus:ring-primary-500/30 {{ 'border-rose-500 ring-2 ring-rose-300 focus:border-rose-500 focus:ring-rose-300' if emailForm.password.failed else '' }}"
            />
            <div class="mt-1 text-sm text-rose-700 {{ '' if emailForm.password.failed else 'hidden' }}">
              {{ $t($n('emailForm/password/errors/0')) }}
            </div>
          </div>
        </div>

        <div class="flex flex-wrap gap-6">
          <label for="allowInsecure" class="inline-flex items-center gap-2 text-sm text-slate-700">
            <input
              value="{{ emailForm.allowInsecure.value }}"
              type="checkbox"
              name="allowInsecure"
              id="allowInsecure"
              class="h-4 w-4 rounded border-slate-300 text-primary-600 focus:ring-primary-500"
            />
            <span>{{ $t('email.allowInsecure') }}</span>
          </label>
          <label for="ssl" class="inline-flex items-center gap-2 text-sm text-slate-700">
            <input
              value="{{ emailForm.ssl.value }}"
              type="checkbox"
              name="ssl"
              id="ssl"
              class="h-4 w-4 rounded border-slate-300 text-primary-600 focus:ring-primary-500"
            />
            <span>{{ $t('email.ssl') }}</span>
          </label>
        </div>

        {% if sendEmailSuccess %}
        <div class="rounded-md border border-emerald-200 bg-emerald-50 p-3 text-sm text-emerald-800">{{ $t('email.success') }}</div>
        {% endif %}

        {% if sendEmailFailed %}
        <div class="rounded-md border border-rose-200 bg-rose-50 p-3 text-sm text-rose-800">{{ $t('email.failed') }}</div>
        {% endif %}

        <button type="submit" class="wave inline-flex items-center rounded-md bg-primary-600 px-5 py-2.5 text-sm font-medium text-white shadow-sm hover:bg-primary-700 focus:outline-none focus:ring-2 focus:ring-primary-500/30">
          {{ $t('email.send') }}
        </button>
      </form>
    </div>
  </div>
</div>
{% endblock %}""",
	r"example/form.j2.html": r"""{% extends 'template/template.j2.html' %}
{% block title %}
    {{ $t('sidebar.formExample') }}
{% endblock %}

{% block content %}
<div class="space-y-6">
  <!-- Page Header -->
  <div class="flex items-center gap-3">
    <div class="flex h-12 w-12 items-center justify-center rounded-xl bg-gradient-to-br from-blue-500 to-blue-600 text-white shadow-lg">
      <svg class="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"></path>
      </svg>
    </div>
    <div>
      <h1 class="text-2xl font-bold text-gray-800">{{ $t('form.validation.title') }}</h1>
      <p class="text-sm text-gray-600">{{ $t('Form validation example') }}</p>
    </div>
  </div>

  <!-- Credentials Info Card -->
  <div class="rounded-xl border border-blue-200 bg-gradient-to-r from-blue-50 to-white p-5 shadow-md">
    <div class="flex items-start gap-3">
      <div class="flex h-10 w-10 shrink-0 items-center justify-center rounded-lg bg-blue-600 text-white shadow-sm">
        <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
        </svg>
      </div>
      <div class="flex-1 text-sm">
        <p class="font-semibold text-gray-800">{{ $t('Test Credentials') }}</p>
        <p class="mt-2 text-gray-700"><span class="font-medium">{{ $t('form.validation.credentials.email') }}:</span> <code class="rounded bg-white px-2 py-0.5 text-blue-700">example@uproid.com</code></p>
        <p class="mt-1 text-gray-700"><span class="font-medium">{{ $t('form.validation.credentials.password') }}:</span> <code class="rounded bg-white px-2 py-0.5 text-blue-700">@Test123</code></p>
      </div>
    </div>
  </div>

  {% if loginResult != true and user == null %}
  <!-- Login Form Card -->
  <div class="overflow-hidden rounded-xl border border-gray-200 bg-white shadow-lg">
    <div class="border-b border-gray-200 bg-gradient-to-r from-gray-50 to-white px-6 py-4">
      <h3 class="text-lg font-bold text-gray-800">{{ $t('Login Form') }}</h3>
      <p class="text-sm text-gray-600">{{ $t('Enter your credentials to continue') }}</p>
    </div>
    <div class="p-6">
      <form action="{{ $e.routeUrl('root.form.post') }}" method="post" class="space-y-5">
        <!-- Email Field -->
        <div>
          <label for="email" class="mb-2 block text-sm font-semibold text-gray-700">{{ $t('form.validation.email') }}</label>
          <div class="relative">
            <div class="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-3">
              <svg class="h-5 w-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"></path>
              </svg>
            </div>
            <input
              value="{{ $n('loginForm/email/value') }}"
              type="email"
              name="email"
              id="email"
              placeholder="{{ $t('form.validation.emailPlaceholder') }}"
              class="block h-12 w-full rounded-lg border pl-10 pr-3 text-sm shadow-sm transition-all duration-200 {{ 'border-rose-500 bg-rose-50 text-rose-900 placeholder-rose-400 focus:border-rose-600 focus:ring-4 focus:ring-rose-500/30' if $n('loginForm/email/failed') else 'border-gray-300 bg-white text-gray-900 focus:border-blue-500 focus:ring-4 focus:ring-blue-500/20' }}"
            />
          </div>
          {% if $n('loginForm/email/failed') %}
          <div class="mt-2 flex items-start gap-2 text-sm text-rose-700">
            <svg class="mt-0.5 h-4 w-4 shrink-0" fill="currentColor" viewBox="0 0 20 20">
              <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd"></path>
            </svg>
            <span>{{ $t($n('loginForm/email/errors/0')) }}</span>
          </div>
          {% endif %}
        </div>

        <!-- Password Field -->
        <div>
          <label for="password" class="mb-2 block text-sm font-semibold text-gray-700">{{ $t('form.validation.password') }}</label>
          <div class="relative">
            <div class="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-3">
              <svg class="h-5 w-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"></path>
              </svg>
            </div>
            <input
              value="{{ $n('loginForm/password/value') }}"
              type="password"
              name="password"
              id="password"
              placeholder="{{ $t('form.validation.passwordPlaceholder') }}"
              class="block h-12 w-full rounded-lg border pl-10 pr-3 text-sm shadow-sm transition-all duration-200 {{ 'border-rose-500 bg-rose-50 text-rose-900 placeholder-rose-400 focus:border-rose-600 focus:ring-4 focus:ring-rose-500/30' if $n('loginForm/password/failed') else 'border-gray-300 bg-white text-gray-900 focus:border-blue-500 focus:ring-4 focus:ring-blue-500/20' }}"
            />
          </div>
          {% if $n('loginForm/password/failed') %}
          <div class="mt-2 flex items-start gap-2 text-sm text-rose-700">
            <svg class="mt-0.5 h-4 w-4 shrink-0" fill="currentColor" viewBox="0 0 20 20">
              <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd"></path>
            </svg>
            <span>{{ $t($n('loginForm/password/errors/0')) }}</span>
          </div>
          {% endif %}
        </div>

        <!-- Submit Button -->
        <button type="submit" class="wave group inline-flex w-full items-center justify-center gap-2 rounded-lg bg-gradient-to-r from-blue-600 to-blue-700 px-6 py-3 text-sm font-semibold text-white shadow-lg transition-all duration-200 hover:from-blue-700 hover:to-blue-800 hover:shadow-xl focus:outline-none focus:ring-4 focus:ring-blue-500/30">
          <svg class="h-5 w-5 transition-transform duration-200 group-hover:scale-110" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 16l-4-4m0 0l4-4m-4 4h14m-5 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h7a3 3 0 013 3v1"></path>
          </svg>
          <span>{{ $t('form.validation.login') }}</span>
        </button>

        {% if loginError %}
        <div class="flex items-start gap-3 rounded-lg border border-rose-300 bg-rose-50 p-4 shadow-sm">
          <svg class="mt-0.5 h-5 w-5 shrink-0 text-rose-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
          </svg>
          <span class="text-sm font-medium text-rose-800">{{ $t('form.validation.loginError') }}</span>
        </div>
        {% endif %}
      </form>
    </div>
  </div>
  {% else %}
  <!-- Success Card -->
  <div class="overflow-hidden rounded-xl border border-emerald-300 bg-gradient-to-r from-emerald-50 to-green-50 shadow-lg">
    <div class="flex items-center justify-between gap-4 p-6">
      <div class="flex items-center gap-4">
        <div class="flex h-12 w-12 shrink-0 items-center justify-center rounded-full bg-emerald-600 text-white shadow-md">
          <svg class="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path>
          </svg>
        </div>
        <div>
          <p class="text-sm font-medium text-emerald-900">{{ $t('form.validation.loginSuccess') }}</p>
          <p class="mt-1 text-sm text-emerald-700">{{ $t('Logged in as') }} <span class="font-semibold">{{ user.name }}</span></p>
        </div>
      </div>
      <a href="{{ $e.routeUrl('root.logout') }}" class="wave inline-flex shrink-0 items-center gap-2 rounded-lg bg-gradient-to-r from-rose-600 to-rose-700 px-4 py-2.5 text-sm font-semibold text-white shadow-md transition-all duration-200 hover:from-rose-700 hover:to-rose-800 hover:shadow-lg focus:outline-none focus:ring-4 focus:ring-rose-500/30">
        <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"></path>
        </svg>
        <span>{{ $t('form.validation.logout') }}</span>
      </a>
    </div>
  </div>
  {% endif %}

  <!-- File References Card -->
  <div class="overflow-hidden rounded-xl border border-gray-200 bg-white shadow-lg">
    <div class="border-b border-gray-200 bg-gradient-to-r from-gray-50 to-white px-6 py-4">
      <h3 class="text-lg font-bold text-gray-800">{{ $t('File References') }}</h3>
      <p class="text-sm text-gray-600">{{ $t('Related files for this form example') }}</p>
    </div>
    <ul class="divide-y divide-gray-100">
      <li class="group transition-colors duration-150 hover:bg-blue-50">
        <div class="flex flex-col gap-2 p-4 md:flex-row md:items-center md:gap-4">
          <div class="flex items-center gap-2 md:w-48">
            <svg class="h-5 w-5 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path>
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"></path>
            </svg>
            <span class="font-semibold text-gray-700">{{ $t('form.validation.view') }}</span>
          </div>
          <code class="rounded-md bg-gray-100 px-3 py-1 text-xs text-blue-700 group-hover:bg-blue-100">example/lib/widgets/example/form.j2.html</code>
        </div>
      </li>
      <li class="group transition-colors duration-150 hover:bg-blue-50">
        <div class="flex flex-col gap-2 p-4 md:flex-row md:items-center md:gap-4">
          <div class="flex items-center gap-2 md:w-48">
            <svg class="h-5 w-5 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 20l4-16m4 4l4 4-4 4M6 16l-4-4 4-4"></path>
            </svg>
            <span class="font-semibold text-gray-700">{{ $t('form.validation.controller') }}</span>
          </div>
          <code class="rounded-md bg-gray-100 px-3 py-1 text-xs text-purple-700 group-hover:bg-blue-100">example/lib/controllers/home_controller.dart</code>
        </div>
      </li>
    </ul>
  </div>
</div>
{% endblock %}""",
	r"example/route.j2.html": r"""{% extends 'template/template.j2.html' %}

{% block title %}
    {{ $t('sidebar.routeExample') }}
{% endblock %}

{% block content %}
<div class="space-y-6">
  <!-- Page Header -->
  <div class="flex items-center gap-3">
    <div class="flex h-12 w-12 items-center justify-center rounded-xl bg-gradient-to-br from-indigo-500 to-indigo-600 text-white shadow-lg">
      <svg class="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 20l-5.447-2.724A1 1 0 013 16.382V5.618a1 1 0 011.447-.894L9 7m0 13l6-3m-6 3V7m6 10l4.553 2.276A1 1 0 0021 18.382V7.618a1 1 0 00-.553-.894L15 4m0 13V4m0 0L9 7"></path>
      </svg>
    </div>
    <div>
      <h1 class="text-2xl font-bold text-gray-800">{{ $t('webRouteExample.title') }}</h1>
      <p class="text-sm text-gray-600">{{ $t('List of all registered application routes') }}</p>
    </div>
  </div>

  <!-- Routes Table Card -->
  <div class="overflow-hidden rounded-xl border border-gray-200 bg-white shadow-lg">
    <div class="overflow-x-auto">
      <table class="min-w-full divide-y divide-gray-200">
        <thead class="bg-gradient-to-r from-gray-50 to-white">
          <tr>
            <th class="px-6 py-4 text-left text-xs font-bold uppercase tracking-wider text-gray-700">#</th>
            <th class="px-6 py-4 text-left text-xs font-bold uppercase tracking-wider text-gray-700">{{ $t('webRouteExample.path') }}</th>
            <th class="px-6 py-4 text-left text-xs font-bold uppercase tracking-wider text-gray-700">{{ $t('webRouteExample.type') }}</th>
            <th class="px-6 py-4 text-left text-xs font-bold uppercase tracking-wider text-gray-700">{{ $t('webRouteExample.permissions') }}</th>
            <th class="px-6 py-4 text-left text-xs font-bold uppercase tracking-wider text-gray-700">{{ $t('webRouteExample.auth') }}</th>
            <th class="px-6 py-4 text-left text-xs font-bold uppercase tracking-wider text-gray-700">{{ $t('webRouteExample.controller') }}</th>
          </tr>
        </thead>
        <tbody class="divide-y divide-gray-100 bg-white">
          {% for route in routes %}
          <tr class="group transition-colors duration-150 hover:bg-blue-50">
            <td class="px-6 py-4 align-top text-sm font-semibold text-gray-600">{{ loop.index }}</td>
            <td class="px-6 py-4 align-top text-sm">
              <div>
                <a class="inline-flex items-center gap-1.5 font-semibold text-blue-600 transition-colors duration-150 hover:text-blue-700 hover:underline" href="{{ route.fullPath }}">
                  <span class="inline-flex items-center rounded-md bg-indigo-100 px-2 py-0.5 text-xs font-bold text-indigo-800">[{{ route.method }}]</span>
                  <span>{{ route.fullPath }}</span>
                  <svg class="h-3 w-3 opacity-0 transition-opacity duration-150 group-hover:opacity-100" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14"></path>
                  </svg>
                </a>
              </div>
              <div class="mt-1 text-xs font-mono text-gray-500">{{ route.key }}</div>
            </td>
            <td class="px-6 py-4 align-top text-sm">
              <span class="inline-flex items-center rounded-full bg-blue-100 px-2.5 py-0.5 text-xs font-semibold text-blue-800">{{ route.type }}</span>
            </td>
            <td class="px-6 py-4 align-top text-sm text-gray-700">{{ route.permissions }}</td>
            <td class="px-6 py-4 align-top text-sm text-gray-700">{{ route.hasAuth | string }}</td>
            <td class="px-6 py-4 align-top text-sm font-mono text-gray-600">{{ route.controller }}{{ route.index }}</td>
          </tr>
          {% endfor %}
        </tbody>
      </table>
    </div>
  </div>

  <!-- File References Card -->
  <div class="rounded-xl border border-gray-200 bg-white shadow-lg">
    <div class="flex items-center gap-4 px-6 py-4 transition-colors duration-150 hover:bg-blue-50">
      <div class="flex h-10 w-10 shrink-0 items-center justify-center rounded-lg bg-indigo-100 text-indigo-600">
        <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 20l-5.447-2.724A1 1 0 013 16.382V5.618a1 1 0 011.447-.894L9 7m0 13l6-3m-6 3V7m6 10l4.553 2.276A1 1 0 0021 18.382V7.618a1 1 0 00-.553-.894L15 4m0 13V4m0 0L9 7"></path>
        </svg>
      </div>
      <div class="flex-1 min-w-0">
        <p class="text-sm font-semibold text-gray-700">{{ $t('webRouteExample.router') }}</p>
        <code class="text-xs text-indigo-600 truncate block">example/lib/route/web_route.dart</code>
      </div>
    </div>
  </div>
</div>
{% endblock %}
""",
	r"example/pagination.j2.html": r"""{% extends 'template/template.j2.html' %}

{% block title %}
    {{ $t('sidebar.paginationExample') }}
{% endblock %}

{% block content %}
<div class="space-y-6">
  <!-- Page Header -->
  <div class="flex items-center gap-3">
    <div class="flex h-12 w-12 items-center justify-center rounded-xl bg-gradient-to-br from-blue-500 to-blue-600 text-white shadow-lg">
      <svg class="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 8h10M7 12h4m1 8l-4-4H5a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v8a2 2 0 01-2 2h-3l-4 4z"></path>
      </svg>
    </div>
    <div>
      <h1 class="text-2xl font-bold text-gray-800">{{ $t('sidebar.paginationExample') }}</h1>
      <p class="text-sm text-gray-600">{{ $t('Pagination component examples') }}</p>
    </div>
  </div>

  <!-- Pagination Examples Card -->
  <div class="rounded-xl border border-gray-200 bg-white p-6 shadow-lg">
    <div class="space-y-6">
      <div class="rounded-lg border border-blue-200 bg-gradient-to-r from-blue-50 to-blue-100/50 p-4">
        {{ paginationA }}
      </div>
      <div class="h-px bg-gray-200"></div>
      <div class="rounded-lg border border-blue-200 bg-gradient-to-r from-blue-50 to-blue-100/50 p-4">
        {{ paginationB }}
      </div>
      <div class="h-px bg-gray-200"></div>
      <div class="rounded-lg border border-blue-200 bg-gradient-to-r from-blue-50 to-blue-100/50 p-4">
        {{ paginationC }}
      </div>
    </div>
  </div>
</div>
{% endblock %}""",
	r"example/mysql/_filtering.j2.html": r"""<form method="get" class="contents">
    <th class="p-1 align-top" style="max-width:80px;">
        <input
            class="h-8 w-full rounded border px-2 text-xs shadow-sm focus:border-primary-500 focus:ring-2 focus:ring-primary-500/30 {{ 'border-emerald-500 ring-2 ring-emerald-300' if $n('filter_books/filter_b.id/value') else '' }}"
            type="number"
            name="filter_b.id"
            placeholder="{{ $t('mysql.placeholder.id') }}"
            value="{{ $n('filter_books/filter_b.id/value') }}"
        />
    </th>
    <th class="p-1 align-top">
        <input
            class="h-8 w-full rounded border px-2 text-xs shadow-sm focus:border-primary-500 focus:ring-2 focus:ring-primary-500/30 {{ 'border-emerald-500 ring-2 ring-emerald-300' if $n('filter_books/filter_title/value') else '' }}"
            type="text"
            name="filter_title"
            placeholder="{{ $t('mysql.placeholder.title') }}"
            value="{{ $n('filter_books/filter_title/value') }}"
        />
    </th>
    <th class="p-1 align-top">
        <input
            class="h-8 w-full rounded border px-2 text-xs shadow-sm focus:border-primary-500 focus:ring-2 focus:ring-primary-500/30 {{ 'border-emerald-500 ring-2 ring-emerald-300' if $n('filter_books/filter_author/value') else '' }}"
            type="text"
            name="filter_author"
            placeholder="{{ $t('mysql.placeholder.author') }}"
            value="{{ $n('filter_books/filter_author/value') }}"
        />
    </th>
    <th class="p-1 align-top">
        <input
            class="h-8 w-full rounded border px-2 text-xs shadow-sm focus:border-primary-500 focus:ring-2 focus:ring-primary-500/30 {{ 'border-emerald-500 ring-2 ring-emerald-300' if $n('filter_books/filter_published_date/value') else '' }}"
            type="date"
            name="filter_published_date"
            placeholder="{{ $t('mysql.placeholder.publishedDate') }}"
            value="{{ $n('filter_books/filter_published_date/value') }}"
        />
    </th>
    <th class="p-1 align-top">
        <select
            class="h-8 w-full rounded border px-2 text-xs shadow-sm focus:border-primary-500 focus:ring-2 focus:ring-primary-500/30 {{ 'border-emerald-500 ring-2 ring-emerald-300' if $n('filter_books/filter_category_id/value') else '' }}"
            name="filter_category_id"
            aria-label="Filter Category ID"
        >
            {% set selected = $n('filter_books/filter_category_id/value')  %}
            <option value="">{{ $t('mysql.filter.allCategories') }}</option>
            {% for category in categories %}
                <option value="{{ category.id }}" {{ 'selected' if selected == category.id else '' }}>{{ category.title }}</option>
            {% endfor %}
        </select>
    </th>
    <th colspan="2" class="p-1 align-top text-end">
        {% set filterIsDirty = $l.existUrlQuery(['filter_b.id','filter_title', 'filter_author', 'filter_published_date', 'filter_category_id']) %}
        <a
            href="{{ $l.removeUrlQuery(['page','filter_b.id','filter_title', 'filter_author', 'filter_published_date', 'filter_category_id']) }}"
            class="wave inline-flex h-8 items-center rounded-md border px-3 text-xs font-medium shadow-sm {{ 'border-slate-300 bg-white text-slate-700 hover:bg-slate-50' if not filterIsDirty else 'border-slate-700 bg-slate-700 text-white hover:bg-slate-800' }}"
            type="reset"
        >{{ $t('mysql.button.reset') }}</a>
        <input
            class="wave ml-2 inline-flex h-8 cursor-pointer items-center rounded-md bg-primary-600 px-3 text-xs font-medium text-white shadow-sm hover:bg-primary-700 focus:outline-none focus:ring-2 focus:ring-primary-500/30"
            type="submit"
            value="{{ $t('mysql.button.filter') }}"
        />
    </th>
</form>""",
	r"example/mysql/_form_edit.j2.html": r"""<form method="post" action="{{ $e.uriString }}" class="contents">
    <input type="hidden" name="action" value="{{ 'update' if(action == 'edit' ?? action == 'update') else 'add' }}" />
    <tr>
        <td colspan="7" class="p-2">
            <div class="flex flex-wrap items-start gap-2">
                <div class="flex min-w-[160px] flex-col">
                    <input
                        type="text"
                        name="title"
                        placeholder="{{ $t('mysql.placeholder.title') }}"
                        required
                        value="{{ $n('form_book/title/value') }}"
                        class="h-9 rounded-md border bg-white px-3 text-xs shadow-sm focus:border-primary-500 focus:ring-2 focus:ring-primary-500/30 {{ 'border-rose-500 ring-2 ring-rose-300' if $n('form_book/title/errors/0') else 'border-slate-300' }}"
                    />
                    <div class="mt-1 text-[10px] text-rose-600 {{ '' if $n('form_book/title/errors/0') else 'hidden' }}">{{ $n('form_book/title/errors/0') }}</div>
                </div>
                <div class="flex min-w-[140px] flex-col">
                    <input
                        type="text"
                        name="author"
                        placeholder="{{ $t('mysql.placeholder.author') }}"
                        required
                        value="{{ $n('form_book/author/value') }}"
                        class="h-9 rounded-md border bg-white px-3 text-xs shadow-sm focus:border-primary-500 focus:ring-2 focus:ring-primary-500/30 {{ 'border-rose-500 ring-2 ring-rose-300' if $n('form_book/author/errors/0') else 'border-slate-300' }}"
                    />
                    <div class="mt-1 text-[10px] text-rose-600 {{ '' if $n('form_book/author/errors/0') else 'hidden' }}">{{ $n('form_book/author/errors/0') }}</div>
                </div>
                <div class="flex min-w-[160px] flex-col">
                    <input
                        type="date"
                        name="published_date"
                        placeholder="{{ $t('mysql.placeholder.publishedDate') }}"
                        required
                        value="{{ $n('form_book/published_date/value') }}"
                        class="h-9 rounded-md border bg-white px-3 text-xs shadow-sm focus:border-primary-500 focus:ring-2 focus:ring-primary-500/30 {{ 'border-rose-500 ring-2 ring-rose-300' if $n('form_book/published_date/errors/0') else 'border-slate-300' }}"
                    />
                    <div class="mt-1 text-[10px] text-rose-600 {{ '' if $n('form_book/published_date/errors/0') else 'hidden' }}">{{ $n('form_book/published_date/errors/0') }}</div>
                </div>
                <div class="flex min-w-[140px] flex-col">
                    <select
                        name="category_id"
                        class="h-9 rounded-md border bg-white px-2 text-xs shadow-sm focus:border-primary-500 focus:ring-2 focus:ring-primary-500/30 {{ 'border-rose-500 ring-2 ring-rose-300' if $n('form_book/category_id/errors/0') else 'border-slate-300' }}"
                    >
                        <option value=""></option>
                        {% set selected = $n('form_book/category_id/value') %}
                        {% for category in $n('form_book/category_id/options') %}
                            <option value="{{ category.id }}" {{ 'selected' if selected == category.id else '' }}>{{ category.title }}</option>
                        {% endfor %}
                    </select>
                    <div class="mt-1 text-[10px] text-rose-600 {{ '' if $n('form_book/category_id/errors/0') else 'hidden' }}">{{ $n('form_book/category_id/errors/0') }}</div>
                </div>
                <!-- CSRF Token -->
                <input type="hidden" name="token" value="{{ $n('form_book/token/value') }}" />
                
                {% if(action == 'edit' ?? action == 'update') %}
                <input type="hidden" name="id" value="{{ id }}" />
                <button type="submit" class="wave inline-flex h-9 items-center rounded-md border border-primary-600 bg-primary-50 px-3 text-xs font-medium text-primary-700 hover:bg-primary-100 focus:outline-none focus:ring-2 focus:ring-primary-500/30">{{ $t('mysql.button.update') }}</button>
                {% else %}
                <button type="submit" class="wave inline-flex h-9 items-center rounded-md border border-primary-600 bg-primary-50 px-3 text-xs font-medium text-primary-700 hover:bg-primary-100 focus:outline-none focus:ring-2 focus:ring-primary-500/30">{{ $t('database.table.button.add') }}</button>
                {% endif %}

                <div class="mt-1 text-[10px] text-rose-600 {{ $n('form_book/token/errors/0') ? '' : 'hidden' }}">{{ $n('form_book/token/errors/0') }}</div>
            </div>
        </td>
    </tr>
    <tr>
        <td colspan="7" class="p-2 text-xs text-slate-600">{{ paging }}</td>
    </tr>
</form>""",
	r"example/mysql/_categories.j2.html": r"""<div class="mt-8">
  <h3 class="text-base font-semibold text-slate-800">{{ $t('mysql.categories.title') }}</h3>
  <div class="mt-4 overflow-x-auto rounded-md border border-slate-200 bg-white shadow-sm">
    <table class="min-w-full text-sm text-slate-700">
      <thead class="bg-slate-50 text-xs uppercase tracking-wide text-slate-600">
        <tr class="divide-x divide-slate-200">
          <th scope="col" class="w-16 px-3 py-2 text-left font-medium">{{ $t('mysql.table.header.id') }}</th>
          <th scope="col" class="px-3 py-2 text-left font-medium">{{ $t('mysql.table.header.title') }}</th>
          <th scope="col" class="w-32 px-3 py-2 text-center font-medium">{{ $t('mysql.table.header.booksCount') }}</th>
          <th scope="col" class="w-20 px-3 py-2 text-center font-medium">{{ $t('mysql.table.header.actions') }}</th>
        </tr>
      </thead>
      <tbody class="divide-y divide-slate-200">
        {% for category in categories|default([]) %}
        <tr class="hover:bg-slate-50">
          <td class="px-3 py-2 font-mono text-[13px] text-slate-500">{{ category.id }}</td>
            <td class="px-3 py-2">{{ category.title }}</td>
            <td class="px-3 py-2 text-center">
              <a
                class="wave inline-flex h-7 items-center rounded border border-cyan-600 bg-cyan-50 px-2 text-[11px] font-medium text-cyan-700 hover:bg-cyan-100 focus:outline-none focus:ring-2 focus:ring-cyan-500/30"
                href="{{ $l.updateUrlQuery( {'filter_category_id': category.id|s}) }}"
              >{{ category.count_books }}</a>
            </td>
            <td class="px-3 py-2 text-center">
              <a
                data-href="{{ $l.updateUrlQuery( {'id': category.id|s, 'action': 'delete_category'|s}) }}"
                data-message="{{ $t('mysql.message.deleteCategory') ~ ' (' ~ category.title ~ ')' }}"
                class="wave js-delete-links inline-flex h-7 w-7 items-center justify-center rounded border border-transparent text-rose-600 hover:border-rose-200 hover:bg-rose-50 hover:text-rose-700 focus:outline-none focus:ring-2 focus:ring-rose-500/30"
                aria-label="{{ $t('mysql.button.delete') }}"
              >
                <i class="fas fa-trash text-[13px]"></i>
              </a>
            </td>
        </tr>
        {% else %}
        <tr>
          <td colspan="4" class="px-3 py-6 text-center text-sm text-slate-500">{{ $t('mysql.message.noCategories') }}</td>
        </tr>
        {% endfor %}
      </tbody>
      <tfoot class="bg-slate-50/60">
        <tr>
          <td colspan="4" class="px-3 py-3">
            <form method="POST" action="{{ $l.updateUrlQuery( {'action': 'add_category'}) }}" class="flex flex-wrap items-start gap-2">
              <div class="flex flex-col">
                <input
                  type="text"
                  name="title"
                  placeholder="{{ $t('mysql.placeholder.title') }}"
                  required
                  value="{{ $n('form/title/value') }}"
                  class="h-9 w-56 rounded-md border bg-white px-3 text-xs shadow-sm focus:border-primary-500 focus:ring-2 focus:ring-primary-500/30 {{ 'border-rose-500 ring-2 ring-rose-300' if $n('form/title/errors/0') else 'border-slate-300' }}"
                />
                <div class="mt-1 text-[10px] text-rose-600 {{ '' if $n('form/title/errors/0') else 'hidden' }}">{{ $n('form/title/errors/0') }}</div>
              </div>
              <button type="submit" class="wave inline-flex h-9 items-center rounded-md border border-primary-600 bg-primary-50 px-3 text-xs font-medium text-primary-700 hover:bg-primary-100 focus:outline-none focus:ring-2 focus:ring-primary-500/30">
                {{ $t('database.table.button.add') }}
              </button>
            </form>
          </td>
        </tr>
      </tfoot>
    </table>
  </div>
</div>
""",
	r"example/mysql/overview.j2.html": r"""{% extends 'template/template.j2.html' %}
{% block title %} {{ $t('mysql.example.title') }} {% endblock %}

{% block content %}
<div class="space-y-6">
  <!-- Page Header -->
  <div class="flex items-center gap-3">
    <div class="flex h-12 w-12 items-center justify-center rounded-xl bg-gradient-to-br from-orange-500 to-orange-600 text-white shadow-lg">
      <svg class="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 12h14M5 12a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v4a2 2 0 01-2 2M5 12a2 2 0 00-2 2v4a2 2 0 002 2h14a2 2 0 002-2v-4a2 2 0 00-2-2m-2-4h.01M17 16h.01"></path>
      </svg>
    </div>
    <div>
      <h1 class="text-2xl font-bold text-gray-800">{{ $t('mysql.example.title') }}</h1>
      <p class="text-sm text-gray-600">{{ $t('MySQL database operations with advanced features') }}</p>
    </div>
  </div>

  <!-- Table Card -->
  <div class="overflow-hidden rounded-xl border border-gray-200 bg-white shadow-lg">
    <div class="overflow-x-auto">
      <table class="min-w-full divide-y divide-gray-200 text-xs md:text-sm">
        <thead class="bg-gradient-to-r from-gray-50 to-white">
          <tr>
            <th colspan="6" class="px-4 py-3">
              {% set pageSize = data.pageSize | default("10") %}
              {% set randonString = $e.randomString() %}
              <div class="flex flex-wrap items-center justify-between gap-3">
                <div class="text-sm font-semibold text-gray-700">{{ $t('Books Management') }}</div>
                <div class="flex items-center gap-2">
                  <button type="button" class="wave group inline-flex h-9 items-center gap-2 rounded-lg border border-rose-300 bg-rose-50 px-4 text-xs font-semibold text-rose-700 transition-all duration-200 hover:bg-rose-100 hover:border-rose-400 hover:shadow-md focus:outline-none focus:ring-4 focus:ring-rose-500/20" onclick="deleteSelectedBooks_{{randonString}}()">
                    <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path>
                    </svg>
                    <span>{{ $t('mysql.button.deleteSelected') }}</span>
                  </button>
                  <select name="pageSize" class="h-9 rounded-lg border border-gray-300 bg-white px-3 text-xs font-medium shadow-sm transition-all duration-200 focus:border-blue-500 focus:ring-4 focus:ring-blue-500/20" onchange="changePageSize_{{randonString}}(this.value)">
                    <option {{ 'selected' if pageSize == '10' else '' }}>10</option>
                    <option {{ 'selected' if pageSize == '20' else '' }}>20</option>
                    <option {{ 'selected' if pageSize == '50' else '' }}>50</option>
                    <option {{ 'selected' if pageSize == '100' else '' }}>100</option>
                  </select>
                </div>
              </div>
              <script>
                function changePageSize_{{randonString}}(value) {
                  var url = new URL(window.location.href);
                  url.searchParams.set('pageSize', value);
                  window.location.href = url.toString();
                }
                function deleteSelectedBooks_{{randonString}}() {
                  var selectedBooks = [];
                  document.querySelectorAll('input[name="selected_books"]:checked').forEach(function(el){selectedBooks.push(el.value);});
                  if (selectedBooks.length > 0) {
                    if (confirm("{{ $t('mysql.message.deleteSelectedBooks') }}")) {
                      var form = document.createElement('form');
                      form.method = 'POST';
                      form.style.display = 'none';
                      var actionInput = document.createElement('input');
                      actionInput.type = 'hidden';
                      actionInput.name = 'action';
                      actionInput.value = 'delete_all';
                      form.appendChild(actionInput);
                      var booksInput = document.createElement('input');
                      booksInput.type = 'hidden';
                      booksInput.name = 'selected_books';
                      booksInput.value = selectedBooks.join(',');
                      form.appendChild(booksInput);
                      document.body.appendChild(form);
                      form.submit();
                    }
                  } else {
                    alert("{{ $t('mysql.message.noBooksSelected') }}");
                  }
                }
              </script>
            </th>
          </tr>
          <tr class="text-left">
            <th class="px-4 py-3">
              <div class="flex items-center gap-2">
                <input class="h-4 w-4 rounded border-gray-300 text-blue-600 transition-all duration-200 focus:ring-4 focus:ring-blue-500/20" type="checkbox" id="select_all" onchange="document.querySelectorAll(`input[name='selected_books']`).forEach(cb=>cb.checked=this.checked);" />
                <span class="text-xs font-bold uppercase tracking-wider text-gray-700">{{ $l.macro("/template/ui/sorting", {'sortby': 'b.id', 'title': 'mysql.table.header.id'} ) }}</span>
              </div>
            </th>
            <th class="px-4 py-3 text-xs font-bold uppercase tracking-wider text-gray-700">{{ $l.macro("/template/ui/sorting", {'sortby': 'title', 'title': 'mysql.table.header.title'} ) }}</th>
            <th class="px-4 py-3 text-xs font-bold uppercase tracking-wider text-gray-700">{{ $l.macro("/template/ui/sorting", {'sortby': 'author', 'title': 'mysql.table.header.author'} ) }}</th>
            <th class="px-4 py-3 text-xs font-bold uppercase tracking-wider text-gray-700">{{ $l.macro("/template/ui/sorting", {'sortby': 'published_date', 'title': 'mysql.table.header.publishedDate'} ) }}</th>
            <th class="px-4 py-3 text-xs font-bold uppercase tracking-wider text-gray-700">{{ $l.macro("/template/ui/sorting", {'sortby': 'category_id', 'title': 'mysql.table.header.categoryId'} ) }}</th>
            <th class="px-4 py-3 text-end text-xs font-bold uppercase tracking-wider text-gray-700">{{ $t('database.table.header.action') }}</th>
          </tr>
          <tr class="bg-gray-50/50">
            {% include 'example/mysql/_filtering.j2.html' %}
          </tr>
        </thead>
        <tbody class="divide-y divide-gray-100 bg-white">
          {% for book in books %}
          <tr class="group transition-colors duration-150 hover:bg-blue-50">
            <td class="px-4 py-3 align-top">
              <div class="flex items-center gap-2">
                <input class="h-4 w-4 rounded border-gray-300 text-blue-600 transition-all duration-200 focus:ring-4 focus:ring-blue-500/20" type="checkbox" name="selected_books" value="{{ book.id }}" />
                <span class="inline-flex h-6 w-6 items-center justify-center rounded-full bg-blue-100 text-xs font-bold text-blue-700">{{ book.id }}</span>
              </div>
            </td>
            <td class="px-4 py-3 font-semibold text-gray-800">{{ book.title }}</td>
            <td class="px-4 py-3 text-gray-700">{{ book.author }}</td>
            <td class="px-4 py-3 text-gray-600">
              <span class="inline-flex items-center gap-1">
                <svg class="h-4 w-4 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"></path>
                </svg>
                {{ book.published_date | dateFormat('dd/MM/y') }}
              </span>
            </td>
            <td class="px-4 py-3">
              <span class="inline-flex items-center rounded-full bg-purple-100 px-2.5 py-0.5 text-xs font-medium text-purple-700">{{ book.category_title }}</span>
            </td>
            <td class="px-4 py-3 text-end">
              <div class="flex items-center justify-end gap-2">
                <a
                  data-href="{{ $l.updateUrlQuery( {'id':book.id|s, 'action': 'delete'|s}) }}"
                  data-message="{{ $t('mysql.message.deleteBook') ~ ' (' ~ book.title ~ ')' }}"
                  class="wave cursor-pointer js-delete-links inline-flex h-8 w-8 items-center justify-center rounded-lg border border-rose-200 text-rose-600 transition-all duration-150 hover:bg-rose-50 hover:border-rose-300 hover:shadow-md focus:outline-none focus:ring-2 focus:ring-rose-500/30"
                  title="{{ $t('mysql.button.delete') }}"
                >
                  <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path>
                  </svg>
                </a>
                <a
                  href="{{ $l.updateUrlQuery( {'id':book.id|s, 'action': 'edit'|s}) }}"
                  class="wave inline-flex h-8 w-8 items-center justify-center rounded-lg border border-blue-200 text-blue-600 transition-all duration-150 hover:bg-blue-50 hover:border-blue-300 hover:shadow-md focus:outline-none focus:ring-2 focus:ring-blue-500/30"
                  title="{{ $t('mysql.button.edit') }}"
                >
                  <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"></path>
                  </svg>
                </a>
              </div>
            </td>
          </tr>
          {% else %}
          <tr>
            <td colspan="6" class="px-4 py-12 text-center">
              <div class="flex flex-col items-center gap-3">
                <div class="flex h-16 w-16 items-center justify-center rounded-full bg-gray-100">
                  <svg class="h-8 w-8 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253"></path>
                  </svg>
                </div>
                <p class="text-sm font-medium text-gray-500">{{ $t('mysql.message.noRecords') }}</p>
              </div>
            </td>
          </tr>
          {% endfor %}
        </tbody>
        <tfoot class="bg-gradient-to-r from-gray-50 to-white">
          {% include form_book.widget | unscape %}
        </tfoot>
      </table>
    </div>
    <div class="border-t border-gray-200 bg-gradient-to-r from-gray-50 to-white p-6">
      {% include 'example/mysql/_categories.j2.html' %}
    </div>
  </div>
</div>
{% endblock %}
""",
	r"example/cookie.j2.html": r"""{% extends 'template/template.j2.html' %}
{% block title %}
    {{ $t('sidebar.cookieExample') }}
{% endblock %}

{% block content %}
<div class="space-y-6">
  <!-- Page Header -->
  <div class="flex items-center gap-3">
    <div class="flex h-12 w-12 items-center justify-center rounded-xl bg-gradient-to-br from-amber-500 to-amber-600 text-white shadow-lg">
      <svg class="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v13m0-13V6a2 2 0 112 2h-2zm0 0V5.5A2.5 2.5 0 109.5 8H12zm-7 4h14M5 12a2 2 0 110-4h14a2 2 0 110 4M5 12v7a2 2 0 002 2h10a2 2 0 002-2v-7"></path>
      </svg>
    </div>
    <div>
      <h1 class="text-2xl font-bold text-gray-800">{{ $t('cookies.test') }}</h1>
      <p class="text-sm text-gray-600">{{ $t('Cookie management example') }}</p>
    </div>
  </div>
  <!-- Cookies Table Card -->
  <div class="overflow-hidden rounded-xl border border-gray-200 bg-white shadow-lg">
    <div class="overflow-x-auto">
      <table class="min-w-full divide-y divide-gray-200">
        <thead class="bg-gradient-to-r from-gray-50 to-white">
          <tr>
            <th class="px-6 py-4 text-left text-xs font-bold uppercase tracking-wider text-gray-700">{{ $t('cookies.key') }}</th>
            <th class="px-6 py-4 text-left text-xs font-bold uppercase tracking-wider text-gray-700">{{ $t('cookies.value') }}</th>
            <th class="px-6 py-4 text-center text-xs font-bold uppercase tracking-wider text-gray-700">{{ $t('cookies.action') }}</th>
          </tr>
        </thead>
        <tbody class="divide-y divide-gray-100 bg-white">
          {% for cookie in session.cookies %}
          <tr class="group transition-colors duration-150 hover:bg-blue-50">
            <td class="px-6 py-4 align-top">
              <div class="flex items-center gap-2">
                <div class="h-2 w-2 rounded-full bg-amber-600"></div>
                <span class="font-semibold text-gray-800">{{ cookie.name }}</span>
              </div>
            </td>
            <td class="px-6 py-4 align-top">
              <code class="rounded-md bg-gray-100 px-2 py-1 text-xs text-gray-700">{{ cookie.value }}</code>
            </td>
            <td class="px-6 py-4 text-center">
              <form method="post" class="inline">
                <input type="hidden" name="name" value="{{ cookie.name }}" />
                <input type="hidden" name="action" value="delete" />
                <button type="submit" class="inline-flex h-8 w-8 items-center justify-center rounded-lg border border-rose-200 text-rose-600 transition-all duration-150 hover:bg-rose-50 hover:border-rose-300 hover:shadow-md focus:outline-none focus:ring-2 focus:ring-rose-500/30" aria-label="{{ $t('cookies.remove') }}">
                  <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path>
                  </svg>
                </button>
              </form>
            </td>
          </tr>
          {% endfor %}
        </tbody>
        <tfoot class="border-t border-gray-200 bg-gradient-to-r from-gray-50 to-white">
          <tr>
            <td colspan="3" class="px-6 py-5">
              <form method="post" class="flex flex-col gap-3 lg:flex-row lg:items-center">
                <input placeholder="{{ $t('cookies.placeholder.name') }}" class="h-11 w-full rounded-lg border border-gray-300 bg-white px-4 text-sm shadow-sm transition-all duration-200 focus:border-blue-500 focus:ring-4 focus:ring-blue-500/20 lg:max-w-xs" type="text" name="name" value="" />
                <div class="flex w-full flex-1 flex-col gap-3 lg:flex-row lg:items-center">
                  <input type="text" name="value" class="h-11 w-full rounded-lg border border-gray-300 bg-white px-4 text-sm shadow-sm transition-all duration-200 focus:border-blue-500 focus:ring-4 focus:ring-blue-500/20" placeholder="{{ $t('cookies.placeholder.value') }}">
                  <label class="inline-flex h-11 items-center gap-3 rounded-lg border border-gray-300 bg-white px-4 text-sm font-medium text-gray-700 transition-all duration-200 hover:bg-gray-50">
                    <input class="h-5 w-5 rounded border-gray-300 text-blue-600 transition-all duration-200 focus:ring-4 focus:ring-blue-500/20" name="safe" type="checkbox" value="1">
                    <span>{{ $t('cookies.safe') }}</span>
                  </label>
                  <button class="wave group inline-flex h-11 shrink-0 items-center gap-2 rounded-lg bg-gradient-to-r from-blue-600 to-blue-700 px-5 text-sm font-semibold text-white shadow-md transition-all duration-200 hover:from-blue-700 hover:to-blue-800 hover:shadow-lg focus:outline-none focus:ring-4 focus:ring-blue-500/30" type="submit">
                    <svg class="h-5 w-5 transition-transform duration-200 group-hover:scale-110" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"></path>
                    </svg>
                    <span>{{ $t('cookies.add') }}</span>
                  </button>
                </div>
                <input type="hidden" name="action" value="add" />
              </form>
            </td>
          </tr>
        </tfoot>
      </table>
    </div>
  </div>
  <div class="my-3 overflow-hidden rounded-lg border border-slate-200 bg-white shadow-sm">
    <ul class="divide-y divide-slate-200">
      <li class="px-4 py-3">
        <div class="flex flex-col gap-1 md:flex-row md:items-center md:gap-3">
          <b class="md:w-48">{{ $t('auth.view') }}</b>
          <i class="text-primary-600">example/lib/widgets/example/auth.j2.html</i>
        </div>
      </li>
      <li class="px-4 py-3">
        <div class="flex flex-col gap-1 md:flex-row md:items-center md:gap-3">
          <b class="md:w-48">{{ $t('auth.controller') }}</b>
          <i class="text-primary-600">example/lib/controllers/home_controller.dart</i>
        </div>
      </li>
      <li class="px-4 py-3">
        <div class="flex flex-col gap-1 md:flex-row md:items-center md:gap-3">
          <b class="md:w-48">{{ $t('auth.authController') }}</b>
          <i class="text-primary-600">example/lib/controllers/auth_controller.dart</i>
        </div>
      </li>
      <li class="px-4 py-3">
        <div class="flex flex-col gap-1 md:flex-row md:items-center md:gap-3">
          <b class="md:w-48">{{ $t('auth.router') }}</b>
          <i class="text-primary-600">example/lib/route/web_route.dart</i>
        </div>
      </li>
    </ul>
  </div>
</div>
{% endblock %}""",
	r"example/info.j2.html": r"""{% extends 'template/template.j2.html' %} {% block title %} {{
$t('sidebar.info') }} 
{% endblock %} 

{% block content %}
<div class="space-y-6">
  <!-- Page Header -->
  <div class="flex items-center gap-3">
    <div class="flex h-12 w-12 items-center justify-center rounded-xl bg-gradient-to-br from-blue-500 to-blue-600 text-white shadow-lg">
      <svg class="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
      </svg>
    </div>
    <div>
      <h1 class="text-2xl font-bold text-gray-800">{{ $t('finchInfo.title') }}</h1>
      <p class="text-sm text-gray-600">{{ $t('Server information and configuration') }}</p>
    </div>
  </div>

  <!-- Server Info Accordions -->
  <div class="space-y-3">
    {% for key, value in server %}
    <details class="animate-details group rounded-xl border border-gray-200 bg-white shadow-lg">
      <summary class="flex cursor-pointer list-none items-center justify-between gap-3 px-6 py-4 transition-colors duration-150">
        <div class="flex items-center gap-3">
          <div class="h-2 w-2 rounded-full bg-blue-600"></div>
          <b class="text-base font-semibold text-gray-800">{{ $t('finchInfo.key', {'key': key}) }}</b>
        </div>
        <svg class="h-5 w-5 text-gray-500 transition-transform duration-200 group-open:rotate-180" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"></path>
        </svg>
      </summary>

      <div class="px-6 pb-5 pt-0">
        <div class="space-y-3">
          {% for info, details in value | items() %}
          <div class="rounded-lg border border-gray-200 bg-gradient-to-r from-gray-50 to-white p-4">
            <b class="block text-sm font-semibold text-gray-800">{{ $t('finchInfo.info', {'info': info}) }}</b>
            <p class="mt-2 text-sm text-gray-700 pl-3 border-l-2 border-blue-500">{{ $t('finchInfo.details', {'details': details}) }}</p>
          </div>
          {% endfor %}
        </div>
      </div>
    </details>
    {% endfor %}
  </div>
</div>
{% endblock %}
""",
	r"example/auth.j2.html": r"""{% extends 'template/template.j2.html' %}
{% block title %}
{{ $t('sidebar.authExample') }}
{% endblock %}
{% block content %}
<div class="space-y-6">
  <!-- Page Header -->
  <div class="flex items-center gap-3">
    <div class="flex h-12 w-12 items-center justify-center rounded-xl bg-gradient-to-br from-blue-500 to-blue-600 text-white shadow-lg">
      <svg class="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"></path>
      </svg>
    </div>
    <div>
      <h1 class="text-2xl font-bold text-gray-800">{{ $t('auth.test') }}</h1>
      <p class="text-sm text-gray-600">{{ $t('Authentication example page') }}</p>
    </div>
  </div>

  <!-- Welcome Card -->
  <div class="overflow-hidden rounded-xl border border-blue-200 bg-gradient-to-r from-blue-50 to-white shadow-lg">
    <div class="flex items-center gap-4 p-6">
      <div class="flex h-14 w-14 items-center justify-center rounded-full bg-blue-600 text-white shadow-md">
        <svg class="h-7 w-7" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"></path>
        </svg>
      </div>
      <div class="flex-1">
        <p class="text-sm text-gray-600">{{ $t('auth.welcome') }}</p>
        <p class="text-xl font-bold text-blue-700">{{ user.name }}</p>
      </div>
    </div>
  </div>

  <!-- Logout Button -->
  <div>
    <a href="/logout" class="wave group inline-flex items-center gap-2 rounded-lg bg-gradient-to-r from-rose-600 to-rose-700 px-6 py-3 text-sm font-semibold text-white shadow-lg transition-all duration-200 hover:from-rose-700 hover:to-rose-800 hover:shadow-xl focus:outline-none focus:ring-4 focus:ring-rose-500/30">
      <svg class="h-5 w-5 transition-transform duration-200 group-hover:scale-110" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"></path>
      </svg>
      <span>{{ $t('auth.logout') }}</span>
    </a>
  </div>

  <!-- File References Card -->
  <div class="overflow-hidden rounded-xl border border-gray-200 bg-white shadow-lg">
    <div class="border-b border-gray-200 bg-gradient-to-r from-gray-50 to-white px-6 py-4">
      <h3 class="text-lg font-bold text-gray-800">{{ $t('File References') }}</h3>
      <p class="text-sm text-gray-600">{{ $t('Related files for this authentication example') }}</p>
    </div>
    <ul class="divide-y divide-gray-100">
      <li class="group transition-colors duration-150 hover:bg-blue-50">
        <div class="flex flex-col gap-2 p-4 md:flex-row md:items-center md:gap-4">
          <div class="flex items-center gap-2 md:w-48">
            <svg class="h-5 w-5 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path>
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"></path>
            </svg>
            <span class="font-semibold text-gray-700">{{ $t('auth.view') }}</span>
          </div>
          <code class="rounded-md bg-gray-100 px-3 py-1 text-xs text-blue-700 group-hover:bg-blue-100">example/lib/widgets/example/auth.j2.html</code>
        </div>
      </li>
      <li class="group transition-colors duration-150 hover:bg-blue-50">
        <div class="flex flex-col gap-2 p-4 md:flex-row md:items-center md:gap-4">
          <div class="flex items-center gap-2 md:w-48">
            <svg class="h-5 w-5 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 20l4-16m4 4l4 4-4 4M6 16l-4-4 4-4"></path>
            </svg>
            <span class="font-semibold text-gray-700">{{ $t('auth.controller') }}</span>
          </div>
          <code class="rounded-md bg-gray-100 px-3 py-1 text-xs text-purple-700 group-hover:bg-blue-100">example/lib/controllers/home_controller.dart</code>
        </div>
      </li>
      <li class="group transition-colors duration-150 hover:bg-blue-50">
        <div class="flex flex-col gap-2 p-4 md:flex-row md:items-center md:gap-4">
          <div class="flex items-center gap-2 md:w-48">
            <svg class="h-5 w-5 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"></path>
            </svg>
            <span class="font-semibold text-gray-700">{{ $t('auth.authController') }}</span>
          </div>
          <code class="rounded-md bg-gray-100 px-3 py-1 text-xs text-green-700 group-hover:bg-blue-100">example/lib/controllers/auth_controller.dart</code>
        </div>
      </li>
      <li class="group transition-colors duration-150 hover:bg-blue-50">
        <div class="flex flex-col gap-2 p-4 md:flex-row md:items-center md:gap-4">
          <div class="flex items-center gap-2 md:w-48">
            <svg class="h-5 w-5 text-orange-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 7h8m0 0v8m0-8l-8 8-4-4-6 6"></path>
            </svg>
            <span class="font-semibold text-gray-700">{{ $t('auth.router') }}</span>
          </div>
          <code class="rounded-md bg-gray-100 px-3 py-1 text-xs text-orange-700 group-hover:bg-blue-100">example/lib/route/web_route.dart</code>
        </div>
      </li>
    </ul>
  </div>
</div>
{% endblock %}
""",
	r"template/ui/sorting.j2.html": r"""{% set asc = ((data.order == 'asc') and (data.sort == sortby)) %}
<a
    href="{{ $l.updateUrlQuery( {'sort': sortby, 'order': 'desc' if asc else 'asc'}) }}"
    class="wave inline-flex items-center gap-1 font-medium rounded text-slate-600 hover:text-slate-900 focus:outline-none no-underline group"
    title="{{ $t(title) }}"
>
    <span>{{ $t(title) }}</span>
    {% if data.sort == sortby %}
        {% if data.order != 'asc' %}
            <i class="fas fa-sort-up ml-1 text-primary-600 group-hover:text-primary-700"></i>
        {% else %}
            <i class="fas fa-sort-down ml-1 text-primary-600 group-hover:text-primary-700"></i>
        {% endif %}
    {% else %}
        <i class="fas fa-sort ml-1 text-slate-400 group-hover:text-slate-500"></i>
    {% endif %}
</a>""",
	r"template/sidebar.j2.html": r"""<!-- Sidebar -->
{% set dir = $t('dir') %}
<aside id="sidebar" class="fixed inset-y-0 start-0 z-40 w-[280px] overflow-y-auto border-e border-gray-200 bg-white transform transition-transform duration-300 ease-in-out shadow-lg {{ 'translate-x-full lg:translate-x-0' if dir=='rtl' else '-translate-x-full lg:translate-x-0' }}" aria-hidden="true" data-state="closed" style="scrollbar-width: thin; scrollbar-color: rgba(59, 130, 246, 0.3) transparent;">
  <div class="h-full flex flex-col">
    <!-- Sidebar Navigation -->
    <nav class="flex-1 overflow-y-auto p-3 space-y-1 pt-16">
      <ul class="flex list-none flex-col gap-1 p-0">
        <!-- Navigation Category -->
        <li>
          <details class="group" {{ $e.hasKey(['root.info', 'root.home']) ? 'open' : '' }}>
            <summary class="flex cursor-pointer list-none items-center justify-between rounded-lg px-3 py-2.5 text-sm font-medium text-gray-700 transition-all duration-150 hover:bg-blue-50 hover:text-blue-700">
              <span class="inline-flex items-center gap-3">
                <svg class="h-5 w-5 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 20l-5.447-2.724A1 1 0 013 16.382V5.618a1 1 0 011.447-.894L9 7m0 13l6-3m-6 3V7m6 10l4.553 2.276A1 1 0 0021 18.382V7.618a1 1 0 00-.553-.894L15 4m0 13V4m0 0L9 7"></path>
                </svg>
                <span>{{ $t('sidebar.navigation') }}</span>
              </span>
              <svg class="h-4 w-4 text-gray-400 transition-transform duration-200 group-open:rotate-180" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"></path>
              </svg>
            </summary>
            <ul class="mt-1 space-y-0.5 pl-3">
              <li>
                <a
                  href="{{ $e.routeUrl('root.home') }}"
                  class="wave flex w-full items-center gap-3 rounded-lg px-3 py-2 text-sm transition-all duration-150 hover:bg-blue-50 hover:text-blue-700 {{ $e.isKey('root.home') ? 'bg-blue-50 font-semibold text-blue-700 shadow-sm' : 'text-gray-600' }}"
                  aria-current="page"
                >
                  <svg class="h-5 w-5 {{ $e.isKey('root.home') ? 'text-blue-600' : 'text-gray-400' }}" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6"></path>
                  </svg>
                  <span>{{ $t('sidebar.home') }}</span>
                </a>
              </li>
              <li>
                <a
                  href="{{ $e.routeUrl('root.info') }}"
                  class="wave flex w-full items-center gap-3 rounded-lg px-3 py-2 text-sm transition-all duration-150 hover:bg-blue-50 hover:text-blue-700 {{ $e.isKey('root.info') ? 'bg-blue-50 font-semibold text-blue-700 shadow-sm' : 'text-gray-600' }}"
                  aria-current="page"
                >
                  <svg class="h-5 w-5 {{ $e.isKey('root.info') ? 'text-blue-600' : 'text-gray-400' }}" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                  </svg>
                  <span>{{ $t('sidebar.info') }}</span>
                </a>
              </li>
            </ul>
          </details>
        </li>

        <!-- Web Examples Category -->
        <li>
          <details class="group" {{ $e.hasKey(['root.form','root.form.post','root.cookie','root.cookie.post','root.route','root.socket','root.email','root.email.post','root.panel','root.language']) ? 'open' : '' }}>
            <summary class="flex cursor-pointer list-none items-center justify-between rounded-lg px-3 py-2.5 text-sm font-medium text-gray-700 transition-all duration-150 hover:bg-blue-50 hover:text-blue-700">
              <span class="inline-flex items-center gap-3">
                <svg class="h-5 w-5 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 12a9 9 0 01-9 9m9-9a9 9 0 00-9-9m9 9H3m9 9a9 9 0 01-9-9m9 9c1.657 0 3-4.03 3-9s-1.343-9-3-9m0 18c-1.657 0-3-4.03-3-9s1.343-9 3-9m-9 9a9 9 0 019-9"></path>
                </svg>
                <span>{{ $t('sidebar.webExamples') }}</span>
              </span>
              <svg class="h-4 w-4 text-gray-400 transition-transform duration-200 group-open:rotate-180" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"></path>
              </svg>
            </summary>
            <ul class="mt-1 space-y-0.5 pl-3 border-l-2 border-gray-200 ml-6">
              <li>
                <a
                  href="{{ $e.routeUrl('root.form') }}"
                  class="wave flex w-full items-center gap-3 rounded-lg px-3 py-2 text-sm transition-all duration-150 hover:bg-blue-50 hover:text-blue-700 {{ $e.hasKey(['root.form','root.form.post']) ? 'bg-blue-50 font-semibold text-blue-700 shadow-sm' : 'text-gray-600' }}"
                  aria-current="page"
                >
                  <svg class="h-5 w-5 {{ $e.hasKey(['root.form','root.form.post']) ? 'text-blue-600' : 'text-gray-400' }}" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"></path>
                  </svg>
                  <span>{{ $t('sidebar.formExample') }}</span>
                </a>
              </li>
              <li>
                <a
                  href="{{ $e.routeUrl('root.cookie') }}"
                  class="wave flex w-full items-center gap-3 rounded-lg px-3 py-2 text-sm transition-all duration-150 hover:bg-blue-50 hover:text-blue-700 {{ $e.hasKey(['root.cookie','root.cookie.post']) ? 'bg-blue-50 font-semibold text-blue-700 shadow-sm' : 'text-gray-600' }}"
                  aria-current="page"
                >
                  <i class="fa-solid fa-cookie-bite w-5 {{ $e.hasKey(['root.cookie','root.cookie.post']) ? 'text-blue-600' : 'text-gray-400' }}"></i>
                  <span>{{ $t('sidebar.cookieExample') }}</span>
                </a>
              </li>
              <li>
                <a
                  href="{{ $e.routeUrl('root.route') }}"
                  class="wave flex w-full items-center gap-3 rounded-lg px-3 py-2 text-sm transition-all duration-150 hover:bg-blue-50 hover:text-blue-700 {{ $e.hasKey(['root.route']) ? 'bg-blue-50 font-semibold text-blue-700 shadow-sm' : 'text-gray-600' }}"
                  aria-current="page"
                >
                  <svg class="h-5 w-5 {{ $e.hasKey(['root.route']) ? 'text-blue-600' : 'text-gray-400' }}" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 7h8m0 0v8m0-8l-8 8-4-4-6 6"></path>
                  </svg>
                  <span>{{ $t('sidebar.routeExample') }}</span>
                </a>
              </li>
              <li>
                <a
                  href="{{ $e.routeUrl('root.socket') }}"
                  class="wave flex w-full items-center gap-3 rounded-lg px-3 py-2 text-sm transition-all duration-150 hover:bg-blue-50 hover:text-blue-700 {{ $e.hasKey(['root.socket']) ? 'bg-blue-50 font-semibold text-blue-700 shadow-sm' : 'text-gray-600' }}"
                  aria-current="page"
                >
                  <svg class="h-5 w-5 {{ $e.hasKey(['root.socket']) ? 'text-blue-600' : 'text-gray-400' }}" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z"></path>
                  </svg>
                  <span>{{ $t('sidebar.socketExample') }}</span>
                </a>
              </li>
              <li>
                <a
                  href="{{ $e.routeUrl('root.email') }}"
                  class="wave flex w-full items-center gap-3 rounded-lg px-3 py-2 text-sm transition-all duration-150 hover:bg-blue-50 hover:text-blue-700 {{ $e.hasKey(['root.email','root.email.post']) ? 'bg-blue-50 font-semibold text-blue-700 shadow-sm' : 'text-gray-600' }}"
                  aria-current="page"
                >
                  <svg class="h-5 w-5 {{ $e.hasKey(['root.email','root.email.post']) ? 'text-blue-600' : 'text-gray-400' }}" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"></path>
                  </svg>
                  <span>{{ $t('sidebar.emailExample') }}</span>
                </a>
              </li>
              <li>
                <a
                  href="{{ $e.routeUrl('root.panel') }}"
                  class="wave flex w-full items-center gap-3 rounded-lg px-3 py-2 text-sm transition-all duration-150 hover:bg-blue-50 hover:text-blue-700 {{ $e.hasKey(['root.panel']) ? 'bg-blue-50 font-semibold text-blue-700 shadow-sm' : 'text-gray-600' }}"
                  aria-current="page"
                >
                  <svg class="h-5 w-5 {{ $e.hasKey(['root.panel']) ? 'text-blue-600' : 'text-gray-400' }}" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"></path>
                  </svg>
                  <span>{{ $t('sidebar.authExample') }}</span>
                </a>
              </li>
              <li>
                <a
                  href="{{ $e.routeUrl('root.language') }}"
                  class="wave flex w-full items-center gap-3 rounded-lg px-3 py-2 text-sm transition-all duration-150 hover:bg-blue-50 hover:text-blue-700 {{ $e.hasKey(['root.language']) ? 'bg-blue-50 font-semibold text-blue-700 shadow-sm' : 'text-gray-600' }}"
                  aria-current="page"
                >
                  <svg class="h-5 w-5 {{ $e.hasKey(['root.language']) ? 'text-blue-600' : 'text-gray-400' }}" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 5h12M9 3v2m1.048 9.5A18.022 18.022 0 016.412 9m6.088 9h7M11 21l5-10 5 10M12.751 5C11.783 10.77 8.07 15.61 3 18.129"></path>
                  </svg>
                  <span>{{ $t('sidebar.languageExample') }}</span>
                </a>
              </li>
            </ul>
          </details>
        </li>

        <!-- Database Examples Category -->
        {% if mongoActive ?? mysqlActive %}
        <li>
          <details class="group" {{ $e.hasKey(['root.database','root.person.delete','root.persons', 'root.person.show', 'root.person.post','root.mysql', 'root.sqlite']) ? 'open' : '' }}>
            <summary class="flex cursor-pointer list-none items-center justify-between rounded-lg px-3 py-2.5 text-sm font-medium text-gray-700 transition-all duration-150 hover:bg-blue-50 hover:text-blue-700">
              <span class="inline-flex items-center gap-3">
                <svg class="h-5 w-5 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 7v10c0 2.21 3.582 4 8 4s8-1.79 8-4V7M4 7c0 2.21 3.582 4 8 4s8-1.79 8-4M4 7c0-2.21 3.582-4 8-4s8 1.79 8 4m0 5c0 2.21-3.582 4-8 4s-8-1.79-8-4"></path>
                </svg>
                <span>{{ $t('sidebar.databaseExamples') }}</span>
              </span>
              <svg class="h-4 w-4 text-gray-400 transition-transform duration-200 group-open:rotate-180" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"></path>
              </svg>
            </summary>
            <ul class="mt-1 space-y-0.5 pl-3 border-l-2 border-gray-200 ml-6">
              {% if mongoActive %}
              <li>
                <a
                  href="{{ $e.routeUrl('root.database') }}"
                  class="wave flex w-full items-center gap-3 rounded-lg px-3 py-2 text-sm transition-all duration-150 hover:bg-blue-50 hover:text-blue-700 {{ $e.hasKey(['root.database']) ? 'bg-blue-50 font-semibold text-blue-700 shadow-sm' : 'text-gray-600' }}"
                  aria-current="page"
                >
                  <svg class="h-5 w-5 {{ $e.hasKey(['root.database']) ? 'text-green-600' : 'text-gray-400' }}" fill="currentColor" viewBox="0 0 20 20">
                    <path d="M10 2c-1.716 0-3.408.106-5.07.31C3.806 2.45 3 3.414 3 4.517V17.25c0 .966.784 1.75 1.75 1.75h10.5A1.75 1.75 0 0017 17.25V4.517c0-1.103-.806-2.068-1.93-2.207A41.403 41.403 0 0010 2z"></path>
                  </svg>
                  <span>{{ $t('sidebar.monogdbExample') }}</span>
                </a>
              </li>
              <li>
                <a
                  href="{{ $e.routeUrl('root.persons') }}"
                  class="wave flex w-full items-center gap-3 rounded-lg px-3 py-2 text-sm transition-all duration-150 hover:bg-blue-50 hover:text-blue-700 {{ $e.hasKey(['root.persons','root.person.show','root.person.delete']) ? 'bg-blue-50 font-semibold text-blue-700 shadow-sm' : 'text-gray-600' }}"
                  aria-current="page"
                >
                  <svg class="h-5 w-5 {{ $e.hasKey(['root.persons','root.person.show','root.person.delete']) ? 'text-blue-600' : 'text-gray-400' }}" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z"></path>
                  </svg>
                  <span>{{ $t('sidebar.freeModelDbExample') }}</span>
                </a>
              </li>
              {% endif %}
              {% if mysqlActive %}
              <li>
                <a
                  href="{{ $e.routeUrl('root.mysql') }}"
                  class="wave flex w-full items-center gap-3 rounded-lg px-3 py-2 text-sm transition-all duration-150 hover:bg-blue-50 hover:text-blue-700 {{ $e.hasKey(['root.mysql']) ? 'bg-blue-50 font-semibold text-blue-700 shadow-sm' : 'text-gray-600' }}"
                  aria-current="page"
                >
                  <svg class="h-5 w-5 {{ $e.hasKey(['root.mysql']) ? 'text-orange-600' : 'text-gray-400' }}" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 12h14M5 12a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v4a2 2 0 01-2 2M5 12a2 2 0 00-2 2v4a2 2 0 002 2h14a2 2 0 002-2v-4a2 2 0 00-2-2m-2-4h.01M17 16h.01"></path>
                  </svg>
                  <span>{{ $t('sidebar.mysqlExample') }}</span>
                </a>
              </li>
              {% endif %}
              {% if mysqlActive %}
              <li>
                <a
                  href="{{ $e.routeUrl('root.sqlite') }}"
                  class="wave flex w-full items-center gap-3 rounded-lg px-3 py-2 text-sm transition-all duration-150 hover:bg-blue-50 hover:text-blue-700 {{ $e.hasKey(['root.sqlite']) ? 'bg-blue-50 font-semibold text-blue-700 shadow-sm' : 'text-gray-600' }}"
                  aria-current="page"
                >
                  <svg class="h-5 w-5 {{ $e.hasKey(['root.sqlite']) ? 'text-blue-600' : 'text-gray-400' }}" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 7v10c0 2.21 3.582 4 8 4s8-1.79 8-4V7M4 7c0 2.21 3.582 4 8 4s8-1.79 8-4M4 7c0-2.21 3.582-4 8-4s8 1.79 8 4"></path>
                  </svg>
                  <span>{{ $t('SQLite Example') }}</span>
                </a>
              </li>
              {% endif %}
            </ul>
          </details>
        </li>
        {% endif %}

        <!-- Development Tools Category -->
        <li>
          <details class="group" {{ 'open' if $e.hasKey(['root.pagination', 'root.htmler', 'root.swagger']) else '' }}>
            <summary class="flex cursor-pointer list-none items-center justify-between rounded-lg px-3 py-2.5 text-sm font-medium text-gray-700 transition-all duration-150 hover:bg-blue-50 hover:text-blue-700">
              <span class="inline-flex items-center gap-3">
                <svg class="h-5 w-5 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"></path>
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path>
                </svg>
                <span>{{ $t('sidebar.developmentTools') }}</span>
              </span>
              <svg class="h-4 w-4 text-gray-400 transition-transform duration-200 group-open:rotate-180" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"></path>
              </svg>
            </summary>
            <ul class="mt-1 space-y-0.5 pl-3 border-l-2 border-gray-200 ml-6">
              <li>
                <a
                  href="{{ $e.routeUrl('root.pagination') }}"
                  class="wave flex w-full items-center gap-3 rounded-lg px-3 py-2 text-sm transition-all duration-150 hover:bg-blue-50 hover:text-blue-700 {{ $e.hasKey(['root.pagination']) ? 'bg-blue-50 font-semibold text-blue-700 shadow-sm' : 'text-gray-600' }}"
                  aria-current="page"
                >
                  <svg class="h-5 w-5 {{ $e.hasKey(['root.pagination']) ? 'text-blue-600' : 'text-gray-400' }}" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 20l4-16m2 16l4-16M6 9h14M4 15h14"></path>
                  </svg>
                  <span>{{ $t('sidebar.paginationExample') }}</span>
                </a>
              </li>
              <li>
                <a
                  href="{{ $e.routeUrl('root.htmler') }}"
                  class="wave flex w-full items-center gap-3 rounded-lg px-3 py-2 text-sm transition-all duration-150 hover:bg-blue-50 hover:text-blue-700 {{ $e.hasKey(['root.htmler']) ? 'bg-blue-50 font-semibold text-blue-700 shadow-sm' : 'text-gray-600' }}"
                  aria-current="page"
                >
                  <svg class="h-5 w-5 {{ $e.hasKey(['root.htmler']) ? 'text-blue-600' : 'text-gray-400' }}" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 20l4-16m4 4l4 4-4 4M6 16l-4-4 4-4"></path>
                  </svg>
                  <span>{{ $t('sidebar.htmlerExample') }}</span>
                </a>
              </li>
              <li>
                <a
                  href="{{ $e.routeUrl('root.swagger') }}"
                  class="wave flex w-full items-center gap-3 rounded-lg px-3 py-2 text-sm transition-all duration-150 hover:bg-blue-50 hover:text-blue-700 {{ $e.hasKey(['root.swagger']) ? 'bg-blue-50 font-semibold text-blue-700 shadow-sm' : 'text-gray-600' }}"
                  aria-current="page"
                >
                  <svg class="h-5 w-5 {{ $e.hasKey(['root.swagger']) ? 'text-blue-600' : 'text-gray-400' }}" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
                  </svg>
                  <span>{{ $t('sidebar.swaggerExample') }}</span>
                </a>
              </li>
            </ul>
          </details>
        </li>

        <!-- Testing Category -->
        <li>
          <details class="group" {{ $e.hasKey(['root.error', 'root.dump']) ? 'open' : '' }}>
            <summary class="flex cursor-pointer list-none items-center justify-between rounded-lg px-3 py-2.5 text-sm font-medium text-gray-700 transition-all duration-150 hover:bg-blue-50 hover:text-blue-700">
              <span class="inline-flex items-center gap-3">
                <svg class="h-5 w-5 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                </svg>
                <span>{{ $t('sidebar.debugTesting') }}</span>
              </span>
              <svg class="h-4 w-4 text-gray-400 transition-transform duration-200 group-open:rotate-180" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"></path>
              </svg>
            </summary>
            <ul class="mt-1 space-y-0.5 pl-3 border-l-2 border-gray-200 ml-6">
              <li>
                <a
                  href="{{ $e.routeUrl('root.error') }}"
                  class="wave flex w-full items-center gap-3 rounded-lg px-3 py-2 text-sm transition-all duration-150 hover:bg-blue-50 hover:text-blue-700 {{ $e.hasKey(['root.error']) ? 'bg-blue-50 font-semibold text-blue-700 shadow-sm' : 'text-gray-600' }}"
                  aria-current="page"
                >
                  <svg class="h-5 w-5 {{ $e.hasKey(['root.error']) ? 'text-rose-600' : 'text-gray-400' }}" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"></path>
                  </svg>
                  <span>{{ $t('sidebar.errorExample') }}</span>
                </a>
              </li>
              <li>
                <a
                  href="{{ $e.routeUrl('root.dump') }}"
                  class="wave flex w-full items-center gap-3 rounded-lg px-3 py-2 text-sm transition-all duration-150 hover:bg-blue-50 hover:text-blue-700 {{ $e.hasKey(['root.dump']) ? 'bg-blue-50 font-semibold text-blue-700 shadow-sm' : 'text-gray-600' }}"
                  aria-current="page"
                >
                  <svg class="h-5 w-5 {{ $e.hasKey(['root.dump']) ? 'text-blue-600' : 'text-gray-400' }}" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 20l4-16m4 4l4 4-4 4M6 16l-4-4 4-4"></path>
                  </svg>
                  <span>{{ $t('sidebar.dumpExample') }}</span>
                </a>
              </li>
            </ul>
          </details>
        </li>
      </ul>
    </nav>
  </div>
</aside>
""",
	r"template/footer.j2.html": r"""<script src="https://cdn.jsdelivr.net/gh/google/code-prettify@master/loader/run_prettify.js"></script>
<script
  src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.11.8/dist/umd/popper.min.js"
  integrity="sha384-I7E8VVD/ismYTF4hNIPjVp/Zjvgyol6VFvRkX/vR+Vc4jQkC+hVqc2pM8ODewa9r"
  crossorigin="anonymous"
></script>
<script
  crossorigin="anonymous"
></script>
<script src="/assets/app.js"></script>
<script src="/assets/effects/wave/wave.js"></script>
<script src="/assets/websocket.js"></script>
{{ assets.dataJs() }}
{{ assets.js() }}
""",
	r"template/navbar.j2.html": r"""<nav
  id="navbar"
  class="fixed w-full top-0 z-50 border-b border-gray-200/80 bg-white/80 backdrop-blur-md shadow-sm transition-all duration-300"
>
  <div class="mx-auto w-full">
    <div class="flex w-full items-center justify-between gap-4 py-3 px-4 lg:px-6">
      <div class="flex items-center gap-2">
        <button
          class="wave button-sidebar lg:hidden group inline-flex h-10 w-10 items-center justify-center rounded-lg text-gray-600 transition-all duration-200 hover:bg-blue-50 hover:text-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-500/30"
          type="button"
          aria-label="{{ $t('navbar.toggleSidebar') }}"
          aria-controls="sidebar"
          aria-expanded="false"
        >
          <svg
            xmlns="http://www.w3.org/2000/svg"
            width="20"
            height="20"
            fill="currentColor"
            viewBox="0 0 16 16"
            class="shrink-0 transition-transform duration-200 group-hover:scale-110"
          >
            <path
              fill-rule="evenodd"
              d="M2.5 12a.5.5 0 0 1 .5-.5h10a.5.5 0 0 1 0 1H3a.5.5 0 0 1-.5-.5m0-4a.5.5 0 0 1 .5-.5h10a.5.5 0 0 1 0 1H3a.5.5 0 0 1-.5-.5m0-4a.5.5 0 0 1 .5-.5h10a.5.5 0 0 1 0 1H3a.5.5 0 0 1-.5-.5"
            />
          </svg>
        </button>
        <a
          class="wave group inline-flex items-center gap-3 rounded-lg px-1 transition-all duration-200 hover:bg-blue-50"
          href="{{ $e.routeUrl('root.home') }}"
        >
          <img
            src="{{ $e.url('logo.svg') }}"
            alt="{{ $t('logo.title') }}"
            class="h-10 w-10 shrink-0"
          />
          <div class="hidden items-baseline gap-2 sm:flex">
            <span class="text-lg font-bold text-gray-800 transition-colors duration-200 group-hover:text-blue-600">{{ $t('logo.title') }}</span>
            <span class="text-xs font-medium text-gray-400">{{ version }}</span>
          </div>
        </a>
      </div>

      <div class="flex items-center gap-3">
        <a
          href="https://github.com/uproid/finch"
          class="wave group inline-flex h-10 w-10 items-center justify-center rounded-lg text-gray-600 transition-all duration-200 hover:bg-gray-100 hover:text-gray-900 focus:outline-none focus:ring-2 focus:ring-gray-400/30"
          aria-label="GitHub"
        >
          <svg
            xmlns="http://www.w3.org/2000/svg"
            width="20"
            height="20"
            viewBox="0 0 512 499.36"
            role="img"
            class="shrink-0 transition-transform duration-200 group-hover:scale-110"
          >
            <title>{{ $t('GitHub') }}</title>
            <path
              fill="currentColor"
              fill-rule="evenodd"
              d="M256 0C114.64 0 0 114.61 0 256c0 113.09 73.34 209 175.08 242.9 12.8 2.35 17.47-5.56 17.47-12.34 0-6.08-.22-22.18-.35-43.54-71.2 15.49-86.2-34.34-86.2-34.34-11.64-29.57-28.42-37.45-28.42-37.45-23.27-15.84 1.73-15.55 1.73-15.55 25.69 1.81 39.21 26.38 39.21 26.38 22.84 39.12 59.92 27.82 74.5 21.27 2.33-16.54 8.94-27.82 16.25-34.22-56.84-6.43-116.6-28.43-116.6-126.49 0-27.95 10-50.8 26.35-68.69-2.63-6.48-11.42-32.5 2.51-67.75 0 0 21.49-6.88 70.4 26.24a242.65 242.65 0 0 1 128.18 0c48.87-33.13 70.33-26.24 70.33-26.24 14 35.25 5.18 61.27 2.55 67.75 16.41 17.9 26.31 40.75 26.31 68.69 0 98.35-59.85 120-116.88 126.32 9.19 7.9 17.38 23.53 17.38 47.41 0 34.22-.31 61.83-.31 70.23 0 6.85 4.61 14.81 17.6 12.31C438.72 464.97 512 369.08 512 256.02 512 114.62 397.37 0 256 0z"
            ></path>
          </svg>
        </a>

        {% if user %}
        <details class="group relative">
          <summary
            class="list-none inline-flex h-10 cursor-pointer items-center gap-2 rounded-lg px-3 text-sm font-medium text-gray-700 transition-all duration-200 hover:bg-gray-100 hover:text-gray-900 focus:outline-none focus:ring-2 focus:ring-gray-400/30"
          >
            <div class="flex h-7 w-7 items-center justify-center rounded-full bg-gradient-to-br from-blue-500 to-blue-600 text-white shadow-sm">
              <i class="fas fa-user text-xs"></i>
            </div>
            <span class="hidden md:block">{{ user.name }}</span>
            <svg class="h-4 w-4 transition-transform duration-200 group-open:rotate-180" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"></path>
            </svg>
          </summary>
          <ul
            class="absolute end-0 mt-2 w-56 origin-top-end scale-95 opacity-0 overflow-hidden rounded-lg border border-gray-200 bg-white py-2 shadow-xl ring-1 ring-black/5 transition-all duration-200 group-open:scale-100 group-open:opacity-100"
          >
            <li>
              <a
                class="wave flex items-center gap-3 px-4 py-2.5 text-sm font-medium text-rose-600 transition-colors duration-150 hover:bg-rose-50"
                href="{{ $e.routeUrl('root.logout') }}"
              >
                <i class="fas fa-sign-out-alt w-4 shrink-0"></i>
                <span>{{ $t('auth.logout') }}</span>
              </a>
            </li>
          </ul>
        </details>
        {% endif %}

        <details
          class="group relative"
        >
          <summary
            class="list-none inline-flex h-10 cursor-pointer items-center gap-2 rounded-lg px-3 text-sm font-medium text-gray-700 transition-all duration-200 hover:bg-gray-100 hover:text-gray-900 focus:outline-none focus:ring-2 focus:ring-gray-400/30"
          >
            <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 5h12M9 3v2m1.048 9.5A18.022 18.022 0 016.412 9m6.088 9h7M11 21l5-10 5 10M12.751 5C11.783 10.77 8.07 15.61 3 18.129"></path>
            </svg>
            <span class="hidden sm:block">{{ $e.ln | upper }}</span>
            <svg class="h-4 w-4 transition-transform duration-200 group-open:rotate-180" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"></path>
            </svg>
          </summary>
          <ul
            class="absolute end-0 mt-2 w-48 max-h-80 origin-top-end scale-95 opacity-0 overflow-y-auto rounded-lg border border-gray-200 bg-white py-2 shadow-xl ring-1 ring-black/5 transition-all duration-200 group-open:scale-100 group-open:opacity-100"
          >
            {% for key, language in languages %}
            <li>
              <a
                class="wave flex items-center gap-3 px-4 py-2.5 text-sm transition-colors duration-150 hover:bg-blue-50 {{ 'bg-blue-50 font-semibold text-blue-700' if $e.ln == key else 'text-gray-700' }}"
                href="{{ $e.urlToLanguage(key) }}"
              >
                <img src="{{ language.flag }}" class="inline-flex w-6 items-center justify-center text-base"/>
                <span>{{ language.name }}</span>
                {% if $e.ln == key %}
                <svg class="ml-auto h-4 w-4 text-blue-600" fill="currentColor" viewBox="0 0 20 20">
                  <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"></path>
                </svg>
                {% endif %}
              </a>
            </li>
            {% endfor %}
          </ul>
        </details>
      </div>
    </div>
  </div>
</nav>
""",
	r"template/home.j2.html": r"""{% extends 'template/template.j2.html' %}

{% block title %}
    {{ $t('sidebar.home') }}
{% endblock %}
  
{% block content %}
<div class="space-y-8">  
  <!-- Hero Section -->  
  <div class="relative overflow-hidden rounded-2xl bg-gradient-to-br from-blue-500 via-blue-600 to-indigo-700 p-8 shadow-xl lg:p-12">
    <div class="absolute inset-0 bg-[url('data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iNjAiIGhlaWdodD0iNjAiIHZpZXdCb3g9IjAgMCA2MCA2MCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj48ZyBmaWxsPSJub25lIiBmaWxsLXJ1bGU9ImV2ZW5vZGQiPjxnIGZpbGw9IiNmZmYiIGZpbGwtb3BhY2l0eT0iMC4xIj48cGF0aCBkPSJNMzYgMzRoLTJWMzJoMnptMCAyaC0ydjJoMnptMi0yaDJ2Mmgtem0wLTJoMnYyaC0yem0tMi0yaC0ydjJoMnptMi0yaDJ2Mmgtenz0iLz48L2c+PC9nPjwvc3ZnPg==')] opacity-20"></div>
    <div class="relative">
      <div dir="ltr" class="flex flex-col items-center justify-center gap-6 text-center lg:flex-row lg:text-left">
        <div class="flex h-24 w-24 items-center justify-center rounded-2xl bg-white/20 shadow-lg backdrop-blur-sm ring-4 ring-white/30">
          <img
            src="{{ $e.url('logo.svg') }}" 
            alt="{{ $t('logo.title') }}"
            class="h-full w-full object-contain drop-shadow-2xl"
          />
        </div>
        <div class="flex flex-col justify-center">
          <h1 style="font-size: 2.5rem;" class="font-black text-white drop-shadow-lg">{{ $t('logo') }}</h1>
          <p class="mt-2 text-sm font-medium tracking-wider text-blue-100">{{ $t('Version') }} {{ version }}</p>
        </div>
      </div>
    </div>  
  </div>  

  {% if loginResult != true %}
  <!-- Features Card -->
  <div class="overflow-hidden rounded-xl border border-gray-200 bg-white shadow-lg">
    <div class="border-b border-gray-200 bg-gradient-to-r from-gray-50 to-white px-6 py-4">
      <h2 class="text-2xl font-bold text-gray-800">{{ $t('features.title') }}</h2>
      <p class="mt-2 text-sm text-gray-600">
        {{ $t('features.description') }}
      </p>
    </div>

    <div class="p-6">
      <ul class="grid gap-3 sm:grid-cols-2 lg:grid-cols-3">
        <li class="flex items-start gap-3 rounded-lg border border-blue-100 bg-blue-50/50 p-4 transition-all duration-200 hover:border-blue-300 hover:shadow-md">
          <div class="flex h-8 w-8 shrink-0 items-center justify-center rounded-lg bg-blue-600 text-white shadow-sm">
            <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z"></path>
            </svg>
          </div>
          <span class="text-sm font-medium text-gray-700">{{ $t('features.websocket') }}</span>
        </li>
        <li class="flex items-start gap-3 rounded-lg border border-green-100 bg-green-50/50 p-4 transition-all duration-200 hover:border-green-300 hover:shadow-md">
          <div class="flex h-8 w-8 shrink-0 items-center justify-center rounded-lg bg-green-600 text-white shadow-sm">
            <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 7v10c0 2.21 3.582 4 8 4s8-1.79 8-4V7M4 7c0 2.21 3.582 4 8 4s8-1.79 8-4M4 7c0-2.21 3.582-4 8-4s8 1.79 8 4"></path>
            </svg>
          </div>
          <span class="text-sm font-medium text-gray-700">{{ $t('features.mongodb') }}</span>
        </li>
        <li class="flex items-start gap-3 rounded-lg border border-purple-100 bg-purple-50/50 p-4 transition-all duration-200 hover:border-purple-300 hover:shadow-md">
          <div class="flex h-8 w-8 shrink-0 items-center justify-center rounded-lg bg-purple-600 text-white shadow-sm">
            <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"></path>
            </svg>
          </div>
          <span class="text-sm font-medium text-gray-700">{{ $t('features.cronjobs') }}</span>
        </li>
        <li class="flex items-start gap-3 rounded-lg border border-blue-100 bg-blue-50/50 p-4 transition-all duration-200 hover:border-blue-300 hover:shadow-md">
          <div class="flex h-8 w-8 shrink-0 items-center justify-center rounded-lg bg-blue-600 text-white shadow-sm">
            <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 7h8m0 0v8m0-8l-8 8-4-4-6 6"></path>
            </svg>
          </div>
          <span class="text-sm font-medium text-gray-700">{{ $t('features.routing') }}</span>
        </li>
        <li class="flex items-start gap-3 rounded-lg border border-amber-100 bg-amber-50/50 p-4 transition-all duration-200 hover:border-amber-300 hover:shadow-md">
          <div class="flex h-8 w-8 shrink-0 items-center justify-center rounded-lg bg-amber-600 text-white shadow-sm">
            <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path>
            </svg>
          </div>
          <span class="text-sm font-medium text-gray-700">{{ $t('features.formvalidators') }}</span>
        </li>
        <li class="flex items-start gap-3 rounded-lg border border-indigo-100 bg-indigo-50/50 p-4 transition-all duration-200 hover:border-indigo-300 hover:shadow-md">
          <div class="flex h-8 w-8 shrink-0 items-center justify-center rounded-lg bg-indigo-600 text-white shadow-sm">
            <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 20l4-16m4 4l4 4-4 4M6 16l-4-4 4-4"></path>
            </svg>
          </div>
          <span class="text-sm font-medium text-gray-700">{{ $t('features.htmltools') }}</span>
        </li>
        <li class="flex items-start gap-3 rounded-lg border border-teal-100 bg-teal-50/50 p-4 transition-all duration-200 hover:border-teal-300 hover:shadow-md">
          <div class="flex h-8 w-8 shrink-0 items-center justify-center rounded-lg bg-teal-600 text-white shadow-sm">
            <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 7v10c0 2.21 3.582 4 8 4s8-1.79 8-4V7"></path>
            </svg>
          </div>
          <span class="text-sm font-medium text-gray-700">{{ $t('features.dbmodel') }}</span>
        </li>
        <li class="flex items-start gap-3 rounded-lg border border-rose-100 bg-rose-50/50 p-4 transition-all duration-200 hover:border-rose-300 hover:shadow-md">
          <div class="flex h-8 w-8 shrink-0 items-center justify-center rounded-lg bg-rose-600 text-white shadow-sm">
            <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z"></path>
            </svg>
          </div>
          <span class="text-sm font-medium text-gray-700">{{ $t('features.fastapi') }}</span>
        </li>
        <li class="flex items-start gap-3 rounded-lg border border-gray-200 bg-gray-50/50 p-4 transition-all duration-200 hover:border-gray-300 hover:shadow-md">
          <div class="flex h-8 w-8 shrink-0 items-center justify-center rounded-lg bg-gray-600 text-white shadow-sm">
            <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6V4m0 2a2 2 0 100 4m0-4a2 2 0 110 4m-6 8a2 2 0 100-4m0 4a2 2 0 110-4m0 4v2m0-6V4m6 6v10m6-2a2 2 0 100-4m0 4a2 2 0 110-4m0 4v2m0-6V4"></path>
            </svg>
          </div>
          <span class="text-sm font-medium text-gray-700">{{ $t('features.other') }}</span>
        </li>
      </ul>

      <!-- Action Buttons -->
      <div class="mt-8 flex flex-wrap gap-3" role="group" aria-label="Quick links">
        <a
          href="https://github.com/uproid/finch"
          class="wave group inline-flex items-center gap-2 rounded-lg border-2 border-blue-600 bg-blue-600 px-5 py-2.5 text-sm font-semibold text-white shadow-md transition-all duration-200 hover:bg-blue-700 hover:border-blue-700 hover:shadow-lg focus:outline-none focus:ring-4 focus:ring-blue-500/30"
        >
          <svg class="h-5 w-5" fill="currentColor" viewBox="0 0 24 24">
            <path d="M12 0c-6.626 0-12 5.373-12 12 0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23.957-.266 1.983-.399 3.003-.404 1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576 4.765-1.589 8.199-6.086 8.199-11.386 0-6.627-5.373-12-12-12z"></path>
          </svg>
          <span>{{ $t('project.github') }}</span>
        </a>
        <a
          href="https://github.com/uproid/finch/blob/master/CONTRIBUTING.md"
          class="wave inline-flex items-center gap-2 rounded-lg border-2 border-blue-600 bg-white px-5 py-2.5 text-sm font-semibold text-blue-700 shadow-md transition-all duration-200 hover:bg-blue-50 hover:shadow-lg focus:outline-none focus:ring-4 focus:ring-blue-500/30"
        >
          <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z"></path>
          </svg>
          <span>{{ $t('project.contributing') }}</span>
        </a>
        <a
          href="https://github.com/uproid/finch/tree/master/doc"
          class="wave inline-flex items-center gap-2 rounded-lg border-2 border-blue-600 bg-white px-5 py-2.5 text-sm font-semibold text-blue-700 shadow-md transition-all duration-200 hover:bg-blue-50 hover:shadow-lg focus:outline-none focus:ring-4 focus:ring-blue-500/30"
        >
          <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253"></path>
          </svg>
          <span>{{ $t('project.documentation') }}</span>
        </a>
        <a
          href="https://pub.dev/packages/finch"
          class="wave inline-flex items-center gap-2 rounded-lg border-2 border-blue-600 bg-white px-5 py-2.5 text-sm font-semibold text-blue-700 shadow-md transition-all duration-200 hover:bg-blue-50 hover:shadow-lg focus:outline-none focus:ring-4 focus:ring-blue-500/30"
        >
          <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4"></path>
          </svg>
          <span>{{ $t('project.pubdev') }}</span>
        </a>
      </div>
    </div>
  </div>
  {% else %}
  <div class="flex items-start gap-4 rounded-xl border border-emerald-300 bg-gradient-to-r from-emerald-50 to-green-50 p-6 shadow-lg">
    <div class="flex h-10 w-10 shrink-0 items-center justify-center rounded-full bg-emerald-600 text-white shadow-md">
      <svg class="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path>
      </svg>
    </div>
    <div class="flex-1">
      <h3 class="text-lg font-semibold text-emerald-900">{{ $t('login.success') }}</h3>
      <p class="mt-1 text-sm text-emerald-700">You have successfully logged in!</p>
    </div>
  </div>
  {% endif %}
</div>
{% endblock %}
""",
	r"template/template.j2.html": r"""<!DOCTYPE html>
<html lang="{{ $e.ln }}" dir="{{ $t('dir') }}" class="h-full overflow-x-hidden">

<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>{% block title %}{% endblock %} | {{ $t(title) }}</title>
  <meta name="robots" content="noindex, nofollow">
  <link rel="icon" href="/favicon.ico" type="image/x-icon" />
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
  <link rel="stylesheet" href="/assets/effects/wave/wave.css" />
  <!-- Local built Tailwind CSS (generated via Tailwind CLI) -->
  <link rel="stylesheet" href="/assets/generated-tailwind.css" />
  <link rel="stylesheet" href="/assets/app.css" crossorigin="anonymous" />
  <script src="https://code.jquery.com/jquery-3.7.1.min.js" integrity="sha256-/JqT3SQfawRcv/BIHPThkBvs0OEvtFFmqPF/lYI/Cxo=" crossorigin="anonymous"></script>
  {% block stylesheets %}
  {{ assets.css() }}
  {% endblock %}
</head>

<body class="h-full bg-gray-50 font-sans antialiased overflow-x-hidden">
  {% block navbar %}
  {% include 'template/navbar.j2.html' %}
  {% endblock %}

  <div class="flex min-h-screen w-screen max-w-full bg-gradient-to-br from-gray-50 to-blue-50/30 overflow-x-hidden">
    {% block sidebar %}
    {% include 'template/sidebar.j2.html' %}
    {% endblock %}
    <!-- Main Component -->
    <div class="main flex-1 flex flex-col lg:ms-[280px] min-w-0 w-full">
      <main class="content flex-1 px-4 py-6 mt-16 lg:px-8 lg:py-8 w-full min-w-0">
        <div class="mx-auto w-full max-w-7xl min-w-0">
          {% block flash %}
          {% if $l.hasFlash() %}
          {% for flash in $l.getFlashs() %}
          <div
            class="mb-6 flex items-start gap-3 rounded-lg border p-4 text-sm shadow-sm animate-in fade-in slide-in-from-top-2 duration-300
            {% if flash.type == 'success' %} bg-emerald-50 border-emerald-300 text-emerald-900 {% endif %}
            {% if flash.type == 'info' %} bg-blue-50 border-blue-300 text-blue-900 {% endif %}
            {% if flash.type == 'warning' %} bg-amber-50 border-amber-300 text-amber-900 {% endif %}
            {% if flash.type == 'danger' ?? flash.type == 'error' %} bg-rose-50 border-rose-300 text-rose-900 {% endif %}
            {% if flash.type != 'success' and flash.type != 'info' and flash.type != 'warning' and flash.type != 'danger' and flash.type != 'error' %} bg-slate-50 border-slate-300 text-slate-900 {% endif %}
            ">
            <span class="shrink-0">
              {% if flash.type == 'success' %}
              <svg class="h-5 w-5 text-emerald-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
              {% elif flash.type == 'info' %}
              <svg class="h-5 w-5 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
              {% elif flash.type == 'warning' %}
              <svg class="h-5 w-5 text-amber-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"></path></svg>
              {% else %}
              <svg class="h-5 w-5 text-rose-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
              {% endif %}
            </span>
            <span class="flex-1">{{ flash.text }}</span>
          </div>
          {% endfor %}
          {% endif %}
          {% endblock %}
          {% block content %}
          {% endblock %}
        </div>
      </main>
    </div>
  </div>

  {% block footer %}
  {% include 'template/footer.j2.html' %}
  {% endblock %}

  <script>
    document.addEventListener('DOMContentLoaded', function () {
      var toggle = document.querySelector('.button-sidebar');
      var sidebar = document.getElementById('sidebar');
      var backdrop = document.getElementById('sidebar-backdrop');
      if (!toggle || !sidebar) return;

      var htmlDir = document.documentElement.getAttribute('dir') || 'ltr';
      var isRTL = htmlDir === 'rtl';
      var lgQuery = window.matchMedia('(min-width: 1024px)');
      var closedClass = isRTL ? 'translate-x-full' : '-translate-x-full';

      function setSidebarOpen(open) {
        var large = lgQuery.matches;
        if (open) {
          sidebar.classList.remove(closedClass);
          sidebar.dataset.state = 'open';
          sidebar.setAttribute('aria-hidden', 'false');
          toggle.setAttribute('aria-expanded', 'true');
          if (!large && backdrop) backdrop.classList.remove('hidden');
        } else {
          if (!sidebar.classList.contains(closedClass)) sidebar.classList.add(closedClass);
          sidebar.dataset.state = 'closed';
          sidebar.setAttribute('aria-hidden', 'true');
          toggle.setAttribute('aria-expanded', 'false');
          if (backdrop) backdrop.classList.add('hidden');
        }
      }

      // Initialize sidebar state based on screen size
      var prefersOpen = lgQuery.matches; // lg and up
      setSidebarOpen(prefersOpen);

      toggle.addEventListener('click', function () {
        var isClosed = sidebar.dataset.state !== 'open';
        setSidebarOpen(isClosed);
      });

      if (backdrop) {
        backdrop.addEventListener('click', function(){ setSidebarOpen(false); });
      }

      lgQuery.addEventListener('change', function(e){
        if (e.matches) {
          if (backdrop) backdrop.classList.add('hidden');
          setSidebarOpen(true); // auto-open when entering large
        } else {
          setSidebarOpen(false); // collapse leaving large
        }
      });
    });
  </script>

  

  {% block script %}{% endblock %}
  <div id="sidebar-backdrop" class="fixed top-0 bottom-0 left-0 right-0 z-30 hidden bg-black/40 backdrop-blur-sm transition-opacity duration-300"></div>
</body>

</html>""",
	r"template/paging.j2.html": r"""<div class="flex flex-col gap-3 md:flex-row md:items-center md:justify-between text-xs md:text-sm">
  <div class="hidden md:block text-gray-600 font-medium">
    {{ $t('pagination.showing') }}
    <span class="font-semibold text-gray-800">{{ (($v.page-1) * $v.pageSize)+1 if $v.total > 0 else 0 }}</span>
    {{ $t('pagination.to') }}
    <span class="font-semibold text-gray-800">{{ $v.toEnd }}</span>
    {{ $t('pagination.of') }}
    <span class="font-semibold text-gray-800">{{ $v.total }}</span>
    {{ $t('pagination.entries') }}
  </div>
  {% if($v.count > 1) %}
  <nav aria-label="Pagination" class="{{ 'md:mr-auto' if $t('dir')=='rtl' else 'md:ml-auto' }}">
    <ul class="flex items-center gap-1">
      <li>
  <a aria-label="First" class="wave group {{ 'pointer-events-none opacity-40' if $v.disableFirst else '' }} inline-flex h-8 w-8 items-center justify-center rounded-lg border border-gray-300 bg-white text-gray-600 transition-all duration-150 hover:bg-blue-50 hover:border-blue-400 hover:text-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500/30" href="?{{ $v.prefix }}={{ 1 }}{{ $v.other }}">
          <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" fill="currentColor" viewBox="0 0 16 16" style="transform: rotate({{ '180' if $t('dir')=='rtl' else '0' }}deg)">
            <path fill-rule="evenodd" d="M8.354 1.646a.5.5 0 0 1 0 .708L2.707 8l5.647 5.646a.5.5 0 0 1-.708.708l-6-6a.5.5 0 0 1 0-.708l6-6a.5.5 0 0 1 .708 0"/>
            <path fill-rule="evenodd" d="M12.354 1.646a.5.5 0 0 1 0 .708L6.707 8l5.647 5.646a.5.5 0 0 1-.708.708l-6-6a.5.5 0 0 1 0-.708l6-6a.5.5 0 0 1 .708 0"/>
          </svg>
        </a>
      </li>
      <li>
  <a aria-label="Previous" class="wave group {{ 'pointer-events-none opacity-40' if $v.disableFirst else '' }} inline-flex h-8 w-8 items-center justify-center rounded-lg border border-gray-300 bg-white text-gray-600 transition-all duration-150 hover:bg-blue-50 hover:border-blue-400 hover:text-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500/30" href="?{{ $v.prefix }}={{ $v.page - 1 }}{{ $v.other }}">
          <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" fill="currentColor" viewBox="0 0 16 16" style="transform: rotate({{ '180' if $t('dir')=='rtl' else '0' }}deg)">
            <path fill-rule="evenodd" d="M11.354 1.646a.5.5 0 0 1 0 .708L5.707 8l5.647 5.646a.5.5 0 0 1-.708.708l-6-6a.5.5 0 0 1 0-.708l6-6a.5.5 0 0 1 .708 0"/>
          </svg>
        </a>
      </li>
      {% for index in range($v.rangeFrom, $v.rangeTo + 1) %}
      {% if index > 0 and index < $v.count+1 %}
      <li>
  <a href="?{{ $v.prefix }}={{ index }}{{ $v.other }}" aria-current="{{ 'page' if (index==$v.page) else 'false' }}" class="wave inline-flex h-8 min-w-8 items-center justify-center rounded-lg border text-xs px-2 {{ 'bg-gradient-to-r from-blue-600 to-blue-700 border-blue-600 text-white font-bold shadow-md hover:from-blue-700 hover:to-blue-800' if (index==$v.page) else 'border-gray-300 bg-white text-gray-700 hover:bg-blue-50 hover:border-blue-400 hover:text-blue-700' }} focus:outline-none focus:ring-2 focus:ring-blue-500/30 transition-all duration-150">
          {{ index }}
        </a>
      </li>
      {% endif %}
      {% endfor %}
      <li>
  <a aria-label="Next" class="wave group {{ 'pointer-events-none opacity-40' if $v.disableLast else '' }} inline-flex h-8 w-8 items-center justify-center rounded-lg border border-gray-300 bg-white text-gray-600 transition-all duration-150 hover:bg-blue-50 hover:border-blue-400 hover:text-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500/30" href="?{{ $v.prefix }}={{ $v.page + 1 }}{{ $v.other }}">
          <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" fill="currentColor" viewBox="0 0 16 16" style="transform: rotate({{ '180' if $t('dir')=='rtl' else '0' }}deg)">
            <path fill-rule="evenodd" d="M4.646 1.646a.5.5 0 0 1 .708 0l6 6a.5.5 0 0 1 0 .708l-6 6a.5.5 0 0 1-.708-.708L10.293 8 4.646 2.354a.5.5 0 0 1 0-.708"/>
          </svg>
        </a>
      </li>
      <li>
  <a aria-label="Last" class="wave group {{ 'pointer-events-none opacity-40' if $v.disableLast else '' }} inline-flex h-8 w-8 items-center justify-center rounded-lg border border-gray-300 bg-white text-gray-600 transition-all duration-150 hover:bg-blue-50 hover:border-blue-400 hover:text-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500/30" href="?{{ $v.prefix }}={{ $v.count }}{{ $v.other }}">
          <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" fill="currentColor" viewBox="0 0 16 16" style="transform: rotate({{ '180' if $t('dir')=='rtl' else '0' }}deg)">
            <path fill-rule="evenodd" d="M3.646 1.646a.5.5 0 0 1 .708 0l6 6a.5.5 0 0 1 0 .708l-6 6a.5.5 0 0 1-.708-.708L9.293 8 3.646 2.354a.5.5 0 0 1 0-.708"/>
            <path fill-rule="evenodd" d="M7.646 1.646a.5.5 0 0 1 .708 0l6 6a.5.5 0 0 1 0 .708l-6 6a.5.5 0 0 1-.708-.708L13.293 8 7.646 2.354a.5.5 0 0 1 0-.708"/>
          </svg>
        </a>
      </li>
    </ul>
  </nav>
  {% endif %}
</div>
"""
};