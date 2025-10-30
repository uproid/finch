/**
 * Tailwind configuration for the example finch.
 * Run the build (see package.json scripts) to generate assets/generated-tailwind.css
 */
module.exports = {
	content: [
		'../../lib/**/*.j2.html',              // all Jinja templates
		'../../lib/widgets/template/**/*.j2.html', // explicit template dir
		'../../lib/widgets/example/**/*.j2.html',  // example widgets
		'../../lib/**/*.dart',
		'../../lib/**/*.html',
		'../../lib/**/*.js',
		'../../lib/**/*.ts',
		'../../lib/**/*.vue',
		'../../lib/**/*.svelte',
		'../../lib/**/*.jsx',
		'../../lib/**/*.tsx'
	],
	theme: {
		ripple: theme => ({
			colors: theme('colors'),
			modifierTransition: 'background 0.2s',
			activeTransition: 'background 0.1s'
		}),
		extend: {
			colors: {
				/* Material Design 3 baseline (seed primary = #6750A4) */
				primary: {
					50: '#f5edff',
					100: '#eaddff',
					200: '#d0bcff',
					300: '#b69df8',
					400: '#9a82db',
					500: '#7f67be',
					600: '#6750a4',
					700: '#574193',
					800: '#463070',
					900: '#311b4b',
					950: '#1d102b'
				},
				secondary: {
					50: '#f5f2fa',
					100: '#e7e0ec',
					200: '#cbc4cf',
					300: '#b0a9b4',
					400: '#958f99',
					500: '#7a757f',
					600: '#625b71',
					700: '#52465d',
					800: '#413349',
					900: '#322338',
					950: '#1d1322'
				},
				tertiary: {
					50: '#f4faf3',
					100: '#dcefe0',
					200: '#c2e3ca',
					300: '#a8d7b3',
					400: '#8ecc9d',
					500: '#73b184',
					600: '#5a986b',
					700: '#427f53',
					800: '#29673c',
					900: '#0f4f25',
					950: '#063614'
				},
				error: {
					50: '#fef1f1',
					100: '#fcd4d5',
					200: '#f9b8ba',
					300: '#f69b9f',
					400: '#f37f84',
					500: '#ea5459',
					600: '#d03439',
					700: '#ab1c22',
					800: '#86080f',
					900: '#620005',
					950: '#410002'
				},
				neutral: {
					50: '#f9f9fb',
					100: '#f1f0f4',
					200: '#e4e2e8',
					300: '#d6d5dc',
					400: '#c9c8d1',
					500: '#b0afb8',
					600: '#96959f',
					700: '#7d7c86',
					800: '#64636c',
					900: '#4b4a53',
					950: '#2f2e37'
				},
				'neutral-variant': {
					50: '#f6f5f9',
					100: '#ebeaf0',
					200: '#dcdbe3',
					300: '#cdccd6',
					400: '#bebdc9',
					500: '#a5a4af',
					600: '#8b8a96',
					700: '#72717c',
					800: '#595862',
					900: '#41404a',
					950: '#27272f'
				},
				/* Role aliases */
				surface: '#fffbfe',
				'surface-variant': '#e7e0ec',
				background: '#fffbfe',
				outline: '#79747e',
				'on-primary': '#ffffff',
				'on-secondary': '#ffffff',
				'on-tertiary': '#ffffff',
				'on-error': '#ffffff',
				'on-surface': '#1c1b1f',
				'on-surface-variant': '#49454f'
			}
		}
	},
	safelist: [
		'bg-primary-600', 'border-primary-600', 'text-white', 'text-on-surface', 'text-primary-700',
		'hover:bg-primary-50', 'focus:ring-primary-500/30'
	],
};
