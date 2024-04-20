/** @type {import('tailwindcss').Config} */
// const defaultTheme = require('tailwindcss/defaultTheme');
import { screens as _screens } from 'tailwindcss/defaultTheme';

export const content = [
  './app/javascript/**/*.{vue,js,ts,jsx,tsx}',
  './app/javascript/**/**/*.{vue,js,ts,jsx,tsx}',
];
export const theme = {
  extend: {},
  screens: {
    xs: '475px',
    ..._screens,
  },
};
export const plugins = [];
