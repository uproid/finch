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
				// Dart & Flutter brand colors
				primary: {
					50: '#e3f2fd',
					100: '#bbdefb',
					200: '#90caf9',
					300: '#2196F3', // darker blue
					400: '#1976D2', // more saturated blue
					500: '#01579B', // much bolder Dart blue
					600: '#013A63', // extra dark blue
					700: '#0D47A1', // deep blue
					800: '#1565C0', // strong blue
					900: '#1A237E'  // very dark blue
				},
				secondary: {
					50: '#e0f7fa',
					100: '#b2ebf2',
					200: '#80deea',
					300: '#4dd0e1',
					400: '#26c6da',
					500: '#00bcd4',
					600: '#00acc1',
					700: '#0097a7',
					800: '#00838f',
					900: '#006064'
				},
				tertiary: {
					50: '#f1f8e9',
					100: '#dcedc8',
					200: '#c5e1a5',
					300: '#aed581',
					400: '#9ccc65',
					500: '#8bc34a',
					600: '#7cb342',
					700: '#689f38',
					800: '#558b2f',
					900: '#33691e'
				},
				/* Role aliases */
				surface: '#e3f2fd',
				'surface-variant': '#bbdefb',
				background: '#e3f2fd',
				outline: '#0175C2',
				'on-primary': '#ffffff',
				'on-secondary': '#ffffff',
				'on-tertiary': '#ffffff',
				'on-error': '#ffffff',
				'on-surface': '#02569B',
				'on-surface-variant': '#13B9FD'
			}
		}
	},
	safelist: [
		'bg-primary-600', 'border-primary-600', 'text-white', 'text-on-surface', 'text-primary-700',
		'hover:bg-primary-50', 'focus:ring-primary-500/30'
	],
};
