var mapTemplates = {
	r"example/person.j2.html": r"""{% extends 'template/template.j2.html' %}
{% block title %}
  {{ $t('Example Free model DB') }}
{% endblock %}

{% block content %}
{% set isEditing = ($n('data/_id') != '') %}

<div class="space-y-6">

  {# ============== HERO ============== #}
  <section class="reveal-up relative overflow-hidden rounded-3xl border border-zinc-200 bg-gradient-to-br from-zinc-900 via-violet-950 to-fuchsia-950 p-6 sm:p-8 shadow-soft">
    <div class="pointer-events-none absolute -top-24 -end-24 h-72 w-72 rounded-full bg-violet-500/20 blur-3xl"></div>
    <div class="pointer-events-none absolute -bottom-24 -start-24 h-72 w-72 rounded-full bg-fuchsia-500/20 blur-3xl"></div>

    <div class="relative flex flex-col gap-6 lg:flex-row lg:items-center lg:justify-between">
      <div class="flex items-start gap-4">
        <div class="relative">
          <div class="inline-flex h-14 w-14 items-center justify-center rounded-2xl bg-white/10 ring-1 ring-white/20 backdrop-blur">
            <i class="fa-solid fa-user-group text-2xl text-violet-300"></i>
          </div>
          <span class="absolute -top-1 -end-1 inline-flex h-3.5 w-3.5">
            <span class="absolute inline-flex h-full w-full animate-ping rounded-full bg-fuchsia-400 opacity-75"></span>
            <span class="relative inline-flex h-3.5 w-3.5 rounded-full bg-fuchsia-400 ring-2 ring-zinc-900"></span>
          </span>
        </div>
        <div>
          <div class="flex flex-wrap items-center gap-2">
            <span class="inline-flex items-center gap-1.5 rounded-full bg-violet-500/15 px-2.5 py-1 text-[11px] font-semibold uppercase tracking-wider text-violet-300 ring-1 ring-violet-400/30">
              <i class="fa-solid fa-bolt"></i>
              Free Model
            </span>
            <span class="inline-flex items-center gap-1.5 rounded-full bg-white/5 px-2.5 py-1 text-[11px] font-medium text-zinc-300 ring-1 ring-white/10">
              <i class="fa-solid fa-database text-fuchsia-300"></i>
              Schemaless
            </span>
            <span class="inline-flex items-center gap-1.5 rounded-full bg-white/5 px-2.5 py-1 text-[11px] font-medium text-zinc-300 ring-1 ring-white/10">
              <i class="fa-solid fa-list-check text-cyan-300"></i>
              Validated
            </span>
          </div>
          <h1 class="mt-2 text-2xl font-bold text-white sm:text-3xl">{{ $t('person.example.title') }}</h1>
          <p class="mt-1 max-w-xl text-sm text-zinc-300">
            Free model database example — store persons with arbitrary fields, validated forms and inline CRUD.
          </p>
        </div>
      </div>

      {# Quick stats / actions #}
      <div class="flex flex-wrap items-stretch gap-3">
        <div class="rounded-2xl border border-white/10 bg-white/5 px-4 py-3 backdrop-blur">
          <div class="text-[10px] font-semibold uppercase tracking-wider text-zinc-400">Persons</div>
          <div class="mt-1 flex items-baseline gap-1.5">
            <span class="text-2xl font-bold text-white">{{ (allPerson | default([])) | length }}</span>
            <span class="text-[11px] text-zinc-400">/ page</span>
          </div>
        </div>
        {% if isEditing %}
        <a href="/example/persons" class="group inline-flex items-center gap-2 rounded-2xl border border-white/10 bg-white/5 px-4 py-3 text-sm font-medium text-white backdrop-blur transition hover:border-white/20 hover:bg-white/10">
          <i class="fa-solid fa-arrow-left-long transition group-hover:-translate-x-0.5"></i>
          Back to list
        </a>
        {% else %}
        <a href="#person-form" class="inline-flex items-center gap-2 rounded-2xl bg-white px-4 py-3 text-sm font-semibold text-violet-700 shadow-sm transition hover:bg-zinc-100">
          <i class="fa-solid fa-plus"></i>
          Add person
        </a>
        {% endif %}
      </div>
    </div>
  </section>

  {% if not isEditing %}
  {# ============== PERSONS LIST CARD ============== #}
  <section class="reveal-up overflow-hidden rounded-2xl border border-zinc-200 bg-white shadow-soft">
    {# Header band #}
    <div class="flex flex-wrap items-center justify-between gap-3 border-b border-zinc-200 bg-gradient-to-r from-zinc-50 to-white px-5 py-4">
      <div class="flex items-center gap-3">
        <span class="inline-flex h-10 w-10 items-center justify-center rounded-xl bg-gradient-to-br from-violet-500 to-fuchsia-600 text-white shadow-sm">
          <i class="fa-solid fa-address-book"></i>
        </span>
        <div>
          <p class="text-sm font-semibold text-zinc-800 leading-tight">{{ $t('person.example.title') }}</p>
          <p class="text-[11px] text-zinc-500">Profile · contacts · skills</p>
        </div>
      </div>
      <span class="inline-flex items-center gap-1.5 rounded-full bg-violet-50 px-2.5 py-1 text-[11px] font-semibold text-violet-700 ring-1 ring-violet-200">
        <i class="fa-solid fa-users text-[10px]"></i>
        {{ (allPerson | default([])) | length }} on this page
      </span>
    </div>

    {# Table #}
    <div class="overflow-x-auto">
      <table class="min-w-full divide-y divide-zinc-200 text-xs md:text-sm">
        <thead class="bg-zinc-50">
          <tr class="text-left">
            <th class="px-4 py-3 text-[11px] font-bold uppercase tracking-wider text-zinc-600">{{ $t('person.table.header.name') }}</th>
            <th class="px-4 py-3 text-[11px] font-bold uppercase tracking-wider text-zinc-600">{{ $t('person.table.header.age') }}</th>
            <th class="px-4 py-3 text-[11px] font-bold uppercase tracking-wider text-zinc-600">{{ $t('person.table.header.married') }}</th>
            <th class="px-4 py-3 text-[11px] font-bold uppercase tracking-wider text-zinc-600">{{ $t('person.table.header.email') }}</th>
            <th class="px-4 py-3 text-[11px] font-bold uppercase tracking-wider text-zinc-600">{{ $t('person.table.header.height') }}</th>
            <th class="px-4 py-3 text-[11px] font-bold uppercase tracking-wider text-zinc-600">{{ $t('person.table.header.birthday') }}</th>
            <th class="px-4 py-3 text-[11px] font-bold uppercase tracking-wider text-zinc-600">{{ $t('person.table.header.job') }}</th>
            <th class="px-4 py-3 text-[11px] font-bold uppercase tracking-wider text-zinc-600">{{ $t('person.table.header.skills') }}</th>
            <th class="px-4 py-3 text-end text-[11px] font-bold uppercase tracking-wider text-zinc-600">{{ $t('person.table.header.action') }}</th>
          </tr>
        </thead>
        <tbody class="divide-y divide-zinc-100 bg-white">
          {% for person in allPerson %}
          {% set initial = (person.name | default('?')) | upper | first %}
          <tr class="group transition hover:bg-violet-50/40">
            <td class="px-4 py-3 align-middle">
              <div class="flex items-center gap-3">
                <span class="relative inline-flex h-9 w-9 shrink-0 items-center justify-center rounded-full text-sm font-bold text-white shadow-sm ring-2 ring-white" style="background-color: {{ person.color }};">
                  {{ initial }}
                  <span class="absolute -bottom-0.5 -end-0.5 inline-block h-2.5 w-2.5 rounded-full ring-2 ring-white" style="background-color: {{ person.color }};"></span>
                </span>
                <div class="min-w-0">
                  <p class="truncate font-semibold text-zinc-800">{{ person.name }}</p>
                  <p class="truncate text-[11px] text-zinc-500">
                    <i class="fa-regular fa-envelope text-zinc-400"></i>
                    {{ person.email }}
                  </p>
                </div>
              </div>
            </td>
            <td class="px-4 py-3">
              <span class="inline-flex items-center gap-1.5 rounded-md bg-zinc-100 px-2 py-0.5 font-mono text-[11px] font-semibold text-zinc-700">
                {{ person.age }}
                <span class="text-[10px] font-normal text-zinc-500">yr</span>
              </span>
            </td>
            <td class="px-4 py-3">
              {% if person.married == 'yes' or person.married == true or person.married == 'true' %}
                <span class="inline-flex items-center gap-1 rounded-full bg-rose-50 px-2.5 py-1 text-[11px] font-semibold text-rose-700 ring-1 ring-rose-200">
                  <i class="fa-solid fa-heart text-[9px]"></i>
                  {{ $t('person.form.gender.dont_ask') ? $t('person.table.header.married') : 'Yes' }}
                </span>
              {% else %}
                <span class="inline-flex items-center gap-1 rounded-full bg-zinc-100 px-2.5 py-1 text-[11px] font-semibold text-zinc-600 ring-1 ring-zinc-200">
                  <i class="fa-regular fa-heart text-[9px]"></i>
                  {{ person.married | default('—') }}
                </span>
              {% endif %}
            </td>
            <td class="px-4 py-3 text-zinc-600">
              <span class="truncate">{{ person.email }}</span>
            </td>
            <td class="px-4 py-3 text-zinc-600">
              <span class="inline-flex items-center gap-1.5">
                <i class="fa-solid fa-ruler-vertical text-zinc-400"></i>
                {{ person.height }}
              </span>
            </td>
            <td class="px-4 py-3 text-zinc-600">
              <span class="inline-flex items-center gap-1.5">
                <i class="fa-regular fa-calendar text-zinc-400"></i>
                {{ person.birthday | dateFormat('dd/MM/yyyy') }}
              </span>
            </td>
            <td class="px-4 py-3">
              <span class="inline-flex items-center gap-1 rounded-full bg-cyan-50 px-2.5 py-1 text-[11px] font-medium text-cyan-700 ring-1 ring-cyan-200">
                <i class="fa-solid fa-briefcase text-[10px]"></i>
                {{ person.job.title | default('—') }}
              </span>
            </td>
            <td class="px-4 py-3">
              <span class="inline-flex items-center gap-1 rounded-full bg-violet-50 px-2.5 py-1 text-[11px] font-semibold text-violet-700 ring-1 ring-violet-200">
                <i class="fa-solid fa-bolt-lightning text-[9px]"></i>
                {{ person.jobs|length }}
              </span>
            </td>
            <td class="px-4 py-3 text-end">
              <div class="flex items-center justify-end gap-1.5">
                <a href="/example/person/{{ person._id }}" class="wave inline-flex h-8 w-8 items-center justify-center rounded-lg border border-zinc-200 bg-white text-teal-600 transition hover:border-teal-300 hover:bg-teal-50 hover:shadow-sm focus:outline-none focus:ring-2 focus:ring-teal-500/30" title="{{ $t('Edit') }}">
                  <i class="fa-solid fa-pen-to-square text-xs"></i>
                </a>
                <form onsubmit="return confirm('{{ $t('Are you sure to delete') }} `{{ person.name }}`?')" action="/example/person/delete/{{ person._id }}" method="POST" class="inline">
                  <input type="hidden" name="action" value="DELETE" />
                  <button type="submit" class="wave inline-flex h-8 w-8 items-center justify-center rounded-lg border border-zinc-200 bg-white text-rose-600 transition hover:border-rose-300 hover:bg-rose-50 hover:shadow-sm focus:outline-none focus:ring-2 focus:ring-rose-500/30" title="{{ $t('Delete') }}">
                    <i class="fa-solid fa-trash-can text-xs"></i>
                  </button>
                </form>
              </div>
            </td>
          </tr>
          {% else %}
          <tr>
            <td colspan="100%" class="px-4 py-16 text-center">
              <div class="mx-auto flex max-w-sm flex-col items-center gap-3">
                <div class="inline-flex h-16 w-16 items-center justify-center rounded-2xl bg-zinc-100 text-zinc-400">
                  <i class="fa-solid fa-user-plus text-2xl"></i>
                </div>
                <p class="text-sm font-semibold text-zinc-700">{{ $t('person.table.empty') }}</p>
                <p class="text-xs text-zinc-500">Use the form below to add your first person.</p>
              </div>
            </td>
          </tr>
          {% endfor %}
        </tbody>
        <tfoot class="border-t border-zinc-200 bg-zinc-50/60">
          <tr>
            <td colspan="100%" class="px-4 py-3 text-sm text-zinc-700">
              {{ paging }}
            </td>
          </tr>
        </tfoot>
      </table>
    </div>
  </section>
  {% endif %}

  {# ============== PERSON FORM CARD ============== #}
  <section id="person-form" class="reveal-up overflow-hidden rounded-2xl border border-zinc-200 bg-white shadow-soft">
    <div class="flex flex-wrap items-center justify-between gap-3 border-b border-zinc-200 bg-gradient-to-r from-violet-50 to-fuchsia-50 px-5 py-4">
      <div class="flex items-center gap-3">
        <span class="inline-flex h-10 w-10 items-center justify-center rounded-xl bg-gradient-to-br from-violet-500 to-fuchsia-600 text-white shadow-sm">
          <i class="fa-solid {{ 'fa-user-pen' if isEditing else 'fa-user-plus' }}"></i>
        </span>
        <div>
          <p class="text-sm font-semibold text-zinc-800 leading-tight">
            {{ 'Edit person' if isEditing else 'Add new person' }}
          </p>
          <p class="text-[11px] text-zinc-500">All fields are validated server-side</p>
        </div>
      </div>
      {% if isEditing %}
      <span class="inline-flex items-center gap-1.5 rounded-full bg-amber-50 px-2.5 py-1 text-[11px] font-semibold text-amber-700 ring-1 ring-amber-200">
        <i class="fa-solid fa-pen-to-square text-[10px]"></i>
        Editing
      </span>
      {% endif %}
    </div>
    <div class="p-5 sm:p-6">
      {% include $e.widgetPath('example/forms/form_person') %}
    </div>
  </section>
</div>
{% endblock %}
""",
	r"example/i18n.j2.html": r"""{% extends 'template/template.j2.html' %}
{% block title %}
    {{ $t('sidebar.languageExample') }}
{% endblock %}

{% block content %}
<div class="space-y-6">

  {# ============== HERO ============== #}
  <section class="reveal-up relative overflow-hidden rounded-3xl border border-zinc-200 bg-gradient-to-br from-zinc-900 via-fuchsia-950 to-purple-950 p-6 sm:p-8 shadow-soft">
    <div class="pointer-events-none absolute -top-24 -end-24 h-72 w-72 rounded-full bg-fuchsia-500/20 blur-3xl"></div>
    <div class="pointer-events-none absolute -bottom-24 -start-24 h-72 w-72 rounded-full bg-purple-500/20 blur-3xl"></div>

    <div class="relative flex flex-col gap-6 lg:flex-row lg:items-center lg:justify-between">
      <div class="flex items-start gap-4">
        <div class="relative">
          <div class="inline-flex h-14 w-14 items-center justify-center rounded-2xl bg-white/10 ring-1 ring-white/20 backdrop-blur">
            <i class="fa-solid fa-language text-2xl text-fuchsia-300"></i>
          </div>
          <span class="absolute -top-1 -end-1 inline-flex h-3.5 w-3.5">
            <span class="absolute inline-flex h-full w-full animate-ping rounded-full bg-purple-400 opacity-75"></span>
            <span class="relative inline-flex h-3.5 w-3.5 rounded-full bg-purple-400 ring-2 ring-zinc-900"></span>
          </span>
        </div>
        <div>
          <div class="flex flex-wrap items-center gap-2">
            <span class="inline-flex items-center gap-1.5 rounded-full bg-fuchsia-500/15 px-2.5 py-1 text-[11px] font-semibold uppercase tracking-wider text-fuchsia-300 ring-1 ring-fuchsia-400/30">
              <i class="fa-solid fa-globe text-[10px]"></i> i18n
            </span>
            <span class="inline-flex items-center gap-1.5 rounded-full bg-purple-500/15 px-2.5 py-1 text-[11px] font-semibold uppercase tracking-wider text-purple-300 ring-1 ring-purple-400/30">
              <i class="fa-solid fa-arrows-left-right text-[10px]"></i> RTL/LTR
            </span>
            <span class="inline-flex items-center gap-1.5 rounded-full bg-cyan-500/15 px-2.5 py-1 text-[11px] font-semibold uppercase tracking-wider text-cyan-300 ring-1 ring-cyan-400/30">
              <i class="fa-solid fa-code text-[10px]"></i> {$t} helper
            </span>
          </div>
          <h1 class="mt-2 text-2xl sm:text-3xl font-bold tracking-tight text-white">{{ $t('i18n.title') }}</h1>
          <p class="mt-1 max-w-2xl text-sm text-zinc-300">Translate any string with <span class="font-semibold text-fuchsia-300">{$t('key')}</span>, support parameters, dynamic keys, and switch the active language on the fly.</p>
        </div>
      </div>

      <div class="flex flex-col gap-3 sm:flex-row lg:flex-col lg:items-end">
        {# ---- Language Dropdown ---- #}
        <details class="group relative w-full sm:w-auto">
          <summary class="list-none inline-flex w-full cursor-pointer select-none items-center justify-between gap-3 rounded-2xl border border-white/15 bg-white/10 px-4 py-3 text-sm font-semibold text-white shadow-soft backdrop-blur transition hover:bg-white/15 focus:outline-none focus:ring-4 focus:ring-fuchsia-400/30 sm:w-64">
            <span class="flex items-center gap-2.5">
              {% for key, language in languages %}
                {% if $e.ln == key %}
                <img src="{{ language.flag }}" class="h-5 w-7 shrink-0 rounded-sm object-cover ring-1 ring-white/30"/>
                <span class="truncate">{{ language.name }}</span>
                {% endif %}
              {% endfor %}
            </span>
            <span class="flex items-center gap-2">
              <span class="rounded-md bg-fuchsia-500/20 px-2 py-0.5 font-mono text-[10px] uppercase tracking-wider text-fuchsia-200 ring-1 ring-fuchsia-400/30">{{ $e.ln }}</span>
              <i class="fa-solid fa-chevron-down text-xs text-zinc-300 transition-transform duration-200 group-open:rotate-180"></i>
            </span>
          </summary>
          <ul class="absolute end-0 z-30 mt-2 w-full max-h-80 min-w-[16rem] overflow-y-auto rounded-2xl border border-zinc-200 bg-white p-1.5 shadow-soft-lg sm:w-72">
            {% for key, language in languages %}
            <li>
              <a href="{{ $e.urlToLanguage(key) }}" class="wave flex items-center gap-3 rounded-lg px-3 py-2.5 text-sm transition-all duration-150 {{ 'bg-gradient-to-r from-fuchsia-500 to-purple-600 text-white shadow-sm' if $e.ln == key else 'text-zinc-700 hover:bg-fuchsia-50 hover:text-fuchsia-700' }}">
                <img src="{{ language.flag }}" class="h-5 w-7 shrink-0 rounded-sm object-cover ring-1 {{ 'ring-white/40' if $e.ln == key else 'ring-zinc-200' }}"/>
                <span class="flex-1 truncate font-medium">{{ language.name }}</span>
                <span class="font-mono text-[10px] uppercase {{ 'text-white/80' if $e.ln == key else 'text-zinc-400' }}">{{ key }}</span>
                {% if $e.ln == key %}<i class="fa-solid fa-circle-check text-xs text-white"></i>{% endif %}
              </a>
            </li>
            {% endfor %}
          </ul>
        </details>

        {# ---- Stat Cards ---- #}
        <div class="grid grid-cols-2 gap-3 sm:gap-4">
          <div class="rounded-2xl border border-white/10 bg-white/5 p-3 sm:p-4 text-center backdrop-blur">
            <div class="text-[10px] uppercase tracking-wider text-zinc-400">Languages</div>
            <div class="mt-1 text-2xl font-bold text-white">{{ languages | length }}</div>
          </div>
          <div class="rounded-2xl border border-white/10 bg-white/5 p-3 sm:p-4 text-center backdrop-blur">
            <div class="text-[10px] uppercase tracking-wider text-zinc-400">Active</div>
            <div class="mt-1 flex items-center justify-center gap-1.5 text-base sm:text-lg font-bold text-white">
              <i class="fa-solid fa-circle text-[10px] text-fuchsia-400 animate-pulse"></i>
              <span class="font-mono uppercase">{{ $e.ln }}</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  </section>

  {# ============== LANGUAGE PICKER ============== #}
  <section class="reveal-up overflow-hidden rounded-2xl border border-zinc-200 bg-white shadow-soft">
    <div class="flex items-center justify-between gap-3 bg-gradient-to-r from-fuchsia-50 to-purple-50 px-5 py-4 border-b border-zinc-200">
      <div class="flex items-center gap-3">
        <span class="grid h-10 w-10 place-items-center rounded-xl bg-gradient-to-br from-fuchsia-500 to-purple-600 text-white shadow-sm ring-1 ring-fuchsia-300/50">
          <i class="fa-solid fa-earth-americas text-sm"></i>
        </span>
        <div>
          <h3 class="text-base font-bold text-zinc-900">Choose a language</h3>
          <p class="text-xs text-zinc-500">Click any flag to switch the active locale</p>
        </div>
      </div>
      <span class="hidden sm:inline-flex items-center gap-1.5 rounded-full bg-fuchsia-100 px-2.5 py-1 text-[10px] font-semibold uppercase tracking-wider text-fuchsia-800 ring-1 ring-fuchsia-200">
        <i class="fa-solid fa-flag text-[9px]"></i> {{ $e.ln }}
      </span>
    </div>
    <div class="grid grid-cols-2 gap-2 p-4 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-6">
      {% for key, language in languages %}
      <a href="{{ $e.urlToLanguage(key) }}" class="wave group relative flex items-center gap-2.5 rounded-xl border px-3 py-2.5 text-sm transition-all duration-200 {{ 'border-fuchsia-400 bg-gradient-to-r from-fuchsia-500 to-purple-600 text-white shadow-soft' if $e.ln == key else 'border-zinc-200 bg-white text-zinc-700 hover:border-fuchsia-300 hover:bg-fuchsia-50 hover:shadow-sm' }}">
        <img src="{{ language.flag }}" class="h-5 w-7 shrink-0 rounded-sm object-cover ring-1 {{ 'ring-white/40' if $e.ln == key else 'ring-zinc-200' }}"/>
        <span class="truncate font-medium">{{ language.name }}</span>
        {% if $e.ln == key %}
        <i class="fa-solid fa-circle-check ml-auto text-xs text-white"></i>
        {% endif %}
      </a>
      {% endfor %}
    </div>
  </section>

  {# ============== TRANSLATION EXAMPLES ============== #}
  <section class="reveal-up overflow-hidden rounded-2xl border border-zinc-200 bg-white shadow-soft">
    <div class="flex items-center justify-between gap-3 bg-gradient-to-r from-zinc-50 to-white px-5 py-4 border-b border-zinc-200">
      <div class="flex items-center gap-3">
        <span class="grid h-10 w-10 place-items-center rounded-xl bg-gradient-to-br from-fuchsia-500 to-purple-600 text-white shadow-sm ring-1 ring-fuchsia-300/50">
          <i class="fa-solid fa-quote-left text-sm"></i>
        </span>
        <div>
          <h3 class="text-base font-bold text-zinc-900">Translation examples</h3>
          <p class="text-xs text-zinc-500">Same template, six different ways to call <code class="rounded bg-zinc-100 px-1 text-[11px] text-fuchsia-700">$t()</code></p>
        </div>
      </div>
    </div>
    <div class="grid gap-3 p-5 md:grid-cols-2">
      {# ----- 1 ----- #}
      <div class="group flex items-start gap-3 rounded-xl border border-zinc-200 bg-gradient-to-br from-white to-fuchsia-50/30 p-4 transition hover:border-fuchsia-300 hover:shadow-sm">
        <span class="grid h-9 w-9 shrink-0 place-items-center rounded-xl bg-gradient-to-br from-fuchsia-500 to-purple-600 text-white shadow-sm">
          <i class="fa-solid fa-1 text-xs font-bold"></i>
        </span>
        <div class="min-w-0 flex-1">
          <p class="mb-1 text-[10px] font-bold uppercase tracking-wider text-fuchsia-700">Plain string</p>
          <p class="text-sm font-medium text-zinc-800">{{ $t('i18n.exampleTString') }}</p>
        </div>
      </div>
      {# ----- 2 ----- #}
      <div class="group flex items-start gap-3 rounded-xl border border-zinc-200 bg-gradient-to-br from-white to-purple-50/30 p-4 transition hover:border-purple-300 hover:shadow-sm">
        <span class="grid h-9 w-9 shrink-0 place-items-center rounded-xl bg-gradient-to-br from-purple-500 to-fuchsia-600 text-white shadow-sm">
          <i class="fa-solid fa-2 text-xs font-bold"></i>
        </span>
        <div class="min-w-0 flex-1">
          <p class="mb-1 text-[10px] font-bold uppercase tracking-wider text-purple-700">Nested path</p>
          <p class="text-sm font-medium text-zinc-800">{{ $t('i18n.examplePath') }}</p>
        </div>
      </div>
      {# ----- 3 ----- #}
      <div class="group flex items-start gap-3 rounded-xl border border-zinc-200 bg-gradient-to-br from-white to-fuchsia-50/30 p-4 transition hover:border-fuchsia-300 hover:shadow-sm">
        <span class="grid h-9 w-9 shrink-0 place-items-center rounded-xl bg-gradient-to-br from-fuchsia-500 to-purple-600 text-white shadow-sm">
          <i class="fa-solid fa-3 text-xs font-bold"></i>
        </span>
        <div class="min-w-0 flex-1">
          <p class="mb-1 text-[10px] font-bold uppercase tracking-wider text-fuchsia-700">Path string</p>
          <p class="text-sm font-medium text-zinc-800">{{ $t('i18n.examplePathString') }}</p>
        </div>
      </div>
      {# ----- 4 ----- #}
      <div class="group flex items-start gap-3 rounded-xl border border-zinc-200 bg-gradient-to-br from-white to-purple-50/30 p-4 transition hover:border-purple-300 hover:shadow-sm">
        <span class="grid h-9 w-9 shrink-0 place-items-center rounded-xl bg-gradient-to-br from-purple-500 to-fuchsia-600 text-white shadow-sm">
          <i class="fa-solid fa-4 text-xs font-bold"></i>
        </span>
        <div class="min-w-0 flex-1">
          <p class="mb-1 text-[10px] font-bold uppercase tracking-wider text-purple-700">Params (raw)</p>
          <p class="text-sm font-medium text-zinc-800">{{ $t('example.params') }}</p>
        </div>
      </div>
      {# ----- 5 ----- #}
      <div class="group flex items-start gap-3 rounded-xl border border-zinc-200 bg-gradient-to-br from-white to-cyan-50/30 p-4 transition hover:border-cyan-300 hover:shadow-sm">
        <span class="grid h-9 w-9 shrink-0 place-items-center rounded-xl bg-gradient-to-br from-cyan-500 to-fuchsia-500 text-white shadow-sm">
          <i class="fa-solid fa-5 text-xs font-bold"></i>
        </span>
        <div class="min-w-0 flex-1">
          <p class="mb-1 flex items-center gap-1.5 text-[10px] font-bold uppercase tracking-wider text-cyan-700">
            Params (with values)
            <span class="rounded bg-cyan-100 px-1 py-0.5 text-[9px] font-mono text-cyan-800">name=Jack, age=20</span>
          </p>
          <p class="text-sm font-medium text-zinc-800">{{ $t('i18n.exampleParams', {'name': 'Jack', 'age': 20}) }}</p>
        </div>
      </div>
      {# ----- 6 ----- #}
      <div class="group flex items-start gap-3 rounded-xl border border-zinc-200 bg-gradient-to-br from-white to-amber-50/30 p-4 transition hover:border-amber-300 hover:shadow-sm">
        <span class="grid h-9 w-9 shrink-0 place-items-center rounded-xl bg-gradient-to-br from-amber-500 to-orange-500 text-white shadow-sm">
          <i class="fa-solid fa-6 text-xs font-bold"></i>
        </span>
        <div class="min-w-0 flex-1">
          <p class="mb-1 flex items-center gap-1.5 text-[10px] font-bold uppercase tracking-wider text-amber-700">
            Dynamic key
            <i class="fa-solid fa-wand-magic-sparkles text-[10px]"></i>
          </p>
          <p class="text-sm font-medium text-zinc-800">{{ $t(exampleTranslateDynamic) }}</p>
        </div>
      </div>
    </div>
  </section>

  {# ============== FILE REFERENCES ============== #}
  <section class="reveal-up overflow-hidden rounded-2xl border border-zinc-200 bg-white shadow-soft">
    <div class="flex items-center gap-3 bg-gradient-to-r from-zinc-50 to-white px-5 py-4 border-b border-zinc-200">
      <span class="grid h-10 w-10 place-items-center rounded-xl bg-gradient-to-br from-zinc-700 to-zinc-900 text-white shadow-sm ring-1 ring-zinc-300/50">
        <i class="fa-solid fa-folder-tree text-sm"></i>
      </span>
      <div>
        <h3 class="text-base font-bold text-zinc-900">File References</h3>
        <p class="text-xs text-zinc-500">Where i18n is wired up</p>
      </div>
    </div>
    <ul class="divide-y divide-zinc-100">
      <li class="group transition-colors duration-150 hover:bg-fuchsia-50/50">
        <div class="flex flex-col gap-3 px-5 py-3.5 md:flex-row md:items-center md:gap-4">
          <div class="flex items-center gap-2.5 md:w-56">
            <span class="grid h-8 w-8 place-items-center rounded-lg bg-fuchsia-100 text-fuchsia-600 ring-1 ring-fuchsia-200">
              <i class="fa-regular fa-eye text-xs"></i>
            </span>
            <span class="text-sm font-semibold text-zinc-700">{{ $t('i18n.view') }}</span>
          </div>
          <code class="break-all rounded-md bg-zinc-100 px-3 py-1.5 text-xs font-mono text-fuchsia-700 ring-1 ring-zinc-200 group-hover:bg-fuchsia-100 group-hover:ring-fuchsia-200">example/lib/widgets/example/i18n.j2.html</code>
        </div>
      </li>
      <li class="group transition-colors duration-150 hover:bg-fuchsia-50/50">
        <div class="flex flex-col gap-3 px-5 py-3.5 md:flex-row md:items-center md:gap-4">
          <div class="flex items-center gap-2.5 md:w-56">
            <span class="grid h-8 w-8 place-items-center rounded-lg bg-purple-100 text-purple-700 ring-1 ring-purple-200">
              <i class="fa-solid fa-code text-xs"></i>
            </span>
            <span class="text-sm font-semibold text-zinc-700">{{ $t('i18n.controller') }}</span>
          </div>
          <code class="break-all rounded-md bg-zinc-100 px-3 py-1.5 text-xs font-mono text-purple-700 ring-1 ring-zinc-200 group-hover:bg-purple-100 group-hover:ring-purple-200">example/lib/controllers/home_controller.dart</code>
        </div>
      </li>
      <li class="group transition-colors duration-150 hover:bg-fuchsia-50/50">
        <div class="flex flex-col gap-3 px-5 py-3.5 md:flex-row md:items-center md:gap-4">
          <div class="flex items-center gap-2.5 md:w-56">
            <span class="grid h-8 w-8 place-items-center rounded-lg bg-amber-100 text-amber-700 ring-1 ring-amber-200">
              <i class="fa-solid fa-folder-open text-xs"></i>
            </span>
            <span class="text-sm font-semibold text-zinc-700">{{ $t('i18n.languagesDirectory') }}</span>
          </div>
          <code class="break-all rounded-md bg-zinc-100 px-3 py-1.5 text-xs font-mono text-amber-800 ring-1 ring-zinc-200 group-hover:bg-amber-100 group-hover:ring-amber-200">example/lib/languages</code>
        </div>
      </li>
    </ul>
  </section>
</div>
{% endblock %}
""",
	r"example/forms/form_person.j2.html": r"""<form method="POST" action="/example/person/{{ $n('data/_id') | oid ?? '' }}" class="space-y-6">
  <input type="hidden" name="action" value="{{ $n('data/_id') ? 'EDIT' : 'ADD' }}" />
  <input type="hidden" name="id" value="{{ $n('data/_id') | oid ?? '' }}" />

  <!-- Row 1: Name / Email -->
  <div class="grid gap-5 md:grid-cols-2">
    <div>
      <label for="name" class="mb-2 block text-sm font-semibold text-zinc-700">{{ $t('person.form.label.name') }}</label>
      <div class="relative">
        <div class="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-3">
          <i class="fas fa-user text-zinc-400 text-sm"></i>
        </div>
        <input
          type="text"
          id="name"
          name="name"
          value="{{ $n('form/name/value') }}"
          placeholder="{{ $t('person.form.placeholder.name') }}"
          class="h-12 w-full rounded-lg border border-zinc-300 bg-white pl-10 pr-4 text-sm shadow-sm transition-all duration-200 focus:border-teal-500 focus:ring-4 focus:ring-teal-500/20 {{ $n('form/name/failed') ? 'border-rose-500 ring-4 ring-rose-500/20 focus:border-rose-500 focus:ring-rose-500/20' : '' }}"
        />
      </div>
      <div class="mt-1.5 flex items-center gap-1.5 text-xs text-rose-700 {{ $n('form/name/failed') ? '' : 'hidden' }}">{{ $t($n('form/name/errors/0')) }}</div>
    </div>
    <div>
      <label for="email" class="mb-2 block text-sm font-semibold text-zinc-700">{{ $t('person.form.label.email') }}</label>
      <div class="relative">
        <div class="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-3">
          <i class="fas fa-envelope text-zinc-400 text-sm"></i>
        </div>
        <input
          type="email"
          id="email"
          name="email"
          value="{{ $n('form/email/value') }}"
          placeholder="{{ $t('person.form.placeholder.email') }}"
          {{ $n('data/_id') ? 'readonly disabled' : '' }}
          class="h-12 w-full rounded-lg border border-zinc-300 bg-white pl-10 pr-4 text-sm shadow-sm transition-all duration-200 focus:border-teal-500 focus:ring-4 focus:ring-teal-500/20 {{ $n('data/_id') ? 'opacity-60 cursor-not-allowed' : '' }} {{ $n('form/email/failed') ? 'border-rose-500 ring-4 ring-rose-500/20 focus:border-rose-500 focus:ring-rose-500/20' : '' }}"
        />
      </div>
      <div class="mt-1.5 flex items-center gap-1.5 text-xs text-rose-700 {{ $n('form/email/failed') ? '' : 'hidden' }}">{{ $t($n('form/email/errors/0')) }}</div>
    </div>
  </div>

  <!-- Row 2: Age / Birthday -->
  <div class="grid gap-5 md:grid-cols-2">
    <div>
      <label for="age" class="mb-2 block text-sm font-semibold text-zinc-700">{{ $t('person.form.label.age') }}</label>
      <div class="relative">
        <div class="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-3">
          <i class="fas fa-calendar-alt text-zinc-400 text-sm"></i>
        </div>
        <input
          type="number"
          id="age"
          name="age"
          value="{{ $n('form/age/value') }}"
          placeholder="{{ $t('person.form.placeholder.age') }}"
          class="h-12 w-full rounded-lg border border-zinc-300 bg-white pl-10 pr-4 text-sm shadow-sm transition-all duration-200 focus:border-teal-500 focus:ring-4 focus:ring-teal-500/20 {{ $n('form/age/failed') ? 'border-rose-500 ring-4 ring-rose-500/20 focus:border-rose-500 focus:ring-rose-500/20' : '' }}"
        />
      </div>
      <div class="mt-1.5 flex items-center gap-1.5 text-xs text-rose-700 {{ $n('form/age/failed') ? '' : 'hidden' }}">{{ $t($n('form/age/errors/0')) }}</div>
    </div>
    <div>
      <label for="birthday" class="mb-2 block text-sm font-semibold text-zinc-700">{{ $t('person.form.label.birthday') }}</label>
      <div class="relative">
        <div class="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-3">
          <i class="fas fa-calendar-alt text-zinc-400 text-sm"></i>
        </div>
        <input
          type="datetime-local"
          id="birthday"
          name="birthday"
          value="{{ $n('form/birthday/value') ? $n('form/birthday/value') | dateFormat('yyyy-MM-ddThh:mm') : '1977-01-01T00:00' }}"
          {{ $n('data/_id') ? 'readonly disabled' : '' }}
          class="h-12 w-full rounded-lg border border-zinc-300 bg-white pl-10 pr-4 text-sm shadow-sm transition-all duration-200 focus:border-teal-500 focus:ring-4 focus:ring-teal-500/20 {{ $n('data/_id') ? 'opacity-60 cursor-not-allowed' : '' }} {{ $n('form/birthday/failed') ? 'border-rose-500 ring-4 ring-rose-500/20 focus:border-rose-500 focus:ring-rose-500/20' : '' }}"
        />
      </div>
      <div class="mt-1.5 flex items-center gap-1.5 text-xs text-rose-700 {{ $n('form/birthday/failed') ? '' : 'hidden' }}">{{ $t($n('form/birthday/errors/0')) }}</div>
    </div>
  </div>

  <!-- Row 3: Height / Job Title -->
  <div class="grid gap-5 md:grid-cols-2">
    <div>
      <label for="height" class="mb-2 block text-sm font-semibold text-zinc-700">{{ $t('person.form.label.height') }}</label>
      <input
        type="number"
        step="0.1"
        id="height"
        name="height"
        value="{{ $n('form/height/value') }}"
        placeholder="{{ $t('person.form.placeholder.height') }}"
        class="h-12 w-full rounded-lg border border-zinc-300 bg-white px-4 text-sm shadow-sm transition-all duration-200 focus:border-teal-500 focus:ring-4 focus:ring-teal-500/20 {{ $n('form/height/failed') ? 'border-rose-500 ring-4 ring-rose-500/20 focus:border-rose-500 focus:ring-rose-500/20' : '' }}"
      />
      <div class="mt-1.5 flex items-center gap-1.5 text-xs text-rose-700 {{ $n('form/height/failed') ? '' : 'hidden' }}">{{ $t($n('form/height/errors/0')) }}</div>
    </div>
    <div>
      <label for="job_id" class="mb-2 block text-sm font-semibold text-zinc-700">{{ $t('person.form.label.job_title') }}</label>
      <select
        id="job_id"
        name="job_id"
        class="h-12 w-full rounded-lg border border-zinc-300 bg-white px-4 text-sm shadow-sm transition-all duration-200 focus:border-teal-500 focus:ring-4 focus:ring-teal-500/20 {{ $n('form/job_id/failed') ? 'border-rose-500 ring-4 ring-rose-500/20 focus:border-rose-500 focus:ring-rose-500/20' : '' }}"
      >
        <option value="">{{ $t('person.form.option.select_job') }}</option>
        {% for job in jobs %}
          <option {{ 'selected' if $n('form/job_id/value')|oid == job._id else '' }} value="{{ job._id }}">{{ job.title }}</option>
        {% endfor %}
      </select>
      <div class="mt-1.5 flex items-center gap-1.5 text-xs text-rose-700 {{ $n('form/job_id/failed') ? '' : 'hidden' }}">{{ $t($n('form/job_id/errors/0')) }}</div>
    </div>
  </div>

  <!-- Row 4: Skills -->
  <div>
    <label class="mb-2 block text-sm font-semibold text-zinc-700">{{ $t('person.form.label.skills') }}</label>
    {% set oids = $n('form/jobs/value') | oid %}
    <div class="grid gap-3 sm:grid-cols-2 md:grid-cols-3">
      {% for job in jobs %}
      <label for="jobs_{{ job._id }}" class="flex items-center gap-3 rounded-lg border border-zinc-300 bg-white px-4 py-3 text-sm font-medium text-zinc-700 shadow-sm transition-all duration-150 hover:border-teal-400 hover:bg-teal-50 cursor-pointer">
        <input
          type="checkbox"
          id="jobs_{{ job._id }}"
          name="jobs[]"
          value="{{ job._id | oid }}"
          class="h-5 w-5 rounded border-zinc-300 text-teal-600 transition-all duration-200 focus:ring-4 focus:ring-teal-500/20"
          {{ 'checked' if ((job._id) in oids) else '' }}
        />
        <span class="truncate">{{ job.title }}</span>
      </label>
      {% endfor %}
    </div>
    <div class="mt-1.5 flex items-center gap-1.5 text-xs text-rose-700 {{ $n('form/jobs/failed') ? '' : 'hidden' }}">{{ $t($n('form/jobs/errors/0')) }}</div>
  </div>

  <!-- Row 5: Password / Gender -->
  <div class="grid gap-5 md:grid-cols-2">
    <div>
      <label for="password" class="mb-2 block text-sm font-semibold text-zinc-700">{{ $t('person.form.label.password') }}</label>
      <div class="relative">
        <div class="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-3">
          <i class="fas fa-lock text-zinc-400 text-sm"></i>
        </div>
        <input
          type="password"
          id="password"
          name="password"
          value="{{ $n('form/password/value') }}"
          placeholder="{{ $t('person.form.placeholder.password') }}"
          {{ $n('data/_id') ? 'readonly disabled' : '' }}
          class="h-12 w-full rounded-lg border border-zinc-300 bg-white pl-10 pr-4 text-sm shadow-sm transition-all duration-200 focus:border-teal-500 focus:ring-4 focus:ring-teal-500/20 {{ $n('data/_id') ? 'opacity-60 cursor-not-allowed' : '' }} {{ $n('form/password/failed') ? 'border-rose-500 ring-4 ring-rose-500/20 focus:border-rose-500 focus:ring-rose-500/20' : '' }}"
        />
      </div>
      <div class="mt-1.5 flex items-center gap-1.5 text-xs text-rose-700 {{ $n('form/password/failed') ? '' : 'hidden' }}">{{ $t($n('form/password/errors/0')) }}</div>
    </div>
    <div>
      <label for="gender" class="mb-2 block text-sm font-semibold text-zinc-700">{{ $t('person.form.label.gender') }}</label>
      <select
        id="gender"
        name="gender"
        class="h-12 w-full rounded-lg border border-zinc-300 bg-white px-4 text-sm shadow-sm transition-all duration-200 focus:border-teal-500 focus:ring-4 focus:ring-teal-500/20 {{ $n('form/gender/failed') ? 'border-rose-500 ring-4 ring-rose-500/20 focus:border-rose-500 focus:ring-rose-500/20' : '' }}"
      >
        <option {{ $n('form/gender/value') == 'none' ? 'selected' : '' }} value="none">{{ $t('person.form.gender.dont_ask') }}</option>
        <option {{ $n('form/gender/value') == 'male' ? 'selected' : '' }} value="male">{{ $t('person.form.gender.male') }}</option>
        <option {{ $n('form/gender/value') == 'female' ? 'selected' : '' }} value="female">{{ $t('person.form.gender.female') }}</option>
        <option {{ $n('form/gender/value') == 'other' ? 'selected' : '' }} value="other">{{ $t('person.form.gender.other') }}</option>
      </select>
      <div class="mt-1.5 flex items-center gap-1.5 text-xs text-rose-700 {{ '' if $n('form/gender/failed') else 'hidden' }}">{{ $t($n('form/gender/errors/0')) }}</div>
    </div>
  </div>

  <!-- Row 6: Married / Color -->
  <div class="grid gap-6 md:grid-cols-2">
    <div>
      <label for="married" class="mb-1 block text-sm font-medium text-zinc-700">{{ $t('person.form.label.married') }}</label>
      <input name="married" type="hidden" value="false" />
      <label class="relative inline-flex cursor-pointer items-center">
        <input name="married" id="married" type="checkbox" value="true" class="peer sr-only" {{ 'checked' if $n('form/married/value') else '' }} />
        <div class="h-5 w-9 rounded-full bg-zinc-300 transition peer-checked:bg-blue-600"></div>
        <div class="absolute left-0 top-0 h-5 w-5 translate-x-0 rounded-full bg-white shadow transition peer-checked:translate-x-4"></div>
      </label>
    </div>
    <div>
      <label for="color" class="mb-1 block text-sm font-medium text-zinc-700">{{ $t('person.form.label.color') }}</label>
      <input type="color" id="color" name="color" value="{{ $n('form/color/value','#FF0055') }}" title="{{ $t('person.form.tooltip.color') }}" class="h-10 w-24 cursor-pointer rounded-md border border-zinc-300 bg-white p-1 shadow-sm focus:border-blue-500 focus:ring-2 focus:ring-blue-500/30" />
    </div>
  </div>

  <!-- Actions -->
  <div class="flex flex-wrap gap-3 border-t border-zinc-200 pt-4">
    <button type="submit" class="wave inline-flex items-center rounded-md bg-blue-600 px-5 py-2.5 text-sm font-medium text-white shadow-sm hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500/30">{{ $t('person.form.button.submit') }}</button>
    {% if $n('data/_id') %}
    <a href="{{ $e.url('/example/person') }}" class="wave inline-flex items-center rounded-md border border-zinc-300 bg-white px-5 py-2.5 text-sm font-medium text-zinc-700 shadow-sm hover:bg-zinc-50 focus:outline-none focus:ring-2 focus:ring-blue-500/30">{{ $t('person.form.button.cancel') }}</a>
    {% endif %}
  </div>
</form>""",
	r"example/forms/form_login.j2.html": r"""<form action="{{ $e.routeUrl('root.form.post') }}" method="post">
  <!-- CSRF Token -->
  <input
    type="hidden"
    name="token"
    value="{{ $n('form_login/token/value') }}"
  />
  {% if $n('form_login/token/failed') %}
  <div class="mt-2 mb-4 flex items-start gap-2 text-sm text-rose-700">
    <i class="fas fa-exclamation-circle"></i>
    <span>{{ $t($n('form_login/token/errors/0')) }}</span>
  </div>
  {% endif %}
  <!-- Email Field -->
  <div>
    <label for="email" class="mb-2 block text-sm font-semibold text-zinc-700"
      >{{ $t('form.validation.email') }}</label
    >
    <div class="relative">
      <div
        class="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-3"
      >
        <i class="fas fa-envelope text-zinc-400"></i>
      </div>
      <input
        value="{{ $n('form_login/email/value') }}"
        type="email"
        name="email"
        id="email"
        placeholder="{{ $t('form.validation.emailPlaceholder') }}"
        class="block h-12 w-full rounded-lg border pl-10 pr-3 text-sm shadow-sm transition-all duration-200 {{ 'border-rose-500 bg-rose-50 text-rose-900 placeholder-rose-400 focus:border-rose-600 focus:ring-4 focus:ring-rose-500/30' if $n('form_login/email/failed') else 'border-zinc-300 bg-white text-zinc-900 focus:border-teal-500 focus:ring-4 focus:ring-teal-500/20' }}"
      />
    </div>
    {% if $n('form_login/email/failed') %}
    <div class="mt-2 mb-4 flex items-start gap-2 text-sm text-rose-700">
      <i class="fas fa-exclamation-circle"></i>
      <span>{{ $t($n('form_login/email/errors/0')) }}</span>
    </div>
    {% endif %}
  </div>

  <!-- Password Field -->
  <div>
    <label for="password" class="mb-2 block text-sm font-semibold text-zinc-700"
      >{{ $t('form.validation.password') }}</label
    >
    <div class="relative">
      <div
        class="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-3"
      >
        <i class="fas fa-lock text-zinc-400"></i>
      </div>
      <input
        value="{{ $n('form_login/password/value') }}"
        type="password"
        name="password"
        id="password"
        placeholder="{{ $t('form.validation.passwordPlaceholder') }}"
        class="block mb-4  h-12 w-full rounded-lg border pl-10 pr-3 text-sm shadow-sm transition-all duration-200 {{ 'border-rose-500 bg-rose-50 text-rose-900 placeholder-rose-400 focus:border-rose-600 focus:ring-4 focus:ring-rose-500/30' if $n('form_login/password/failed') else 'border-zinc-300 bg-white text-zinc-900 focus:border-teal-500 focus:ring-4 focus:ring-teal-500/20' }}"
      />
    </div>
    {% if $n('form_login/password/failed') %}
    <div class="mb-4 flex items-start gap-2 text-sm text-rose-700">
      <i class="fas fa-exclamation-circle"></i>
      <span>{{ $t($n('form_login/password/errors/0')) }}</span>
    </div>
    {% endif %}
  </div>

  <!-- Submit Button -->
  <button
    type="submit"
    class="wave group inline-flex w-full items-center justify-center gap-2 rounded-lg bg-gradient-to-r from-teal-600 to-cyan-700 px-6 py-3 text-sm font-semibold text-white shadow-sm transition-all duration-200 hover:from-teal-700 hover:to-cyan-800 hover:shadow-xl focus:outline-none focus:ring-4 focus:ring-teal-500/30"
  >
    <i class="fas fa-sign-in-alt text-white"></i>
    <span>{{ $t('form.validation.login') }}</span>
  </button>

  {% if errorLogin %}
  <div
    class="mt-4 flex items-start gap-3 rounded-lg border border-rose-300 bg-rose-50 p-4 shadow-sm"
  >
    <i class="fas fa-exclamation-circle text-rose-600"></i>
    <span class="text-sm font-medium text-rose-800">{{ errorLogin }}</span>
  </div>
  {% endif %}
</form>
""",
	r"example/database.j2.html": r"""{% extends 'template/template.j2.html' %}
{% block title %}
  {{ $t('sidebar.mongo') }}
{% endblock %}

{% block content %}
<div class="space-y-6">

  {# ============== HERO ============== #}
  <section class="reveal-up relative overflow-hidden rounded-3xl border border-zinc-200 bg-gradient-to-br from-zinc-900 via-emerald-950 to-green-950 p-6 sm:p-8 shadow-soft">
    <div class="pointer-events-none absolute -top-24 -end-24 h-72 w-72 rounded-full bg-emerald-500/20 blur-3xl"></div>
    <div class="pointer-events-none absolute -bottom-24 -start-24 h-72 w-72 rounded-full bg-green-500/20 blur-3xl"></div>

    <div class="relative flex flex-col gap-6 lg:flex-row lg:items-center lg:justify-between">
      <div class="flex items-start gap-4">
        <div class="relative">
          <div class="inline-flex h-14 w-14 items-center justify-center rounded-2xl bg-white/10 ring-1 ring-white/20 backdrop-blur">
            <i class="fa-solid fa-leaf text-2xl text-emerald-300"></i>
          </div>
          <span class="absolute -top-1 -end-1 inline-flex h-3.5 w-3.5">
            <span class="absolute inline-flex h-full w-full animate-ping rounded-full bg-green-400 opacity-75"></span>
            <span class="relative inline-flex h-3.5 w-3.5 rounded-full bg-green-400 ring-2 ring-zinc-900"></span>
          </span>
        </div>
        <div>
          <div class="flex flex-wrap items-center gap-2">
            <span class="inline-flex items-center gap-1.5 rounded-full bg-emerald-500/15 px-2.5 py-1 text-[11px] font-semibold uppercase tracking-wider text-emerald-300 ring-1 ring-emerald-400/30">
              <i class="fa-solid fa-bolt"></i>
              MongoDB
            </span>
            <span class="inline-flex items-center gap-1.5 rounded-full bg-white/5 px-2.5 py-1 text-[11px] font-medium text-zinc-300 ring-1 ring-white/10">
              <i class="fa-solid fa-cubes text-green-300"></i>
              Document
            </span>
            <span class="inline-flex items-center gap-1.5 rounded-full bg-white/5 px-2.5 py-1 text-[11px] font-medium text-zinc-300 ring-1 ring-white/10">
              <i class="fa-solid fa-code text-cyan-300"></i>
              NoSQL
            </span>
          </div>
          <h1 class="mt-2 text-2xl font-bold text-white sm:text-3xl">{{ $t('database.test.title') }}</h1>
          <p class="mt-1 max-w-xl text-sm text-zinc-300">
            MongoDB example with CRUD operations — flexible, schemaless documents with title and auto-generated slug.
          </p>
        </div>
      </div>

      {# Quick stats #}
      <div class="grid grid-cols-2 gap-3 sm:flex sm:items-stretch">
        <div class="rounded-2xl border border-white/10 bg-white/5 px-4 py-3 backdrop-blur">
          <div class="text-[10px] font-semibold uppercase tracking-wider text-zinc-400">Records</div>
          <div class="mt-1 flex items-baseline gap-1.5">
            <span class="text-2xl font-bold text-white">{{ (allRecords | default([])) | length }}</span>
            <span class="text-[11px] text-zinc-400">/ page</span>
          </div>
        </div>
        <div class="rounded-2xl border border-white/10 bg-white/5 px-4 py-3 backdrop-blur">
          <div class="text-[10px] font-semibold uppercase tracking-wider text-zinc-400">Page</div>
          <div class="mt-1 flex items-baseline gap-1.5">
            <span class="text-2xl font-bold text-white">{{ data.page if data.page else 1 }}</span>
          </div>
        </div>
      </div>
    </div>
  </section>

  {# ============== RECORDS CARD ============== #}
  <section class="reveal-up overflow-hidden rounded-2xl border border-zinc-200 bg-white shadow-soft">
    {# Header band #}
    <div class="flex flex-wrap items-center justify-between gap-3 border-b border-zinc-200 bg-gradient-to-r from-zinc-50 to-white px-5 py-4">
      <div class="flex items-center gap-3">
        <span class="inline-flex h-10 w-10 items-center justify-center rounded-xl bg-gradient-to-br from-emerald-500 to-green-600 text-white shadow-sm">
          <i class="fa-solid fa-database"></i>
        </span>
        <div>
          <p class="text-sm font-semibold text-zinc-800 leading-tight">Documents</p>
          <p class="text-[11px] text-zinc-500">Collection · title and slug</p>
        </div>
      </div>
      <span class="inline-flex items-center gap-1.5 rounded-full bg-emerald-50 px-2.5 py-1 text-[11px] font-semibold text-emerald-700 ring-1 ring-emerald-200">
        <span class="h-1.5 w-1.5 rounded-full bg-emerald-500"></span>
        Live
      </span>
    </div>

    {# Table #}
    <div class="overflow-x-auto">
      <table class="min-w-full divide-y divide-zinc-200 text-xs md:text-sm">
        <thead class="bg-zinc-50">
          <tr class="text-left">
            <th class="px-5 py-3 text-[11px] font-bold uppercase tracking-wider text-zinc-600">{{ $t('database.table.header.title') }}</th>
            <th class="px-5 py-3 text-[11px] font-bold uppercase tracking-wider text-zinc-600">{{ $t('database.table.header.slug') }}</th>
            <th class="px-5 py-3 text-end text-[11px] font-bold uppercase tracking-wider text-zinc-600">{{ $t('database.table.header.action') }}</th>
          </tr>
        </thead>
        <tbody class="divide-y divide-zinc-100 bg-white">
          {% for record in allRecords %}
          <tr class="group transition hover:bg-emerald-50/40">
            <td class="px-5 py-3 align-middle">
              <div class="flex items-center gap-2.5">
                <span class="inline-flex h-7 w-7 shrink-0 items-center justify-center rounded-lg bg-gradient-to-br from-emerald-500 to-green-600 text-white shadow-sm">
                  <i class="fa-solid fa-file-lines text-[11px]"></i>
                </span>
                <span class="font-semibold text-zinc-800">{{ record.title }}</span>
              </div>
            </td>
            <td class="px-5 py-3">
              <code class="inline-flex items-center gap-1.5 rounded-md bg-zinc-100 px-2 py-1 font-mono text-[11px] text-zinc-700 ring-1 ring-zinc-200">
                <i class="fa-solid fa-link text-[9px] text-zinc-400"></i>
                {{ record.slug }}
              </code>
            </td>
            <td class="px-5 py-3 text-end">
              <a
                href="/example/database?page={{ data.page if data.page else 1 }}&action=delete&id={{ record.id }}"
                class="wave inline-flex h-8 w-8 items-center justify-center rounded-lg border border-zinc-200 bg-white text-rose-600 transition hover:border-rose-300 hover:bg-rose-50 hover:shadow-sm focus:outline-none focus:ring-2 focus:ring-rose-500/30"
                title="{{ $t('database.table.header.action') }}">
                <i class="fa-solid fa-trash-can text-xs"></i>
              </a>
            </td>
          </tr>
          {% else %}
          <tr>
            <td colspan="3" class="px-5 py-16 text-center">
              <div class="mx-auto flex max-w-sm flex-col items-center gap-3">
                <div class="inline-flex h-16 w-16 items-center justify-center rounded-2xl bg-zinc-100 text-zinc-400">
                  <i class="fa-solid fa-folder-open text-2xl"></i>
                </div>
                <p class="text-sm font-semibold text-zinc-700">{{ $t('database.table.empty') if $t('database.table.empty') else $t('No records found') }}</p>
                <p class="text-xs text-zinc-500">Insert your first document using the form below.</p>
              </div>
            </td>
          </tr>
          {% endfor %}
        </tbody>
      </table>
    </div>

    {# Add document form + pagination #}
    <div class="space-y-4 border-t border-zinc-200 bg-zinc-50/60 p-5">
      <form method="post" class="rounded-xl border border-dashed border-zinc-300 bg-white p-4">
        <input type="hidden" name="action" value="add" />
        <div class="mb-3 flex items-center gap-2">
          <span class="inline-flex h-7 w-7 items-center justify-center rounded-lg bg-gradient-to-br from-emerald-500 to-green-600 text-white shadow-sm">
            <i class="fa-solid fa-plus text-[11px]"></i>
          </span>
          <p class="text-xs font-semibold text-zinc-700">
            {{ $t('database.table.button.add') }}
            <span class="font-normal text-zinc-500">·</span>
            <span class="font-normal text-zinc-500">New document</span>
          </p>
        </div>
        <div class="flex flex-col gap-2 sm:flex-row sm:items-start">
          <div class="flex-1">
            <label class="mb-1 block text-[10px] font-semibold uppercase tracking-wider text-zinc-500">
              {{ $t('database.table.header.title') }}
            </label>
            <div class="relative">
              <span class="pointer-events-none absolute inset-y-0 start-3 flex items-center text-zinc-400">
                <i class="fa-solid fa-heading text-xs"></i>
              </span>
              <input
                type="text"
                name="title"
                placeholder="{{ $t('database.table.input.placeholder.title') }}"
                class="block h-10 w-full rounded-lg border border-zinc-200 bg-white ps-9 pe-3 text-xs shadow-sm transition focus:border-teal-500 focus:ring-2 focus:ring-teal-500/20"
              />
            </div>
          </div>
          <div class="sm:pt-[22px]">
            <button
              type="submit"
              class="wave inline-flex h-10 w-full items-center justify-center gap-2 rounded-lg bg-gradient-to-r from-emerald-600 to-green-600 px-4 text-xs font-semibold text-white shadow-sm transition hover:from-emerald-700 hover:to-green-700 focus:outline-none focus:ring-2 focus:ring-emerald-500/40 sm:w-auto"
            >
              <i class="fa-solid fa-plus"></i>
              <span>{{ $t('database.table.button.add') }}</span>
            </button>
          </div>
        </div>
      </form>

      {% if pagination %}
      <div class="flex items-center justify-center pt-1">
        <div class="pagination-wrapper text-sm text-zinc-600">
          {{ pagination }}
        </div>
      </div>
      {% endif %}
    </div>
  </section>
</div>
{% endblock %}
""",
	r"example/socket.j2.html": r"""{% extends 'template/template.j2.html' %}

{% block title %}
    {{ $t('sidebar.socketExample') }}
{% endblock %}

{% block content %}

{# Reusable button templates used by websocket.js (do NOT remove) #}
<template id="btn-template-client">
  <button data-id="{id}"
          class="wave socket-client-send group inline-flex w-full items-center justify-between gap-2 rounded-xl border border-zinc-200 bg-white px-3 py-2.5 text-sm font-medium text-zinc-700 transition hover:-translate-y-0.5 hover:border-teal-300 hover:bg-teal-50 hover:text-teal-700 hover:shadow-sm disable-wave">
    <span class="inline-flex items-center gap-2 truncate">
      <span class="inline-flex h-7 w-7 shrink-0 items-center justify-center rounded-lg bg-gradient-to-br from-teal-500 to-cyan-600 text-white text-[11px] font-semibold shadow-sm">
        <i class="fa-solid fa-user"></i>
      </span>
      <span class="truncate">{text}</span>
    </span>
    <i class="fa-solid fa-paper-plane text-xs text-zinc-400 transition group-hover:text-teal-600 group-hover:translate-x-0.5"></i>
  </button>
</template>

{# ============== HERO ============== #}
<section class="reveal-up relative overflow-hidden rounded-3xl border border-zinc-200 bg-gradient-to-br from-zinc-900 via-teal-950 to-cyan-950 p-6 sm:p-8 shadow-soft">
  <div class="pointer-events-none absolute -top-24 -end-24 h-72 w-72 rounded-full bg-teal-500/20 blur-3xl"></div>
  <div class="pointer-events-none absolute -bottom-24 -start-24 h-72 w-72 rounded-full bg-cyan-500/20 blur-3xl"></div>

  <div class="relative flex flex-col gap-6 lg:flex-row lg:items-center lg:justify-between">
    <div class="flex items-start gap-4">
      <div class="relative">
        <div class="inline-flex h-14 w-14 items-center justify-center rounded-2xl bg-white/10 ring-1 ring-white/20 backdrop-blur">
          <i class="fa-solid fa-tower-broadcast text-2xl text-teal-300"></i>
        </div>
        <span class="absolute -top-1 -end-1 inline-flex h-3.5 w-3.5">
          <span class="absolute inline-flex h-full w-full animate-ping rounded-full bg-emerald-400 opacity-75"></span>
          <span class="relative inline-flex h-3.5 w-3.5 rounded-full bg-emerald-400 ring-2 ring-zinc-900"></span>
        </span>
      </div>
      <div>
        <div class="flex flex-wrap items-center gap-2">
          <span class="inline-flex items-center gap-1.5 rounded-full bg-emerald-500/15 px-2.5 py-1 text-[11px] font-semibold uppercase tracking-wider text-emerald-300 ring-1 ring-emerald-400/30">
            <span class="h-1.5 w-1.5 rounded-full bg-emerald-400"></span>
            Realtime
          </span>
          <span class="inline-flex items-center gap-1.5 rounded-full bg-white/5 px-2.5 py-1 text-[11px] font-medium text-zinc-300 ring-1 ring-white/10">
            <i class="fa-solid fa-bolt text-amber-300"></i>
            Bi-directional
          </span>
        </div>
        <h1 class="mt-2 text-2xl font-bold text-white sm:text-3xl">
          {{ $t('testWebSocket.title') }}
        </h1>
        <p class="mt-1 max-w-xl text-sm text-zinc-300">
          Send and receive messages over a persistent WebSocket connection — broadcast time, random text, list peers, or stream live video.
        </p>
      </div>
    </div>

    <div class="flex flex-col gap-2 sm:flex-row lg:flex-col lg:items-end">
      <div class="inline-flex items-center gap-2 rounded-xl border border-white/10 bg-white/5 px-3 py-2 font-mono text-xs text-zinc-200 backdrop-blur">
        <i class="fa-solid fa-link text-teal-300"></i>
        <span class="text-zinc-400">endpoint</span>
        <span class="text-white">/ws</span>
      </div>
      <div class="inline-flex items-center gap-2 rounded-xl border border-white/10 bg-white/5 px-3 py-2 text-xs text-zinc-200 backdrop-blur">
        <i class="fa-solid fa-shield-halved text-cyan-300"></i>
        Protocol&nbsp;<span class="font-semibold text-white">ws / wss</span>
      </div>
    </div>
  </div>
</section>

{# ============== MAIN GRID ============== #}
<section class="mt-6 grid grid-cols-1 gap-6 lg:grid-cols-3">

  {# ---------- CONSOLE (left, 2 cols) ---------- #}
  <div class="lg:col-span-2 reveal-up">
    <div class="overflow-hidden rounded-2xl border border-zinc-200 bg-white shadow-soft">
      {# Console header #}
      <div class="flex items-center justify-between border-b border-zinc-200 bg-zinc-50 px-4 py-3">
        <div class="flex items-center gap-3">
          <div class="flex items-center gap-1.5">
            <span class="h-2.5 w-2.5 rounded-full bg-rose-400"></span>
            <span class="h-2.5 w-2.5 rounded-full bg-amber-400"></span>
            <span class="h-2.5 w-2.5 rounded-full bg-emerald-400"></span>
          </div>
          <div class="hidden items-center gap-2 sm:flex">
            <i class="fa-solid fa-terminal text-xs text-zinc-500"></i>
            <span class="text-sm font-semibold text-zinc-700">
              {{ $t('testWebSocket.output') }}
            </span>
          </div>
        </div>
        <button
          onclick="document.getElementById('socket-output').value='';document.getElementById('socket-output').innerHTML='';document.getElementById('client-list').innerHTML=''"
          class="wave inline-flex items-center gap-1.5 rounded-lg border border-zinc-200 bg-white px-2.5 py-1.5 text-xs font-medium text-zinc-600 hover:border-rose-300 hover:bg-rose-50 hover:text-rose-700 focus:outline-none focus:ring-2 focus:ring-rose-500/30 disable-wave">
          <i class="fa-solid fa-broom"></i>
          {{ $t('testWebSocket.clear') }}
        </button>
      </div>

      {# Console body — dark terminal #}
      <div class="relative bg-zinc-950">
        <div class="pointer-events-none absolute inset-0 bg-[radial-gradient(circle_at_top,_rgba(20,184,166,0.08),transparent_60%)]"></div>
        <label for="socket-output" class="sr-only">{{ $t('testWebSocket.output') }}</label>
        <textarea id="socket-output" readonly
                  class="relative block h-[420px] w-full resize-none border-0 bg-transparent p-5 font-mono text-[13px] leading-relaxed text-emerald-300 placeholder:text-zinc-600 focus:outline-none focus:ring-0"
                  placeholder="// Waiting for messages from /ws ...
// Click an action below to send a frame."></textarea>
      </div>

      {# Action bar #}
      <div class="flex flex-wrap items-center gap-2 border-t border-zinc-200 bg-zinc-50 px-4 py-3">
        <button id="btn-socket-time"
                class="wave inline-flex items-center gap-1.5 rounded-lg border border-zinc-200 bg-white px-3 py-2 text-sm font-medium text-zinc-700 transition hover:border-teal-300 hover:bg-teal-50 hover:text-teal-700 focus:outline-none focus:ring-2 focus:ring-teal-500/30 disable-wave">
          <i class="fa-regular fa-clock text-teal-600"></i>
          {{ $t('testWebSocket.getTime') }}
        </button>
        <button id="btn-socket-fa"
                class="wave inline-flex items-center gap-1.5 rounded-lg border border-zinc-200 bg-white px-3 py-2 text-sm font-medium text-zinc-700 transition hover:border-cyan-300 hover:bg-cyan-50 hover:text-cyan-700 focus:outline-none focus:ring-2 focus:ring-cyan-500/30 disable-wave">
          <i class="fa-solid fa-shuffle text-cyan-600"></i>
          {{ $t('testWebSocket.randomMessage') }}
        </button>
        <button id="btn-socket-clients"
                class="wave inline-flex items-center gap-1.5 rounded-lg border border-zinc-200 bg-white px-3 py-2 text-sm font-medium text-zinc-700 transition hover:border-violet-300 hover:bg-violet-50 hover:text-violet-700 focus:outline-none focus:ring-2 focus:ring-violet-500/30 disable-wave">
          <i class="fa-solid fa-users text-violet-600"></i>
          {{ $t('testWebSocket.clientLists') }}
        </button>
        <div class="ms-auto">
          <button id="btn-socket-stream"
                  class="wave inline-flex items-center gap-2 rounded-lg bg-gradient-to-r from-emerald-600 to-teal-600 px-4 py-2 text-sm font-semibold text-white shadow-sm transition hover:from-emerald-700 hover:to-teal-700 focus:outline-none focus:ring-2 focus:ring-emerald-500/40 disable-wave">
            <i class="fa-solid fa-video"></i>
            {{ $t('testWebSocket.stream') }}
          </button>
        </div>
      </div>
    </div>
  </div>

  {# ---------- CLIENTS (right) ---------- #}
  <aside class="reveal-up">
    <div class="overflow-hidden rounded-2xl border border-zinc-200 bg-white shadow-soft">
      <div class="flex items-center justify-between border-b border-zinc-200 bg-zinc-50 px-4 py-3">
        <div class="flex items-center gap-2">
          <span class="inline-flex h-8 w-8 items-center justify-center rounded-lg bg-gradient-to-br from-teal-500 to-cyan-600 text-white shadow-sm">
            <i class="fa-solid fa-network-wired text-xs"></i>
          </span>
          <div>
            <p class="text-sm font-semibold text-zinc-800 leading-tight">Connected clients</p>
            <p class="text-[11px] text-zinc-500">Click a peer to send a hello</p>
          </div>
        </div>
        <button id="btn-refresh-clients" type="button"
                onclick="document.getElementById('btn-socket-clients')?.click()"
                class="inline-flex h-8 w-8 items-center justify-center rounded-lg border border-zinc-200 bg-white text-zinc-500 transition hover:border-teal-300 hover:text-teal-600 focus:outline-none focus:ring-2 focus:ring-teal-500/30"
                title="Refresh">
          <i class="fa-solid fa-arrows-rotate text-xs"></i>
        </button>
      </div>

      <div class="p-4">
        <div id="client-list" class="flex flex-col gap-2 min-h-[200px]">
          {# Empty-state placeholder is overwritten by JS once clients arrive #}
          <div class="flex h-[280px] flex-col items-center justify-center rounded-xl border border-dashed border-zinc-200 bg-zinc-50/60 px-4 text-center">
            <div class="inline-flex h-12 w-12 items-center justify-center rounded-2xl bg-white text-zinc-400 shadow-sm ring-1 ring-zinc-200">
              <i class="fa-solid fa-user-slash"></i>
            </div>
            <p class="mt-3 text-sm font-medium text-zinc-700">No peers yet</p>
            <p class="mt-1 text-xs text-zinc-500">
              Press <span class="rounded bg-white px-1.5 py-0.5 font-mono text-[11px] text-zinc-700 ring-1 ring-zinc-200">{{ $t('testWebSocket.clientLists') }}</span>
              to query.
            </p>
          </div>
        </div>
      </div>
    </div>

    {# Info card #}
    <div class="mt-4 rounded-2xl border border-amber-200 bg-amber-50/60 p-4">
      <div class="flex items-start gap-3">
        <div class="inline-flex h-9 w-9 shrink-0 items-center justify-center rounded-xl bg-amber-100 text-amber-700">
          <i class="fa-solid fa-lightbulb"></i>
        </div>
        <div class="text-xs leading-relaxed text-amber-900">
          Open this page in two browser tabs, list the clients, then click any peer to deliver a direct message to that socket.
        </div>
      </div>
    </div>
  </aside>
</section>

{# ============== VIDEO STREAM (hidden by default, toggled by JS) ============== #}
<section id="videoStream" class="reveal-up mt-6 hidden">
  <div class="overflow-hidden rounded-2xl border border-zinc-200 bg-white shadow-soft">
    <div class="flex flex-wrap items-center justify-between gap-3 border-b border-zinc-200 bg-gradient-to-r from-emerald-50 to-teal-50 px-5 py-3">
      <div class="flex items-center gap-3">
        <span class="inline-flex h-10 w-10 items-center justify-center rounded-xl bg-gradient-to-br from-emerald-500 to-teal-600 text-white shadow-sm">
          <i class="fa-solid fa-video"></i>
        </span>
        <div>
          <p class="text-sm font-semibold text-zinc-800 leading-tight">Live video stream</p>
          <p class="text-[11px] text-zinc-500">Local camera ⇄ Server playback</p>
        </div>
        <span class="ms-2 inline-flex items-center gap-1.5 rounded-full bg-rose-500/10 px-2.5 py-1 text-[11px] font-semibold uppercase tracking-wider text-rose-600 ring-1 ring-rose-300">
          <span class="h-1.5 w-1.5 animate-pulse rounded-full bg-rose-500"></span>
          LIVE
        </span>
      </div>
      <button id="btn-stop-stream"
              class="wave inline-flex items-center gap-2 rounded-lg bg-rose-600 px-3.5 py-2 text-sm font-semibold text-white shadow-sm transition hover:bg-rose-700 focus:outline-none focus:ring-2 focus:ring-rose-500/40 disable-wave">
        <i class="fa-solid fa-stop"></i>
        {{ $t('testWebSocket.stopStream') }}
      </button>
    </div>

    <div class="grid grid-cols-1 gap-4 p-5 md:grid-cols-2">
      <div class="relative overflow-hidden rounded-xl border border-zinc-200 bg-zinc-950">
        <div class="absolute left-3 top-3 z-10 inline-flex items-center gap-1.5 rounded-full bg-black/50 px-2.5 py-1 text-[11px] font-medium text-white backdrop-blur">
          <i class="fa-solid fa-camera"></i> Local
        </div>
        <video id="localVideo" class="block aspect-video w-full bg-black" autoplay muted></video>
      </div>
      <div class="relative overflow-hidden rounded-xl border border-zinc-200 bg-zinc-950">
        <div class="absolute left-3 top-3 z-10 inline-flex items-center gap-1.5 rounded-full bg-black/50 px-2.5 py-1 text-[11px] font-medium text-white backdrop-blur">
          <i class="fa-solid fa-server"></i> Server
        </div>
        <video id="serverVideo" class="block aspect-video w-full bg-black" controls></video>
      </div>
    </div>
  </div>
</section>

{% endblock %}
""",
	r"example/dump.j2.html": r"""{% extends 'template/template.j2.html' %}

{% block title %}
    {{ $t('sidebar.dumpExample') }}
{% endblock %}

{% block content %}
<div class="space-y-6">

  {# ============== HERO ============== #}
  <section class="reveal-up relative overflow-hidden rounded-3xl border border-zinc-200 bg-gradient-to-br from-zinc-950 via-slate-900 to-zinc-800 p-6 sm:p-8 shadow-soft">
    <div class="pointer-events-none absolute -top-24 -end-24 h-72 w-72 rounded-full bg-lime-500/15 blur-3xl"></div>
    <div class="pointer-events-none absolute -bottom-24 -start-24 h-72 w-72 rounded-full bg-cyan-500/15 blur-3xl"></div>

    {# subtle terminal grid #}
    <div class="pointer-events-none absolute inset-0 opacity-[0.06]" style="background-image: linear-gradient(rgba(255,255,255,.5) 1px, transparent 1px), linear-gradient(90deg, rgba(255,255,255,.5) 1px, transparent 1px); background-size: 24px 24px;"></div>

    <div class="relative flex flex-col gap-6 lg:flex-row lg:items-center lg:justify-between">
      <div class="flex items-start gap-4">
        <div class="relative">
          <div class="inline-flex h-14 w-14 items-center justify-center rounded-2xl bg-white/10 ring-1 ring-white/20 backdrop-blur">
            <i class="fa-solid fa-bug text-2xl text-lime-300"></i>
          </div>
          <span class="absolute -top-1 -end-1 inline-flex h-3.5 w-3.5">
            <span class="absolute inline-flex h-full w-full animate-ping rounded-full bg-lime-400 opacity-75"></span>
            <span class="relative inline-flex h-3.5 w-3.5 rounded-full bg-lime-400 ring-2 ring-zinc-950"></span>
          </span>
        </div>
        <div>
          <div class="flex flex-wrap items-center gap-2">
            <span class="inline-flex items-center gap-1.5 rounded-full bg-lime-500/15 px-2.5 py-1 text-[11px] font-semibold uppercase tracking-wider text-lime-300 ring-1 ring-lime-400/30">
              <i class="fa-solid fa-magnifying-glass text-[10px]"></i> Inspect
            </span>
            <span class="inline-flex items-center gap-1.5 rounded-full bg-cyan-500/15 px-2.5 py-1 text-[11px] font-semibold uppercase tracking-wider text-cyan-300 ring-1 ring-cyan-400/30">
              <i class="fa-solid fa-diagram-project text-[10px]"></i> Nested
            </span>
            <span class="inline-flex items-center gap-1.5 rounded-full bg-amber-500/15 px-2.5 py-1 text-[11px] font-semibold uppercase tracking-wider text-amber-300 ring-1 ring-amber-400/30">
              <i class="fa-solid fa-code text-[10px]"></i> dump()
            </span>
          </div>
          <h1 class="mt-2 text-2xl sm:text-3xl font-bold tracking-tight text-white">{{ $t('Variable Dump') }}</h1>
          <p class="mt-1 max-w-2xl text-sm text-zinc-300">Pretty-print any Dart value — primitives, lists, maps, nested objects — straight from your Jinja template with <code class="rounded bg-white/10 px-1 text-[12px] text-lime-200">{{ '{{ dump(variable) }}' }}</code>.</p>
        </div>
      </div>

      <div class="grid grid-cols-2 gap-3 sm:gap-4">
        <div class="rounded-2xl border border-white/10 bg-white/5 p-3 sm:p-4 text-center backdrop-blur">
          <div class="text-[10px] uppercase tracking-wider text-zinc-400">Helper</div>
          <div class="mt-1 flex items-center justify-center gap-1.5 text-lg font-bold text-white">
            <i class="fa-solid fa-wand-magic-sparkles text-sm text-lime-300"></i>
            <span class="font-mono">dump()</span>
          </div>
        </div>
        <div class="rounded-2xl border border-white/10 bg-white/5 p-3 sm:p-4 text-center backdrop-blur">
          <div class="text-[10px] uppercase tracking-wider text-zinc-400">Mode</div>
          <div class="mt-1 flex items-center justify-center gap-1.5 text-base font-bold text-white">
            <i class="fa-solid fa-circle text-[10px] text-amber-400 animate-pulse"></i>
            <span>Debug</span>
          </div>
        </div>
      </div>
    </div>
  </section>

  {# ============== RENDERED DUMP ============== #}
  <section class="reveal-up overflow-hidden rounded-2xl border border-zinc-200 bg-white shadow-soft">
    <div class="flex flex-wrap items-center justify-between gap-3 bg-gradient-to-r from-slate-50 to-zinc-50 px-5 py-4 border-b border-zinc-200">
      <div class="flex items-center gap-3">
        <span class="grid h-10 w-10 place-items-center rounded-xl bg-gradient-to-br from-slate-700 to-zinc-900 text-white shadow-sm ring-1 ring-slate-400/40">
          <i class="fa-solid fa-eye text-sm"></i>
        </span>
        <div>
          <h3 class="text-base font-bold text-zinc-900">Rendered output</h3>
          <p class="text-xs text-zinc-500">Interactive, expandable tree of your variable</p>
        </div>
      </div>
      <div class="flex items-center gap-2">
        <span class="inline-flex items-center gap-1.5 rounded-full bg-lime-100 px-2.5 py-1 text-[10px] font-semibold uppercase tracking-wider text-lime-800 ring-1 ring-lime-200">
          <i class="fa-solid fa-circle text-[8px] text-lime-500 animate-pulse"></i> Live
        </span>
        <span class="hidden sm:inline-flex items-center gap-1.5 rounded-full bg-zinc-100 px-2.5 py-1 text-[10px] font-semibold uppercase tracking-wider text-zinc-700 ring-1 ring-zinc-200">
          <i class="fa-solid fa-cube text-[9px]"></i> Map
        </span>
      </div>
    </div>
    <div class="p-5">
      <div class="rounded-xl border border-dashed border-slate-300 bg-gradient-to-br from-slate-50 to-zinc-50 p-4 overflow-x-auto">
        {{ dump(variable) }}
      </div>
    </div>
  </section>

  {# ============== CODE SOURCE ============== #}
  <section class="reveal-up overflow-hidden rounded-2xl border border-zinc-200 bg-white shadow-soft">
    <div class="flex flex-wrap items-center justify-between gap-3 bg-gradient-to-r from-zinc-900 to-slate-900 px-5 py-4 border-b border-zinc-700">
      <div class="flex items-center gap-3">
        <span class="grid h-10 w-10 place-items-center rounded-xl bg-white/10 ring-1 ring-white/20 backdrop-blur">
          <i class="fa-solid fa-terminal text-sm text-lime-300"></i>
        </span>
        <div>
          <h3 class="text-base font-bold text-white">Source snippet</h3>
          <p class="text-xs text-zinc-400">The exact Jinja call used above</p>
        </div>
      </div>
      <div class="flex items-center gap-1.5">
        <span class="inline-flex h-2.5 w-2.5 rounded-full bg-rose-500/80"></span>
        <span class="inline-flex h-2.5 w-2.5 rounded-full bg-amber-400/80"></span>
        <span class="inline-flex h-2.5 w-2.5 rounded-full bg-lime-400/80"></span>
      </div>
    </div>
    <div class="bg-zinc-950 p-5">
      <pre class="overflow-x-auto text-sm font-mono leading-relaxed text-lime-300"><code>{% raw %}{{ dump(variable) }}{% endraw %}</code></pre>
    </div>
  </section>

  {# ============== TIPS ============== #}
  <section class="reveal-up overflow-hidden rounded-2xl border border-zinc-200 bg-white shadow-soft">
    <div class="flex items-center gap-3 bg-gradient-to-r from-zinc-50 to-white px-5 py-4 border-b border-zinc-200">
      <span class="grid h-10 w-10 place-items-center rounded-xl bg-gradient-to-br from-amber-500 to-orange-500 text-white shadow-sm ring-1 ring-amber-300/50">
        <i class="fa-solid fa-lightbulb text-sm"></i>
      </span>
      <div>
        <h3 class="text-base font-bold text-zinc-900">Good to know</h3>
        <p class="text-xs text-zinc-500">When and how to reach for <code class="rounded bg-zinc-100 px-1 text-amber-700">dump()</code></p>
      </div>
    </div>
    <div class="grid gap-3 p-5 md:grid-cols-3">
      <div class="rounded-xl border border-lime-200 bg-gradient-to-br from-white to-lime-50/40 p-4">
        <div class="flex items-center gap-2 mb-2">
          <span class="grid h-7 w-7 place-items-center rounded-lg bg-lime-100 text-lime-700 ring-1 ring-lime-200">
            <i class="fa-solid fa-bolt text-[11px]"></i>
          </span>
          <p class="text-sm font-bold text-zinc-900">Any type</p>
        </div>
        <p class="text-xs leading-relaxed text-zinc-600">Pass strings, numbers, booleans, lists, maps, even controller objects — <code class="rounded bg-zinc-100 px-1 text-lime-700">dump()</code> walks them recursively.</p>
      </div>
      <div class="rounded-xl border border-cyan-200 bg-gradient-to-br from-white to-cyan-50/40 p-4">
        <div class="flex items-center gap-2 mb-2">
          <span class="grid h-7 w-7 place-items-center rounded-lg bg-cyan-100 text-cyan-700 ring-1 ring-cyan-200">
            <i class="fa-solid fa-folder-tree text-[11px]"></i>
          </span>
          <p class="text-sm font-bold text-zinc-900">Collapsible tree</p>
        </div>
        <p class="text-xs leading-relaxed text-zinc-600">Click any node to expand/collapse — perfect for inspecting deeply nested API responses and session payloads.</p>
      </div>
      <div class="rounded-xl border border-rose-200 bg-gradient-to-br from-white to-rose-50/40 p-4">
        <div class="flex items-center gap-2 mb-2">
          <span class="grid h-7 w-7 place-items-center rounded-lg bg-rose-100 text-rose-700 ring-1 ring-rose-200">
            <i class="fa-solid fa-triangle-exclamation text-[11px]"></i>
          </span>
          <p class="text-sm font-bold text-zinc-900">Dev only</p>
        </div>
        <p class="text-xs leading-relaxed text-zinc-600">Strip <code class="rounded bg-zinc-100 px-1 text-rose-700">dump()</code> calls before going to production — they expose internal state to every visitor.</p>
      </div>
    </div>
  </section>

  {# ============== FILE REFERENCES ============== #}
  <section class="reveal-up overflow-hidden rounded-2xl border border-zinc-200 bg-white shadow-soft">
    <div class="flex items-center gap-3 bg-gradient-to-r from-zinc-50 to-white px-5 py-4 border-b border-zinc-200">
      <span class="grid h-10 w-10 place-items-center rounded-xl bg-gradient-to-br from-zinc-700 to-zinc-900 text-white shadow-sm ring-1 ring-zinc-300/50">
        <i class="fa-solid fa-folder-tree text-sm"></i>
      </span>
      <div>
        <h3 class="text-base font-bold text-zinc-900">File References</h3>
        <p class="text-xs text-zinc-500">Where this example lives</p>
      </div>
    </div>
    <ul class="divide-y divide-zinc-100">
      <li class="group transition-colors duration-150 hover:bg-slate-50">
        <div class="flex flex-col gap-3 px-5 py-3.5 md:flex-row md:items-center md:gap-4">
          <div class="flex items-center gap-2.5 md:w-48">
            <span class="grid h-8 w-8 place-items-center rounded-lg bg-slate-100 text-slate-700 ring-1 ring-slate-200">
              <i class="fa-regular fa-eye text-xs"></i>
            </span>
            <span class="text-sm font-semibold text-zinc-700">View</span>
          </div>
          <code class="break-all rounded-md bg-zinc-100 px-3 py-1.5 text-xs font-mono text-slate-700 ring-1 ring-zinc-200 group-hover:bg-slate-100 group-hover:ring-slate-300">example/lib/widgets/example/dump.j2.html</code>
        </div>
      </li>
      <li class="group transition-colors duration-150 hover:bg-slate-50">
        <div class="flex flex-col gap-3 px-5 py-3.5 md:flex-row md:items-center md:gap-4">
          <div class="flex items-center gap-2.5 md:w-48">
            <span class="grid h-8 w-8 place-items-center rounded-lg bg-lime-100 text-lime-700 ring-1 ring-lime-200">
              <i class="fa-solid fa-code text-xs"></i>
            </span>
            <span class="text-sm font-semibold text-zinc-700">Controller</span>
          </div>
          <code class="break-all rounded-md bg-zinc-100 px-3 py-1.5 text-xs font-mono text-lime-700 ring-1 ring-zinc-200 group-hover:bg-lime-100 group-hover:ring-lime-200">example/lib/controllers/home_controller.dart → exampleDump()</code>
        </div>
      </li>
      <li class="group transition-colors duration-150 hover:bg-slate-50">
        <div class="flex flex-col gap-3 px-5 py-3.5 md:flex-row md:items-center md:gap-4">
          <div class="flex items-center gap-2.5 md:w-48">
            <span class="grid h-8 w-8 place-items-center rounded-lg bg-amber-100 text-amber-700 ring-1 ring-amber-200">
              <i class="fa-solid fa-route text-xs"></i>
            </span>
            <span class="text-sm font-semibold text-zinc-700">Router</span>
          </div>
          <code class="break-all rounded-md bg-zinc-100 px-3 py-1.5 text-xs font-mono text-amber-800 ring-1 ring-zinc-200 group-hover:bg-amber-100 group-hover:ring-amber-200">example/lib/route/web_route.dart → key: 'root.dump'</code>
        </div>
      </li>
    </ul>
  </section>
</div>
{% endblock %}
""",
	r"example/sqlite/_filtering.j2.html": r"""<form method="get" class="contents">
    <th class="p-1.5 align-top">
        <input
            class="h-9 w-full rounded-lg border bg-white px-2.5 text-xs shadow-sm transition focus:border-teal-500 focus:ring-2 focus:ring-teal-500/20 {{ 'border-emerald-400 ring-2 ring-emerald-200' if $n('filter_books/filter_b.id/value') else 'border-zinc-200' }}"
            type="number"
            name="filter_b.id"
            placeholder="{{ $t('mysql.placeholder.id') }}"
            value="{{ $n('filter_books/filter_b.id/value') }}"
        />
    </th>
    <th class="p-1.5 align-top">
        <input
            class="h-9 w-full rounded-lg border bg-white px-2.5 text-xs shadow-sm transition focus:border-teal-500 focus:ring-2 focus:ring-teal-500/20 {{ 'border-emerald-400 ring-2 ring-emerald-200' if $n('filter_books/filter_title/value') else 'border-zinc-200' }}"
            type="text"
            name="filter_title"
            placeholder="{{ $t('mysql.placeholder.title') }}"
            value="{{ $n('filter_books/filter_title/value') }}"
        />
    </th>
    <th class="p-1.5 align-top">
        <input
            class="h-9 w-full rounded-lg border bg-white px-2.5 text-xs shadow-sm transition focus:border-teal-500 focus:ring-2 focus:ring-teal-500/20 {{ 'border-emerald-400 ring-2 ring-emerald-200' if $n('filter_books/filter_author/value') else 'border-zinc-200' }}"
            type="text"
            name="filter_author"
            placeholder="{{ $t('mysql.placeholder.author') }}"
            value="{{ $n('filter_books/filter_author/value') }}"
        />
    </th>
    <th class="p-1.5 align-top">
        <input
            class="h-9 w-full rounded-lg border bg-white px-2.5 text-xs shadow-sm transition focus:border-teal-500 focus:ring-2 focus:ring-teal-500/20 {{ 'border-emerald-400 ring-2 ring-emerald-200' if $n('filter_books/filter_published_date/value') else 'border-zinc-200' }}"
            type="date"
            name="filter_published_date"
            placeholder="{{ $t('mysql.placeholder.publishedDate') }}"
            value="{{ $n('filter_books/filter_published_date/value') }}"
        />
    </th>
    <th class="p-1.5 align-top">
        <select
            class="h-9 w-full rounded-lg border bg-white px-2.5 text-xs shadow-sm transition focus:border-teal-500 focus:ring-2 focus:ring-teal-500/20 {{ 'border-emerald-400 ring-2 ring-emerald-200' if $n('filter_books/filter_category_id/value') else 'border-zinc-200' }}"
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
    <th colspan="2" class="p-1.5 align-top text-end">
        {% set filterIsDirty = $l.existUrlQuery(['filter_b.id','filter_title', 'filter_author', 'filter_published_date', 'filter_category_id']) %}
        <div class="flex items-center justify-end gap-1.5">
            <a
                href="{{ $l.removeUrlQuery(['page','filter_b.id','filter_title', 'filter_author', 'filter_published_date', 'filter_category_id']) }}"
                class="wave inline-flex h-9 items-center gap-1.5 rounded-lg border px-3 text-xs font-medium shadow-sm transition {{ 'border-zinc-200 bg-white text-zinc-500 hover:bg-zinc-50' if not filterIsDirty else 'border-zinc-800 bg-zinc-900 text-white hover:bg-zinc-800' }}"
                type="reset"
                title="{{ $t('mysql.button.reset') }}"
            >
                <i class="fa-solid fa-rotate-left text-[11px]"></i>
                <span class="hidden sm:inline">{{ $t('mysql.button.reset') }}</span>
            </a>
            <button
                class="wave inline-flex h-9 cursor-pointer items-center gap-1.5 rounded-lg bg-gradient-to-r from-teal-600 to-cyan-600 px-3.5 text-xs font-semibold text-white shadow-sm transition hover:from-teal-700 hover:to-cyan-700 focus:outline-none focus:ring-2 focus:ring-teal-500/40"
                type="submit"
            >
                <i class="fa-solid fa-filter text-[11px]"></i>
                <span>{{ $t('mysql.button.filter') }}</span>
            </button>
        </div>
    </th>
</form>
""",
	r"example/sqlite/_form_edit.j2.html": r"""<form method="post" action="{{ $e.uriString }}" class="contents">
    <input type="hidden" name="action" value="{{ 'update' if(action == 'edit' ?? action == 'update') else 'add' }}" />
    <tr>
        <td colspan="7" class="px-4 py-4">
            <div class="rounded-xl border border-dashed border-zinc-300 bg-zinc-50/60 p-4">
                <div class="mb-3 flex items-center gap-2">
                    <span class="inline-flex h-7 w-7 items-center justify-center rounded-lg bg-gradient-to-br from-teal-500 to-cyan-600 text-white shadow-sm">
                        <i class="fa-solid {{ 'fa-pen-to-square' if(action == 'edit' ?? action == 'update') else 'fa-plus' }} text-[11px]"></i>
                    </span>
                    <p class="text-xs font-semibold text-zinc-700">
                        {{ $t('mysql.button.update') if(action == 'edit' ?? action == 'update') else $t('database.table.button.add') }}
                        <span class="font-normal text-zinc-500">·</span>
                        <span class="font-normal text-zinc-500">Book record</span>
                    </p>
                </div>
                <div class="grid grid-cols-1 gap-3 sm:grid-cols-2 lg:grid-cols-4">
                    <div class="flex flex-col">
                        <label class="mb-1 text-[10px] font-semibold uppercase tracking-wider text-zinc-500">{{ $t('mysql.placeholder.title') }}</label>
                        <input
                            type="text"
                            name="title"
                            placeholder="{{ $t('mysql.placeholder.title') }}"
                            required
                            value="{{ $n('form_book/title/value') }}"
                            class="h-10 rounded-lg border bg-white px-3 text-xs shadow-sm transition focus:border-teal-500 focus:ring-2 focus:ring-teal-500/20 {{ 'border-rose-500 ring-2 ring-rose-300' if $n('form_book/title/errors/0') else 'border-zinc-200' }}"
                        />
                        <div class="mt-1 text-[10px] text-rose-600 {{ '' if $n('form_book/title/errors/0') else 'hidden' }}">{{ $n('form_book/title/errors/0') }}</div>
                    </div>
                    <div class="flex flex-col">
                        <label class="mb-1 text-[10px] font-semibold uppercase tracking-wider text-zinc-500">{{ $t('mysql.placeholder.author') }}</label>
                        <input
                            type="text"
                            name="author"
                            placeholder="{{ $t('mysql.placeholder.author') }}"
                            required
                            value="{{ $n('form_book/author/value') }}"
                            class="h-10 rounded-lg border bg-white px-3 text-xs shadow-sm transition focus:border-teal-500 focus:ring-2 focus:ring-teal-500/20 {{ 'border-rose-500 ring-2 ring-rose-300' if $n('form_book/author/errors/0') else 'border-zinc-200' }}"
                        />
                        <div class="mt-1 text-[10px] text-rose-600 {{ '' if $n('form_book/author/errors/0') else 'hidden' }}">{{ $n('form_book/author/errors/0') }}</div>
                    </div>
                    <div class="flex flex-col">
                        <label class="mb-1 text-[10px] font-semibold uppercase tracking-wider text-zinc-500">{{ $t('mysql.placeholder.publishedDate') }}</label>
                        <input
                            type="date"
                            name="published_date"
                            required
                            value="{{ $n('form_book/published_date/value') }}"
                            class="h-10 rounded-lg border bg-white px-3 text-xs shadow-sm transition focus:border-teal-500 focus:ring-2 focus:ring-teal-500/20 {{ 'border-rose-500 ring-2 ring-rose-300' if $n('form_book/published_date/errors/0') else 'border-zinc-200' }}"
                        />
                        <div class="mt-1 text-[10px] text-rose-600 {{ '' if $n('form_book/published_date/errors/0') else 'hidden' }}">{{ $n('form_book/published_date/errors/0') }}</div>
                    </div>
                    <div class="flex flex-col">
                        <label class="mb-1 text-[10px] font-semibold uppercase tracking-wider text-zinc-500">{{ $t('mysql.table.header.categoryId') }}</label>
                        <select
                            name="category_id"
                            class="h-10 rounded-lg border bg-white px-2.5 text-xs shadow-sm transition focus:border-teal-500 focus:ring-2 focus:ring-teal-500/20 {{ 'border-rose-500 ring-2 ring-rose-300' if $n('form_book/category_id/errors/0') else 'border-zinc-200' }}"
                        >
                            <option value=""></option>
                            {% set selected = $n('form_book/category_id/value') %}
                            {% for category in $n('form_book/category_id/options') %}
                                <option value="{{ category.id }}" {{ 'selected' if selected == category.id else '' }}>{{ category.title }}</option>
                            {% endfor %}
                        </select>
                        <div class="mt-1 text-[10px] text-rose-600 {{ '' if $n('form_book/category_id/errors/0') else 'hidden' }}">{{ $n('form_book/category_id/errors/0') }}</div>
                    </div>
                </div>

                <input type="hidden" name="token" value="{{ $n('form_book/token/value') }}" />
                {% if(action == 'edit' ?? action == 'update') %}
                <input type="hidden" name="id" value="{{ id }}" />
                {% endif %}

                <div class="mt-3 flex flex-wrap items-center justify-between gap-2">
                    <div class="text-[10px] text-rose-600 {{ $n('form_book/token/errors/0') ? '' : 'hidden' }}">{{ $n('form_book/token/errors/0') }}</div>
                    <button type="submit" class="wave inline-flex h-10 items-center gap-2 rounded-lg bg-gradient-to-r from-teal-600 to-cyan-600 px-4 text-xs font-semibold text-white shadow-sm transition hover:from-teal-700 hover:to-cyan-700 focus:outline-none focus:ring-2 focus:ring-teal-500/40">
                        <i class="fa-solid {{ 'fa-floppy-disk' if(action == 'edit' ?? action == 'update') else 'fa-plus' }}"></i>
                        {{ $t('mysql.button.update') if(action == 'edit' ?? action == 'update') else $t('database.table.button.add') }}
                    </button>
                </div>
            </div>
        </td>
    </tr>
    <tr>
        <td colspan="7" class="px-4 py-3 text-xs text-zinc-600">{{ paging }}</td>
    </tr>
</form>
""",
	r"example/sqlite/_categories.j2.html": r"""<section class="reveal-up overflow-hidden rounded-2xl border border-zinc-200 bg-white shadow-soft">
  <div class="flex flex-wrap items-center justify-between gap-3 border-b border-zinc-200 bg-gradient-to-r from-zinc-50 to-white px-5 py-4">
    <div class="flex items-center gap-3">
      <span class="inline-flex h-10 w-10 items-center justify-center rounded-xl bg-gradient-to-br from-cyan-500 to-teal-600 text-white shadow-sm">
        <i class="fa-solid fa-folder-tree"></i>
      </span>
      <div>
        <p class="text-sm font-semibold text-zinc-800 leading-tight">{{ $t('mysql.categories.title') }}</p>
        <p class="text-[11px] text-zinc-500">Browse, filter and manage book categories</p>
      </div>
    </div>
    <span class="inline-flex items-center gap-1.5 rounded-full bg-cyan-50 px-2.5 py-1 text-[11px] font-semibold text-cyan-700 ring-1 ring-cyan-200">
      <i class="fa-solid fa-layer-group text-[10px]"></i>
      {{ (categories | default([])) | length }} total
    </span>
  </div>

  <div class="overflow-x-auto">
    <table class="min-w-full divide-y divide-zinc-200 text-xs md:text-sm">
      <thead class="bg-zinc-50">
        <tr class="text-left">
          <th scope="col" class="w-20 px-4 py-3 text-[11px] font-bold uppercase tracking-wider text-zinc-600">{{ $t('mysql.table.header.id') }}</th>
          <th scope="col" class="px-4 py-3 text-[11px] font-bold uppercase tracking-wider text-zinc-600">{{ $t('mysql.table.header.title') }}</th>
          <th scope="col" class="w-36 px-4 py-3 text-center text-[11px] font-bold uppercase tracking-wider text-zinc-600">{{ $t('mysql.table.header.booksCount') }}</th>
          <th scope="col" class="w-24 px-4 py-3 text-end text-[11px] font-bold uppercase tracking-wider text-zinc-600">{{ $t('mysql.table.header.actions') }}</th>
        </tr>
      </thead>
      <tbody class="divide-y divide-zinc-100 bg-white">
        {% for category in categories|default([]) %}
        <tr class="group transition hover:bg-cyan-50/40">
          <td class="px-4 py-3">
            <span class="inline-flex h-6 min-w-[1.75rem] items-center justify-center rounded-md bg-cyan-100 px-1.5 font-mono text-[11px] font-bold text-cyan-700">{{ category.id }}</span>
          </td>
          <td class="px-4 py-3 font-medium text-zinc-800">{{ category.title }}</td>
          <td class="px-4 py-3 text-center">
            <a
              class="wave inline-flex h-7 items-center gap-1.5 rounded-full border border-cyan-200 bg-cyan-50 px-3 text-[11px] font-semibold text-cyan-700 hover:border-cyan-300 hover:bg-cyan-100 focus:outline-none focus:ring-2 focus:ring-cyan-500/30"
              href="{{ $l.updateUrlQuery( {'filter_category_id': category.id|s}) }}"
            >
              <i class="fa-solid fa-book text-[10px]"></i>
              {{ category.count_books }}
            </a>
          </td>
          <td class="px-4 py-3 text-end">
            <a
              data-href="{{ $l.updateUrlQuery( {'id': category.id|s, 'action': 'delete_category'|s}) }}"
              data-message="{{ $t('mysql.message.deleteCategory') ~ ' (' ~ category.title ~ ')' }}"
              class="wave js-delete-links inline-flex h-8 w-8 items-center justify-center rounded-lg border border-zinc-200 bg-white text-rose-600 transition hover:border-rose-300 hover:bg-rose-50 hover:shadow-sm focus:outline-none focus:ring-2 focus:ring-rose-500/30"
              aria-label="{{ $t('mysql.button.delete') }}"
            >
              <i class="fa-solid fa-trash-can text-xs"></i>
            </a>
          </td>
        </tr>
        {% else %}
        <tr>
          <td colspan="4" class="px-4 py-12 text-center">
            <div class="mx-auto flex max-w-sm flex-col items-center gap-3">
              <div class="inline-flex h-14 w-14 items-center justify-center rounded-2xl bg-zinc-100 text-zinc-400">
                <i class="fa-solid fa-folder-open text-xl"></i>
              </div>
              <p class="text-sm font-medium text-zinc-600">{{ $t('mysql.message.noCategories') }}</p>
            </div>
          </td>
        </tr>
        {% endfor %}
      </tbody>
      <tfoot class="border-t border-zinc-200 bg-zinc-50/60">
        <tr>
          <td colspan="4" class="px-4 py-4">
            <form method="POST" action="{{ $l.updateUrlQuery( {'action': 'add_category'}) }}" class="flex flex-wrap items-start gap-2">
              <div class="flex min-w-[220px] flex-1 flex-col">
                <div class="relative">
                  <span class="pointer-events-none absolute inset-y-0 start-3 flex items-center text-zinc-400">
                    <i class="fa-solid fa-plus text-xs"></i>
                  </span>
                  <input
                    type="text"
                    name="title"
                    placeholder="{{ $t('mysql.placeholder.title') }}"
                    required
                    value="{{ $n('form/title/value') }}"
                    class="h-10 w-full rounded-lg border bg-white ps-9 pe-3 text-xs shadow-sm focus:border-teal-500 focus:ring-2 focus:ring-teal-500/20 {{ 'border-rose-500 ring-2 ring-rose-300' if $n('form/title/errors/0') else 'border-zinc-300' }}"
                  />
                </div>
                <div class="mt-1 text-[10px] text-rose-600 {{ '' if $n('form/title/errors/0') else 'hidden' }}">{{ $n('form/title/errors/0') }}</div>
              </div>
              <button type="submit" class="wave inline-flex h-10 items-center gap-2 rounded-lg bg-gradient-to-r from-teal-600 to-cyan-600 px-4 text-xs font-semibold text-white shadow-sm transition hover:from-teal-700 hover:to-cyan-700 focus:outline-none focus:ring-2 focus:ring-teal-500/40">
                <i class="fa-solid fa-plus"></i>
                {{ $t('database.table.button.add') }}
              </button>
            </form>
          </td>
        </tr>
      </tfoot>
    </table>
  </div>
</section>
""",
	r"example/sqlite/overview.j2.html": r"""{% extends 'template/template.j2.html' %}
{% block title %} {{ $t('Example SQLite') }} {% endblock %}

{% block content %}
{% set pageSize = data.pageSize | default("10") %}
{% set randonString = $e.randomString() %}

<div class="space-y-6">

  {# ============== HERO ============== #}
  <section class="reveal-up relative overflow-hidden rounded-3xl border border-zinc-200 bg-gradient-to-br from-zinc-900 via-sky-950 to-cyan-950 p-6 sm:p-8 shadow-soft">
    <div class="pointer-events-none absolute -top-24 -end-24 h-72 w-72 rounded-full bg-sky-500/20 blur-3xl"></div>
    <div class="pointer-events-none absolute -bottom-24 -start-24 h-72 w-72 rounded-full bg-cyan-500/20 blur-3xl"></div>

    <div class="relative flex flex-col gap-6 lg:flex-row lg:items-center lg:justify-between">
      <div class="flex items-start gap-4">
        <div class="relative">
          <div class="inline-flex h-14 w-14 items-center justify-center rounded-2xl bg-white/10 ring-1 ring-white/20 backdrop-blur">
            <i class="fa-solid fa-database text-2xl text-sky-300"></i>
          </div>
          <span class="absolute -top-1 -end-1 inline-flex h-3.5 w-3.5">
            <span class="absolute inline-flex h-full w-full animate-ping rounded-full bg-cyan-400 opacity-75"></span>
            <span class="relative inline-flex h-3.5 w-3.5 rounded-full bg-cyan-400 ring-2 ring-zinc-900"></span>
          </span>
        </div>
        <div>
          <div class="flex flex-wrap items-center gap-2">
            <span class="inline-flex items-center gap-1.5 rounded-full bg-sky-500/15 px-2.5 py-1 text-[11px] font-semibold uppercase tracking-wider text-sky-300 ring-1 ring-sky-400/30">
              <i class="fa-solid fa-bolt"></i>
              SQLite
            </span>
            <span class="inline-flex items-center gap-1.5 rounded-full bg-white/5 px-2.5 py-1 text-[11px] font-medium text-zinc-300 ring-1 ring-white/10">
              <i class="fa-solid fa-table text-cyan-300"></i>
              Embedded
            </span>
          </div>
          <h1 class="mt-2 text-2xl font-bold text-white sm:text-3xl">{{ $t('Example SQLite') }}</h1>
          <p class="mt-1 max-w-xl text-sm text-zinc-300">
            SQLite embedded database — zero-config, file-based, with the same advanced features — pagination, sortable columns, multi-field filters and bulk actions.
          </p>
        </div>
      </div>

      {# Quick stats #}
      <div class="grid grid-cols-2 gap-3 sm:grid-cols-3 lg:flex lg:items-stretch">
        <div class="rounded-2xl border border-white/10 bg-white/5 px-4 py-3 backdrop-blur">
          <div class="text-[10px] font-semibold uppercase tracking-wider text-zinc-400">Books</div>
          <div class="mt-1 flex items-baseline gap-1.5">
            <span class="text-2xl font-bold text-white">{{ (books | default([])) | length }}</span>
            <span class="text-[11px] text-zinc-400">/ page</span>
          </div>
        </div>
        <div class="rounded-2xl border border-white/10 bg-white/5 px-4 py-3 backdrop-blur">
          <div class="text-[10px] font-semibold uppercase tracking-wider text-zinc-400">Categories</div>
          <div class="mt-1 flex items-baseline gap-1.5">
            <span class="text-2xl font-bold text-white">{{ (categories | default([])) | length }}</span>
          </div>
        </div>
        <div class="col-span-2 rounded-2xl border border-white/10 bg-white/5 px-4 py-3 backdrop-blur sm:col-span-1">
          <div class="text-[10px] font-semibold uppercase tracking-wider text-zinc-400">Page size</div>
          <div class="mt-1 inline-flex items-baseline gap-1.5">
            <span class="text-2xl font-bold text-white">{{ pageSize }}</span>
            <span class="text-[11px] text-zinc-400">rows</span>
          </div>
        </div>
      </div>
    </div>
  </section>

  {# ============== BOOKS CARD ============== #}
  <section class="reveal-up overflow-hidden rounded-2xl border border-zinc-200 bg-white shadow-soft">
    {# Toolbar #}
    <div class="flex flex-wrap items-center justify-between gap-3 border-b border-zinc-200 bg-gradient-to-r from-zinc-50 to-white px-5 py-4">
      <div class="flex items-center gap-3">
        <span class="inline-flex h-10 w-10 items-center justify-center rounded-xl bg-gradient-to-br from-sky-500 to-cyan-600 text-white shadow-sm">
          <i class="fa-solid fa-book"></i>
        </span>
        <div>
          <p class="text-sm font-semibold text-zinc-800 leading-tight">{{ $t('Books Management') }}</p>
          <p class="text-[11px] text-zinc-500">Sortable · filterable · bulk operations</p>
        </div>
      </div>
      <div class="flex flex-wrap items-center gap-2">
        <button type="button" class="wave group inline-flex h-9 items-center gap-2 rounded-lg border border-rose-300 bg-rose-50 px-3.5 text-xs font-semibold text-rose-700 transition hover:border-rose-400 hover:bg-rose-100 focus:outline-none focus:ring-2 focus:ring-rose-500/30" onclick="deleteSelectedBooks_{{randonString}}()">
          <i class="fa-solid fa-trash-can text-[11px]"></i>
          <span>{{ $t('mysql.button.deleteSelected') }}</span>
        </button>
        <div class="inline-flex items-center gap-2 rounded-lg border border-zinc-200 bg-white pl-3">
          <span class="text-[11px] font-medium text-zinc-500">
            <i class="fa-solid fa-list-ol text-zinc-400"></i>
            Rows
          </span>
          <select name="pageSize" class="h-9 cursor-pointer rounded-r-lg border-0 bg-white pe-2 ps-1 text-xs font-semibold text-zinc-700 focus:outline-none focus:ring-2 focus:ring-teal-500/30" onchange="changePageSize_{{randonString}}(this.value)">
            <option {{ 'selected' if pageSize == '10' else '' }}>10</option>
            <option {{ 'selected' if pageSize == '20' else '' }}>20</option>
            <option {{ 'selected' if pageSize == '50' else '' }}>50</option>
            <option {{ 'selected' if pageSize == '100' else '' }}>100</option>
          </select>
        </div>
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

    {# Table #}
    <div class="overflow-x-auto">
      <table class="min-w-full divide-y divide-zinc-200 text-xs md:text-sm">
        <thead class="bg-zinc-50">
          <tr class="text-left">
            <th class="px-4 py-3">
              <div class="flex items-center gap-2">
                <input class="h-4 w-4 rounded border-zinc-300 text-teal-600 focus:ring-2 focus:ring-teal-500/30" type="checkbox" id="select_all" onchange="document.querySelectorAll(`input[name='selected_books']`).forEach(cb=>cb.checked=this.checked);" />
                <span class="text-[11px] font-bold uppercase tracking-wider text-zinc-600">{{ $l.macro("/template/ui/sorting", {'sortby': 'b.id', 'title': 'mysql.table.header.id'} ) }}</span>
              </div>
            </th>
            <th class="px-4 py-3 text-[11px] font-bold uppercase tracking-wider text-zinc-600">{{ $l.macro("/template/ui/sorting", {'sortby': 'title', 'title': 'mysql.table.header.title'} ) }}</th>
            <th class="px-4 py-3 text-[11px] font-bold uppercase tracking-wider text-zinc-600">{{ $l.macro("/template/ui/sorting", {'sortby': 'author', 'title': 'mysql.table.header.author'} ) }}</th>
            <th class="px-4 py-3 text-[11px] font-bold uppercase tracking-wider text-zinc-600">{{ $l.macro("/template/ui/sorting", {'sortby': 'published_date', 'title': 'mysql.table.header.publishedDate'} ) }}</th>
            <th class="px-4 py-3 text-[11px] font-bold uppercase tracking-wider text-zinc-600">{{ $l.macro("/template/ui/sorting", {'sortby': 'category_id', 'title': 'mysql.table.header.categoryId'} ) }}</th>
            <th class="px-4 py-3 text-end text-[11px] font-bold uppercase tracking-wider text-zinc-600">{{ $t('database.table.header.action') }}</th>
          </tr>
          <tr class="bg-white">
            {% include 'example/sqlite/_filtering.j2.html' %}
          </tr>
        </thead>
        <tbody class="divide-y divide-zinc-100 bg-white">
          {% for book in books %}
          <tr class="group transition hover:bg-sky-50/40">
            <td class="px-4 py-3 align-middle">
              <div class="flex items-center gap-2.5">
                <input class="h-4 w-4 rounded border-zinc-300 text-teal-600 focus:ring-2 focus:ring-teal-500/30" type="checkbox" name="selected_books" value="{{ book.id }}" />
                <span class="inline-flex h-6 min-w-[1.75rem] items-center justify-center rounded-md bg-sky-100 px-1.5 text-[11px] font-bold text-sky-700">{{ book.id }}</span>
              </div>
            </td>
            <td class="px-4 py-3 font-semibold text-zinc-800">{{ book.title }}</td>
            <td class="px-4 py-3 text-zinc-600">
              <span class="inline-flex items-center gap-1.5">
                <i class="fa-regular fa-user text-zinc-400"></i>
                {{ book.author }}
              </span>
            </td>
            <td class="px-4 py-3 text-zinc-600">
              <span class="inline-flex items-center gap-1.5">
                <i class="fa-regular fa-calendar text-zinc-400"></i>
                {{ book.published_date | dateFormat('dd/MM/y') }}
              </span>
            </td>
            <td class="px-4 py-3">
              <span class="inline-flex items-center gap-1 rounded-full bg-cyan-50 px-2.5 py-1 text-[11px] font-medium text-cyan-700 ring-1 ring-cyan-200">
                <span class="h-1.5 w-1.5 rounded-full bg-cyan-500"></span>
                {{ book.category_title }}
              </span>
            </td>
            <td class="px-4 py-3 text-end">
              <div class="flex items-center justify-end gap-1.5">
                <a
                  href="{{ $l.updateUrlQuery( {'id':book.id|s, 'action': 'edit'|s}) }}"
                  class="wave inline-flex h-8 w-8 items-center justify-center rounded-lg border border-zinc-200 bg-white text-teal-600 transition hover:border-teal-300 hover:bg-teal-50 hover:shadow-sm focus:outline-none focus:ring-2 focus:ring-teal-500/30"
                  title="{{ $t('mysql.button.edit') }}">
                  <i class="fa-solid fa-pen-to-square text-xs"></i>
                </a>
                <a
                  data-href="{{ $l.updateUrlQuery( {'id':book.id|s, 'action': 'delete'|s}) }}"
                  data-message="{{ $t('mysql.message.deleteBook') ~ ' (' ~ book.title ~ ')' }}"
                  class="wave cursor-pointer js-delete-links inline-flex h-8 w-8 items-center justify-center rounded-lg border border-zinc-200 bg-white text-rose-600 transition hover:border-rose-300 hover:bg-rose-50 hover:shadow-sm focus:outline-none focus:ring-2 focus:ring-rose-500/30"
                  title="{{ $t('mysql.button.delete') }}">
                  <i class="fa-solid fa-trash-can text-xs"></i>
                </a>
              </div>
            </td>
          </tr>
          {% else %}
          <tr>
            <td colspan="6" class="px-4 py-16 text-center">
              <div class="mx-auto flex max-w-sm flex-col items-center gap-3">
                <div class="inline-flex h-16 w-16 items-center justify-center rounded-2xl bg-zinc-100 text-zinc-400">
                  <i class="fa-solid fa-book-open text-2xl"></i>
                </div>
                <p class="text-sm font-semibold text-zinc-700">{{ $t('mysql.message.noRecords') }}</p>
                <p class="text-xs text-zinc-500">Use the form below to add your first book.</p>
              </div>
            </td>
          </tr>
          {% endfor %}
        </tbody>
        <tfoot class="border-t border-zinc-200 bg-zinc-50/60">
          {% include form_book.widget | unscape %}
        </tfoot>
      </table>
    </div>
  </section>

  {# ============== CATEGORIES CARD ============== #}
  {% include 'example/sqlite/_categories.j2.html' %}

</div>
{% endblock %}
""",
	r"example/email.j2.html": r"""{% extends 'template/template.j2.html' %}
{% block title %}
    {{ $t('sidebar.emailExample') }}
{% endblock %}

{% block content %}
{% set hasSuccess = sendEmailSuccess %}
{% set hasFailed = sendEmailFailed %}

<div class="space-y-6">

  {# ============== HERO ============== #}
  <section class="reveal-up relative overflow-hidden rounded-3xl border border-zinc-200 bg-gradient-to-br from-zinc-900 via-sky-950 to-indigo-950 p-6 sm:p-8 shadow-soft">
    <div class="pointer-events-none absolute -top-24 -end-24 h-72 w-72 rounded-full bg-sky-500/20 blur-3xl"></div>
    <div class="pointer-events-none absolute -bottom-24 -start-24 h-72 w-72 rounded-full bg-indigo-500/20 blur-3xl"></div>

    <div class="relative flex flex-col gap-6 lg:flex-row lg:items-center lg:justify-between">
      <div class="flex items-start gap-4">
        <div class="relative">
          <div class="inline-flex h-14 w-14 items-center justify-center rounded-2xl bg-white/10 ring-1 ring-white/20 backdrop-blur">
            <i class="fa-solid fa-paper-plane text-2xl text-sky-300"></i>
          </div>
          <span class="absolute -top-1 -end-1 inline-flex h-3.5 w-3.5">
            <span class="absolute inline-flex h-full w-full animate-ping rounded-full bg-indigo-400 opacity-75"></span>
            <span class="relative inline-flex h-3.5 w-3.5 rounded-full bg-indigo-400 ring-2 ring-zinc-900"></span>
          </span>
        </div>
        <div>
          <div class="flex flex-wrap items-center gap-2">
            <span class="inline-flex items-center gap-1.5 rounded-full bg-sky-500/15 px-2.5 py-1 text-[11px] font-semibold uppercase tracking-wider text-sky-300 ring-1 ring-sky-400/30">
              <i class="fa-solid fa-envelope-open-text text-[10px]"></i> SMTP
            </span>
            <span class="inline-flex items-center gap-1.5 rounded-full bg-indigo-500/15 px-2.5 py-1 text-[11px] font-semibold uppercase tracking-wider text-indigo-300 ring-1 ring-indigo-400/30">
              <i class="fa-solid fa-lock text-[10px]"></i> SSL / TLS
            </span>
            <span class="inline-flex items-center gap-1.5 rounded-full bg-emerald-500/15 px-2.5 py-1 text-[11px] font-semibold uppercase tracking-wider text-emerald-300 ring-1 ring-emerald-400/30">
              <i class="fa-solid fa-list-check text-[10px]"></i> Validated
            </span>
          </div>
          <h1 class="mt-2 text-2xl sm:text-3xl font-bold tracking-tight text-white">{{ $t('email.title') }}</h1>
          <p class="mt-1 max-w-2xl text-sm text-zinc-300">Compose and dispatch a test email through any <span class="font-semibold text-sky-300">SMTP host</span> &mdash; with full per-field validation and inline error reporting.</p>
        </div>
      </div>

      <div class="grid grid-cols-2 gap-3 sm:gap-4">
        <div class="rounded-2xl border border-white/10 bg-white/5 p-3 sm:p-4 text-center backdrop-blur">
          <div class="text-[10px] uppercase tracking-wider text-zinc-400">Default port</div>
          <div class="mt-1 text-2xl font-bold text-white font-mono">1025</div>
        </div>
        <div class="rounded-2xl border border-white/10 bg-white/5 p-3 sm:p-4 text-center backdrop-blur">
          <div class="text-[10px] uppercase tracking-wider text-zinc-400">Status</div>
          {% if hasSuccess %}
          <div class="mt-1 flex items-center justify-center gap-1.5 text-base sm:text-lg font-bold text-emerald-300">
            <i class="fa-solid fa-circle-check"></i> Sent
          </div>
          {% elif hasFailed %}
          <div class="mt-1 flex items-center justify-center gap-1.5 text-base sm:text-lg font-bold text-rose-300">
            <i class="fa-solid fa-circle-xmark"></i> Failed
          </div>
          {% else %}
          <div class="mt-1 flex items-center justify-center gap-1.5 text-base sm:text-lg font-bold text-zinc-200">
            <i class="fa-solid fa-circle text-[10px] animate-pulse"></i> Idle
          </div>
          {% endif %}
        </div>
      </div>
    </div>
  </section>

  {# ============== FLASH ALERTS ============== #}
  {% if hasSuccess %}
  <div class="reveal-up flex items-start gap-3 rounded-2xl border border-emerald-200 bg-gradient-to-r from-emerald-50 to-green-50 p-4 shadow-soft">
    <span class="grid h-10 w-10 shrink-0 place-items-center rounded-xl bg-emerald-500 text-white shadow-sm">
      <i class="fa-solid fa-circle-check text-lg"></i>
    </span>
    <div class="flex-1">
      <p class="text-sm font-bold text-emerald-900">{{ $t('email.success') }}</p>
      <p class="mt-0.5 text-xs text-emerald-700">Your message was accepted by the SMTP server.</p>
    </div>
  </div>
  {% endif %}

  {% if hasFailed %}
  <div class="reveal-up flex items-start gap-3 rounded-2xl border border-rose-200 bg-gradient-to-r from-rose-50 to-pink-50 p-4 shadow-soft">
    <span class="grid h-10 w-10 shrink-0 place-items-center rounded-xl bg-rose-500 text-white shadow-sm">
      <i class="fa-solid fa-triangle-exclamation text-lg"></i>
    </span>
    <div class="flex-1">
      <p class="text-sm font-bold text-rose-900">{{ $t('email.failed') }}</p>
      <p class="mt-0.5 text-xs text-rose-700">Please review the SMTP host, port and credentials and try again.</p>
    </div>
  </div>
  {% endif %}

  {# ============== EMAIL FORM ============== #}
  <section class="reveal-up overflow-hidden rounded-2xl border border-zinc-200 bg-white shadow-soft">
    <div class="flex items-center justify-between gap-3 bg-gradient-to-r from-sky-50 to-indigo-50 px-5 py-4 border-b border-zinc-200">
      <div class="flex items-center gap-3">
        <span class="grid h-10 w-10 place-items-center rounded-xl bg-gradient-to-br from-sky-500 to-indigo-600 text-white shadow-sm ring-1 ring-sky-300/50">
          <i class="fa-solid fa-paper-plane text-sm"></i>
        </span>
        <div>
          <h3 class="text-base font-bold text-zinc-900">Compose email</h3>
          <p class="text-xs text-zinc-500">Fill in the message and SMTP details to send</p>
        </div>
      </div>
      <span class="hidden sm:inline-flex items-center gap-1.5 rounded-full bg-sky-100 px-2.5 py-1 text-[10px] font-semibold uppercase tracking-wider text-sky-800 ring-1 ring-sky-200">
        <i class="fa-solid fa-shield-halved text-[9px]"></i> Validated
      </span>
    </div>

    <form method="post" action="{{ $e.routeUrl('root.email.post') }}" class="space-y-6 p-5 sm:p-6">

      {# ----- Sender section ----- #}
      <fieldset>
        <legend class="mb-3 flex items-center gap-2 text-[11px] font-bold uppercase tracking-wider text-sky-700">
          <span class="grid h-6 w-6 place-items-center rounded-md bg-sky-100 text-sky-600 ring-1 ring-sky-200">
            <i class="fa-solid fa-user text-[10px]"></i>
          </span>
          Sender
        </legend>
        <div class="grid gap-4 md:grid-cols-2">
          <div>
            <label for="from" class="mb-1 block text-[11px] font-semibold uppercase tracking-wider text-zinc-600">{{ $t('email.from') }}</label>
            <div class="relative">
              <i class="fa-solid fa-at pointer-events-none absolute left-3 top-1/2 -translate-y-1/2 text-xs text-sky-500"></i>
              <input
                value="{{ $n('emailForm/from/value') }}"
                type="text"
                name="from"
                id="from"
                class="h-10 w-full rounded-lg border border-zinc-300 bg-white pl-9 pr-3 text-sm shadow-sm transition-all duration-200 focus:border-sky-500 focus:ring-2 focus:ring-sky-500/20 {{ 'border-rose-400 ring-2 ring-rose-200 focus:border-rose-500 focus:ring-rose-300' if $n('emailForm/from/failed') else '' }}"
              />
            </div>
            <div class="mt-1 flex items-center gap-1 text-xs text-rose-600 {{ '' if $n('emailForm/from/failed') else 'hidden' }}">
              <i class="fa-solid fa-circle-exclamation text-[10px]"></i>
              {{ $t($n('emailForm/from/errors/0')) }}
            </div>
          </div>
          <div>
            <label for="fromName" class="mb-1 block text-[11px] font-semibold uppercase tracking-wider text-zinc-600">{{ $t('email.fromName') }}</label>
            <div class="relative">
              <i class="fa-solid fa-id-badge pointer-events-none absolute left-3 top-1/2 -translate-y-1/2 text-xs text-sky-500"></i>
              <input
                value="{{ $n('emailForm/fromName/value') }}"
                type="text"
                name="fromName"
                id="fromName"
                placeholder="{{ $t('email.placeholder.name') }}"
                class="h-10 w-full rounded-lg border border-zinc-300 bg-white pl-9 pr-3 text-sm shadow-sm transition-all duration-200 focus:border-sky-500 focus:ring-2 focus:ring-sky-500/20 {{ 'border-rose-400 ring-2 ring-rose-200 focus:border-rose-500 focus:ring-rose-300' if $n('emailForm/fromName/failed') else '' }}"
              />
            </div>
            <div class="mt-1 flex items-center gap-1 text-xs text-rose-600 {{ '' if $n('emailForm/fromName/failed') else 'hidden' }}">
              <i class="fa-solid fa-circle-exclamation text-[10px]"></i>
              {{ $t($n('emailForm/fromName/errors/0')) }}
            </div>
          </div>
        </div>
      </fieldset>

      {# ----- Message section ----- #}
      <fieldset>
        <legend class="mb-3 flex items-center gap-2 text-[11px] font-bold uppercase tracking-wider text-indigo-700">
          <span class="grid h-6 w-6 place-items-center rounded-md bg-indigo-100 text-indigo-600 ring-1 ring-indigo-200">
            <i class="fa-solid fa-envelope text-[10px]"></i>
          </span>
          Message
        </legend>
        <div class="space-y-4">
          <div>
            <label for="email" class="mb-1 block text-[11px] font-semibold uppercase tracking-wider text-zinc-600">{{ $t('email.to') }}</label>
            <div class="relative">
              <i class="fa-solid fa-envelope pointer-events-none absolute left-3 top-1/2 -translate-y-1/2 text-xs text-indigo-500"></i>
              <input
                value="{{ $n('emailForm/email/value') }}"
                type="email"
                name="email"
                id="email"
                placeholder="{{ $t('email.placeholder.to') }}"
                class="h-10 w-full rounded-lg border border-zinc-300 bg-white pl-9 pr-3 text-sm shadow-sm transition-all duration-200 focus:border-indigo-500 focus:ring-2 focus:ring-indigo-500/20 {{ 'border-rose-400 ring-2 ring-rose-200 focus:border-rose-500 focus:ring-rose-300' if $n('emailForm/email/failed') else '' }}"
              />
            </div>
            <div class="mt-1 flex items-center gap-1 text-xs text-rose-600 {{ '' if $n('emailForm/email/failed') else 'hidden' }}">
              <i class="fa-solid fa-circle-exclamation text-[10px]"></i>
              {{ $t($n('emailForm/email/errors/0')) }}
            </div>
          </div>
          <div>
            <label for="subject" class="mb-1 block text-[11px] font-semibold uppercase tracking-wider text-zinc-600">{{ $t('email.subject') }}</label>
            <div class="relative">
              <i class="fa-solid fa-heading pointer-events-none absolute left-3 top-1/2 -translate-y-1/2 text-xs text-indigo-500"></i>
              <input
                value="{{ $n('emailForm/subject/value') }}"
                type="text"
                name="subject"
                id="subject"
                placeholder="{{ $t('email.placeholder.subject') }}"
                class="h-10 w-full rounded-lg border border-zinc-300 bg-white pl-9 pr-3 text-sm shadow-sm transition-all duration-200 focus:border-indigo-500 focus:ring-2 focus:ring-indigo-500/20 {{ 'border-rose-400 ring-2 ring-rose-200 focus:border-rose-500 focus:ring-rose-300' if $n('emailForm/subject/failed') else '' }}"
              />
            </div>
            <div class="mt-1 flex items-center gap-1 text-xs text-rose-600 {{ '' if $n('emailForm/subject/failed') else 'hidden' }}">
              <i class="fa-solid fa-circle-exclamation text-[10px]"></i>
              {{ $t($n('emailForm/subject/errors/0')) }}
            </div>
          </div>
          <div>
            <label for="message" class="mb-1 block text-[11px] font-semibold uppercase tracking-wider text-zinc-600">{{ $t('email.message') }}</label>
            <textarea
              name="message"
              id="message"
              placeholder="{{ $t('email.placeholder.message') }}"
              class="min-h-[140px] w-full rounded-lg border border-zinc-300 bg-white px-3 py-2 text-sm shadow-sm transition-all duration-200 focus:border-indigo-500 focus:ring-2 focus:ring-indigo-500/20 {{ 'border-rose-400 ring-2 ring-rose-200 focus:border-rose-500 focus:ring-rose-300' if $n('emailForm/message/failed') else '' }}"
            >{{ $n('emailForm/message/value') }}</textarea>
            <div class="mt-1 flex items-center gap-1 text-xs text-rose-600 {{ '' if $n('emailForm/message/failed') else 'hidden' }}">
              <i class="fa-solid fa-circle-exclamation text-[10px]"></i>
              {{ $t($n('emailForm/message/errors/0')) }}
            </div>
          </div>
        </div>
      </fieldset>

      {# ----- SMTP section ----- #}
      <fieldset class="rounded-xl border border-dashed border-sky-300 bg-sky-50/40 p-4">
        <legend class="ml-2 flex items-center gap-2 rounded-md bg-white px-2 py-1 text-[11px] font-bold uppercase tracking-wider text-sky-700 ring-1 ring-sky-200">
          <i class="fa-solid fa-server text-[10px]"></i>
          SMTP server
        </legend>
        <div class="space-y-4">
          <div class="grid gap-4 md:grid-cols-[1fr_140px]">
            <div>
              <label for="host" class="mb-1 block text-[11px] font-semibold uppercase tracking-wider text-zinc-600">{{ $t('email.host') }}</label>
              <div class="relative">
                <i class="fa-solid fa-server pointer-events-none absolute left-3 top-1/2 -translate-y-1/2 text-xs text-sky-500"></i>
                <input
                  value="{{ $n('emailForm/host/value') }}"
                  type="text"
                  name="host"
                  id="host"
                  placeholder="{{ $t('email.placeholder.host') }}"
                  class="h-10 w-full rounded-lg border border-zinc-300 bg-white pl-9 pr-3 text-sm shadow-sm transition-all duration-200 focus:border-sky-500 focus:ring-2 focus:ring-sky-500/20 {{ 'border-rose-400 ring-2 ring-rose-200 focus:border-rose-500 focus:ring-rose-300' if $n('emailForm/host/failed') else '' }}"
                />
              </div>
              <div class="mt-1 flex items-center gap-1 text-xs text-rose-600 {{ '' if $n('emailForm/host/failed') else 'hidden' }}">
                <i class="fa-solid fa-circle-exclamation text-[10px]"></i>
                {{ $t($n('emailForm/host/errors/0')) }}
              </div>
            </div>
            <div>
              <label for="port" class="mb-1 block text-[11px] font-semibold uppercase tracking-wider text-zinc-600">{{ $t('email.port') }}</label>
              <div class="relative">
                <i class="fa-solid fa-plug pointer-events-none absolute left-3 top-1/2 -translate-y-1/2 text-xs text-sky-500"></i>
                <input
                  value="{{ $n('emailForm/port/value') if $n('emailForm/port/value') else '1025' }}"
                  type="number"
                  name="port"
                  id="port"
                  placeholder="{{ $t('email.placeholder.port') }}"
                  class="h-10 w-full rounded-lg border border-zinc-300 bg-white pl-9 pr-3 text-sm shadow-sm transition-all duration-200 focus:border-sky-500 focus:ring-2 focus:ring-sky-500/20 {{ 'border-rose-400 ring-2 ring-rose-200 focus:border-rose-500 focus:ring-rose-300' if $n('emailForm/port/failed') else '' }}"
                />
              </div>
              <div class="mt-1 flex items-center gap-1 text-xs text-rose-600 {{ '' if $n('emailForm/port/failed') else 'hidden' }}">
                <i class="fa-solid fa-circle-exclamation text-[10px]"></i>
                {{ $t($n('emailForm/port/errors/0')) }}
              </div>
            </div>
          </div>

          <div class="grid gap-4 md:grid-cols-2">
            <div>
              <label for="username" class="mb-1 block text-[11px] font-semibold uppercase tracking-wider text-zinc-600">{{ $t('email.username') }}</label>
              <div class="relative">
                <i class="fa-solid fa-user pointer-events-none absolute left-3 top-1/2 -translate-y-1/2 text-xs text-sky-500"></i>
                <input
                  value="{{ $n('emailForm/username/value') }}"
                  type="text"
                  name="username"
                  id="username"
                  placeholder="{{ $t('email.placeholder.username') }}"
                  class="h-10 w-full rounded-lg border border-zinc-300 bg-white pl-9 pr-3 text-sm shadow-sm transition-all duration-200 focus:border-sky-500 focus:ring-2 focus:ring-sky-500/20 {{ 'border-rose-400 ring-2 ring-rose-200 focus:border-rose-500 focus:ring-rose-300' if $n('emailForm/username/failed') else '' }}"
                />
              </div>
              <div class="mt-1 flex items-center gap-1 text-xs text-rose-600 {{ '' if $n('emailForm/username/failed') else 'hidden' }}">
                <i class="fa-solid fa-circle-exclamation text-[10px]"></i>
                {{ $t($n('emailForm/username/errors/0')) }}
              </div>
            </div>
            <div>
              <label for="password" class="mb-1 block text-[11px] font-semibold uppercase tracking-wider text-zinc-600">{{ $t('email.password') }}</label>
              <div class="relative">
                <i class="fa-solid fa-lock pointer-events-none absolute left-3 top-1/2 -translate-y-1/2 text-xs text-sky-500"></i>
                <input
                  value="{{ $n('emailForm/password/value') }}"
                  type="password"
                  name="password"
                  id="password"
                  placeholder="{{ $t('email.placeholder.password') }}"
                  class="h-10 w-full rounded-lg border border-zinc-300 bg-white pl-9 pr-3 text-sm shadow-sm transition-all duration-200 focus:border-sky-500 focus:ring-2 focus:ring-sky-500/20 {{ 'border-rose-400 ring-2 ring-rose-200 focus:border-rose-500 focus:ring-rose-300' if $n('emailForm/password/failed') else '' }}"
                />
              </div>
              <div class="mt-1 flex items-center gap-1 text-xs text-rose-600 {{ '' if $n('emailForm/password/failed') else 'hidden' }}">
                <i class="fa-solid fa-circle-exclamation text-[10px]"></i>
                {{ $t($n('emailForm/password/errors/0')) }}
              </div>
            </div>
          </div>

          <div class="flex flex-wrap gap-3 pt-1">
            <label for="allowInsecure" class="inline-flex h-10 cursor-pointer items-center gap-2 rounded-lg border border-zinc-300 bg-white px-3 text-sm font-medium text-zinc-700 transition-all duration-200 hover:border-sky-400 hover:bg-sky-50">
              <input
                value="true"
                {{ $n('emailForm/allowInsecure/value') ? 'checked' : '' }}
                type="checkbox"
                name="allowInsecure"
                id="allowInsecure"
                class="h-4 w-4 rounded border-zinc-300 text-sky-600 focus:ring-2 focus:ring-sky-500/30"
              />
              <i class="fa-solid fa-shield text-xs text-amber-600"></i>
              <span>{{ $t('email.allowInsecure') }}</span>
            </label>
            <label for="ssl" class="inline-flex h-10 cursor-pointer items-center gap-2 rounded-lg border border-zinc-300 bg-white px-3 text-sm font-medium text-zinc-700 transition-all duration-200 hover:border-sky-400 hover:bg-sky-50">
              <input
                value="true"
                {{ $n('emailForm/ssl/value') ? 'checked' : '' }}
                type="checkbox"
                name="ssl"
                id="ssl"
                class="h-4 w-4 rounded border-zinc-300 text-sky-600 focus:ring-2 focus:ring-sky-500/30"
              />
              <i class="fa-solid fa-lock text-xs text-emerald-600"></i>
              <span>{{ $t('email.ssl') }}</span>
            </label>
          </div>
        </div>
      </fieldset>

      <div class="flex flex-col-reverse gap-3 border-t border-zinc-200 pt-5 sm:flex-row sm:items-center sm:justify-end">
        <button type="submit" class="wave group inline-flex items-center justify-center gap-2 rounded-xl bg-gradient-to-r from-sky-500 to-indigo-600 px-6 py-2.5 text-sm font-semibold text-white shadow-soft transition-all duration-200 hover:from-sky-600 hover:to-indigo-700 hover:shadow-soft-lg focus:outline-none focus:ring-4 focus:ring-sky-500/30">
          <i class="fa-solid fa-paper-plane text-sm transition-transform duration-200 group-hover:translate-x-0.5 group-hover:-translate-y-0.5"></i>
          <span>{{ $t('email.send') }}</span>
        </button>
      </div>
    </form>
  </section>
</div>
{% endblock %}
""",
	r"example/form.j2.html": r"""{% extends 'template/template.j2.html' %}
{% block title %}
    {{ $t('sidebar.formExample') }}
{% endblock %}

{% block content %}
{% set isLoggedIn = (loginResult == true or user != null) %}

<div class="space-y-6">

  {# ============== HERO ============== #}
  <section class="reveal-up relative overflow-hidden rounded-3xl border border-zinc-200 bg-gradient-to-br from-zinc-900 via-rose-950 to-pink-950 p-6 sm:p-8 shadow-soft">
    <div class="pointer-events-none absolute -top-24 -end-24 h-72 w-72 rounded-full bg-rose-500/20 blur-3xl"></div>
    <div class="pointer-events-none absolute -bottom-24 -start-24 h-72 w-72 rounded-full bg-pink-500/20 blur-3xl"></div>

    <div class="relative flex flex-col gap-6 lg:flex-row lg:items-center lg:justify-between">
      <div class="flex items-start gap-4">
        <div class="relative">
          <div class="inline-flex h-14 w-14 items-center justify-center rounded-2xl bg-white/10 ring-1 ring-white/20 backdrop-blur">
            <i class="fa-solid fa-shield-halved text-2xl text-rose-300"></i>
          </div>
          <span class="absolute -top-1 -end-1 inline-flex h-3.5 w-3.5">
            <span class="absolute inline-flex h-full w-full animate-ping rounded-full bg-pink-400 opacity-75"></span>
            <span class="relative inline-flex h-3.5 w-3.5 rounded-full bg-pink-400 ring-2 ring-zinc-900"></span>
          </span>
        </div>
        <div>
          <div class="flex flex-wrap items-center gap-2">
            <span class="inline-flex items-center gap-1.5 rounded-full bg-rose-500/15 px-2.5 py-1 text-[11px] font-semibold uppercase tracking-wider text-rose-300 ring-1 ring-rose-400/30">
              <i class="fa-solid fa-list-check text-[10px]"></i> Validation
            </span>
            <span class="inline-flex items-center gap-1.5 rounded-full bg-pink-500/15 px-2.5 py-1 text-[11px] font-semibold uppercase tracking-wider text-pink-300 ring-1 ring-pink-400/30">
              <i class="fa-solid fa-shield text-[10px]"></i> Server-side
            </span>
            <span class="inline-flex items-center gap-1.5 rounded-full bg-emerald-500/15 px-2.5 py-1 text-[11px] font-semibold uppercase tracking-wider text-emerald-300 ring-1 ring-emerald-400/30">
              <i class="fa-solid fa-lock text-[10px]"></i> CSRF
            </span>
          </div>
          <h1 class="mt-2 text-2xl sm:text-3xl font-bold tracking-tight text-white">{{ $t('form.validation.title') }}</h1>
          <p class="mt-1 max-w-2xl text-sm text-zinc-300">A complete login flow built with Finch's <span class="text-rose-300 font-semibold">FormValidator</span> &mdash; type-safe rules, friendly errors and built-in CSRF protection.</p>
        </div>
      </div>

      <div class="grid grid-cols-2 gap-3 sm:gap-4">
        <div class="rounded-2xl border border-white/10 bg-white/5 p-3 sm:p-4 text-center backdrop-blur">
          <div class="text-[10px] uppercase tracking-wider text-zinc-400">Status</div>
          <div class="mt-1 flex items-center justify-center gap-1.5 text-base sm:text-lg font-bold {{ 'text-emerald-300' if isLoggedIn else 'text-rose-300' }}">
            <i class="fa-solid {{ 'fa-circle-check' if isLoggedIn else 'fa-circle-xmark' }}"></i>
            {{ 'Signed in' if isLoggedIn else 'Signed out' }}
          </div>
        </div>
        <div class="rounded-2xl border border-white/10 bg-white/5 p-3 sm:p-4 text-center backdrop-blur">
          <div class="text-[10px] uppercase tracking-wider text-zinc-400">Method</div>
          <div class="mt-1 text-base sm:text-lg font-bold text-white">
            <span class="font-mono">POST</span>
          </div>
        </div>
      </div>
    </div>
  </section>

  {# ============== TEST CREDENTIALS ============== #}
  <section class="reveal-up overflow-hidden rounded-2xl border border-amber-200 bg-gradient-to-br from-amber-50 to-orange-50 shadow-soft">
    <div class="flex flex-col gap-4 p-5 sm:flex-row sm:items-center sm:justify-between">
      <div class="flex items-start gap-3">
        <div class="grid h-11 w-11 shrink-0 place-items-center rounded-xl bg-gradient-to-br from-amber-500 to-orange-600 text-white shadow-sm ring-1 ring-amber-300/50">
          <i class="fa-solid fa-key text-base"></i>
        </div>
        <div>
          <p class="text-sm font-bold text-zinc-900">{{ $t('Test Credentials') }}</p>
          <p class="text-xs text-zinc-600">Use these to try the login form.</p>
        </div>
      </div>
      <div class="flex flex-wrap items-center gap-2">
        <span class="inline-flex items-center gap-1.5 rounded-lg border border-amber-200 bg-white px-3 py-1.5 shadow-sm">
          <i class="fa-solid fa-envelope text-[11px] text-amber-600"></i>
          <span class="text-[11px] font-semibold uppercase tracking-wider text-zinc-500">{{ $t('form.validation.credentials.email') }}</span>
          <code class="rounded bg-amber-100 px-1.5 py-0.5 text-xs font-mono text-amber-900">example@finchdart.com</code>
        </span>
        <span class="inline-flex items-center gap-1.5 rounded-lg border border-amber-200 bg-white px-3 py-1.5 shadow-sm">
          <i class="fa-solid fa-lock text-[11px] text-amber-600"></i>
          <span class="text-[11px] font-semibold uppercase tracking-wider text-zinc-500">{{ $t('form.validation.credentials.password') }}</span>
          <code class="rounded bg-amber-100 px-1.5 py-0.5 text-xs font-mono text-amber-900">@Test123</code>
        </span>
      </div>
    </div>
  </section>

  {% if not isLoggedIn %}
  {# ============== LOGIN FORM ============== #}
  <section class="reveal-up overflow-hidden rounded-2xl border border-zinc-200 bg-white shadow-soft">
    <div class="flex items-center justify-between gap-3 bg-gradient-to-r from-rose-50 to-pink-50 px-5 py-4 border-b border-zinc-200">
      <div class="flex items-center gap-3">
        <span class="grid h-10 w-10 place-items-center rounded-xl bg-gradient-to-br from-rose-500 to-pink-600 text-white shadow-sm ring-1 ring-rose-300/50">
          <i class="fa-solid fa-right-to-bracket text-sm"></i>
        </span>
        <div>
          <h3 class="text-base font-bold text-zinc-900">{{ $t('Login Form') }}</h3>
          <p class="text-xs text-zinc-500">{{ $t('Enter your credentials to continue') }}</p>
        </div>
      </div>
      <span class="hidden sm:inline-flex items-center gap-1.5 rounded-full bg-zinc-900 px-2.5 py-1 text-[10px] font-semibold uppercase tracking-wider text-rose-300 ring-1 ring-rose-400/30">
        <i class="fa-solid fa-shield-halved text-[9px]"></i> Validated
      </span>
    </div>
    <div class="p-5 sm:p-6">
      {% include form_login.widget | unscape %}
    </div>
  </section>
  {% else %}
  {# ============== SUCCESS CARD ============== #}
  <section class="reveal-up overflow-hidden rounded-2xl border border-emerald-200 bg-gradient-to-br from-emerald-50 via-white to-green-50 shadow-soft">
    <div class="flex flex-col gap-4 p-5 sm:flex-row sm:items-center sm:justify-between sm:p-6">
      <div class="flex items-center gap-4">
        <div class="relative grid h-14 w-14 place-items-center rounded-2xl bg-gradient-to-br from-emerald-500 to-green-600 text-white shadow-lg ring-1 ring-emerald-300/50">
          <i class="fa-solid fa-circle-check text-2xl"></i>
          <span class="absolute -top-1 -right-1 inline-flex h-3 w-3">
            <span class="absolute inline-flex h-full w-full animate-ping rounded-full bg-emerald-400 opacity-75"></span>
            <span class="relative inline-flex h-3 w-3 rounded-full bg-emerald-500 ring-2 ring-white"></span>
          </span>
        </div>
        <div>
          <p class="text-base font-bold text-emerald-900">{{ $t('form.validation.loginSuccess') }}</p>
          <p class="mt-0.5 text-sm text-emerald-700">{{ $t('Logged in as') }} <span class="rounded-md bg-emerald-100 px-2 py-0.5 font-mono text-xs font-semibold text-emerald-800">{{ user.name }}</span></p>
        </div>
      </div>
      <a href="{{ $e.routeUrl('root.logout') }}" class="wave inline-flex shrink-0 items-center justify-center gap-2 rounded-xl bg-gradient-to-r from-rose-500 to-pink-600 px-4 py-2.5 text-sm font-semibold text-white shadow-soft transition-all duration-200 hover:from-rose-600 hover:to-pink-700 hover:shadow-soft-lg focus:outline-none focus:ring-4 focus:ring-rose-500/30">
        <i class="fa-solid fa-right-from-bracket text-sm"></i>
        <span>{{ $t('form.validation.logout') }}</span>
      </a>
    </div>
  </section>
  {% endif %}

  {# ============== FILE REFERENCES ============== #}
  <section class="reveal-up overflow-hidden rounded-2xl border border-zinc-200 bg-white shadow-soft">
    <div class="flex items-center justify-between gap-3 bg-gradient-to-r from-zinc-50 to-white px-5 py-4 border-b border-zinc-200">
      <div class="flex items-center gap-3">
        <span class="grid h-10 w-10 place-items-center rounded-xl bg-gradient-to-br from-zinc-700 to-zinc-900 text-white shadow-sm ring-1 ring-zinc-300/50">
          <i class="fa-solid fa-folder-tree text-sm"></i>
        </span>
        <div>
          <h3 class="text-base font-bold text-zinc-900">{{ $t('File References') }}</h3>
          <p class="text-xs text-zinc-500">{{ $t('Related files for this form example') }}</p>
        </div>
      </div>
      <span class="hidden sm:inline-flex items-center gap-1.5 rounded-full bg-zinc-100 px-2.5 py-1 text-[10px] font-semibold uppercase tracking-wider text-zinc-600 ring-1 ring-zinc-200">
        <i class="fa-solid fa-code text-[9px]"></i> Source
      </span>
    </div>
    <ul class="divide-y divide-zinc-100">
      <li class="group transition-colors duration-150 hover:bg-rose-50/50">
        <div class="flex flex-col gap-3 px-5 py-3.5 md:flex-row md:items-center md:gap-4">
          <div class="flex items-center gap-2.5 md:w-56">
            <span class="grid h-8 w-8 place-items-center rounded-lg bg-rose-100 text-rose-600 ring-1 ring-rose-200">
              <i class="fa-regular fa-eye text-xs"></i>
            </span>
            <span class="text-sm font-semibold text-zinc-700">{{ $t('form.validation.view') }}</span>
          </div>
          <code class="break-all rounded-md bg-zinc-100 px-3 py-1.5 text-xs font-mono text-rose-700 ring-1 ring-zinc-200 group-hover:bg-rose-100 group-hover:ring-rose-200">example/lib/widgets/example/form.j2.html</code>
        </div>
      </li>
      <li class="group transition-colors duration-150 hover:bg-rose-50/50">
        <div class="flex flex-col gap-3 px-5 py-3.5 md:flex-row md:items-center md:gap-4">
          <div class="flex items-center gap-2.5 md:w-56">
            <span class="grid h-8 w-8 place-items-center rounded-lg bg-pink-100 text-pink-600 ring-1 ring-pink-200">
              <i class="fa-solid fa-code text-xs"></i>
            </span>
            <span class="text-sm font-semibold text-zinc-700">{{ $t('form.validation.controller') }}</span>
          </div>
          <code class="break-all rounded-md bg-zinc-100 px-3 py-1.5 text-xs font-mono text-pink-700 ring-1 ring-zinc-200 group-hover:bg-pink-100 group-hover:ring-pink-200">example/lib/controllers/home_controller.dart</code>
        </div>
      </li>
    </ul>
  </section>
</div>
{% endblock %}
""",
	r"example/route.j2.html": r"""{% extends 'template/template.j2.html' %}

{% block title %}
    {{ $t('sidebar.routeExample') }}
{% endblock %}

{% block content %}
<div class="space-y-6">

  {# ============== HERO ============== #}
  <section class="reveal-up relative overflow-hidden rounded-3xl border border-zinc-200 bg-gradient-to-br from-zinc-900 via-blue-950 to-indigo-950 p-6 sm:p-8 shadow-soft">
    <div class="pointer-events-none absolute -top-24 -end-24 h-72 w-72 rounded-full bg-blue-500/20 blur-3xl"></div>
    <div class="pointer-events-none absolute -bottom-24 -start-24 h-72 w-72 rounded-full bg-indigo-500/20 blur-3xl"></div>

    <div class="relative flex flex-col gap-6 lg:flex-row lg:items-center lg:justify-between">
      <div class="flex items-start gap-4">
        <div class="relative">
          <div class="inline-flex h-14 w-14 items-center justify-center rounded-2xl bg-white/10 ring-1 ring-white/20 backdrop-blur">
            <i class="fa-solid fa-route text-2xl text-blue-300"></i>
          </div>
          <span class="absolute -top-1 -end-1 inline-flex h-3.5 w-3.5">
            <span class="absolute inline-flex h-full w-full animate-ping rounded-full bg-indigo-400 opacity-75"></span>
            <span class="relative inline-flex h-3.5 w-3.5 rounded-full bg-indigo-400 ring-2 ring-zinc-900"></span>
          </span>
        </div>
        <div>
          <div class="flex flex-wrap items-center gap-2">
            <span class="inline-flex items-center gap-1.5 rounded-full bg-blue-500/15 px-2.5 py-1 text-[11px] font-semibold uppercase tracking-wider text-blue-300 ring-1 ring-blue-400/30">
              <i class="fa-solid fa-sitemap text-[10px]"></i> Router map
            </span>
            <span class="inline-flex items-center gap-1.5 rounded-full bg-indigo-500/15 px-2.5 py-1 text-[11px] font-semibold uppercase tracking-wider text-indigo-300 ring-1 ring-indigo-400/30">
              <i class="fa-solid fa-shield text-[10px]"></i> Middleware
            </span>
            <span class="inline-flex items-center gap-1.5 rounded-full bg-emerald-500/15 px-2.5 py-1 text-[11px] font-semibold uppercase tracking-wider text-emerald-300 ring-1 ring-emerald-400/30">
              <i class="fa-solid fa-lock text-[10px]"></i> Auth-aware
            </span>
          </div>
          <h1 class="mt-2 text-2xl sm:text-3xl font-bold tracking-tight text-white">{{ $t('webRouteExample.title') }}</h1>
          <p class="mt-1 max-w-2xl text-sm text-zinc-300">A live registry of every <span class="font-semibold text-blue-300">FinchRoute</span> &mdash; methods, paths, permissions, auth requirements and the controllers that handle them.</p>
        </div>
      </div>

      <div class="grid grid-cols-2 gap-3 sm:gap-4">
        <div class="rounded-2xl border border-white/10 bg-white/5 p-3 sm:p-4 text-center backdrop-blur">
          <div class="text-[10px] uppercase tracking-wider text-zinc-400">Routes</div>
          <div class="mt-1 text-2xl font-bold text-white">{{ routes | length }}</div>
        </div>
        <div class="rounded-2xl border border-white/10 bg-white/5 p-3 sm:p-4 text-center backdrop-blur">
          <div class="text-[10px] uppercase tracking-wider text-zinc-400">Status</div>
          <div class="mt-1 flex items-center justify-center gap-1.5 text-base sm:text-lg font-bold text-emerald-300">
            <i class="fa-solid fa-circle text-[10px] animate-pulse"></i>
            Active
          </div>
        </div>
      </div>
    </div>
  </section>

  {# ============== ROUTES TABLE ============== #}
  <section class="reveal-up overflow-hidden rounded-2xl border border-zinc-200 bg-white shadow-soft">
    <div class="flex items-center justify-between gap-3 bg-gradient-to-r from-zinc-50 to-white px-5 py-4 border-b border-zinc-200">
      <div class="flex items-center gap-3">
        <span class="grid h-10 w-10 place-items-center rounded-xl bg-gradient-to-br from-blue-500 to-indigo-600 text-white shadow-sm ring-1 ring-blue-300/50">
          <i class="fa-solid fa-sitemap text-sm"></i>
        </span>
        <div>
          <h3 class="text-base font-bold text-zinc-900">Registered routes</h3>
          <p class="text-xs text-zinc-500">{{ routes | length }} {{ 'route' if routes | length == 1 else 'routes' }} discovered</p>
        </div>
      </div>
      <span class="hidden sm:inline-flex items-center gap-1.5 rounded-full bg-blue-100 px-2.5 py-1 text-[10px] font-semibold uppercase tracking-wider text-blue-800 ring-1 ring-blue-200">
        <i class="fa-solid fa-bolt text-[9px]"></i> Runtime
      </span>
    </div>

    <div class="overflow-x-auto">
      <table class="min-w-full divide-y divide-zinc-200">
        <thead class="bg-zinc-50">
          <tr>
            <th class="px-4 py-3 text-left text-[11px] font-bold uppercase tracking-wider text-zinc-600">#</th>
            <th class="px-4 py-3 text-left text-[11px] font-bold uppercase tracking-wider text-zinc-600">{{ $t('webRouteExample.path') }}</th>
            <th class="px-4 py-3 text-left text-[11px] font-bold uppercase tracking-wider text-zinc-600">{{ $t('webRouteExample.type') }}</th>
            <th class="px-4 py-3 text-left text-[11px] font-bold uppercase tracking-wider text-zinc-600">{{ $t('webRouteExample.permissions') }}</th>
            <th class="px-4 py-3 text-center text-[11px] font-bold uppercase tracking-wider text-zinc-600">{{ $t('webRouteExample.auth') }}</th>
            <th class="px-4 py-3 text-left text-[11px] font-bold uppercase tracking-wider text-zinc-600">{{ $t('webRouteExample.controller') }}</th>
          </tr>
        </thead>
        <tbody class="divide-y divide-zinc-100 bg-white">
          {% for route in routes %}
          <tr class="group transition-colors duration-150 hover:bg-blue-50/50">
            <td class="px-4 py-3 align-middle">
              <span class="inline-flex h-7 w-7 items-center justify-center rounded-md bg-zinc-100 text-[11px] font-bold text-zinc-600 ring-1 ring-zinc-200">{{ loop.index }}</span>
            </td>
            <td class="px-4 py-3 align-middle text-sm">
              <div class="flex flex-wrap items-center gap-2">
                <span class="inline-flex items-center rounded-md bg-gradient-to-r from-blue-600 to-indigo-600 px-2 py-0.5 text-[10px] font-bold uppercase tracking-wider text-white shadow-sm">{{ route.method }}</span>
                <a class="inline-flex items-center gap-1.5 font-mono text-sm font-semibold text-blue-700 transition-colors duration-150 hover:text-blue-900 hover:underline" href="{{ route.fullPath }}">
                  <span>{{ route.fullPath }}</span>
                  <i class="fa-solid fa-arrow-up-right-from-square text-[10px] opacity-0 transition-opacity duration-150 group-hover:opacity-100"></i>
                </a>
              </div>
              {% if route.key %}
              <div class="mt-1 inline-flex items-center gap-1 text-[11px] font-mono text-zinc-500">
                <i class="fa-solid fa-key text-[9px] text-zinc-400"></i>
                {{ route.key }}
              </div>
              {% endif %}
            </td>
            <td class="px-4 py-3 align-middle">
              <span class="inline-flex items-center gap-1.5 rounded-full bg-indigo-100 px-2.5 py-1 text-[11px] font-semibold text-indigo-800 ring-1 ring-indigo-200">
                <i class="fa-solid fa-tag text-[9px]"></i>
                {{ route.type }}
              </span>
            </td>
            <td class="px-4 py-3 align-middle text-sm text-zinc-700">
              {% if route.permissions %}
              <span class="inline-flex items-center gap-1.5 rounded-md bg-amber-50 px-2 py-1 text-xs font-medium text-amber-800 ring-1 ring-amber-200">
                <i class="fa-solid fa-shield-halved text-[10px]"></i>
                {{ route.permissions }}
              </span>
              {% else %}
              <span class="text-xs text-zinc-400">&mdash;</span>
              {% endif %}
            </td>
            <td class="px-4 py-3 align-middle text-center">
              {% if route.hasAuth %}
              <span class="inline-flex h-7 items-center gap-1 rounded-full bg-emerald-100 px-2.5 text-[11px] font-bold text-emerald-700 ring-1 ring-emerald-200">
                <i class="fa-solid fa-lock text-[10px]"></i> Yes
              </span>
              {% else %}
              <span class="inline-flex h-7 items-center gap-1 rounded-full bg-zinc-100 px-2.5 text-[11px] font-semibold text-zinc-500 ring-1 ring-zinc-200">
                <i class="fa-solid fa-lock-open text-[10px]"></i> No
              </span>
              {% endif %}
            </td>
            <td class="px-4 py-3 align-middle text-sm">
              {% if route.middlewares %}
              <div class="mb-1 flex flex-wrap gap-1">
                {% for mw in route.middlewares %}
                <span class="inline-flex items-center gap-1 rounded-md bg-violet-50 px-1.5 py-0.5 text-[10px] font-mono font-semibold text-violet-700 ring-1 ring-violet-200">
                  <i class="fa-solid fa-layer-group text-[8px]"></i>{{ mw }}
                </span>
                {% endfor %}
              </div>
              {% endif %}
              <div class="font-mono text-xs text-zinc-700">{{ route.controller }}{{ route.index }}</div>
            </td>
          </tr>
          {% endfor %}
          {% if routes | length == 0 %}
          <tr>
            <td colspan="6" class="px-5 py-10 text-center">
              <div class="mx-auto flex max-w-sm flex-col items-center gap-2">
                <span class="grid h-14 w-14 place-items-center rounded-2xl bg-blue-50 text-blue-400 ring-1 ring-blue-100">
                  <i class="fa-solid fa-route text-2xl"></i>
                </span>
                <p class="text-sm font-semibold text-zinc-700">No routes registered</p>
              </div>
            </td>
          </tr>
          {% endif %}
        </tbody>
      </table>
    </div>
  </section>

  {# ============== FILE REFERENCES ============== #}
  <section class="reveal-up overflow-hidden rounded-2xl border border-zinc-200 bg-white shadow-soft">
    <div class="flex items-center justify-between gap-3 bg-gradient-to-r from-zinc-50 to-white px-5 py-4 border-b border-zinc-200">
      <div class="flex items-center gap-3">
        <span class="grid h-10 w-10 place-items-center rounded-xl bg-gradient-to-br from-zinc-700 to-zinc-900 text-white shadow-sm ring-1 ring-zinc-300/50">
          <i class="fa-solid fa-folder-tree text-sm"></i>
        </span>
        <div>
          <h3 class="text-base font-bold text-zinc-900">File References</h3>
          <p class="text-xs text-zinc-500">Where the router lives</p>
        </div>
      </div>
    </div>
    <ul class="divide-y divide-zinc-100">
      <li class="group transition-colors duration-150 hover:bg-blue-50/50">
        <div class="flex flex-col gap-3 px-5 py-3.5 md:flex-row md:items-center md:gap-4">
          <div class="flex items-center gap-2.5 md:w-56">
            <span class="grid h-8 w-8 place-items-center rounded-lg bg-blue-100 text-blue-600 ring-1 ring-blue-200">
              <i class="fa-solid fa-route text-xs"></i>
            </span>
            <span class="text-sm font-semibold text-zinc-700">{{ $t('webRouteExample.router') }}</span>
          </div>
          <code class="break-all rounded-md bg-zinc-100 px-3 py-1.5 text-xs font-mono text-blue-700 ring-1 ring-zinc-200 group-hover:bg-blue-100 group-hover:ring-blue-200">example/lib/route/web_route.dart</code>
        </div>
      </li>
    </ul>
  </section>
</div>
{% endblock %}
""",
	r"example/pagination.j2.html": r"""{% extends 'template/template.j2.html' %}

{% block title %}
    {{ $t('sidebar.paginationExample') }}
{% endblock %}

{% block content %}
<div class="space-y-6">

  {# ============== HERO ============== #}
  <section class="reveal-up relative overflow-hidden rounded-3xl border border-zinc-200 bg-gradient-to-br from-zinc-900 via-cyan-950 to-blue-950 p-6 sm:p-8 shadow-soft">
    <div class="pointer-events-none absolute -top-24 -end-24 h-72 w-72 rounded-full bg-cyan-500/20 blur-3xl"></div>
    <div class="pointer-events-none absolute -bottom-24 -start-24 h-72 w-72 rounded-full bg-blue-500/20 blur-3xl"></div>

    <div class="relative flex flex-col gap-6 lg:flex-row lg:items-center lg:justify-between">
      <div class="flex items-start gap-4">
        <div class="relative">
          <div class="inline-flex h-14 w-14 items-center justify-center rounded-2xl bg-white/10 ring-1 ring-white/20 backdrop-blur">
            <i class="fa-solid fa-bars-staggered text-2xl text-cyan-300"></i>
          </div>
          <span class="absolute -top-1 -end-1 inline-flex h-3.5 w-3.5">
            <span class="absolute inline-flex h-full w-full animate-ping rounded-full bg-blue-400 opacity-75"></span>
            <span class="relative inline-flex h-3.5 w-3.5 rounded-full bg-blue-400 ring-2 ring-zinc-900"></span>
          </span>
        </div>
        <div>
          <div class="flex flex-wrap items-center gap-2">
            <span class="inline-flex items-center gap-1.5 rounded-full bg-cyan-500/15 px-2.5 py-1 text-[11px] font-semibold uppercase tracking-wider text-cyan-300 ring-1 ring-cyan-400/30">
              <i class="fa-solid fa-table-list text-[10px]"></i> UIPaging
            </span>
            <span class="inline-flex items-center gap-1.5 rounded-full bg-blue-500/15 px-2.5 py-1 text-[11px] font-semibold uppercase tracking-wider text-blue-300 ring-1 ring-blue-400/30">
              <i class="fa-solid fa-arrows-left-right text-[10px]"></i> Multi-instance
            </span>
            <span class="inline-flex items-center gap-1.5 rounded-full bg-indigo-500/15 px-2.5 py-1 text-[11px] font-semibold uppercase tracking-wider text-indigo-300 ring-1 ring-indigo-400/30">
              <i class="fa-solid fa-link text-[10px]"></i> Query-preserving
            </span>
          </div>
          <h1 class="mt-2 text-2xl sm:text-3xl font-bold tracking-tight text-white">{{ $t('sidebar.paginationExample') }}</h1>
          <p class="mt-1 max-w-2xl text-sm text-zinc-300">Render multiple <span class="font-semibold text-cyan-300">UIPaging</span> widgets on the same page with independent <code class="rounded bg-white/10 px-1 text-[12px] text-cyan-200">prefix</code> and <code class="rounded bg-white/10 px-1 text-[12px] text-cyan-200">otherQuery</code> so each pager preserves the others' state.</p>
        </div>
      </div>

      <div class="grid grid-cols-3 gap-3 sm:gap-4">
        <div class="rounded-2xl border border-white/10 bg-white/5 p-3 sm:p-4 text-center backdrop-blur">
          <div class="text-[10px] uppercase tracking-wider text-zinc-400">Pagers</div>
          <div class="mt-1 text-2xl font-bold text-white">3</div>
        </div>
        <div class="rounded-2xl border border-white/10 bg-white/5 p-3 sm:p-4 text-center backdrop-blur">
          <div class="text-[10px] uppercase tracking-wider text-zinc-400">Records</div>
          <div class="mt-1 text-2xl font-bold text-white">2,500</div>
        </div>
        <div class="rounded-2xl border border-white/10 bg-white/5 p-3 sm:p-4 text-center backdrop-blur">
          <div class="text-[10px] uppercase tracking-wider text-zinc-400">Styles</div>
          <div class="mt-1 flex items-center justify-center gap-1.5 text-base sm:text-lg font-bold text-white">
            <i class="fa-solid fa-palette text-[12px] text-cyan-300"></i>
            <span>3</span>
          </div>
        </div>
      </div>
    </div>
  </section>

  {# ============== PAGER A — DEFAULT ============== #}
  <section class="reveal-up overflow-hidden rounded-2xl border border-zinc-200 bg-white shadow-soft">
    <div class="flex flex-wrap items-center justify-between gap-3 bg-gradient-to-r from-cyan-50 to-blue-50 px-5 py-4 border-b border-zinc-200">
      <div class="flex items-center gap-3">
        <span class="grid h-10 w-10 place-items-center rounded-xl bg-gradient-to-br from-cyan-500 to-blue-600 text-white shadow-sm ring-1 ring-cyan-300/50">
          <i class="fa-solid fa-1 text-sm font-bold"></i>
        </span>
        <div>
          <h3 class="text-base font-bold text-zinc-900">Pager A — default width</h3>
          <p class="text-xs text-zinc-500">1,000 records · 10 per page · prefix <code class="rounded bg-cyan-100 px-1 text-cyan-800">page_a</code></p>
        </div>
      </div>
      <div class="flex flex-wrap items-center gap-2">
        <span class="inline-flex items-center gap-1.5 rounded-full bg-white px-2.5 py-1 text-[10px] font-semibold uppercase tracking-wider text-cyan-700 ring-1 ring-cyan-200">
          <i class="fa-solid fa-database text-[9px]"></i> total 1000
        </span>
        <span class="inline-flex items-center gap-1.5 rounded-full bg-white px-2.5 py-1 text-[10px] font-semibold uppercase tracking-wider text-blue-700 ring-1 ring-blue-200">
          <i class="fa-solid fa-layer-group text-[9px]"></i> page-size 10
        </span>
      </div>
    </div>
    <div class="p-5">
      <div class="rounded-xl border border-dashed border-cyan-200 bg-gradient-to-br from-cyan-50/40 to-blue-50/40 p-4">
        {{ paginationA }}
      </div>
    </div>
  </section>

  {# ============== PAGER B — WIDE SIDE ============== #}
  <section class="reveal-up overflow-hidden rounded-2xl border border-zinc-200 bg-white shadow-soft">
    <div class="flex flex-wrap items-center justify-between gap-3 bg-gradient-to-r from-blue-50 to-indigo-50 px-5 py-4 border-b border-zinc-200">
      <div class="flex items-center gap-3">
        <span class="grid h-10 w-10 place-items-center rounded-xl bg-gradient-to-br from-blue-500 to-indigo-600 text-white shadow-sm ring-1 ring-blue-300/50">
          <i class="fa-solid fa-2 text-sm font-bold"></i>
        </span>
        <div>
          <h3 class="text-base font-bold text-zinc-900">Pager B — wide side</h3>
          <p class="text-xs text-zinc-500">500 records · 10 per page · <code class="rounded bg-blue-100 px-1 text-blue-800">widthSide: 5</code> · prefix <code class="rounded bg-blue-100 px-1 text-blue-800">page_b</code></p>
        </div>
      </div>
      <div class="flex flex-wrap items-center gap-2">
        <span class="inline-flex items-center gap-1.5 rounded-full bg-white px-2.5 py-1 text-[10px] font-semibold uppercase tracking-wider text-blue-700 ring-1 ring-blue-200">
          <i class="fa-solid fa-database text-[9px]"></i> total 500
        </span>
        <span class="inline-flex items-center gap-1.5 rounded-full bg-white px-2.5 py-1 text-[10px] font-semibold uppercase tracking-wider text-indigo-700 ring-1 ring-indigo-200">
          <i class="fa-solid fa-arrows-left-right-to-line text-[9px]"></i> side 5
        </span>
      </div>
    </div>
    <div class="p-5">
      <div class="rounded-xl border border-dashed border-blue-200 bg-gradient-to-br from-blue-50/40 to-indigo-50/40 p-4">
        {{ paginationB }}
      </div>
    </div>
  </section>

  {# ============== PAGER C — LARGE PAGE SIZE ============== #}
  <section class="reveal-up overflow-hidden rounded-2xl border border-zinc-200 bg-white shadow-soft">
    <div class="flex flex-wrap items-center justify-between gap-3 bg-gradient-to-r from-indigo-50 to-cyan-50 px-5 py-4 border-b border-zinc-200">
      <div class="flex items-center gap-3">
        <span class="grid h-10 w-10 place-items-center rounded-xl bg-gradient-to-br from-indigo-500 to-cyan-500 text-white shadow-sm ring-1 ring-indigo-300/50">
          <i class="fa-solid fa-3 text-sm font-bold"></i>
        </span>
        <div>
          <h3 class="text-base font-bold text-zinc-900">Pager C — large page size</h3>
          <p class="text-xs text-zinc-500">1,000 records · 100 per page · prefix <code class="rounded bg-indigo-100 px-1 text-indigo-800">page_c</code></p>
        </div>
      </div>
      <div class="flex flex-wrap items-center gap-2">
        <span class="inline-flex items-center gap-1.5 rounded-full bg-white px-2.5 py-1 text-[10px] font-semibold uppercase tracking-wider text-indigo-700 ring-1 ring-indigo-200">
          <i class="fa-solid fa-database text-[9px]"></i> total 1000
        </span>
        <span class="inline-flex items-center gap-1.5 rounded-full bg-white px-2.5 py-1 text-[10px] font-semibold uppercase tracking-wider text-cyan-700 ring-1 ring-cyan-200">
          <i class="fa-solid fa-layer-group text-[9px]"></i> page-size 100
        </span>
      </div>
    </div>
    <div class="p-5">
      <div class="rounded-xl border border-dashed border-indigo-200 bg-gradient-to-br from-indigo-50/40 to-cyan-50/40 p-4">
        {{ paginationC }}
      </div>
    </div>
  </section>

  {# ============== USAGE / TIPS ============== #}
  <section class="reveal-up overflow-hidden rounded-2xl border border-zinc-200 bg-white shadow-soft">
    <div class="flex items-center gap-3 bg-gradient-to-r from-zinc-50 to-white px-5 py-4 border-b border-zinc-200">
      <span class="grid h-10 w-10 place-items-center rounded-xl bg-gradient-to-br from-cyan-500 to-blue-600 text-white shadow-sm ring-1 ring-cyan-300/50">
        <i class="fa-solid fa-lightbulb text-sm"></i>
      </span>
      <div>
        <h3 class="text-base font-bold text-zinc-900">How it works</h3>
        <p class="text-xs text-zinc-500">Each pager owns its own query parameter prefix</p>
      </div>
    </div>
    <div class="grid gap-3 p-5 md:grid-cols-3">
      <div class="rounded-xl border border-cyan-200 bg-gradient-to-br from-white to-cyan-50/40 p-4">
        <div class="flex items-center gap-2 mb-2">
          <span class="grid h-7 w-7 place-items-center rounded-lg bg-cyan-100 text-cyan-700 ring-1 ring-cyan-200">
            <i class="fa-solid fa-hashtag text-[11px]"></i>
          </span>
          <p class="text-sm font-bold text-zinc-900">prefix</p>
        </div>
        <p class="text-xs leading-relaxed text-zinc-600">Sets the query key — e.g. <code class="rounded bg-zinc-100 px-1 text-cyan-700">?page_a=2</code>. Lets several pagers coexist independently.</p>
      </div>
      <div class="rounded-xl border border-blue-200 bg-gradient-to-br from-white to-blue-50/40 p-4">
        <div class="flex items-center gap-2 mb-2">
          <span class="grid h-7 w-7 place-items-center rounded-lg bg-blue-100 text-blue-700 ring-1 ring-blue-200">
            <i class="fa-solid fa-shuffle text-[11px]"></i>
          </span>
          <p class="text-sm font-bold text-zinc-900">otherQuery</p>
        </div>
        <p class="text-xs leading-relaxed text-zinc-600">Forward the other pagers' current page so clicking one pager doesn't reset the others.</p>
      </div>
      <div class="rounded-xl border border-indigo-200 bg-gradient-to-br from-white to-indigo-50/40 p-4">
        <div class="flex items-center gap-2 mb-2">
          <span class="grid h-7 w-7 place-items-center rounded-lg bg-indigo-100 text-indigo-700 ring-1 ring-indigo-200">
            <i class="fa-solid fa-arrows-left-right-to-line text-[11px]"></i>
          </span>
          <p class="text-sm font-bold text-zinc-900">widthSide</p>
        </div>
        <p class="text-xs leading-relaxed text-zinc-600">Number of page links on each side of the current page. Larger values produce wider button strips.</p>
      </div>
    </div>
  </section>

  {# ============== FILE REFERENCES ============== #}
  <section class="reveal-up overflow-hidden rounded-2xl border border-zinc-200 bg-white shadow-soft">
    <div class="flex items-center gap-3 bg-gradient-to-r from-zinc-50 to-white px-5 py-4 border-b border-zinc-200">
      <span class="grid h-10 w-10 place-items-center rounded-xl bg-gradient-to-br from-zinc-700 to-zinc-900 text-white shadow-sm ring-1 ring-zinc-300/50">
        <i class="fa-solid fa-folder-tree text-sm"></i>
      </span>
      <div>
        <h3 class="text-base font-bold text-zinc-900">File References</h3>
        <p class="text-xs text-zinc-500">Where this example lives</p>
      </div>
    </div>
    <ul class="divide-y divide-zinc-100">
      <li class="group transition-colors duration-150 hover:bg-cyan-50/50">
        <div class="flex flex-col gap-3 px-5 py-3.5 md:flex-row md:items-center md:gap-4">
          <div class="flex items-center gap-2.5 md:w-48">
            <span class="grid h-8 w-8 place-items-center rounded-lg bg-cyan-100 text-cyan-600 ring-1 ring-cyan-200">
              <i class="fa-regular fa-eye text-xs"></i>
            </span>
            <span class="text-sm font-semibold text-zinc-700">View</span>
          </div>
          <code class="break-all rounded-md bg-zinc-100 px-3 py-1.5 text-xs font-mono text-cyan-700 ring-1 ring-zinc-200 group-hover:bg-cyan-100 group-hover:ring-cyan-200">example/lib/widgets/example/pagination.j2.html</code>
        </div>
      </li>
      <li class="group transition-colors duration-150 hover:bg-cyan-50/50">
        <div class="flex flex-col gap-3 px-5 py-3.5 md:flex-row md:items-center md:gap-4">
          <div class="flex items-center gap-2.5 md:w-48">
            <span class="grid h-8 w-8 place-items-center rounded-lg bg-blue-100 text-blue-700 ring-1 ring-blue-200">
              <i class="fa-solid fa-code text-xs"></i>
            </span>
            <span class="text-sm font-semibold text-zinc-700">Controller</span>
          </div>
          <code class="break-all rounded-md bg-zinc-100 px-3 py-1.5 text-xs font-mono text-blue-700 ring-1 ring-zinc-200 group-hover:bg-blue-100 group-hover:ring-blue-200">example/lib/controllers/home_controller.dart → paginationExample()</code>
        </div>
      </li>
      <li class="group transition-colors duration-150 hover:bg-cyan-50/50">
        <div class="flex flex-col gap-3 px-5 py-3.5 md:flex-row md:items-center md:gap-4">
          <div class="flex items-center gap-2.5 md:w-48">
            <span class="grid h-8 w-8 place-items-center rounded-lg bg-indigo-100 text-indigo-700 ring-1 ring-indigo-200">
              <i class="fa-solid fa-puzzle-piece text-xs"></i>
            </span>
            <span class="text-sm font-semibold text-zinc-700">Paging widget</span>
          </div>
          <code class="break-all rounded-md bg-zinc-100 px-3 py-1.5 text-xs font-mono text-indigo-700 ring-1 ring-zinc-200 group-hover:bg-indigo-100 group-hover:ring-indigo-200">example/lib/widgets/template/paging.j2.html</code>
        </div>
      </li>
    </ul>
  </section>
</div>
{% endblock %}
""",
	r"example/mysql/_filtering.j2.html": r"""<form method="get" class="contents">
    <th class="p-1.5 align-top">
        <input
            class="h-9 w-full rounded-lg border bg-white px-2.5 text-xs shadow-sm transition focus:border-teal-500 focus:ring-2 focus:ring-teal-500/20 {{ 'border-emerald-400 ring-2 ring-emerald-200' if $n('filter_books/filter_b.id/value') else 'border-zinc-200' }}"
            type="number"
            name="filter_b.id"
            placeholder="{{ $t('mysql.placeholder.id') }}"
            value="{{ $n('filter_books/filter_b.id/value') }}"
        />
    </th>
    <th class="p-1.5 align-top">
        <input
            class="h-9 w-full rounded-lg border bg-white px-2.5 text-xs shadow-sm transition focus:border-teal-500 focus:ring-2 focus:ring-teal-500/20 {{ 'border-emerald-400 ring-2 ring-emerald-200' if $n('filter_books/filter_title/value') else 'border-zinc-200' }}"
            type="text"
            name="filter_title"
            placeholder="{{ $t('mysql.placeholder.title') }}"
            value="{{ $n('filter_books/filter_title/value') }}"
        />
    </th>
    <th class="p-1.5 align-top">
        <input
            class="h-9 w-full rounded-lg border bg-white px-2.5 text-xs shadow-sm transition focus:border-teal-500 focus:ring-2 focus:ring-teal-500/20 {{ 'border-emerald-400 ring-2 ring-emerald-200' if $n('filter_books/filter_author/value') else 'border-zinc-200' }}"
            type="text"
            name="filter_author"
            placeholder="{{ $t('mysql.placeholder.author') }}"
            value="{{ $n('filter_books/filter_author/value') }}"
        />
    </th>
    <th class="p-1.5 align-top">
        <input
            class="h-9 w-full rounded-lg border bg-white px-2.5 text-xs shadow-sm transition focus:border-teal-500 focus:ring-2 focus:ring-teal-500/20 {{ 'border-emerald-400 ring-2 ring-emerald-200' if $n('filter_books/filter_published_date/value') else 'border-zinc-200' }}"
            type="date"
            name="filter_published_date"
            placeholder="{{ $t('mysql.placeholder.publishedDate') }}"
            value="{{ $n('filter_books/filter_published_date/value') }}"
        />
    </th>
    <th class="p-1.5 align-top">
        <select
            class="h-9 w-full rounded-lg border bg-white px-2.5 text-xs shadow-sm transition focus:border-teal-500 focus:ring-2 focus:ring-teal-500/20 {{ 'border-emerald-400 ring-2 ring-emerald-200' if $n('filter_books/filter_category_id/value') else 'border-zinc-200' }}"
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
    <th colspan="2" class="p-1.5 align-top text-end">
        {% set filterIsDirty = $l.existUrlQuery(['filter_b.id','filter_title', 'filter_author', 'filter_published_date', 'filter_category_id']) %}
        <div class="flex items-center justify-end gap-1.5">
            <a
                href="{{ $l.removeUrlQuery(['page','filter_b.id','filter_title', 'filter_author', 'filter_published_date', 'filter_category_id']) }}"
                class="wave inline-flex h-9 items-center gap-1.5 rounded-lg border px-3 text-xs font-medium shadow-sm transition {{ 'border-zinc-200 bg-white text-zinc-500 hover:bg-zinc-50' if not filterIsDirty else 'border-zinc-800 bg-zinc-900 text-white hover:bg-zinc-800' }}"
                type="reset"
                title="{{ $t('mysql.button.reset') }}"
            >
                <i class="fa-solid fa-rotate-left text-[11px]"></i>
                <span class="hidden sm:inline">{{ $t('mysql.button.reset') }}</span>
            </a>
            <button
                class="wave inline-flex h-9 cursor-pointer items-center gap-1.5 rounded-lg bg-gradient-to-r from-teal-600 to-cyan-600 px-3.5 text-xs font-semibold text-white shadow-sm transition hover:from-teal-700 hover:to-cyan-700 focus:outline-none focus:ring-2 focus:ring-teal-500/40"
                type="submit"
            >
                <i class="fa-solid fa-filter text-[11px]"></i>
                <span>{{ $t('mysql.button.filter') }}</span>
            </button>
        </div>
    </th>
</form>
""",
	r"example/mysql/_form_edit.j2.html": r"""<form method="post" action="{{ $e.uriString }}" class="contents">
    <input type="hidden" name="action" value="{{ 'update' if(action == 'edit' ?? action == 'update') else 'add' }}" />
    <tr>
        <td colspan="7" class="px-4 py-4">
            <div class="rounded-xl border border-dashed border-zinc-300 bg-zinc-50/60 p-4">
                <div class="mb-3 flex items-center gap-2">
                    <span class="inline-flex h-7 w-7 items-center justify-center rounded-lg bg-gradient-to-br from-teal-500 to-cyan-600 text-white shadow-sm">
                        <i class="fa-solid {{ 'fa-pen-to-square' if(action == 'edit' ?? action == 'update') else 'fa-plus' }} text-[11px]"></i>
                    </span>
                    <p class="text-xs font-semibold text-zinc-700">
                        {{ $t('mysql.button.update') if(action == 'edit' ?? action == 'update') else $t('database.table.button.add') }}
                        <span class="font-normal text-zinc-500">·</span>
                        <span class="font-normal text-zinc-500">Book record</span>
                    </p>
                </div>
                <div class="grid grid-cols-1 gap-3 sm:grid-cols-2 lg:grid-cols-4">
                    <div class="flex flex-col">
                        <label class="mb-1 text-[10px] font-semibold uppercase tracking-wider text-zinc-500">{{ $t('mysql.placeholder.title') }}</label>
                        <input
                            type="text"
                            name="title"
                            placeholder="{{ $t('mysql.placeholder.title') }}"
                            required
                            value="{{ $n('form_book/title/value') }}"
                            class="h-10 rounded-lg border bg-white px-3 text-xs shadow-sm transition focus:border-teal-500 focus:ring-2 focus:ring-teal-500/20 {{ 'border-rose-500 ring-2 ring-rose-300' if $n('form_book/title/errors/0') else 'border-zinc-200' }}"
                        />
                        <div class="mt-1 text-[10px] text-rose-600 {{ '' if $n('form_book/title/errors/0') else 'hidden' }}">{{ $n('form_book/title/errors/0') }}</div>
                    </div>
                    <div class="flex flex-col">
                        <label class="mb-1 text-[10px] font-semibold uppercase tracking-wider text-zinc-500">{{ $t('mysql.placeholder.author') }}</label>
                        <input
                            type="text"
                            name="author"
                            placeholder="{{ $t('mysql.placeholder.author') }}"
                            required
                            value="{{ $n('form_book/author/value') }}"
                            class="h-10 rounded-lg border bg-white px-3 text-xs shadow-sm transition focus:border-teal-500 focus:ring-2 focus:ring-teal-500/20 {{ 'border-rose-500 ring-2 ring-rose-300' if $n('form_book/author/errors/0') else 'border-zinc-200' }}"
                        />
                        <div class="mt-1 text-[10px] text-rose-600 {{ '' if $n('form_book/author/errors/0') else 'hidden' }}">{{ $n('form_book/author/errors/0') }}</div>
                    </div>
                    <div class="flex flex-col">
                        <label class="mb-1 text-[10px] font-semibold uppercase tracking-wider text-zinc-500">{{ $t('mysql.placeholder.publishedDate') }}</label>
                        <input
                            type="date"
                            name="published_date"
                            required
                            value="{{ $n('form_book/published_date/value') }}"
                            class="h-10 rounded-lg border bg-white px-3 text-xs shadow-sm transition focus:border-teal-500 focus:ring-2 focus:ring-teal-500/20 {{ 'border-rose-500 ring-2 ring-rose-300' if $n('form_book/published_date/errors/0') else 'border-zinc-200' }}"
                        />
                        <div class="mt-1 text-[10px] text-rose-600 {{ '' if $n('form_book/published_date/errors/0') else 'hidden' }}">{{ $n('form_book/published_date/errors/0') }}</div>
                    </div>
                    <div class="flex flex-col">
                        <label class="mb-1 text-[10px] font-semibold uppercase tracking-wider text-zinc-500">{{ $t('mysql.table.header.categoryId') }}</label>
                        <select
                            name="category_id"
                            class="h-10 rounded-lg border bg-white px-2.5 text-xs shadow-sm transition focus:border-teal-500 focus:ring-2 focus:ring-teal-500/20 {{ 'border-rose-500 ring-2 ring-rose-300' if $n('form_book/category_id/errors/0') else 'border-zinc-200' }}"
                        >
                            <option value=""></option>
                            {% set selected = $n('form_book/category_id/value') %}
                            {% for category in $n('form_book/category_id/options') %}
                                <option value="{{ category.id }}" {{ 'selected' if selected == category.id else '' }}>{{ category.title }}</option>
                            {% endfor %}
                        </select>
                        <div class="mt-1 text-[10px] text-rose-600 {{ '' if $n('form_book/category_id/errors/0') else 'hidden' }}">{{ $n('form_book/category_id/errors/0') }}</div>
                    </div>
                </div>

                <input type="hidden" name="token" value="{{ $n('form_book/token/value') }}" />
                {% if(action == 'edit' ?? action == 'update') %}
                <input type="hidden" name="id" value="{{ id }}" />
                {% endif %}

                <div class="mt-3 flex flex-wrap items-center justify-between gap-2">
                    <div class="text-[10px] text-rose-600 {{ $n('form_book/token/errors/0') ? '' : 'hidden' }}">{{ $n('form_book/token/errors/0') }}</div>
                    <button type="submit" class="wave inline-flex h-10 items-center gap-2 rounded-lg bg-gradient-to-r from-teal-600 to-cyan-600 px-4 text-xs font-semibold text-white shadow-sm transition hover:from-teal-700 hover:to-cyan-700 focus:outline-none focus:ring-2 focus:ring-teal-500/40">
                        <i class="fa-solid {{ 'fa-floppy-disk' if(action == 'edit' ?? action == 'update') else 'fa-plus' }}"></i>
                        {{ $t('mysql.button.update') if(action == 'edit' ?? action == 'update') else $t('database.table.button.add') }}
                    </button>
                </div>
            </div>
        </td>
    </tr>
    <tr>
        <td colspan="7" class="px-4 py-3 text-xs text-zinc-600">{{ paging }}</td>
    </tr>
</form>
""",
	r"example/mysql/_categories.j2.html": r"""<section class="reveal-up overflow-hidden rounded-2xl border border-zinc-200 bg-white shadow-soft">
  <div class="flex flex-wrap items-center justify-between gap-3 border-b border-zinc-200 bg-gradient-to-r from-zinc-50 to-white px-5 py-4">
    <div class="flex items-center gap-3">
      <span class="inline-flex h-10 w-10 items-center justify-center rounded-xl bg-gradient-to-br from-cyan-500 to-teal-600 text-white shadow-sm">
        <i class="fa-solid fa-folder-tree"></i>
      </span>
      <div>
        <p class="text-sm font-semibold text-zinc-800 leading-tight">{{ $t('mysql.categories.title') }}</p>
        <p class="text-[11px] text-zinc-500">Browse, filter and manage book categories</p>
      </div>
    </div>
    <span class="inline-flex items-center gap-1.5 rounded-full bg-cyan-50 px-2.5 py-1 text-[11px] font-semibold text-cyan-700 ring-1 ring-cyan-200">
      <i class="fa-solid fa-layer-group text-[10px]"></i>
      {{ (categories | default([])) | length }} total
    </span>
  </div>

  <div class="overflow-x-auto">
    <table class="min-w-full divide-y divide-zinc-200 text-xs md:text-sm">
      <thead class="bg-zinc-50">
        <tr class="text-left">
          <th scope="col" class="w-20 px-4 py-3 text-[11px] font-bold uppercase tracking-wider text-zinc-600">{{ $t('mysql.table.header.id') }}</th>
          <th scope="col" class="px-4 py-3 text-[11px] font-bold uppercase tracking-wider text-zinc-600">{{ $t('mysql.table.header.title') }}</th>
          <th scope="col" class="w-36 px-4 py-3 text-center text-[11px] font-bold uppercase tracking-wider text-zinc-600">{{ $t('mysql.table.header.booksCount') }}</th>
          <th scope="col" class="w-24 px-4 py-3 text-end text-[11px] font-bold uppercase tracking-wider text-zinc-600">{{ $t('mysql.table.header.actions') }}</th>
        </tr>
      </thead>
      <tbody class="divide-y divide-zinc-100 bg-white">
        {% for category in categories|default([]) %}
        <tr class="group transition hover:bg-cyan-50/40">
          <td class="px-4 py-3">
            <span class="inline-flex h-6 min-w-[1.75rem] items-center justify-center rounded-md bg-cyan-100 px-1.5 font-mono text-[11px] font-bold text-cyan-700">{{ category.id }}</span>
          </td>
          <td class="px-4 py-3 font-medium text-zinc-800">{{ category.title }}</td>
          <td class="px-4 py-3 text-center">
            <a
              class="wave inline-flex h-7 items-center gap-1.5 rounded-full border border-cyan-200 bg-cyan-50 px-3 text-[11px] font-semibold text-cyan-700 hover:border-cyan-300 hover:bg-cyan-100 focus:outline-none focus:ring-2 focus:ring-cyan-500/30"
              href="{{ $l.updateUrlQuery( {'filter_category_id': category.id|s}) }}"
            >
              <i class="fa-solid fa-book text-[10px]"></i>
              {{ category.count_books }}
            </a>
          </td>
          <td class="px-4 py-3 text-end">
            <a
              data-href="{{ $l.updateUrlQuery( {'id': category.id|s, 'action': 'delete_category'|s}) }}"
              data-message="{{ $t('mysql.message.deleteCategory') ~ ' (' ~ category.title ~ ')' }}"
              class="wave js-delete-links inline-flex h-8 w-8 items-center justify-center rounded-lg border border-zinc-200 bg-white text-rose-600 transition hover:border-rose-300 hover:bg-rose-50 hover:shadow-sm focus:outline-none focus:ring-2 focus:ring-rose-500/30"
              aria-label="{{ $t('mysql.button.delete') }}"
            >
              <i class="fa-solid fa-trash-can text-xs"></i>
            </a>
          </td>
        </tr>
        {% else %}
        <tr>
          <td colspan="4" class="px-4 py-12 text-center">
            <div class="mx-auto flex max-w-sm flex-col items-center gap-3">
              <div class="inline-flex h-14 w-14 items-center justify-center rounded-2xl bg-zinc-100 text-zinc-400">
                <i class="fa-solid fa-folder-open text-xl"></i>
              </div>
              <p class="text-sm font-medium text-zinc-600">{{ $t('mysql.message.noCategories') }}</p>
            </div>
          </td>
        </tr>
        {% endfor %}
      </tbody>
      <tfoot class="border-t border-zinc-200 bg-zinc-50/60">
        <tr>
          <td colspan="4" class="px-4 py-4">
            <form method="POST" action="{{ $l.updateUrlQuery( {'action': 'add_category'}) }}" class="flex flex-wrap items-start gap-2">
              <div class="flex min-w-[220px] flex-1 flex-col">
                <div class="relative">
                  <span class="pointer-events-none absolute inset-y-0 start-3 flex items-center text-zinc-400">
                    <i class="fa-solid fa-plus text-xs"></i>
                  </span>
                  <input
                    type="text"
                    name="title"
                    placeholder="{{ $t('mysql.placeholder.title') }}"
                    required
                    value="{{ $n('form/title/value') }}"
                    class="h-10 w-full rounded-lg border bg-white ps-9 pe-3 text-xs shadow-sm focus:border-teal-500 focus:ring-2 focus:ring-teal-500/20 {{ 'border-rose-500 ring-2 ring-rose-300' if $n('form/title/errors/0') else 'border-zinc-300' }}"
                  />
                </div>
                <div class="mt-1 text-[10px] text-rose-600 {{ '' if $n('form/title/errors/0') else 'hidden' }}">{{ $n('form/title/errors/0') }}</div>
              </div>
              <button type="submit" class="wave inline-flex h-10 items-center gap-2 rounded-lg bg-gradient-to-r from-teal-600 to-cyan-600 px-4 text-xs font-semibold text-white shadow-sm transition hover:from-teal-700 hover:to-cyan-700 focus:outline-none focus:ring-2 focus:ring-teal-500/40">
                <i class="fa-solid fa-plus"></i>
                {{ $t('database.table.button.add') }}
              </button>
            </form>
          </td>
        </tr>
      </tfoot>
    </table>
  </div>
</section>
""",
	r"example/mysql/overview.j2.html": r"""{% extends 'template/template.j2.html' %}
{% block title %} {{ $t('mysql.example.title') }} {% endblock %}

{% block content %}
{% set pageSize = data.pageSize | default("10") %}
{% set randonString = $e.randomString() %}

<div class="space-y-6">

  {# ============== HERO ============== #}
  <section class="reveal-up relative overflow-hidden rounded-3xl border border-zinc-200 bg-gradient-to-br from-zinc-900 via-orange-950 to-amber-950 p-6 sm:p-8 shadow-soft">
    <div class="pointer-events-none absolute -top-24 -end-24 h-72 w-72 rounded-full bg-orange-500/20 blur-3xl"></div>
    <div class="pointer-events-none absolute -bottom-24 -start-24 h-72 w-72 rounded-full bg-amber-500/20 blur-3xl"></div>

    <div class="relative flex flex-col gap-6 lg:flex-row lg:items-center lg:justify-between">
      <div class="flex items-start gap-4">
        <div class="relative">
          <div class="inline-flex h-14 w-14 items-center justify-center rounded-2xl bg-white/10 ring-1 ring-white/20 backdrop-blur">
            <i class="fa-solid fa-database text-2xl text-orange-300"></i>
          </div>
          <span class="absolute -top-1 -end-1 inline-flex h-3.5 w-3.5">
            <span class="absolute inline-flex h-full w-full animate-ping rounded-full bg-amber-400 opacity-75"></span>
            <span class="relative inline-flex h-3.5 w-3.5 rounded-full bg-amber-400 ring-2 ring-zinc-900"></span>
          </span>
        </div>
        <div>
          <div class="flex flex-wrap items-center gap-2">
            <span class="inline-flex items-center gap-1.5 rounded-full bg-orange-500/15 px-2.5 py-1 text-[11px] font-semibold uppercase tracking-wider text-orange-300 ring-1 ring-orange-400/30">
              <i class="fa-solid fa-bolt"></i>
              MySQL
            </span>
            <span class="inline-flex items-center gap-1.5 rounded-full bg-white/5 px-2.5 py-1 text-[11px] font-medium text-zinc-300 ring-1 ring-white/10">
              <i class="fa-solid fa-table text-amber-300"></i>
              Relational
            </span>
          </div>
          <h1 class="mt-2 text-2xl font-bold text-white sm:text-3xl">{{ $t('mysql.example.title') }}</h1>
          <p class="mt-1 max-w-xl text-sm text-zinc-300">
            MySQL database operations with advanced features — pagination, sortable columns, multi-field filters and bulk actions.
          </p>
        </div>
      </div>

      {# Quick stats #}
      <div class="grid grid-cols-2 gap-3 sm:grid-cols-3 lg:flex lg:items-stretch">
        <div class="rounded-2xl border border-white/10 bg-white/5 px-4 py-3 backdrop-blur">
          <div class="text-[10px] font-semibold uppercase tracking-wider text-zinc-400">Books</div>
          <div class="mt-1 flex items-baseline gap-1.5">
            <span class="text-2xl font-bold text-white">{{ (books | default([])) | length }}</span>
            <span class="text-[11px] text-zinc-400">/ page</span>
          </div>
        </div>
        <div class="rounded-2xl border border-white/10 bg-white/5 px-4 py-3 backdrop-blur">
          <div class="text-[10px] font-semibold uppercase tracking-wider text-zinc-400">Categories</div>
          <div class="mt-1 flex items-baseline gap-1.5">
            <span class="text-2xl font-bold text-white">{{ (categories | default([])) | length }}</span>
          </div>
        </div>
        <div class="col-span-2 rounded-2xl border border-white/10 bg-white/5 px-4 py-3 backdrop-blur sm:col-span-1">
          <div class="text-[10px] font-semibold uppercase tracking-wider text-zinc-400">Page size</div>
          <div class="mt-1 inline-flex items-baseline gap-1.5">
            <span class="text-2xl font-bold text-white">{{ pageSize }}</span>
            <span class="text-[11px] text-zinc-400">rows</span>
          </div>
        </div>
      </div>
    </div>
  </section>

  {# ============== BOOKS CARD ============== #}
  <section class="reveal-up overflow-hidden rounded-2xl border border-zinc-200 bg-white shadow-soft">
    {# Toolbar #}
    <div class="flex flex-wrap items-center justify-between gap-3 border-b border-zinc-200 bg-gradient-to-r from-zinc-50 to-white px-5 py-4">
      <div class="flex items-center gap-3">
        <span class="inline-flex h-10 w-10 items-center justify-center rounded-xl bg-gradient-to-br from-orange-500 to-amber-600 text-white shadow-sm">
          <i class="fa-solid fa-book"></i>
        </span>
        <div>
          <p class="text-sm font-semibold text-zinc-800 leading-tight">{{ $t('Books Management') }}</p>
          <p class="text-[11px] text-zinc-500">Sortable · filterable · bulk operations</p>
        </div>
      </div>
      <div class="flex flex-wrap items-center gap-2">
        <button type="button" class="wave group inline-flex h-9 items-center gap-2 rounded-lg border border-rose-300 bg-rose-50 px-3.5 text-xs font-semibold text-rose-700 transition hover:border-rose-400 hover:bg-rose-100 focus:outline-none focus:ring-2 focus:ring-rose-500/30" onclick="deleteSelectedBooks_{{randonString}}()">
          <i class="fa-solid fa-trash-can text-[11px]"></i>
          <span>{{ $t('mysql.button.deleteSelected') }}</span>
        </button>
        <div class="inline-flex items-center gap-2 rounded-lg border border-zinc-200 bg-white pl-3">
          <span class="text-[11px] font-medium text-zinc-500">
            <i class="fa-solid fa-list-ol text-zinc-400"></i>
            Rows
          </span>
          <select name="pageSize" class="h-9 cursor-pointer rounded-r-lg border-0 bg-white pe-2 ps-1 text-xs font-semibold text-zinc-700 focus:outline-none focus:ring-2 focus:ring-teal-500/30" onchange="changePageSize_{{randonString}}(this.value)">
            <option {{ 'selected' if pageSize == '10' else '' }}>10</option>
            <option {{ 'selected' if pageSize == '20' else '' }}>20</option>
            <option {{ 'selected' if pageSize == '50' else '' }}>50</option>
            <option {{ 'selected' if pageSize == '100' else '' }}>100</option>
          </select>
        </div>
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

    {# Table #}
    <div class="overflow-x-auto">
      <table class="min-w-full divide-y divide-zinc-200 text-xs md:text-sm">
        <thead class="bg-zinc-50">
          <tr class="text-left">
            <th class="px-4 py-3">
              <div class="flex items-center gap-2">
                <input class="h-4 w-4 rounded border-zinc-300 text-teal-600 focus:ring-2 focus:ring-teal-500/30" type="checkbox" id="select_all" onchange="document.querySelectorAll(`input[name='selected_books']`).forEach(cb=>cb.checked=this.checked);" />
                <span class="text-[11px] font-bold uppercase tracking-wider text-zinc-600">{{ $l.macro("/template/ui/sorting", {'sortby': 'b.id', 'title': 'mysql.table.header.id'} ) }}</span>
              </div>
            </th>
            <th class="px-4 py-3 text-[11px] font-bold uppercase tracking-wider text-zinc-600">{{ $l.macro("/template/ui/sorting", {'sortby': 'title', 'title': 'mysql.table.header.title'} ) }}</th>
            <th class="px-4 py-3 text-[11px] font-bold uppercase tracking-wider text-zinc-600">{{ $l.macro("/template/ui/sorting", {'sortby': 'author', 'title': 'mysql.table.header.author'} ) }}</th>
            <th class="px-4 py-3 text-[11px] font-bold uppercase tracking-wider text-zinc-600">{{ $l.macro("/template/ui/sorting", {'sortby': 'published_date', 'title': 'mysql.table.header.publishedDate'} ) }}</th>
            <th class="px-4 py-3 text-[11px] font-bold uppercase tracking-wider text-zinc-600">{{ $l.macro("/template/ui/sorting", {'sortby': 'category_id', 'title': 'mysql.table.header.categoryId'} ) }}</th>
            <th class="px-4 py-3 text-end text-[11px] font-bold uppercase tracking-wider text-zinc-600">{{ $t('database.table.header.action') }}</th>
          </tr>
          <tr class="bg-white">
            {% include 'example/mysql/_filtering.j2.html' %}
          </tr>
        </thead>
        <tbody class="divide-y divide-zinc-100 bg-white">
          {% for book in books %}
          <tr class="group transition hover:bg-orange-50/40">
            <td class="px-4 py-3 align-middle">
              <div class="flex items-center gap-2.5">
                <input class="h-4 w-4 rounded border-zinc-300 text-teal-600 focus:ring-2 focus:ring-teal-500/30" type="checkbox" name="selected_books" value="{{ book.id }}" />
                <span class="inline-flex h-6 min-w-[1.75rem] items-center justify-center rounded-md bg-orange-100 px-1.5 text-[11px] font-bold text-orange-700">{{ book.id }}</span>
              </div>
            </td>
            <td class="px-4 py-3 font-semibold text-zinc-800">{{ book.title }}</td>
            <td class="px-4 py-3 text-zinc-600">
              <span class="inline-flex items-center gap-1.5">
                <i class="fa-regular fa-user text-zinc-400"></i>
                {{ book.author }}
              </span>
            </td>
            <td class="px-4 py-3 text-zinc-600">
              <span class="inline-flex items-center gap-1.5">
                <i class="fa-regular fa-calendar text-zinc-400"></i>
                {{ book.published_date | dateFormat('dd/MM/y') }}
              </span>
            </td>
            <td class="px-4 py-3">
              <span class="inline-flex items-center gap-1 rounded-full bg-cyan-50 px-2.5 py-1 text-[11px] font-medium text-cyan-700 ring-1 ring-cyan-200">
                <span class="h-1.5 w-1.5 rounded-full bg-cyan-500"></span>
                {{ book.category_title }}
              </span>
            </td>
            <td class="px-4 py-3 text-end">
              <div class="flex items-center justify-end gap-1.5">
                <a
                  href="{{ $l.updateUrlQuery( {'id':book.id|s, 'action': 'edit'|s}) }}"
                  class="wave inline-flex h-8 w-8 items-center justify-center rounded-lg border border-zinc-200 bg-white text-teal-600 transition hover:border-teal-300 hover:bg-teal-50 hover:shadow-sm focus:outline-none focus:ring-2 focus:ring-teal-500/30"
                  title="{{ $t('mysql.button.edit') }}">
                  <i class="fa-solid fa-pen-to-square text-xs"></i>
                </a>
                <a
                  data-href="{{ $l.updateUrlQuery( {'id':book.id|s, 'action': 'delete'|s}) }}"
                  data-message="{{ $t('mysql.message.deleteBook') ~ ' (' ~ book.title ~ ')' }}"
                  class="wave cursor-pointer js-delete-links inline-flex h-8 w-8 items-center justify-center rounded-lg border border-zinc-200 bg-white text-rose-600 transition hover:border-rose-300 hover:bg-rose-50 hover:shadow-sm focus:outline-none focus:ring-2 focus:ring-rose-500/30"
                  title="{{ $t('mysql.button.delete') }}">
                  <i class="fa-solid fa-trash-can text-xs"></i>
                </a>
              </div>
            </td>
          </tr>
          {% else %}
          <tr>
            <td colspan="6" class="px-4 py-16 text-center">
              <div class="mx-auto flex max-w-sm flex-col items-center gap-3">
                <div class="inline-flex h-16 w-16 items-center justify-center rounded-2xl bg-zinc-100 text-zinc-400">
                  <i class="fa-solid fa-book-open text-2xl"></i>
                </div>
                <p class="text-sm font-semibold text-zinc-700">{{ $t('mysql.message.noRecords') }}</p>
                <p class="text-xs text-zinc-500">Use the form below to add your first book.</p>
              </div>
            </td>
          </tr>
          {% endfor %}
        </tbody>
        <tfoot class="border-t border-zinc-200 bg-zinc-50/60">
          {% include form_book.widget | unscape %}
        </tfoot>
      </table>
    </div>
  </section>

  {# ============== CATEGORIES CARD ============== #}
  {% include 'example/mysql/_categories.j2.html' %}

</div>
{% endblock %}
""",
	r"example/cookie.j2.html": r"""{% extends 'template/template.j2.html' %}
{% block title %}
    {{ $t('sidebar.cookieExample') }}
{% endblock %}

{% block content %}
<div class="space-y-6">

  {# ============== HERO ============== #}
  <section class="reveal-up relative overflow-hidden rounded-3xl border border-zinc-200 bg-gradient-to-br from-zinc-900 via-amber-950 to-yellow-950 p-6 sm:p-8 shadow-soft">
    <div class="pointer-events-none absolute -top-24 -end-24 h-72 w-72 rounded-full bg-amber-500/20 blur-3xl"></div>
    <div class="pointer-events-none absolute -bottom-24 -start-24 h-72 w-72 rounded-full bg-yellow-500/20 blur-3xl"></div>

    <div class="relative flex flex-col gap-6 lg:flex-row lg:items-center lg:justify-between">
      <div class="flex items-start gap-4">
        <div class="relative">
          <div class="inline-flex h-14 w-14 items-center justify-center rounded-2xl bg-white/10 ring-1 ring-white/20 backdrop-blur">
            <i class="fa-solid fa-cookie-bite text-2xl text-amber-300"></i>
          </div>
          <span class="absolute -top-1 -end-1 inline-flex h-3.5 w-3.5">
            <span class="absolute inline-flex h-full w-full animate-ping rounded-full bg-yellow-400 opacity-75"></span>
            <span class="relative inline-flex h-3.5 w-3.5 rounded-full bg-yellow-400 ring-2 ring-zinc-900"></span>
          </span>
        </div>
        <div>
          <div class="flex flex-wrap items-center gap-2">
            <span class="inline-flex items-center gap-1.5 rounded-full bg-amber-500/15 px-2.5 py-1 text-[11px] font-semibold uppercase tracking-wider text-amber-300 ring-1 ring-amber-400/30">
              <i class="fa-solid fa-cookie text-[10px]"></i> Browser storage
            </span>
            <span class="inline-flex items-center gap-1.5 rounded-full bg-yellow-500/15 px-2.5 py-1 text-[11px] font-semibold uppercase tracking-wider text-yellow-300 ring-1 ring-yellow-400/30">
              <i class="fa-solid fa-shield-halved text-[10px]"></i> Safe / Signed
            </span>
            <span class="inline-flex items-center gap-1.5 rounded-full bg-emerald-500/15 px-2.5 py-1 text-[11px] font-semibold uppercase tracking-wider text-emerald-300 ring-1 ring-emerald-400/30">
              <i class="fa-solid fa-bolt text-[10px]"></i> Session-aware
            </span>
          </div>
          <h1 class="mt-2 text-2xl sm:text-3xl font-bold tracking-tight text-white">{{ $t('cookies.test') }}</h1>
          <p class="mt-1 max-w-2xl text-sm text-zinc-300">Manage the current request's cookies &mdash; add a name/value pair, optionally sign it as <span class="font-semibold text-amber-300">safe</span>, and remove entries one at a time.</p>
        </div>
      </div>

      <div class="grid grid-cols-2 gap-3 sm:gap-4">
        <div class="rounded-2xl border border-white/10 bg-white/5 p-3 sm:p-4 text-center backdrop-blur">
          <div class="text-[10px] uppercase tracking-wider text-zinc-400">Cookies</div>
          <div class="mt-1 text-2xl font-bold text-white">{{ session.cookies | length }}</div>
        </div>
        <div class="rounded-2xl border border-white/10 bg-white/5 p-3 sm:p-4 text-center backdrop-blur">
          <div class="text-[10px] uppercase tracking-wider text-zinc-400">Scope</div>
          <div class="mt-1 text-base sm:text-lg font-bold text-white">
            <i class="fa-solid fa-globe text-amber-300"></i> Request
          </div>
        </div>
      </div>
    </div>
  </section>

  {# ============== COOKIES CARD ============== #}
  <section class="reveal-up overflow-hidden rounded-2xl border border-zinc-200 bg-white shadow-soft">
    <div class="flex items-center justify-between gap-3 bg-gradient-to-r from-zinc-50 to-white px-5 py-4 border-b border-zinc-200">
      <div class="flex items-center gap-3">
        <span class="grid h-10 w-10 place-items-center rounded-xl bg-gradient-to-br from-amber-500 to-yellow-600 text-white shadow-sm ring-1 ring-amber-300/50">
          <i class="fa-solid fa-cookie-bite text-sm"></i>
        </span>
        <div>
          <h3 class="text-base font-bold text-zinc-900">Cookies</h3>
          <p class="text-xs text-zinc-500">{{ session.cookies | length }} {{ 'cookie' if session.cookies | length == 1 else 'cookies' }} on this request</p>
        </div>
      </div>
      <span class="hidden sm:inline-flex items-center gap-1.5 rounded-full bg-amber-100 px-2.5 py-1 text-[10px] font-semibold uppercase tracking-wider text-amber-800 ring-1 ring-amber-200">
        <i class="fa-solid fa-circle text-[8px] animate-pulse"></i> Live
      </span>
    </div>

    <div class="overflow-x-auto">
      <table class="min-w-full divide-y divide-zinc-200">
        <thead class="bg-zinc-50">
          <tr>
            <th class="px-5 py-3 text-left text-[11px] font-bold uppercase tracking-wider text-zinc-600">{{ $t('cookies.key') }}</th>
            <th class="px-5 py-3 text-left text-[11px] font-bold uppercase tracking-wider text-zinc-600">{{ $t('cookies.value') }}</th>
            <th class="px-5 py-3 text-center text-[11px] font-bold uppercase tracking-wider text-zinc-600">{{ $t('cookies.action') }}</th>
          </tr>
        </thead>
        <tbody class="divide-y divide-zinc-100 bg-white">
          {% for cookie in session.cookies %}
          <tr class="group transition-colors duration-150 hover:bg-amber-50/60">
            <td class="px-5 py-3.5 align-middle">
              <div class="flex items-center gap-2.5">
                <span class="grid h-8 w-8 place-items-center rounded-lg bg-amber-100 text-amber-700 ring-1 ring-amber-200">
                  <i class="fa-solid fa-key text-[11px]"></i>
                </span>
                <span class="font-semibold text-zinc-900">{{ cookie.name }}</span>
              </div>
            </td>
            <td class="px-5 py-3.5 align-middle">
              <code class="inline-block max-w-md break-all rounded-md bg-zinc-100 px-2 py-1 text-xs font-mono text-zinc-800 ring-1 ring-zinc-200">{{ cookie.value }}</code>
            </td>
            <td class="px-5 py-3.5 text-center">
              <form method="post" class="inline">
                <input type="hidden" name="name" value="{{ cookie.name }}" />
                <input type="hidden" name="action" value="delete" />
                <button type="submit" class="inline-flex h-9 w-9 items-center justify-center rounded-lg border border-rose-200 bg-white text-rose-600 transition-all duration-150 hover:bg-rose-50 hover:border-rose-300 hover:shadow-sm focus:outline-none focus:ring-2 focus:ring-rose-500/30" aria-label="{{ $t('cookies.remove') }}" title="{{ $t('cookies.remove') }}">
                  <i class="fa-solid fa-trash-can text-sm"></i>
                </button>
              </form>
            </td>
          </tr>
          {% endfor %}
          {% if session.cookies | length == 0 %}
          <tr>
            <td colspan="3" class="px-5 py-10 text-center">
              <div class="mx-auto flex max-w-sm flex-col items-center gap-2">
                <span class="grid h-14 w-14 place-items-center rounded-2xl bg-amber-50 text-amber-400 ring-1 ring-amber-100">
                  <i class="fa-solid fa-cookie text-2xl"></i>
                </span>
                <p class="text-sm font-semibold text-zinc-700">No cookies yet</p>
                <p class="text-xs text-zinc-500">Use the form below to add your first cookie.</p>
              </div>
            </td>
          </tr>
          {% endif %}
        </tbody>
        <tfoot class="border-t border-zinc-200 bg-gradient-to-r from-amber-50/50 to-yellow-50/50">
          <tr>
            <td colspan="3" class="px-5 py-5">
              <form method="post" class="rounded-xl border border-dashed border-amber-300 bg-white/70 p-4">
                <div class="mb-3 flex items-center gap-2">
                  <span class="grid h-7 w-7 place-items-center rounded-lg bg-gradient-to-br from-amber-500 to-yellow-600 text-white shadow-sm">
                    <i class="fa-solid fa-plus text-[11px]"></i>
                  </span>
                  <p class="text-sm font-semibold text-zinc-800">{{ $t('cookies.addCookie') }}</p>
                </div>
                <div class="flex flex-col gap-3 lg:flex-row lg:items-stretch">
                  <div class="relative w-full lg:max-w-xs">
                    <i class="fa-solid fa-tag pointer-events-none absolute left-3 top-1/2 -translate-y-1/2 text-xs text-amber-500"></i>
                    <input placeholder="{{ $t('cookies.placeholder.name') }}" class="h-10 w-full rounded-lg border border-zinc-300 bg-white pl-9 pr-3 text-sm shadow-sm transition-all duration-200 focus:border-amber-500 focus:ring-2 focus:ring-amber-500/20" type="text" name="name" value="" />
                  </div>
                  <div class="relative w-full flex-1">
                    <i class="fa-solid fa-quote-right pointer-events-none absolute left-3 top-1/2 -translate-y-1/2 text-xs text-amber-500"></i>
                    <input type="text" name="value" class="h-10 w-full rounded-lg border border-zinc-300 bg-white pl-9 pr-3 text-sm shadow-sm transition-all duration-200 focus:border-amber-500 focus:ring-2 focus:ring-amber-500/20" placeholder="{{ $t('cookies.placeholder.value') }}">
                  </div>
                  <label class="inline-flex h-10 cursor-pointer items-center gap-2 rounded-lg border border-zinc-300 bg-white px-3 text-sm font-medium text-zinc-700 transition-all duration-200 hover:border-amber-400 hover:bg-amber-50">
                    <input class="h-4 w-4 rounded border-zinc-300 text-amber-600 focus:ring-2 focus:ring-amber-500/30" name="safe" type="checkbox" value="1">
                    <i class="fa-solid fa-shield-halved text-xs text-amber-600"></i>
                    <span>{{ $t('cookies.safe') }}</span>
                  </label>
                  <button class="wave group inline-flex h-10 shrink-0 items-center justify-center gap-2 rounded-lg bg-gradient-to-r from-amber-500 to-yellow-600 px-5 text-sm font-semibold text-white shadow-soft transition-all duration-200 hover:from-amber-600 hover:to-yellow-700 hover:shadow-soft-lg focus:outline-none focus:ring-4 focus:ring-amber-500/30" type="submit">
                    <i class="fa-solid fa-plus text-xs transition-transform duration-200 group-hover:scale-110"></i>
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
  </section>

  {# ============== FILE REFERENCES ============== #}
  <section class="reveal-up overflow-hidden rounded-2xl border border-zinc-200 bg-white shadow-soft">
    <div class="flex items-center justify-between gap-3 bg-gradient-to-r from-zinc-50 to-white px-5 py-4 border-b border-zinc-200">
      <div class="flex items-center gap-3">
        <span class="grid h-10 w-10 place-items-center rounded-xl bg-gradient-to-br from-zinc-700 to-zinc-900 text-white shadow-sm ring-1 ring-zinc-300/50">
          <i class="fa-solid fa-folder-tree text-sm"></i>
        </span>
        <div>
          <h3 class="text-base font-bold text-zinc-900">File References</h3>
          <p class="text-xs text-zinc-500">Related files powering this example</p>
        </div>
      </div>
    </div>
    <ul class="divide-y divide-zinc-100">
      <li class="group transition-colors duration-150 hover:bg-amber-50/50">
        <div class="flex flex-col gap-3 px-5 py-3.5 md:flex-row md:items-center md:gap-4">
          <div class="flex items-center gap-2.5 md:w-56">
            <span class="grid h-8 w-8 place-items-center rounded-lg bg-amber-100 text-amber-600 ring-1 ring-amber-200">
              <i class="fa-regular fa-eye text-xs"></i>
            </span>
            <span class="text-sm font-semibold text-zinc-700">{{ $t('auth.view') }}</span>
          </div>
          <code class="break-all rounded-md bg-zinc-100 px-3 py-1.5 text-xs font-mono text-amber-700 ring-1 ring-zinc-200 group-hover:bg-amber-100 group-hover:ring-amber-200">example/lib/widgets/example/cookie.j2.html</code>
        </div>
      </li>
      <li class="group transition-colors duration-150 hover:bg-amber-50/50">
        <div class="flex flex-col gap-3 px-5 py-3.5 md:flex-row md:items-center md:gap-4">
          <div class="flex items-center gap-2.5 md:w-56">
            <span class="grid h-8 w-8 place-items-center rounded-lg bg-yellow-100 text-yellow-700 ring-1 ring-yellow-200">
              <i class="fa-solid fa-code text-xs"></i>
            </span>
            <span class="text-sm font-semibold text-zinc-700">{{ $t('auth.controller') }}</span>
          </div>
          <code class="break-all rounded-md bg-zinc-100 px-3 py-1.5 text-xs font-mono text-yellow-800 ring-1 ring-zinc-200 group-hover:bg-yellow-100 group-hover:ring-yellow-200">example/lib/controllers/home_controller.dart</code>
        </div>
      </li>
      <li class="group transition-colors duration-150 hover:bg-amber-50/50">
        <div class="flex flex-col gap-3 px-5 py-3.5 md:flex-row md:items-center md:gap-4">
          <div class="flex items-center gap-2.5 md:w-56">
            <span class="grid h-8 w-8 place-items-center rounded-lg bg-rose-100 text-rose-600 ring-1 ring-rose-200">
              <i class="fa-solid fa-user-shield text-xs"></i>
            </span>
            <span class="text-sm font-semibold text-zinc-700">{{ $t('auth.authController') }}</span>
          </div>
          <code class="break-all rounded-md bg-zinc-100 px-3 py-1.5 text-xs font-mono text-rose-700 ring-1 ring-zinc-200 group-hover:bg-rose-100 group-hover:ring-rose-200">example/lib/controllers/auth_controller.dart</code>
        </div>
      </li>
      <li class="group transition-colors duration-150 hover:bg-amber-50/50">
        <div class="flex flex-col gap-3 px-5 py-3.5 md:flex-row md:items-center md:gap-4">
          <div class="flex items-center gap-2.5 md:w-56">
            <span class="grid h-8 w-8 place-items-center rounded-lg bg-indigo-100 text-indigo-600 ring-1 ring-indigo-200">
              <i class="fa-solid fa-route text-xs"></i>
            </span>
            <span class="text-sm font-semibold text-zinc-700">{{ $t('auth.router') }}</span>
          </div>
          <code class="break-all rounded-md bg-zinc-100 px-3 py-1.5 text-xs font-mono text-indigo-700 ring-1 ring-zinc-200 group-hover:bg-indigo-100 group-hover:ring-indigo-200">example/lib/route/web_route.dart</code>
        </div>
      </li>
    </ul>
  </section>
</div>
{% endblock %}
""",
	r"example/info.j2.html": r"""{% extends 'template/template.j2.html' %} {% block title %} {{
$t('sidebar.info') }}
{% endblock %}

{% block content %}

<div class="space-y-6">
  <!-- Hero -->
  <section class="reveal-up relative overflow-hidden rounded-3xl border border-zinc-200 bg-gradient-to-br from-zinc-900 via-indigo-950 to-blue-950 p-6 sm:p-8 shadow-soft">
    <div class="pointer-events-none absolute -right-16 -top-16 h-64 w-64 rounded-full bg-indigo-500/20 blur-3xl"></div>
    <div class="pointer-events-none absolute -bottom-20 -left-10 h-72 w-72 rounded-full bg-blue-500/10 blur-3xl"></div>

    <div class="relative flex flex-col gap-6 lg:flex-row lg:items-center lg:justify-between">
      <div class="flex items-start gap-4">
        <div class="relative grid h-14 w-14 place-items-center rounded-2xl bg-gradient-to-br from-indigo-400 to-blue-500 text-white shadow-lg ring-1 ring-white/20">
          <i class="fa-solid fa-circle-info text-2xl"></i>
          <span class="absolute -right-1 -top-1 h-3 w-3 rounded-full bg-emerald-400 ring-2 ring-zinc-900">
            <span class="absolute inset-0 animate-ping rounded-full bg-emerald-400"></span>
          </span>
        </div>
        <div class="space-y-2">
          <div class="flex flex-wrap items-center gap-2">
            <span class="inline-flex items-center gap-1.5 rounded-full bg-indigo-500/20 px-2.5 py-1 text-xs font-semibold uppercase tracking-wider text-indigo-200 ring-1 ring-inset ring-indigo-400/30">
              <i class="fa-solid fa-gauge-high text-[10px]"></i> Diagnostics
            </span>
            <span class="inline-flex items-center gap-1.5 rounded-full bg-blue-500/20 px-2.5 py-1 text-xs font-semibold uppercase tracking-wider text-blue-200 ring-1 ring-inset ring-blue-400/30">
              <i class="fa-solid fa-heart-pulse text-[10px]"></i> Live status
            </span>
            <span class="inline-flex items-center gap-1.5 rounded-full bg-emerald-500/20 px-2.5 py-1 text-xs font-semibold uppercase tracking-wider text-emerald-200 ring-1 ring-inset ring-emerald-400/30">
              <i class="fa-solid fa-circle-check text-[10px]"></i> Runtime
            </span>
          </div>
          <h1 class="text-2xl sm:text-3xl font-bold tracking-tight text-white">{{ $t('sidebar.info') }}</h1>
          <p class="max-w-2xl text-sm text-zinc-300">A live snapshot of your Finch server &mdash; runtime versions, database connectivity, system specs, sockets and scheduled jobs.</p>
        </div>
      </div>

      <div class="grid grid-cols-1 gap-3 sm:gap-4">
        <div class="rounded-2xl border border-white/10 bg-white/5 p-3 sm:p-4 text-center backdrop-blur">
          <div class="text-[10px] uppercase tracking-wider text-zinc-400">Status</div>
          <div class="mt-1 flex items-center justify-center gap-1.5 text-xl sm:text-2xl font-bold text-emerald-300">
            <i class="fa-solid fa-circle text-[10px] animate-pulse"></i>
            OK
          </div>
        </div>
      </div>
    </div>
  </section>

  <!-- Server Info Accordions -->
  <div class="grid gap-4 md:grid-cols-2">
    {% for key, value in server %}
    <details class="reveal-up animate-details group overflow-hidden rounded-2xl border border-zinc-200 bg-white shadow-soft transition hover:border-indigo-200 hover:shadow-soft-lg" open>
      <summary class="flex cursor-pointer list-none items-center justify-between gap-3 bg-gradient-to-r from-zinc-50 to-white px-5 py-4 transition-colors duration-150 group-open:from-indigo-50 group-open:to-blue-50">
        <div class="flex items-center gap-3">
          <span class="grid h-10 w-10 place-items-center rounded-xl bg-gradient-to-br from-indigo-500 to-blue-600 text-white shadow-sm ring-1 ring-indigo-300/50">
            <i class="fa-solid fa-circle-info text-sm"></i>
          </span>
          <div>
            <b class="block text-sm font-semibold text-zinc-900">{{ $t('finchInfo.key', {'key': key}) }}</b>
          </div>
        </div>
        <span class="grid h-8 w-8 place-items-center rounded-lg border border-zinc-200 bg-white text-zinc-500 transition group-hover:border-indigo-300 group-hover:text-indigo-600 group-open:rotate-180 group-open:border-indigo-400 group-open:text-indigo-600">
          <i class="fa-solid fa-chevron-down text-xs"></i>
        </span>
      </summary>

      <div class="border-t border-zinc-100 bg-zinc-50/50 px-4 py-4 sm:px-5">
        <dl class="space-y-2">
          {% for info, details in value | items() %}
          <div class="group/item flex flex-col gap-1 rounded-xl border border-zinc-200 bg-white px-3 py-2.5 transition hover:border-indigo-200 hover:shadow-sm sm:flex-row sm:items-center sm:justify-between sm:gap-4">
            <dt class="flex items-center gap-2 text-xs font-semibold uppercase tracking-wide text-zinc-600">
              <i class="fa-solid fa-angle-right text-[10px] text-indigo-500"></i>
              {{ $t('finchInfo.info', {'info': info}) }}
            </dt>
            <dd class="break-all rounded-md bg-zinc-100 px-2 py-1 font-mono text-xs text-zinc-800 sm:max-w-[60%] sm:text-right">{{ $t('finchInfo.details', {'details': details}) }}</dd>
          </div>
          {% endfor %}
        </dl>
      </div>
    </details>
    {% endfor %}
  </div>
</div>
{% endblock %}
""",
	r"example/mcp.j2.html": r"""<!doctype html>
<html class="h-full">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>MCP Server (Example)</title>
    <meta name="robots" content="noindex, nofollow" />
    <meta name="theme-color" content="#0d9488" />
    <link rel="icon" href="/favicon.ico" type="image/x-icon" />
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" />
    <link rel="stylesheet" href="/assets/effects/wave/wave.css" />
    <link rel="stylesheet" href="/assets/generated-tailwind.css" />
    <link rel="stylesheet" href="/assets/app.css" crossorigin="anonymous" />
    <style>
      html, body { font-family: 'Inter', ui-sans-serif, system-ui, -apple-system, sans-serif; }
    </style>
  </head>

  <body class="min-h-screen bg-zinc-50 text-zinc-800 antialiased">
    <div class="flex min-h-screen items-center justify-center p-6">
      <div class="w-full max-w-xl">

        <div class="overflow-hidden rounded-2xl border border-zinc-200 bg-white shadow-sm">

          <!-- Header strip -->
          <div class="relative h-28 overflow-hidden bg-gradient-to-br from-teal-600 via-cyan-600 to-emerald-600">
            <div aria-hidden="true" class="pointer-events-none absolute -top-12 -right-12 h-40 w-40 rounded-full bg-white/20 blur-2xl"></div>
            <div aria-hidden="true" class="pointer-events-none absolute -bottom-12 -left-8 h-32 w-32 rounded-full bg-emerald-300/30 blur-2xl"></div>
            <div class="relative flex h-full items-center px-6">
              <div class="flex h-14 w-14 items-center justify-center rounded-2xl bg-white/15 text-white ring-1 ring-white/30 backdrop-blur">
                <i class="fa-solid fa-robot text-2xl"></i>
              </div>
              <div class="ms-4">
                <div class="inline-flex items-center gap-1.5 rounded-full bg-white/15 px-2 py-0.5 text-[10px] font-bold uppercase tracking-[0.18em] text-white ring-1 ring-inset ring-white/30">
                  <span class="h-1.5 w-1.5 rounded-full bg-emerald-300"></span>
                  AI
                </div>
                <h1 class="mt-1 text-xl font-extrabold tracking-tight text-white drop-shadow">MCP Server</h1>
              </div>
            </div>
          </div>

          <!-- Body -->
          <div class="space-y-5 p-6 sm:p-8">

            <div>
              <label class="flex items-center gap-2 text-[11px] font-bold uppercase tracking-wider text-zinc-500">
                <i class="fa-solid fa-link text-teal-600"></i> Endpoint
              </label>
              <div class="mt-1.5 flex items-stretch gap-2">
                <code class="flex-1 select-all break-all rounded-lg border border-zinc-200 bg-zinc-50 px-3 py-2.5 text-sm font-mono text-zinc-800">{{ url }}</code>
                <button type="button" data-copy="{{ url }}"
                        class="wave inline-flex shrink-0 items-center gap-1.5 rounded-lg border border-zinc-200 bg-white px-3 text-sm font-semibold text-zinc-700 hover:bg-zinc-50 hover:border-zinc-300">
                  <i class="fa-regular fa-copy"></i>
                </button>
              </div>
            </div>

            <div>
              <label class="flex items-center gap-2 text-[11px] font-bold uppercase tracking-wider text-zinc-500">
                <i class="fa-solid fa-plug text-cyan-600"></i> Type
              </label>
              <div class="mt-1.5">
                <span class="inline-flex items-center gap-1.5 rounded-md bg-cyan-50 px-2.5 py-1 text-sm font-semibold text-cyan-700 ring-1 ring-inset ring-cyan-200">
                  {{ type }}
                </span>
              </div>
            </div>

            <div>
              <label class="flex items-center gap-2 text-[11px] font-bold uppercase tracking-wider text-zinc-500">
                <i class="fa-solid fa-key text-emerald-600"></i> API Key
              </label>
              <div class="mt-1.5 flex items-stretch gap-2">
                <code class="flex-1 select-all break-all rounded-lg border border-zinc-200 bg-zinc-50 px-3 py-2.5 text-sm font-mono text-zinc-800">{{ apikey }}</code>
                <button type="button" data-copy="{{ apikey }}"
                        class="wave inline-flex shrink-0 items-center gap-1.5 rounded-lg border border-zinc-200 bg-white px-3 text-sm font-semibold text-zinc-700 hover:bg-zinc-50 hover:border-zinc-300">
                  <i class="fa-regular fa-copy"></i>
                </button>
              </div>
            </div>

            <div class="rounded-lg border border-amber-200 bg-amber-50 p-3 text-xs text-amber-800">
              <i class="fa-solid fa-circle-info me-1"></i>
              Configure your MCP-capable AI client with the values above.
            </div>
          </div>

          <div class="flex items-center justify-between border-t border-zinc-200 bg-zinc-50 px-6 py-3 text-xs text-zinc-500">
            <span class="inline-flex items-center gap-1.5"><i class="fa-solid fa-feather text-teal-600"></i> Powered by Finch</span>
            <a href="https://github.com/uproid/finch" target="_blank" rel="noopener"
               class="inline-flex items-center gap-1 font-semibold text-zinc-600 hover:text-teal-700">
              <i class="fa-brands fa-github"></i> uproid/finch
            </a>
          </div>
        </div>

      </div>
    </div>

    <script src="https://code.jquery.com/jquery-3.7.1.min.js" crossorigin="anonymous"></script>
    <script>
      document.querySelectorAll('[data-copy]').forEach(function(btn){
        btn.addEventListener('click', function(){
          var v = btn.getAttribute('data-copy') || '';
          (navigator.clipboard ? navigator.clipboard.writeText(v) : Promise.resolve())
            .then(function(){
              var icon = btn.querySelector('i');
              if(!icon) return;
              var prev = icon.className;
              icon.className = 'fa-solid fa-check text-emerald-600';
              setTimeout(function(){ icon.className = prev; }, 1400);
            });
        });
      });
    </script>
  </body>
</html>
""",
	r"example/auth.j2.html": r"""{% extends 'template/template.j2.html' %}
{% block title %}
{{ $t('sidebar.authExample') }}
{% endblock %}
{% block content %}
<div class="space-y-6">

  {# ============== HERO ============== #}
  <section class="reveal-up relative overflow-hidden rounded-3xl border border-zinc-200 bg-gradient-to-br from-zinc-900 via-green-950 to-lime-950 p-6 sm:p-8 shadow-soft">
    <div class="pointer-events-none absolute -top-24 -end-24 h-72 w-72 rounded-full bg-green-500/20 blur-3xl"></div>
    <div class="pointer-events-none absolute -bottom-24 -start-24 h-72 w-72 rounded-full bg-lime-500/20 blur-3xl"></div>

    <div class="relative flex flex-col gap-6 lg:flex-row lg:items-center lg:justify-between">
      <div class="flex items-start gap-4">
        <div class="relative">
          <div class="inline-flex h-14 w-14 items-center justify-center rounded-2xl bg-white/10 ring-1 ring-white/20 backdrop-blur">
            <i class="fa-solid fa-user-shield text-2xl text-green-300"></i>
          </div>
          <span class="absolute -top-1 -end-1 inline-flex h-3.5 w-3.5">
            <span class="absolute inline-flex h-full w-full animate-ping rounded-full bg-lime-400 opacity-75"></span>
            <span class="relative inline-flex h-3.5 w-3.5 rounded-full bg-lime-400 ring-2 ring-zinc-900"></span>
          </span>
        </div>
        <div>
          <div class="flex flex-wrap items-center gap-2">
            <span class="inline-flex items-center gap-1.5 rounded-full bg-green-500/15 px-2.5 py-1 text-[11px] font-semibold uppercase tracking-wider text-green-300 ring-1 ring-green-400/30">
              <i class="fa-solid fa-circle-check text-[10px]"></i> Authenticated
            </span>
            <span class="inline-flex items-center gap-1.5 rounded-full bg-lime-500/15 px-2.5 py-1 text-[11px] font-semibold uppercase tracking-wider text-lime-300 ring-1 ring-lime-400/30">
              <i class="fa-solid fa-shield-halved text-[10px]"></i> Session-based
            </span>
            <span class="inline-flex items-center gap-1.5 rounded-full bg-amber-500/15 px-2.5 py-1 text-[11px] font-semibold uppercase tracking-wider text-amber-300 ring-1 ring-amber-400/30">
              <i class="fa-solid fa-key text-[10px]"></i> Permissions
            </span>
          </div>
          <h1 class="mt-2 text-2xl sm:text-3xl font-bold tracking-tight text-white">{{ $t('auth.test') }}</h1>
          <p class="mt-1 max-w-2xl text-sm text-zinc-300">A protected route guarded by Finch's <span class="font-semibold text-green-300">AuthController</span> &mdash; only signed-in users can see this page.</p>
        </div>
      </div>

      <div class="grid grid-cols-1 gap-3 sm:gap-4">
        <div class="rounded-2xl border border-white/10 bg-white/5 p-3 sm:p-4 text-center backdrop-blur">
          <div class="text-[10px] uppercase tracking-wider text-zinc-400">Access</div>
          <div class="mt-1 flex items-center justify-center gap-1.5 text-base sm:text-lg font-bold text-green-300">
            <i class="fa-solid fa-lock-open text-sm"></i> Granted
          </div>
        </div>
      </div>
    </div>
  </section>

  {# ============== WELCOME CARD ============== #}
  <section class="reveal-up overflow-hidden rounded-2xl border border-green-200 bg-gradient-to-br from-green-50 via-white to-lime-50 shadow-soft">
    <div class="flex flex-col gap-5 p-5 sm:flex-row sm:items-center sm:justify-between sm:p-6">
      <div class="flex items-center gap-4">
        <div class="relative grid h-16 w-16 place-items-center rounded-2xl bg-gradient-to-br from-green-500 to-lime-600 text-white shadow-lg ring-2 ring-white">
          <i class="fa-solid fa-user-check text-2xl"></i>
          <span class="absolute -bottom-1 -right-1 grid h-6 w-6 place-items-center rounded-full bg-white ring-2 ring-green-200">
            <i class="fa-solid fa-circle-check text-[14px] text-green-600"></i>
          </span>
        </div>
        <div>
          <p class="flex items-center gap-1.5 text-xs font-semibold uppercase tracking-wider text-green-700">
            <i class="fa-solid fa-hand text-[11px]"></i>
            {{ $t('auth.welcome') }}
          </p>
          <p class="mt-0.5 text-2xl font-bold text-zinc-900">{{ user.name }}</p>
          <p class="mt-1 inline-flex items-center gap-1.5 rounded-full bg-green-100 px-2.5 py-0.5 text-[11px] font-semibold text-green-800 ring-1 ring-green-200">
            <i class="fa-solid fa-circle text-[8px] animate-pulse"></i>
            Signed in
          </p>
        </div>
      </div>
      <a href="/logout" class="wave group inline-flex shrink-0 items-center justify-center gap-2 rounded-xl bg-gradient-to-r from-rose-500 to-pink-600 px-5 py-2.5 text-sm font-semibold text-white shadow-soft transition-all duration-200 hover:from-rose-600 hover:to-pink-700 hover:shadow-soft-lg focus:outline-none focus:ring-4 focus:ring-rose-500/30">
        <i class="fa-solid fa-right-from-bracket text-sm transition-transform duration-200 group-hover:translate-x-0.5"></i>
        <span>{{ $t('auth.logout') }}</span>
      </a>
    </div>
  </section>

  {# ============== HOW IT WORKS ============== #}
  <section class="reveal-up overflow-hidden rounded-2xl border border-zinc-200 bg-white shadow-soft">
    <div class="flex items-center gap-3 bg-gradient-to-r from-zinc-50 to-white px-5 py-4 border-b border-zinc-200">
      <span class="grid h-10 w-10 place-items-center rounded-xl bg-gradient-to-br from-green-500 to-lime-600 text-white shadow-sm ring-1 ring-green-300/50">
        <i class="fa-solid fa-diagram-project text-sm"></i>
      </span>
      <div>
        <h3 class="text-base font-bold text-zinc-900">How it works</h3>
        <p class="text-xs text-zinc-500">The auth flow at a glance</p>
      </div>
    </div>
    <div class="grid gap-4 p-5 sm:grid-cols-3">
      <div class="group rounded-xl border border-zinc-200 bg-white p-4 transition hover:border-green-300 hover:shadow-sm">
        <div class="mb-2 flex items-center gap-2">
          <span class="grid h-8 w-8 place-items-center rounded-lg bg-green-100 text-green-700 ring-1 ring-green-200">
            <i class="fa-solid fa-1 text-xs font-bold"></i>
          </span>
          <p class="text-sm font-bold text-zinc-900">Login</p>
        </div>
        <p class="text-xs text-zinc-600">Submit credentials; <code class="rounded bg-zinc-100 px-1 text-[11px] text-green-700">AuthController</code> validates them and stores a session.</p>
      </div>
      <div class="group rounded-xl border border-zinc-200 bg-white p-4 transition hover:border-lime-300 hover:shadow-sm">
        <div class="mb-2 flex items-center gap-2">
          <span class="grid h-8 w-8 place-items-center rounded-lg bg-lime-100 text-lime-700 ring-1 ring-lime-200">
            <i class="fa-solid fa-2 text-xs font-bold"></i>
          </span>
          <p class="text-sm font-bold text-zinc-900">Guarded route</p>
        </div>
        <p class="text-xs text-zinc-600">This route has <code class="rounded bg-zinc-100 px-1 text-[11px] text-lime-700">auth</code> attached, so unauthenticated requests are redirected.</p>
      </div>
      <div class="group rounded-xl border border-zinc-200 bg-white p-4 transition hover:border-rose-300 hover:shadow-sm">
        <div class="mb-2 flex items-center gap-2">
          <span class="grid h-8 w-8 place-items-center rounded-lg bg-rose-100 text-rose-700 ring-1 ring-rose-200">
            <i class="fa-solid fa-3 text-xs font-bold"></i>
          </span>
          <p class="text-sm font-bold text-zinc-900">Logout</p>
        </div>
        <p class="text-xs text-zinc-600">Hitting <code class="rounded bg-zinc-100 px-1 text-[11px] text-rose-700">/logout</code> destroys the session and revokes access.</p>
      </div>
    </div>
  </section>

  {# ============== FILE REFERENCES ============== #}
  <section class="reveal-up overflow-hidden rounded-2xl border border-zinc-200 bg-white shadow-soft">
    <div class="flex items-center justify-between gap-3 bg-gradient-to-r from-zinc-50 to-white px-5 py-4 border-b border-zinc-200">
      <div class="flex items-center gap-3">
        <span class="grid h-10 w-10 place-items-center rounded-xl bg-gradient-to-br from-zinc-700 to-zinc-900 text-white shadow-sm ring-1 ring-zinc-300/50">
          <i class="fa-solid fa-folder-tree text-sm"></i>
        </span>
        <div>
          <h3 class="text-base font-bold text-zinc-900">{{ $t('File References') }}</h3>
          <p class="text-xs text-zinc-500">{{ $t('Related files for this authentication example') }}</p>
        </div>
      </div>
    </div>
    <ul class="divide-y divide-zinc-100">
      <li class="group transition-colors duration-150 hover:bg-green-50/50">
        <div class="flex flex-col gap-3 px-5 py-3.5 md:flex-row md:items-center md:gap-4">
          <div class="flex items-center gap-2.5 md:w-56">
            <span class="grid h-8 w-8 place-items-center rounded-lg bg-green-100 text-green-600 ring-1 ring-green-200">
              <i class="fa-regular fa-eye text-xs"></i>
            </span>
            <span class="text-sm font-semibold text-zinc-700">{{ $t('auth.view') }}</span>
          </div>
          <code class="break-all rounded-md bg-zinc-100 px-3 py-1.5 text-xs font-mono text-green-700 ring-1 ring-zinc-200 group-hover:bg-green-100 group-hover:ring-green-200">example/lib/widgets/example/auth.j2.html</code>
        </div>
      </li>
      <li class="group transition-colors duration-150 hover:bg-green-50/50">
        <div class="flex flex-col gap-3 px-5 py-3.5 md:flex-row md:items-center md:gap-4">
          <div class="flex items-center gap-2.5 md:w-56">
            <span class="grid h-8 w-8 place-items-center rounded-lg bg-lime-100 text-lime-700 ring-1 ring-lime-200">
              <i class="fa-solid fa-code text-xs"></i>
            </span>
            <span class="text-sm font-semibold text-zinc-700">{{ $t('auth.controller') }}</span>
          </div>
          <code class="break-all rounded-md bg-zinc-100 px-3 py-1.5 text-xs font-mono text-lime-800 ring-1 ring-zinc-200 group-hover:bg-lime-100 group-hover:ring-lime-200">example/lib/controllers/home_controller.dart</code>
        </div>
      </li>
      <li class="group transition-colors duration-150 hover:bg-green-50/50">
        <div class="flex flex-col gap-3 px-5 py-3.5 md:flex-row md:items-center md:gap-4">
          <div class="flex items-center gap-2.5 md:w-56">
            <span class="grid h-8 w-8 place-items-center rounded-lg bg-emerald-100 text-emerald-700 ring-1 ring-emerald-200">
              <i class="fa-solid fa-user-shield text-xs"></i>
            </span>
            <span class="text-sm font-semibold text-zinc-700">{{ $t('auth.authController') }}</span>
          </div>
          <code class="break-all rounded-md bg-zinc-100 px-3 py-1.5 text-xs font-mono text-emerald-700 ring-1 ring-zinc-200 group-hover:bg-emerald-100 group-hover:ring-emerald-200">example/lib/controllers/auth_controller.dart</code>
        </div>
      </li>
      <li class="group transition-colors duration-150 hover:bg-green-50/50">
        <div class="flex flex-col gap-3 px-5 py-3.5 md:flex-row md:items-center md:gap-4">
          <div class="flex items-center gap-2.5 md:w-56">
            <span class="grid h-8 w-8 place-items-center rounded-lg bg-indigo-100 text-indigo-600 ring-1 ring-indigo-200">
              <i class="fa-solid fa-route text-xs"></i>
            </span>
            <span class="text-sm font-semibold text-zinc-700">{{ $t('auth.router') }}</span>
          </div>
          <code class="break-all rounded-md bg-zinc-100 px-3 py-1.5 text-xs font-mono text-indigo-700 ring-1 ring-zinc-200 group-hover:bg-indigo-100 group-hover:ring-indigo-200">example/lib/route/web_route.dart</code>
        </div>
      </li>
    </ul>
  </section>
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
	r"template/sidebar.j2.html": r"""{% set dir = $t('dir') %}
<aside
  id="sidebar"
  class="fixed inset-y-0 start-0 z-40 w-[280px] overflow-y-auto border-e border-zinc-200 bg-white transform transition-transform duration-300 ease-out  {{ 'translate-x-full lg:translate-x-0' if dir=='rtl' else '-translate-x-full lg:translate-x-0' }}"
  aria-hidden="true"
  data-state="closed"
  style="scrollbar-width: thin;"
>
  <!-- accent stripe -->
  <div class="pointer-events-none absolute inset-y-0 {{ 'right-0' if dir=='rtl' else 'left-0' }} w-px bg-gradient-to-b from-teal-400/40 via-cyan-400/30 to-emerald-400/40"></div>

  <div class="h-full flex flex-col pt-16">
    <!-- Sidebar Navigation -->
    <nav class="flex-1 overflow-y-auto px-3 py-4 space-y-6">

      <!-- ====== QUICK ACTION ====== -->
      <div>
        <div class="relative overflow-hidden rounded-2xl border border-zinc-200/70 bg-gradient-to-br from-zinc-900 to-zinc-800 p-4 text-white shadow-lg">
          <div aria-hidden="true" class="pointer-events-none absolute -top-10 -right-10 h-32 w-32 rounded-full bg-teal-500/30 blur-2xl"></div>
          <div class="relative flex items-center gap-3">
            <span class="flex h-10 w-10 items-center justify-center rounded-xl bg-gradient-to-br from-teal-400 to-emerald-500 text-zinc-900 shadow-md shadow-teal-500/40">
              <i class="fa-solid fa-bolt-lightning"></i>
            </span>
            <div class="min-w-0 flex-1">
              <div class="truncate text-xs font-bold text-white">Finch Framework</div>
              <div class="truncate text-[10px] font-medium text-white">{{ version }} · made with ❤</div>
            </div>
          </div>
        </div>
      </div>

      <!-- ====== NAVIGATION ====== -->
      <div class="space-y-1.5">
        <div class="px-3 mb-1 flex items-center gap-2">
          <span class="h-px flex-1 bg-gradient-to-r from-transparent via-zinc-200 to-transparent"></span>
          <span class="text-[10px] font-bold uppercase tracking-[0.15em] text-zinc-400">{{ $t('sidebar.navigation') }}</span>
          <span class="h-px flex-1 bg-gradient-to-r from-transparent via-zinc-200 to-transparent"></span>
        </div>

        <a
          href="{{ $e.routeUrl('root.home') }}"
          class="wave group relative flex w-full items-center gap-3 rounded-xl px-3 py-2.5 text-sm transition-all duration-200 {{ 'bg-gradient-to-r from-teal-50 via-cyan-50 to-white text-teal-700 font-semibold ring-1 ring-teal-200/70 shadow-sm shadow-teal-100' if $e.isKey('root.home') else 'text-zinc-600 hover:bg-zinc-50 hover:text-teal-700' }}"
          aria-current="page"
        >
          {% if $e.isKey('root.home') %}<span class="absolute inset-y-2 {{ 'right-0' if dir=='rtl' else 'left-0' }} w-1 rounded-full bg-gradient-to-b from-teal-500 to-cyan-500"></span>{% endif %}
          <span class="flex h-8 w-8 items-center justify-center rounded-lg transition-all duration-200 {{ 'bg-gradient-to-br from-teal-500 to-cyan-500 text-white shadow-md shadow-teal-500/30' if $e.isKey('root.home') else 'bg-zinc-100 text-zinc-500 group-hover:bg-teal-100 group-hover:text-teal-600' }}">
            <i class="fa-solid fa-house text-sm"></i>
          </span>
          <span class="flex-1 truncate">{{ $t('sidebar.home') }}</span>
        </a>

        <a
          href="{{ $e.routeUrl('root.info') }}"
          class="wave group relative flex w-full items-center gap-3 rounded-xl px-3 py-2.5 text-sm transition-all duration-200 {{ 'bg-gradient-to-r from-teal-50 via-cyan-50 to-white text-teal-700 font-semibold ring-1 ring-teal-200/70 shadow-sm shadow-teal-100' if $e.isKey('root.info') else 'text-zinc-600 hover:bg-zinc-50 hover:text-teal-700' }}"
        >
          {% if $e.isKey('root.info') %}<span class="absolute inset-y-2 {{ 'right-0' if dir=='rtl' else 'left-0' }} w-1 rounded-full bg-gradient-to-b from-teal-500 to-cyan-500"></span>{% endif %}
          <span class="flex h-8 w-8 items-center justify-center rounded-lg transition-all duration-200 {{ 'bg-gradient-to-br from-teal-500 to-cyan-500 text-white shadow-md shadow-teal-500/30' if $e.isKey('root.info') else 'bg-zinc-100 text-zinc-500 group-hover:bg-teal-100 group-hover:text-teal-600' }}">
            <i class="fa-solid fa-circle-info text-sm"></i>
          </span>
          <span class="flex-1 truncate">{{ $t('sidebar.info') }}</span>
        </a>
      </div>

      <!-- ====== WEB EXAMPLES ====== -->
      <div class="space-y-1.5">
        <div class="px-3 mb-1 flex items-center gap-2">
          <span class="h-px flex-1 bg-gradient-to-r from-transparent via-zinc-200 to-transparent"></span>
          <span class="text-[10px] font-bold uppercase tracking-[0.15em] text-zinc-400">{{ $t('sidebar.webExamples') }}</span>
          <span class="h-px flex-1 bg-gradient-to-r from-transparent via-zinc-200 to-transparent"></span>
        </div>

        {% set isFormActive = $e.hasKey(['root.form','root.form.post']) %}
        <a href="{{ $e.routeUrl('root.form') }}" class="wave group relative flex w-full items-center gap-3 rounded-xl px-3 py-2.5 text-sm transition-all duration-200 {{ 'bg-gradient-to-r from-teal-50 via-cyan-50 to-white text-teal-700 font-semibold ring-1 ring-teal-200/70 shadow-sm' if isFormActive else 'text-zinc-600 hover:bg-zinc-50 hover:text-teal-700' }}">
          {% if isFormActive %}<span class="absolute inset-y-2 {{ 'right-0' if dir=='rtl' else 'left-0' }} w-1 rounded-full bg-gradient-to-b from-teal-500 to-cyan-500"></span>{% endif %}
          <span class="flex h-8 w-8 items-center justify-center rounded-lg transition-all duration-200 {{ 'bg-gradient-to-br from-teal-500 to-cyan-500 text-white shadow-md shadow-teal-500/30' if isFormActive else 'bg-zinc-100 text-zinc-500 group-hover:bg-teal-100 group-hover:text-teal-600' }}">
            <i class="fa-solid fa-pen-to-square text-sm"></i>
          </span>
          <span class="flex-1 truncate">{{ $t('sidebar.formExample') }}</span>
        </a>

        {% set isCookieActive = $e.hasKey(['root.cookie','root.cookie.post']) %}
        <a href="{{ $e.routeUrl('root.cookie') }}" class="wave group relative flex w-full items-center gap-3 rounded-xl px-3 py-2.5 text-sm transition-all duration-200 {{ 'bg-gradient-to-r from-teal-50 via-cyan-50 to-white text-teal-700 font-semibold ring-1 ring-teal-200/70 shadow-sm' if isCookieActive else 'text-zinc-600 hover:bg-zinc-50 hover:text-teal-700' }}">
          {% if isCookieActive %}<span class="absolute inset-y-2 {{ 'right-0' if dir=='rtl' else 'left-0' }} w-1 rounded-full bg-gradient-to-b from-teal-500 to-cyan-500"></span>{% endif %}
          <span class="flex h-8 w-8 items-center justify-center rounded-lg transition-all duration-200 {{ 'bg-gradient-to-br from-amber-500 to-orange-500 text-white shadow-md shadow-amber-500/30' if isCookieActive else 'bg-zinc-100 text-zinc-500 group-hover:bg-amber-100 group-hover:text-amber-600' }}">
            <i class="fa-solid fa-cookie-bite text-sm"></i>
          </span>
          <span class="flex-1 truncate">{{ $t('sidebar.cookieExample') }}</span>
        </a>

        {% set isRouteActive = $e.hasKey(['root.route']) %}
        <a href="{{ $e.routeUrl('root.route') }}" class="wave group relative flex w-full items-center gap-3 rounded-xl px-3 py-2.5 text-sm transition-all duration-200 {{ 'bg-gradient-to-r from-teal-50 via-cyan-50 to-white text-teal-700 font-semibold ring-1 ring-teal-200/70 shadow-sm' if isRouteActive else 'text-zinc-600 hover:bg-zinc-50 hover:text-teal-700' }}">
          {% if isRouteActive %}<span class="absolute inset-y-2 {{ 'right-0' if dir=='rtl' else 'left-0' }} w-1 rounded-full bg-gradient-to-b from-teal-500 to-cyan-500"></span>{% endif %}
          <span class="flex h-8 w-8 items-center justify-center rounded-lg transition-all duration-200 {{ 'bg-gradient-to-br from-teal-500 to-cyan-500 text-white shadow-md shadow-teal-500/30' if isRouteActive else 'bg-zinc-100 text-zinc-500 group-hover:bg-teal-100 group-hover:text-teal-600' }}">
            <i class="fa-solid fa-route text-sm"></i>
          </span>
          <span class="flex-1 truncate">{{ $t('sidebar.routeExample') }}</span>
        </a>

        {% set isSocketActive = $e.hasKey(['root.socket']) %}
        <a href="{{ $e.routeUrl('root.socket') }}" class="wave group relative flex w-full items-center gap-3 rounded-xl px-3 py-2.5 text-sm transition-all duration-200 {{ 'bg-gradient-to-r from-teal-50 via-cyan-50 to-white text-teal-700 font-semibold ring-1 ring-teal-200/70 shadow-sm' if isSocketActive else 'text-zinc-600 hover:bg-zinc-50 hover:text-teal-700' }}">
          {% if isSocketActive %}<span class="absolute inset-y-2 {{ 'right-0' if dir=='rtl' else 'left-0' }} w-1 rounded-full bg-gradient-to-b from-teal-500 to-cyan-500"></span>{% endif %}
          <span class="flex h-8 w-8 items-center justify-center rounded-lg transition-all duration-200 {{ 'bg-gradient-to-br from-yellow-400 to-amber-500 text-white shadow-md shadow-yellow-500/30' if isSocketActive else 'bg-zinc-100 text-zinc-500 group-hover:bg-amber-100 group-hover:text-amber-600' }}">
            <i class="fa-solid fa-bolt text-sm"></i>
          </span>
          <span class="flex-1 truncate">{{ $t('sidebar.socketExample') }}</span>
        </a>

        {% set isEmailActive = $e.hasKey(['root.email','root.email.post']) %}
        <a href="{{ $e.routeUrl('root.email') }}" class="wave group relative flex w-full items-center gap-3 rounded-xl px-3 py-2.5 text-sm transition-all duration-200 {{ 'bg-gradient-to-r from-teal-50 via-cyan-50 to-white text-teal-700 font-semibold ring-1 ring-teal-200/70 shadow-sm' if isEmailActive else 'text-zinc-600 hover:bg-zinc-50 hover:text-teal-700' }}">
          {% if isEmailActive %}<span class="absolute inset-y-2 {{ 'right-0' if dir=='rtl' else 'left-0' }} w-1 rounded-full bg-gradient-to-b from-teal-500 to-cyan-500"></span>{% endif %}
          <span class="flex h-8 w-8 items-center justify-center rounded-lg transition-all duration-200 {{ 'bg-gradient-to-br from-sky-500 to-cyan-500 text-white shadow-md shadow-sky-500/30' if isEmailActive else 'bg-zinc-100 text-zinc-500 group-hover:bg-sky-100 group-hover:text-sky-600' }}">
            <i class="fa-solid fa-envelope text-sm"></i>
          </span>
          <span class="flex-1 truncate">{{ $t('sidebar.emailExample') }}</span>
        </a>

        {% set isAuthActive = $e.hasKey(['root.panel']) %}
        <a href="{{ $e.routeUrl('root.panel') }}" class="wave group relative flex w-full items-center gap-3 rounded-xl px-3 py-2.5 text-sm transition-all duration-200 {{ 'bg-gradient-to-r from-teal-50 via-cyan-50 to-white text-teal-700 font-semibold ring-1 ring-teal-200/70 shadow-sm' if isAuthActive else 'text-zinc-600 hover:bg-zinc-50 hover:text-teal-700' }}">
          {% if isAuthActive %}<span class="absolute inset-y-2 {{ 'right-0' if dir=='rtl' else 'left-0' }} w-1 rounded-full bg-gradient-to-b from-teal-500 to-cyan-500"></span>{% endif %}
          <span class="flex h-8 w-8 items-center justify-center rounded-lg transition-all duration-200 {{ 'bg-gradient-to-br from-emerald-500 to-teal-500 text-white shadow-md shadow-emerald-500/30' if isAuthActive else 'bg-zinc-100 text-zinc-500 group-hover:bg-emerald-100 group-hover:text-emerald-600' }}">
            <i class="fa-solid fa-shield-alt text-sm"></i>
          </span>
          <span class="flex-1 truncate">{{ $t('sidebar.authExample') }}</span>
        </a>

        {% set isLangActive = $e.hasKey(['root.language']) %}
        <a href="{{ $e.routeUrl('root.language') }}" class="wave group relative flex w-full items-center gap-3 rounded-xl px-3 py-2.5 text-sm transition-all duration-200 {{ 'bg-gradient-to-r from-teal-50 via-cyan-50 to-white text-teal-700 font-semibold ring-1 ring-teal-200/70 shadow-sm' if isLangActive else 'text-zinc-600 hover:bg-zinc-50 hover:text-teal-700' }}">
          {% if isLangActive %}<span class="absolute inset-y-2 {{ 'right-0' if dir=='rtl' else 'left-0' }} w-1 rounded-full bg-gradient-to-b from-teal-500 to-cyan-500"></span>{% endif %}
          <span class="flex h-8 w-8 items-center justify-center rounded-lg transition-all duration-200 {{ 'bg-gradient-to-br from-emerald-500 to-rose-500 text-white shadow-md shadow-emerald-500/30' if isLangActive else 'bg-zinc-100 text-zinc-500 group-hover:bg-emerald-100 group-hover:text-emerald-600' }}">
            <i class="fa-solid fa-language text-sm"></i>
          </span>
          <span class="flex-1 truncate">{{ $t('sidebar.languageExample') }}</span>
        </a>

        <a href="{{ $e.routeUrl('mcp.books') }}" class="wave group relative flex w-full items-center gap-3 rounded-xl px-3 py-2.5 text-sm transition-all duration-200 text-zinc-600 hover:bg-zinc-50 hover:text-teal-700">
          <span class="flex h-8 w-8 items-center justify-center rounded-lg bg-zinc-100 text-zinc-500 group-hover:bg-cyan-100 group-hover:text-cyan-600 transition-all duration-200">
            <i class="fa-solid fa-robot text-sm"></i>
          </span>
          <span class="flex-1 truncate">{{ $t('MCP Server') }}</span>
          <span class="rounded-md bg-cyan-100 px-1.5 py-0.5 text-[9px] font-bold uppercase tracking-wider text-cyan-700 ring-1 ring-inset ring-cyan-200">AI</span>
        </a>
      </div>

      <!-- ====== DATABASE ====== -->
      {% if mongoActive ?? mysqlActive %}
      <div class="space-y-1.5">
        <div class="px-3 mb-1 flex items-center gap-2">
          <span class="h-px flex-1 bg-gradient-to-r from-transparent via-zinc-200 to-transparent"></span>
          <span class="text-[10px] font-bold uppercase tracking-[0.15em] text-zinc-400">{{ $t('sidebar.databaseExamples') }}</span>
          <span class="h-px flex-1 bg-gradient-to-r from-transparent via-zinc-200 to-transparent"></span>
        </div>

        {% if mongoActive %}
        {% set isDbActive = $e.hasKey(['root.database']) %}
        <a href="{{ $e.routeUrl('root.database') }}" class="wave group relative flex w-full items-center gap-3 rounded-xl px-3 py-2.5 text-sm transition-all duration-200 {{ 'bg-gradient-to-r from-emerald-50 via-green-50 to-white text-emerald-700 font-semibold ring-1 ring-emerald-200/70 shadow-sm' if isDbActive else 'text-zinc-600 hover:bg-zinc-50 hover:text-emerald-700' }}">
          {% if isDbActive %}<span class="absolute inset-y-2 {{ 'right-0' if dir=='rtl' else 'left-0' }} w-1 rounded-full bg-gradient-to-b from-emerald-500 to-green-500"></span>{% endif %}
          <span class="flex h-8 w-8 items-center justify-center rounded-lg transition-all duration-200 {{ 'bg-gradient-to-br from-emerald-500 to-green-500 text-white shadow-md shadow-emerald-500/30' if isDbActive else 'bg-zinc-100 text-zinc-500 group-hover:bg-emerald-100 group-hover:text-emerald-600' }}">
            <i class="fa-solid fa-leaf text-sm"></i>
          </span>
          <span class="flex-1 truncate">{{ $t('sidebar.monogdbExample') }}</span>
        </a>

        {% set isPersonsActive = $e.hasKey(['root.persons','root.person.show','root.person.delete']) %}
        <a href="{{ $e.routeUrl('root.persons') }}" class="wave group relative flex w-full items-center gap-3 rounded-xl px-3 py-2.5 text-sm transition-all duration-200 {{ 'bg-gradient-to-r from-teal-50 via-cyan-50 to-white text-teal-700 font-semibold ring-1 ring-teal-200/70 shadow-sm' if isPersonsActive else 'text-zinc-600 hover:bg-zinc-50 hover:text-teal-700' }}">
          {% if isPersonsActive %}<span class="absolute inset-y-2 {{ 'right-0' if dir=='rtl' else 'left-0' }} w-1 rounded-full bg-gradient-to-b from-teal-500 to-cyan-500"></span>{% endif %}
          <span class="flex h-8 w-8 items-center justify-center rounded-lg transition-all duration-200 {{ 'bg-gradient-to-br from-teal-500 to-cyan-500 text-white shadow-md shadow-teal-500/30' if isPersonsActive else 'bg-zinc-100 text-zinc-500 group-hover:bg-teal-100 group-hover:text-teal-600' }}">
            <i class="fa-solid fa-users text-sm"></i>
          </span>
          <span class="flex-1 truncate">{{ $t('sidebar.freeModelDbExample') }}</span>
        </a>
        {% endif %}

        {% if mysqlActive %}
        {% set isMysqlActive = $e.hasKey(['root.mysql']) %}
        <a href="{{ $e.routeUrl('root.mysql') }}" class="wave group relative flex w-full items-center gap-3 rounded-xl px-3 py-2.5 text-sm transition-all duration-200 {{ 'bg-gradient-to-r from-orange-50 via-amber-50 to-white text-orange-700 font-semibold ring-1 ring-orange-200/70 shadow-sm' if isMysqlActive else 'text-zinc-600 hover:bg-zinc-50 hover:text-orange-700' }}">
          {% if isMysqlActive %}<span class="absolute inset-y-2 {{ 'right-0' if dir=='rtl' else 'left-0' }} w-1 rounded-full bg-gradient-to-b from-orange-500 to-amber-500"></span>{% endif %}
          <span class="flex h-8 w-8 items-center justify-center rounded-lg transition-all duration-200 {{ 'bg-gradient-to-br from-orange-500 to-amber-500 text-white shadow-md shadow-orange-500/30' if isMysqlActive else 'bg-zinc-100 text-zinc-500 group-hover:bg-orange-100 group-hover:text-orange-600' }}">
            <i class="fa-solid fa-database text-sm"></i>
          </span>
          <span class="flex-1 truncate">{{ $t('sidebar.mysqlExample') }}</span>
        </a>

        {% set isSqliteActive = $e.hasKey(['root.sqlite']) %}
        <a href="{{ $e.routeUrl('root.sqlite') }}" class="wave group relative flex w-full items-center gap-3 rounded-xl px-3 py-2.5 text-sm transition-all duration-200 {{ 'bg-gradient-to-r from-sky-50 via-blue-50 to-white text-sky-700 font-semibold ring-1 ring-sky-200/70 shadow-sm' if isSqliteActive else 'text-zinc-600 hover:bg-zinc-50 hover:text-sky-700' }}">
          {% if isSqliteActive %}<span class="absolute inset-y-2 {{ 'right-0' if dir=='rtl' else 'left-0' }} w-1 rounded-full bg-gradient-to-b from-sky-500 to-blue-500"></span>{% endif %}
          <span class="flex h-8 w-8 items-center justify-center rounded-lg transition-all duration-200 {{ 'bg-gradient-to-br from-sky-500 to-blue-500 text-white shadow-md shadow-sky-500/30' if isSqliteActive else 'bg-zinc-100 text-zinc-500 group-hover:bg-sky-100 group-hover:text-sky-600' }}">
            <i class="fa-solid fa-hard-drive text-sm"></i>
          </span>
          <span class="flex-1 truncate">{{ $t('SQLite Example') }}</span>
        </a>
        {% endif %}
      </div>
      {% endif %}

      <!-- ====== DEV TOOLS ====== -->
      <div class="space-y-1.5">
        <div class="px-3 mb-1 flex items-center gap-2">
          <span class="h-px flex-1 bg-gradient-to-r from-transparent via-zinc-200 to-transparent"></span>
          <span class="text-[10px] font-bold uppercase tracking-[0.15em] text-zinc-400">{{ $t('sidebar.developmentTools') }}</span>
          <span class="h-px flex-1 bg-gradient-to-r from-transparent via-zinc-200 to-transparent"></span>
        </div>

        {% set isPagActive = $e.hasKey(['root.pagination']) %}
        <a href="{{ $e.routeUrl('root.pagination') }}" class="wave group relative flex w-full items-center gap-3 rounded-xl px-3 py-2.5 text-sm transition-all duration-200 {{ 'bg-gradient-to-r from-teal-50 via-cyan-50 to-white text-teal-700 font-semibold ring-1 ring-teal-200/70 shadow-sm' if isPagActive else 'text-zinc-600 hover:bg-zinc-50 hover:text-teal-700' }}">
          {% if isPagActive %}<span class="absolute inset-y-2 {{ 'right-0' if dir=='rtl' else 'left-0' }} w-1 rounded-full bg-gradient-to-b from-teal-500 to-cyan-500"></span>{% endif %}
          <span class="flex h-8 w-8 items-center justify-center rounded-lg transition-all duration-200 {{ 'bg-gradient-to-br from-teal-500 to-cyan-500 text-white shadow-md shadow-teal-500/30' if isPagActive else 'bg-zinc-100 text-zinc-500 group-hover:bg-teal-100 group-hover:text-teal-600' }}">
            <i class="fa-solid fa-route text-sm"></i>
          </span>
          <span class="flex-1 truncate">{{ $t('sidebar.paginationExample') }}</span>
        </a>

        {% set isHtmlerActive = $e.hasKey(['root.htmler']) %}
        <a href="{{ $e.routeUrl('root.htmler') }}" class="wave group relative flex w-full items-center gap-3 rounded-xl px-3 py-2.5 text-sm transition-all duration-200 {{ 'bg-gradient-to-r from-teal-50 via-cyan-50 to-white text-teal-700 font-semibold ring-1 ring-teal-200/70 shadow-sm' if isHtmlerActive else 'text-zinc-600 hover:bg-zinc-50 hover:text-teal-700' }}">
          {% if isHtmlerActive %}<span class="absolute inset-y-2 {{ 'right-0' if dir=='rtl' else 'left-0' }} w-1 rounded-full bg-gradient-to-b from-teal-500 to-cyan-500"></span>{% endif %}
          <span class="flex h-8 w-8 items-center justify-center rounded-lg transition-all duration-200 {{ 'bg-gradient-to-br from-emerald-500 to-emerald-500 text-white shadow-md shadow-emerald-500/30' if isHtmlerActive else 'bg-zinc-100 text-zinc-500 group-hover:bg-emerald-100 group-hover:text-emerald-600' }}">
            <i class="fa-solid fa-code text-sm"></i>
          </span>
          <span class="flex-1 truncate">{{ $t('sidebar.htmlerExample') }}</span>
        </a>

        {% set isSwagActive = $e.hasKey(['root.swagger']) %}
        <a href="{{ $e.routeUrl('root.swagger') }}" class="wave group relative flex w-full items-center gap-3 rounded-xl px-3 py-2.5 text-sm transition-all duration-200 {{ 'bg-gradient-to-r from-green-50 via-emerald-50 to-white text-green-700 font-semibold ring-1 ring-green-200/70 shadow-sm' if isSwagActive else 'text-zinc-600 hover:bg-zinc-50 hover:text-green-700' }}">
          {% if isSwagActive %}<span class="absolute inset-y-2 {{ 'right-0' if dir=='rtl' else 'left-0' }} w-1 rounded-full bg-gradient-to-b from-green-500 to-emerald-500"></span>{% endif %}
          <span class="flex h-8 w-8 items-center justify-center rounded-lg transition-all duration-200 {{ 'bg-gradient-to-br from-green-500 to-emerald-500 text-white shadow-md shadow-green-500/30' if isSwagActive else 'bg-zinc-100 text-zinc-500 group-hover:bg-green-100 group-hover:text-green-600' }}">
            <i class="fa-solid fa-book-open text-sm"></i>
          </span>
          <span class="flex-1 truncate">{{ $t('sidebar.swaggerExample') }}</span>
        </a>
      </div>

      <!-- ====== DEBUG & TESTING ====== -->
      <div class="space-y-1.5">
        <div class="px-3 mb-1 flex items-center gap-2">
          <span class="h-px flex-1 bg-gradient-to-r from-transparent via-zinc-200 to-transparent"></span>
          <span class="text-[10px] font-bold uppercase tracking-[0.15em] text-zinc-400">{{ $t('sidebar.debugTesting') }}</span>
          <span class="h-px flex-1 bg-gradient-to-r from-transparent via-zinc-200 to-transparent"></span>
        </div>

        {% set isErrorActive = $e.hasKey(['root.error']) %}
        <a href="{{ $e.routeUrl('root.error') }}" class="wave group relative flex w-full items-center gap-3 rounded-xl px-3 py-2.5 text-sm transition-all duration-200 {{ 'bg-gradient-to-r from-rose-50 via-emerald-50 to-white text-rose-700 font-semibold ring-1 ring-rose-200/70 shadow-sm' if isErrorActive else 'text-zinc-600 hover:bg-zinc-50 hover:text-rose-700' }}">
          {% if isErrorActive %}<span class="absolute inset-y-2 {{ 'right-0' if dir=='rtl' else 'left-0' }} w-1 rounded-full bg-gradient-to-b from-rose-500 to-emerald-500"></span>{% endif %}
          <span class="flex h-8 w-8 items-center justify-center rounded-lg transition-all duration-200 {{ 'bg-gradient-to-br from-rose-500 to-emerald-500 text-white shadow-md shadow-rose-500/30' if isErrorActive else 'bg-zinc-100 text-zinc-500 group-hover:bg-rose-100 group-hover:text-rose-600' }}">
            <i class="fa-solid fa-triangle-exclamation text-sm"></i>
          </span>
          <span class="flex-1 truncate">{{ $t('sidebar.errorExample') }}</span>
        </a>

        {% set isDumpActive = $e.hasKey(['root.dump']) %}
        <a href="{{ $e.routeUrl('root.dump') }}" class="wave group relative flex w-full items-center gap-3 rounded-xl px-3 py-2.5 text-sm transition-all duration-200 {{ 'bg-gradient-to-r from-teal-50 via-cyan-50 to-white text-teal-700 font-semibold ring-1 ring-teal-200/70 shadow-sm' if isDumpActive else 'text-zinc-600 hover:bg-zinc-50 hover:text-teal-700' }}">
          {% if isDumpActive %}<span class="absolute inset-y-2 {{ 'right-0' if dir=='rtl' else 'left-0' }} w-1 rounded-full bg-gradient-to-b from-teal-500 to-cyan-500"></span>{% endif %}
          <span class="flex h-8 w-8 items-center justify-center rounded-lg transition-all duration-200 {{ 'bg-gradient-to-br from-cyan-500 to-teal-500 text-white shadow-md shadow-cyan-500/30' if isDumpActive else 'bg-zinc-100 text-zinc-500 group-hover:bg-cyan-100 group-hover:text-cyan-600' }}">
            <i class="fa-solid fa-bug text-sm"></i>
          </span>
          <span class="flex-1 truncate">{{ $t('sidebar.dumpExample') }}</span>
        </a>
      </div>
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
	r"template/navbar.j2.html": r"""<nav id="navbar"
     class="fixed inset-x-0 top-0 z-50 h-16 border-b border-zinc-200 bg-white">
  <div class="flex h-full w-full items-center">

    <!-- ============ BRAND ZONE (aligned with sidebar width on lg) ============ -->
    <div class="flex h-full w-[240px] shrink-0 items-center gap-2 border-zinc-200 px-4 lg:border-e">
      <!-- Mobile-only sidebar toggle -->
      <button
        type="button"
        class="wave button-sidebar inline-flex h-10 w-10 items-center justify-center rounded-lg text-zinc-600 hover:bg-zinc-100 hover:text-zinc-900 focus:outline-none focus:ring-2 focus:ring-teal-500/40 lg:hidden"
        aria-label="{{ $t('navbar.toggleSidebar') }}"
        aria-controls="sidebar"
        aria-expanded="false"
      >
        <i class="fas fa-bars"></i>
      </button>

      <!-- Logo -->
      <a class="wave inline-flex items-center gap-2.5 rounded-lg px-1.5 py-1 hover:bg-zinc-50"
         href="{{ $e.routeUrl('root.home') }}">
        <img src="{{ $e.url('logo.svg') }}" alt="{{ $t('logo.title') }}" class="h-9 w-9 shrink-0" />
        <span class="flex items-baseline gap-1.5">
          <span class="text-lg font-extrabold tracking-tight text-zinc-900">{{ $t('logo.title') }}</span>
          <span class="rounded-md bg-zinc-100 px-1.5 py-0.5 text-[10px] font-semibold tracking-wide text-zinc-500 ring-1 ring-inset ring-zinc-200">{{ version }}</span>
        </span>
      </a>
    </div>

    <!-- ============ RIGHT ZONE ============ -->
    <div class="flex h-full flex-1 items-center justify-end gap-2 px-4 sm:px-6">

      {% if middleware %}
        <span class="hidden md:inline-flex items-center gap-1.5 rounded-md bg-teal-50 px-2 py-1 text-[11px] font-semibold text-teal-700 ring-1 ring-inset ring-teal-200">
          <i class="fa-solid fa-shield-halved text-[10px]"></i>{{ middleware }}
        </span>
      {% endif %}

      <!-- GitHub -->
      <a href="https://github.com/uproid/finch"
         class="wave inline-flex h-10 w-10 items-center justify-center rounded-lg text-zinc-600 hover:bg-zinc-100 hover:text-zinc-900 focus:outline-none focus:ring-2 focus:ring-zinc-400/40"
         aria-label="GitHub" target="_blank" rel="noopener">
        <i class="fab fa-github"></i>
      </a>

      {% if user %}
      <!-- User menu -->
      <details class="group relative">
        <summary class="list-none inline-flex h-10 cursor-pointer items-center gap-2 rounded-lg border border-zinc-200 bg-white px-2 text-sm font-semibold text-zinc-700 hover:bg-zinc-50 hover:border-zinc-300 focus:outline-none focus:ring-2 focus:ring-teal-500/40">
          <span class="flex h-7 w-7 items-center justify-center rounded-md bg-gradient-to-br from-teal-500 to-cyan-500 text-white">
            <i class="fas fa-user text-[11px]"></i>
          </span>
          <span class="hidden md:block max-w-[120px] truncate">{{ user.name }}</span>
          <i class="text-zinc-400 text-xs fas fa-chevron-down transition-transform duration-200 group-open:rotate-180"></i>
        </summary>
        <ul class="absolute end-0 mt-2 w-60 overflow-hidden rounded-xl border border-zinc-200 bg-white py-1.5 shadow-soft-lg">
          <li class="px-3 pb-2 pt-1 mb-1 border-b border-zinc-100">
            <div class="text-[10px] font-bold uppercase tracking-wider text-zinc-400">Account</div>
            <div class="mt-0.5 truncate text-sm font-semibold text-zinc-900">{{ user.name }}</div>
          </li>
          <li>
            <a class="wave flex items-center gap-3 mx-1.5 rounded-lg px-2.5 py-2 text-sm font-medium text-rose-600 hover:bg-rose-50"
               href="{{ $e.routeUrl('root.logout') }}">
              <span class="flex h-7 w-7 items-center justify-center rounded-md bg-rose-100 text-rose-600">
                <i class="fas fa-sign-out-alt text-xs"></i>
              </span>
              <span>{{ $t('auth.logout') }}</span>
            </a>
          </li>
        </ul>
      </details>
      {% endif %}

      <!-- Language switcher -->
      <details class="group relative">
        <summary class="list-none inline-flex h-10 cursor-pointer items-center gap-1.5 rounded-lg border border-zinc-200 bg-white px-2.5 text-sm font-semibold text-zinc-700 hover:bg-zinc-50 hover:border-zinc-300 focus:outline-none focus:ring-2 focus:ring-teal-500/40">
          <i class="text-teal-600 text-sm fas fa-globe text-[11px]"></i>
          <span class="hidden md:block">{{ $e.ln | upper }}</span>
          <i class="text-zinc-400 text-xs fas fa-chevron-down transition-transform duration-200 group-open:rotate-180"></i>
        </summary>
        <ul class="absolute end-0 mt-2 w-56 max-h-80 overflow-y-auto rounded-xl border border-zinc-200 bg-white py-1.5 shadow-soft-lg">
          <li class="px-3 pb-2 pt-1 mb-1 border-b border-zinc-100">
            <div class="text-[10px] font-bold uppercase tracking-wider text-zinc-400">Language</div>
          </li>
          {% for key, language in languages %}
          <li>
            <a class="wave flex items-center gap-3 mx-1.5 rounded-lg px-2.5 py-2 text-sm transition-colors {{ 'bg-teal-50 font-semibold text-teal-700' if $e.ln == key else 'text-zinc-700 hover:bg-zinc-50' }}"
               href="{{ $e.urlToLanguage(key) }}">
              <img src="{{ language.flag }}" class="h-5 w-6 rounded-sm object-cover ring-1 ring-zinc-200" alt=""/>
              <span class="flex-1">{{ language.name }}</span>
              {% if $e.ln == key %}
              <i class="text-teal-600 text-xs fas fa-check"></i>
              {% endif %}
            </a>
          </li>
          {% endfor %}
        </ul>
      </details>
    </div>
  </div>
</nav>
""",
	r"template/home.j2.html": r"""{% extends 'template/template.j2.html' %}

{% block title %}
  {{ $t('sidebar.home') }}
{% endblock %}

{% block content %}
<div class="space-y-10">

  <!-- ====== HERO ====== -->
  <section class="relative isolate overflow-hidden rounded-[2rem] border border-white/10 bg-gradient-to-br from-zinc-900 via-zinc-900 to-teal-900 p-8 shadow-[0_30px_80px_-30px_rgba(13,148,136,.6)] lg:p-14 noise">
    <!-- mesh blobs -->
    <div aria-hidden="true" class="pointer-events-none absolute -top-32 -left-20 h-80 w-80 rounded-full bg-teal-500/40 blur-3xl"></div>
    <div aria-hidden="true" class="pointer-events-none absolute -bottom-32 -right-20 h-96 w-96 rounded-full bg-emerald-500/30 blur-3xl"></div>
    <div aria-hidden="true" class="pointer-events-none absolute top-1/2 left-1/3 h-72 w-72 -translate-y-1/2 rounded-full bg-cyan-500/20 blur-3xl"></div>
    <!-- grid overlay -->
    <div aria-hidden="true" class="pointer-events-none absolute inset-0 opacity-[0.15]"
         style="background-image: linear-gradient(rgba(255,255,255,.4) 1px, transparent 1px), linear-gradient(90deg, rgba(255,255,255,.4) 1px, transparent 1px); background-size: 32px 32px; mask-image: radial-gradient(ellipse at center, black 30%, transparent 75%);"></div>
    <!-- shine -->
    <div aria-hidden="true" class="pointer-events-none absolute inset-x-0 top-0 h-px bg-gradient-to-r from-transparent via-white/70 to-transparent"></div>

    <div class="relative">
      <div dir="ltr" class="flex flex-col items-center gap-8 text-center lg:flex-row lg:text-left lg:gap-10">
        <div class="relative">
          <div class="absolute inset-0 -m-3 rounded-3xl bg-white/30 blur-xl"></div>
          <div class="relative flex h-28 w-28 items-center justify-center rounded-3xl bg-white/15 shadow-2xl ring-1 ring-white/40 backdrop-blur-md">
            <img src="{{ $e.url('logo.svg') }}" alt="{{ $t('logo.title') }}" class="h-20 w-20 object-contain drop-shadow-2xl"/>
          </div>
        </div>
        <div class="flex flex-col items-center lg:items-start gap-3">
          <span class="inline-flex items-center gap-2 rounded-full bg-white/15 px-3 py-1 text-[11px] font-semibold uppercase tracking-[0.18em] text-white/90 ring-1 ring-inset ring-white/30 backdrop-blur-md">
            <span class="relative flex h-2 w-2"><span class="absolute inset-0 animate-ping rounded-full bg-emerald-300 opacity-75"></span><span class="relative h-2 w-2 rounded-full bg-emerald-400"></span></span>
            {{ $t('Version') }} {{ version }}
          </span>
          <h1 class="text-5xl font-black tracking-tight text-white drop-shadow-[0_6px_24px_rgba(0,0,0,.25)] sm:text-6xl">{{ $t('logo') }}</h1>
          <p class="max-w-xl text-sm font-medium text-white/85 sm:text-base">
            A modern, fast, full-featured backend framework crafted in Dart.
          </p>
        </div>
      </div>
    </div>
  </section>

  {% if loginResult != true %}

  <!-- ====== FEATURES BENTO ====== -->
  <section>
    <div class="mb-6 flex flex-col gap-1.5">
      <span class="text-xs font-bold uppercase tracking-[0.18em] text-teal-600">{{ $t('features.title') }}</span>
      <h2 class="text-3xl font-extrabold tracking-tight text-zinc-900 sm:text-4xl">
        Everything you need, <span class="text-gradient">built-in</span>.
      </h2>
      <p class="max-w-2xl text-sm text-zinc-600">{{ $t('features.description') }}</p>
    </div>

    <div class="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
      <!-- Feature: WebSocket (large) -->
      <article class="group relative col-span-1 sm:col-span-2 lg:col-span-2 lg:row-span-2 overflow-hidden rounded-2xl border border-zinc-200 bg-white p-6 shadow-soft transition-all duration-300 hover:-translate-y-1 hover:shadow-[0_20px_45px_-15px_rgba(99,102,241,.35)] hover:border-teal-200">
        <div aria-hidden="true" class="pointer-events-none absolute -top-16 -right-16 h-48 w-48 rounded-full bg-gradient-to-br from-teal-300/40 to-cyan-300/40 blur-2xl transition-opacity duration-300 group-hover:opacity-100 opacity-60"></div>
        <div class="relative flex h-full flex-col">
          <div class="inline-flex h-14 w-14 items-center justify-center rounded-2xl bg-gradient-to-br from-teal-500 to-cyan-500 text-white shadow-lg shadow-teal-500/40">
            <i class="fas fa-broadcast-tower text-sm"></i>
          </div>
          <h3 class="mt-5 text-xl font-bold text-zinc-900">{{ $t('features.websocket') }}</h3>
          <p class="mt-2 text-sm leading-relaxed text-zinc-600">Real-time, bi-directional, low-latency communication out of the box.</p>
          <div class="mt-auto pt-6">
            <div class="inline-flex items-center gap-1.5 text-xs font-semibold text-teal-600">
              <span class="h-1.5 w-1.5 rounded-full bg-teal-500 animate-pulse"></span> Realtime
            </div>
          </div>
        </div>
      </article>

      <!-- Feature: MongoDB -->
      <article class="group relative overflow-hidden rounded-2xl border border-zinc-200 bg-white p-5 shadow-soft transition-all duration-300 hover:-translate-y-1 hover:shadow-[0_20px_45px_-15px_rgba(16,185,129,.35)] hover:border-emerald-200">
        <div class="inline-flex h-11 w-11 items-center justify-center rounded-xl bg-gradient-to-br from-emerald-500 to-green-500 text-white shadow-md shadow-emerald-500/40"><i class="fa-solid fa-leaf"></i></div>
        <h3 class="mt-4 text-base font-bold text-zinc-900">{{ $t('features.mongodb') }}</h3>
      </article>

      <!-- Feature: Cronjobs -->
      <article class="group relative overflow-hidden rounded-2xl border border-zinc-200 bg-white p-5 shadow-soft transition-all duration-300 hover:-translate-y-1 hover:shadow-[0_20px_45px_-15px_rgba(8,145,178,.35)] hover:border-cyan-200">
        <div class="inline-flex h-11 w-11 items-center justify-center rounded-xl bg-gradient-to-br from-cyan-500 to-sky-500 text-white shadow-md shadow-cyan-500/40">
          <i class="fas fa-clock text-sm"></i>
        </div>
        <h3 class="mt-4 text-base font-bold text-zinc-900">{{ $t('features.cronjobs') }}</h3>
      </article>

      <!-- Feature: Routing -->
      <article class="group relative overflow-hidden rounded-2xl border border-zinc-200 bg-white p-5 shadow-soft transition-all duration-300 hover:-translate-y-1 hover:shadow-[0_20px_45px_-15px_rgba(59,130,246,.35)] hover:border-blue-200">
        <div class="inline-flex h-11 w-11 items-center justify-center rounded-xl bg-gradient-to-br from-blue-500 to-sky-500 text-white shadow-md shadow-blue-500/40">
          <i class="fas fa-route text-sm"></i>
        </div>
        <h3 class="mt-4 text-base font-bold text-zinc-900">{{ $t('features.routing') }}</h3>
      </article>

      <!-- Feature: Form Validators -->
      <article class="group relative overflow-hidden rounded-2xl border border-zinc-200 bg-white p-5 shadow-soft transition-all duration-300 hover:-translate-y-1 hover:shadow-[0_20px_45px_-15px_rgba(245,158,11,.35)] hover:border-amber-200">
        <div class="inline-flex h-11 w-11 items-center justify-center rounded-xl bg-gradient-to-br from-amber-500 to-orange-500 text-white shadow-md shadow-amber-500/40">
          <i class="fas fa-check-circle text-sm"></i>
        </div>
        <h3 class="mt-4 text-base font-bold text-zinc-900">{{ $t('features.formvalidators') }}</h3>
      </article>

      <!-- Feature: HTML Tools -->
      <article class="group relative overflow-hidden rounded-2xl border border-zinc-200 bg-white p-5 shadow-soft transition-all duration-300 hover:-translate-y-1 hover:shadow-[0_20px_45px_-15px_rgba(99,102,241,.35)] hover:border-teal-200">
        <div class="inline-flex h-11 w-11 items-center justify-center rounded-xl bg-gradient-to-br from-teal-500 to-blue-500 text-white shadow-md shadow-teal-500/40">
          <i class="fas fa-file-code text-sm"></i>
        </div>
        <h3 class="mt-4 text-base font-bold text-zinc-900">{{ $t('features.htmltools') }}</h3>
      </article>

      <!-- Feature: DB Model -->
      <article class="group relative overflow-hidden rounded-2xl border border-zinc-200 bg-white p-5 shadow-soft transition-all duration-300 hover:-translate-y-1 hover:shadow-[0_20px_45px_-15px_rgba(20,184,166,.35)] hover:border-teal-200">
        <div class="inline-flex h-11 w-11 items-center justify-center rounded-xl bg-gradient-to-br from-teal-500 to-cyan-500 text-white shadow-md shadow-teal-500/40">
          <i class="fa-solid fa-database text-sm"></i>
        </div>
        <h3 class="mt-4 text-base font-bold text-zinc-900">{{ $t('features.dbmodel') }}</h3>
      </article>

      <!-- Feature: Fast API -->
      <article class="group relative overflow-hidden rounded-2xl border border-zinc-200 bg-white p-5 shadow-soft transition-all duration-300 hover:-translate-y-1 hover:shadow-[0_20px_45px_-15px_rgba(245,158,11,.35)] hover:border-amber-200">
        <div class="inline-flex h-11 w-11 items-center justify-center rounded-xl bg-gradient-to-br from-amber-500 to-orange-500 text-white shadow-md shadow-amber-500/40">
          <i class="fas fa-bolt text-sm"></i>
        </div>
        <h3 class="mt-4 text-base font-bold text-zinc-900">{{ $t('features.fastapi') }}</h3>
      </article>

      <!-- Feature: Other (wide) -->
      <article class="group relative col-span-1 sm:col-span-2 overflow-hidden rounded-2xl border border-zinc-800/70 bg-gradient-to-br from-zinc-900 to-zinc-800 p-5 text-white shadow-[0_8px_30px_-12px_rgba(15,23,42,.4)] transition-all duration-300 hover:-translate-y-1 hover:shadow-[0_20px_45px_-15px_rgba(15,23,42,.6)]">
        <div aria-hidden="true" class="pointer-events-none absolute -top-12 -right-12 h-40 w-40 rounded-full bg-gradient-to-br from-teal-500/40 to-emerald-500/40 blur-2xl"></div>
        <div class="relative">
          <div class="inline-flex h-11 w-11 items-center justify-center rounded-xl bg-white/10 text-white ring-1 ring-white/20 backdrop-blur">
            <i class="fas fa-cogs text-sm"></i>
          </div>
          <h3 class="mt-4 text-base font-bold">{{ $t('features.other') }}</h3>
          <p class="mt-1 text-xs text-zinc-300">And much more — explore the docs to discover all built-in capabilities.</p>
        </div>
      </article>
    </div>
  </section>

  <!-- ====== ACTION BUTTONS ====== -->
  <section>
    <div class="relative overflow-hidden rounded-2xl border border-zinc-200 bg-white p-6 shadow-soft sm:p-8">
      <div aria-hidden="true" class="pointer-events-none absolute -top-24 left-1/2 -translate-x-1/2 h-48 w-[120%] rounded-full bg-gradient-to-r from-teal-200/40 via-cyan-200/40 to-emerald-200/40 blur-3xl"></div>
      <div class="relative">
        <h3 class="text-lg font-bold text-zinc-900">{{ $t('project.documentation') }}</h3>
        <p class="mt-1 text-sm text-zinc-600">Get started, contribute, or explore the package.</p>
        <div class="mt-6 flex flex-wrap gap-3" role="group" aria-label="Quick links">
          <a href="https://github.com/uproid/finch" class="wave group inline-flex items-center gap-2 rounded-xl bg-zinc-900 px-5 py-2.5 text-sm font-semibold text-white shadow-lg shadow-zinc-900/20 transition-all duration-200 hover:-translate-y-0.5 hover:bg-zinc-800 hover:shadow-xl focus:outline-none focus:ring-4 focus:ring-zinc-700/30">
            <i class="fab fa-github text-sm"></i>
            <span>{{ $t('project.github') }}</span>
          </a>
          <a href="https://github.com/uproid/finch/blob/master/CONTRIBUTING.md" class="wave inline-flex items-center gap-2 rounded-xl border border-zinc-200 bg-white px-5 py-2.5 text-sm font-semibold text-zinc-700 shadow-sm transition-all duration-200 hover:-translate-y-0.5 hover:border-teal-300 hover:text-teal-700 hover:shadow-md focus:outline-none focus:ring-4 focus:ring-teal-500/20">
            <i class="fas fa-users text-sm"></i>
            <span>{{ $t('project.contributing') }}</span>
          </a>
          <a href="https://finchdart.com" class="wave inline-flex items-center gap-2 rounded-xl border border-zinc-200 bg-white px-5 py-2.5 text-sm font-semibold text-zinc-700 shadow-sm transition-all duration-200 hover:-translate-y-0.5 hover:border-teal-300 hover:text-teal-700 hover:shadow-md focus:outline-none focus:ring-4 focus:ring-teal-500/20">
            <i class="fas fa-book text-sm"></i>
            <span>{{ $t('project.documentation') }}</span>
          </a>
          <a href="https://pub.dev/packages/finch" class="wave inline-flex items-center gap-2 rounded-xl border border-zinc-200 bg-white px-5 py-2.5 text-sm font-semibold text-zinc-700 shadow-sm transition-all duration-200 hover:-translate-y-0.5 hover:border-teal-300 hover:text-teal-700 hover:shadow-md focus:outline-none focus:ring-4 focus:ring-teal-500/20">
            <i class="fas fa-box text-sm"></i>
            <span>{{ $t('project.pubdev') }}</span>
          </a>
        </div>
      </div>
    </div>
  </section>

  {% else %}

  <!-- ====== LOGIN SUCCESS ====== -->
  <section class="relative overflow-hidden rounded-2xl border border-emerald-200/70 bg-gradient-to-br from-emerald-50 via-green-50 to-teal-50 p-6 shadow-[0_8px_30px_-12px_rgba(16,185,129,.3)] backdrop-blur-md sm:p-8">
    <div aria-hidden="true" class="pointer-events-none absolute -top-20 -right-20 h-56 w-56 rounded-full bg-emerald-300/40 blur-3xl"></div>
    <div class="relative flex items-start gap-5">
      <div class="relative flex h-14 w-14 shrink-0 items-center justify-center rounded-2xl bg-gradient-to-br from-emerald-500 to-green-600 text-white shadow-xl shadow-emerald-500/40 ring-4 ring-white">
        <i class="fas fa-check text-sm"></i>
      </div>
      <div class="flex-1">
        <h3 class="text-xl font-bold text-emerald-900">{{ $t('login.success') }}</h3>
        <p class="mt-1.5 text-sm text-emerald-700">You have successfully logged in!</p>
      </div>
    </div>
  </section>

  {% endif %}
</div>
{% endblock %}
""",
	r"template/template.j2.html": r"""<!DOCTYPE html>
<html lang="{{ $e.ln }}" dir="{{ $t('dir') }}" class="h-full scroll-smooth">

<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>{% block title %}{% endblock %} | {{ $t(title) }}</title>
  <meta name="robots" content="noindex, nofollow">
  <meta name="theme-color" content="#0d9488" />
  <link rel="icon" href="/favicon.ico" type="image/x-icon" />
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Rubik:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
  <link rel="stylesheet" href="/assets/effects/wave/wave.css" />
  <link rel="stylesheet" href="/assets/generated-tailwind.css" />
  <link rel="stylesheet" href="/assets/app.css" crossorigin="anonymous" />
  <script src="https://code.jquery.com/jquery-3.7.1.min.js" integrity="sha256-/JqT3SQfawRcv/BIHPThkBvs0OEvtFFmqPF/lYI/Cxo=" crossorigin="anonymous"></script>
  <style>
    html, body {
      font-family: 'Rubik', ui-sans-serif, system-ui, -apple-system, "Segoe UI", Roboto, sans-serif;
    }
    body { font-feature-settings: "cv11","ss01","ss03"; }

    /* Subtle scrollbar */
    *::-webkit-scrollbar { width: 10px; height: 10px; }
    *::-webkit-scrollbar-track { background: transparent; }
    *::-webkit-scrollbar-thumb {
      background: #d4d4d8; /* zinc-300 */
      border-radius: 9999px;
      border: 2px solid transparent;
      background-clip: padding-box;
    }
    *::-webkit-scrollbar-thumb:hover { background: #14b8a6; background-clip: padding-box; }

    /* Reveal animation */
    @keyframes reveal-up { from { opacity: 0; transform: translateY(6px); } to { opacity: 1; transform: translateY(0); } }
    .reveal-up { animation: reveal-up .35s ease-out both; }

    /* Brand gradient text — high contrast on white */
    .text-gradient-brand {
      background: linear-gradient(90deg, #0f766e 0%, #0891b2 55%, #047857 100%);
      -webkit-background-clip: text;
      background-clip: text;
      color: transparent;
    }

    /* Soft elevation tokens */
    .shadow-soft   { box-shadow: 0 1px 2px rgba(24,24,27,.04), 0 1px 3px rgba(24,24,27,.06); }
    .shadow-soft-lg{ box-shadow: 0 4px 10px -2px rgba(24,24,27,.06), 0 10px 30px -10px rgba(24,24,27,.12); }
  </style>
  {% block stylesheets %}
  {{ assets.css() }}
  {% endblock %}
</head>

<body class="h-full min-h-screen bg-zinc-50 text-zinc-800 font-sans antialiased selection:bg-teal-200 selection:text-teal-900">

  {% block navbar %}
  {% include 'template/navbar.j2.html' %}
  {% endblock %}

  <div class="flex min-h-screen w-full">
    {% block sidebar %}
    {% include 'template/sidebar.j2.html' %}
    {% endblock %}

    <!-- Main column -->
    <div class="flex flex-1 min-w-0 flex-col lg:ms-[280px]">
      <main class="flex-1 px-4 pt-20 pb-10 sm:px-6 lg:px-10 lg:pt-24">
        <div class="mx-auto w-full max-w-7xl reveal-up">

          {% block flash %}
          {% if $l.hasFlash() %}
          <div class="mb-6 space-y-3">
          {% for flash in $l.getFlashs() %}
          <div role="alert"
               class="relative flex items-start gap-3 overflow-hidden rounded-xl border p-4 text-sm shadow-soft
               {% if flash.type == 'success' %} border-emerald-200 bg-emerald-50 text-emerald-900 {% endif %}
               {% if flash.type == 'info' %} border-sky-200 bg-sky-50 text-sky-900 {% endif %}
               {% if flash.type == 'warning' %} border-amber-200 bg-amber-50 text-amber-900 {% endif %}
               {% if flash.type == 'danger' ?? flash.type == 'error' %} border-rose-200 bg-rose-50 text-rose-900 {% endif %}
               {% if flash.type != 'success' and flash.type != 'info' and flash.type != 'warning' and flash.type != 'danger' and flash.type != 'error' %} border-zinc-200 bg-white text-zinc-900 {% endif %}">
            <span class="pointer-events-none absolute inset-y-0 start-0 w-1
              {% if flash.type == 'success' %} bg-emerald-500 {% endif %}
              {% if flash.type == 'info' %} bg-sky-500 {% endif %}
              {% if flash.type == 'warning' %} bg-amber-500 {% endif %}
              {% if flash.type == 'danger' ?? flash.type == 'error' %} bg-rose-500 {% endif %}
              {% if flash.type != 'success' and flash.type != 'info' and flash.type != 'warning' and flash.type != 'danger' and flash.type != 'error' %} bg-zinc-400 {% endif %}"></span>
            <span class="ms-2 flex h-9 w-9 shrink-0 items-center justify-center rounded-lg
              {% if flash.type == 'success' %} bg-emerald-100 text-emerald-700 {% endif %}
              {% if flash.type == 'info' %} bg-sky-100 text-sky-700 {% endif %}
              {% if flash.type == 'warning' %} bg-amber-100 text-amber-700 {% endif %}
              {% if flash.type == 'danger' ?? flash.type == 'error' %} bg-rose-100 text-rose-700 {% endif %}
              {% if flash.type != 'success' and flash.type != 'info' and flash.type != 'warning' and flash.type != 'danger' and flash.type != 'error' %} bg-zinc-100 text-zinc-600 {% endif %}">
              {% if flash.type == 'success' %}
              <i class="text-lg fa-solid fa-check"></i>
              {% elif flash.type == 'info' %}
              <i class="text-lg fa-solid fa-info"></i>
              {% elif flash.type == 'warning' %}
              <i class="text-lg fa-solid fa-exclamation-triangle"></i>
              {% else %}
              <i class="text-lg fa-solid fa-circle-exclamation"></i>
              {% endif %}
            </span>
            <span class="flex-1 pt-1.5 font-medium leading-relaxed">{{ flash.text }}</span>
          </div>
          {% endfor %}
          </div>
          {% endif %}
          {% endblock %}

          {% block content %}{% endblock %}
        </div>
      </main>

      {% block footer %}
      {% include 'template/footer.j2.html' %}
      {% endblock %}
    </div>
  </div>

  <!-- Mobile sidebar backdrop -->
  <div id="sidebar-backdrop"
       class="fixed inset-0 z-30 hidden bg-zinc-900/50 backdrop-blur-sm transition-opacity duration-200 lg:hidden"></div>

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

      // Initialize based on screen size
      setSidebarOpen(lgQuery.matches);

      toggle.addEventListener('click', function () {
        var isClosed = sidebar.dataset.state !== 'open';
        setSidebarOpen(isClosed);
      });

      if (backdrop) {
        backdrop.addEventListener('click', function () { setSidebarOpen(false); });
      }

      lgQuery.addEventListener('change', function (e) {
        if (e.matches) {
          if (backdrop) backdrop.classList.add('hidden');
          setSidebarOpen(true);
        } else {
          setSidebarOpen(false);
        }
      });
    });
  </script>

  {% block script %}{% endblock %}
</body>
</html>
""",
	r"template/paging.j2.html": r"""<div class="flex flex-col gap-3 md:flex-row md:items-center md:justify-between text-xs md:text-sm">
  <div class="hidden md:flex items-center gap-2 text-zinc-500 font-medium">
    <span class="inline-flex h-7 items-center gap-1.5 rounded-lg bg-zinc-100 px-2.5 ring-1 ring-inset ring-zinc-200/70">
      <i class="fas fa-list text-[11px]"></i>
      <span>
        <span class="font-bold text-zinc-900">{{ (($v.page-1) * $v.pageSize)+1 if $v.total > 0 else 0 }}</span>
        <span class="text-zinc-400">–</span>
        <span class="font-bold text-zinc-900">{{ $v.toEnd }}</span>
      </span>
    </span>
    <span>{{ $t('pagination.of') }}</span>
    <span class="font-bold text-zinc-900">{{ $v.total }}</span>
    <span>{{ $t('pagination.entries') }}</span>
  </div>

  {% if($v.count > 1) %}
  <nav aria-label="Pagination" class="{{ 'md:mr-auto' if $t('dir')=='rtl' else 'md:ml-auto' }}">
    <ul class="inline-flex items-center gap-1 rounded-2xl border border-zinc-200/70 bg-white p-1 shadow-soft">

      <li>
        <a aria-label="First" class="wave group {{ 'pointer-events-none opacity-40' if $v.disableFirst else '' }} inline-flex h-6 w-6 items-center justify-center rounded-xl text-zinc-500 transition-all duration-150 hover:bg-teal-50 hover:text-teal-700 focus:outline-none focus:ring-2 focus:ring-teal-500/30" href="?{{ $v.prefix }}={{ 1 }}{{ $v.other }}">
          <i class="fas fa-angle-double-{{ 'left' if $t('dir')=='ltr' else 'right' }} text-sm"></i>
        </a>
      </li>
      <li>
        <a aria-label="Previous" class="wave group {{ 'pointer-events-none opacity-40' if $v.disableFirst else '' }} inline-flex h-6 w-6 items-center justify-center rounded-xl text-zinc-500 transition-all duration-150 hover:bg-teal-50 hover:text-teal-700 focus:outline-none focus:ring-2 focus:ring-teal-500/30" href="?{{ $v.prefix }}={{ $v.page - 1 }}{{ $v.other }}">
          <i class="fas fa-angle-{{ 'left' if $t('dir')=='ltr' else 'right' }} text-sm"></i>
        </a>
      </li>

      {% for index in range($v.rangeFrom, $v.rangeTo + 1) %}
      {% if index > 0 and index < $v.count+1 %}
      <li>
        <a href="?{{ $v.prefix }}={{ index }}{{ $v.other }}" aria-current="{{ 'page' if (index==$v.page) else 'false' }}" class="wave inline-flex h-6 min-w-6 items-center justify-center rounded-xl px-2.5 text-xs font-semibold transition-all duration-200 {{ 'bg-gradient-to-br from-teal-500 via-cyan-500 to-emerald-500 text-white shadow-md shadow-teal-500/40 ring-1 ring-white/40' if (index==$v.page) else 'text-zinc-600 hover:bg-teal-50 hover:text-teal-700' }} focus:outline-none focus:ring-2 focus:ring-teal-500/30">
          {{ index }}
        </a>
      </li>
      {% endif %}
      {% endfor %}

      <li>
        <a aria-label="Next" class="wave group {{ 'pointer-events-none opacity-40' if $v.disableLast else '' }} inline-flex h-6 w-6 items-center justify-center rounded-xl text-zinc-500 transition-all duration-150 hover:bg-teal-50 hover:text-teal-700 focus:outline-none focus:ring-2 focus:ring-teal-500/30" href="?{{ $v.prefix }}={{ $v.page + 1 }}{{ $v.other }}">
          <i class="fas fa-angle-{{ 'right' if $t('dir')=='ltr' else 'left' }} text-sm"></i>
        </a>
      </li>
      <li>
        <a aria-label="Last" class="wave group {{ 'pointer-events-none opacity-40' if $v.disableLast else '' }} inline-flex h-6 w-6 items-center justify-center rounded-xl text-zinc-500 transition-all duration-150 hover:bg-teal-50 hover:text-teal-700 focus:outline-none focus:ring-2 focus:ring-teal-500/30" href="?{{ $v.prefix }}={{ $v.count }}{{ $v.other }}">
          <i class="fas fa-angle-double-{{ 'right' if $t('dir')=='ltr' else 'left' }} text-sm"></i>
        </a>
      </li>
    </ul>
  </nav>
  {% endif %}
</div>
""",
	r"errors/404.j2.html": r"""<!DOCTYPE html>
<html lang="{{ $e.ln }}" dir="{{ $t('dir') }}" class="h-full scroll-smooth">

	<head>
		<meta charset="UTF-8"/>
		<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
		<title>{{ $t('error.404') }}</title>
		<meta name="robots" content="noindex, nofollow">
		<meta name="theme-color" content="#0d9488"/>
		<link rel="icon" href="/favicon.ico" type="image/x-icon"/>
		<link href="https://fonts.googleapis.com/css2?family=Rubik:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">
		<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
		<link rel="stylesheet" href="/assets/effects/wave/wave.css"/>
		<link rel="stylesheet" href="/assets/generated-tailwind.css"/>
		<link rel="stylesheet" href="/assets/app.css" crossorigin="anonymous"/>
		<script src="https://code.jquery.com/jquery-3.7.1.min.js" integrity="sha256-/JqT3SQfawRcv/BIHPThkBvs0OEvtFFmqPF/lYI/Cxo=" crossorigin="anonymous"></script>
		<style>
			html,
			body {
				font-family: 'Rubik', ui-sans-serif, system-ui, -apple-system, "Segoe UI", Roboto, sans-serif;
			}
			body {
				font-feature-settings: "cv11", "ss01", "ss03";
			}
		</style>
	</head>

	<body class="h-full min-h-screen bg-zinc-50 text-zinc-800 font-sans antialiased selection:bg-teal-200 selection:text-teal-900">

		<div
			class="flex flex-col items-center justify-center min-h-screen px-6 text-center">

			<!-- Title -->
			<h1 class="reveal-up mt-4 text-6xl font-bold text-teal-600">
				{{ $t('error.404') }}
			</h1>

			<!-- Description -->
			<p class="reveal-up mt-6 text-lg max-w-md text-zinc-500 leading-relaxed">
				{{ $t('error.404.message') }}
			</p>

			<!-- Actions -->
			<div class="reveal-up mt-8 flex flex-col sm:flex-row items-center gap-3">
				<a href="/" class="inline-flex items-center justify-center gap-2 rounded-xl bg-teal-600 hover:bg-teal-700 active:bg-teal-800 text-white font-semibold px-6 py-3 text-sm transition-colors shadow-soft-lg focus:outline-none focus:ring-2 focus:ring-teal-400 focus:ring-offset-2">
					<i class="fa-solid fa-house text-xs"></i>
					{{ $t('sidebar.home') }}
				</a>
			</div>
		</div>
	</body>
</html>
"""
};