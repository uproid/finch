/**
 * Tailwind configuration for the example finch.
 * Run the build (see package.json scripts) to generate assets/generated-tailwind.css
 */
module.exports = {
	content: [
		'./lib/**/*.j2.html',              // all Jinja templates
		'./lib/widgets/template/**/*.j2.html', // explicit template dir
		'./lib/widgets/example/**/*.j2.html',  // example widgets
		'./lib/**/*.dart',
		'./lib/**/*.html',
		'./lib/**/*.js',
		'./lib/**/*.ts',
		'./lib/**/*.vue',
		'./lib/**/*.svelte',
		'./lib/**/*.jsx',
		'./lib/**/*.tsx'
	],
	theme: {
		ripple: theme => ({
			colors: theme('colors'),
			modifierTransition: 'background 0.2s',
			activeTransition: 'background 0.1s'
		}),
		extend: {
			colors: {
				// Primary brand = Tailwind teal
				primary: {
					50:  '#f0fdfa',
					100: '#ccfbf1',
					200: '#99f6e4',
					300: '#5eead4',
					400: '#2dd4bf',
					500: '#14b8a6',
					600: '#0d9488',
					700: '#0f766e',
					800: '#115e59',
					900: '#134e4a'
				},
				// Secondary = Tailwind cyan
				secondary: {
					50:  '#ecfeff',
					100: '#cffafe',
					200: '#a5f3fc',
					300: '#67e8f9',
					400: '#22d3ee',
					500: '#06b6d4',
					600: '#0891b2',
					700: '#0e7490',
					800: '#155e75',
					900: '#164e63'
				},
				// Tertiary = Tailwind emerald
				tertiary: {
					50:  '#ecfdf5',
					100: '#d1fae5',
					200: '#a7f3d0',
					300: '#6ee7b7',
					400: '#34d399',
					500: '#10b981',
					600: '#059669',
					700: '#047857',
					800: '#065f46',
					900: '#064e3b'
				},
				/* Role aliases */
				surface:             '#ffffff',
				'surface-variant':   '#f4f4f5', // zinc-100
				background:          '#fafafa', // zinc-50
				outline:             '#0d9488', // teal-600
				'on-primary':        '#ffffff',
				'on-secondary':      '#ffffff',
				'on-tertiary':       '#ffffff',
				'on-error':          '#ffffff',
				'on-surface':        '#18181b', // zinc-900
				'on-surface-variant':'#52525b'  // zinc-600
			}
		}
	},
	safelist: [
		'bg-primary-50','bg-primary-100','bg-primary-500','bg-primary-600','bg-primary-700',
		'text-primary-600','text-primary-700','text-primary-800',
		'border-primary-200','border-primary-300','border-primary-500','border-primary-600',
		'ring-primary-200','ring-primary-300','ring-primary-500',
		'hover:bg-primary-50','hover:bg-primary-700','hover:text-primary-700',
		'focus:ring-primary-500','focus:ring-primary-500/30',
		'text-white','text-on-surface'
	],
};
