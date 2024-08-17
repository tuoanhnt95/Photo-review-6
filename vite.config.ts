import { defineConfig } from 'vite';
import RubyPlugin from 'vite-plugin-ruby';
import vue from '@vitejs/plugin-vue';

export default defineConfig({
  resolve: {
    extensions: ['.mjs', '.js', '.ts', '.jsx', '.tsx', '.json', '.vue'],
  },
  plugins: [
    vue({
      template: {
        transformAssetUrls: {
          includeAbsolute: false,
        },
      },
    })
    , RubyPlugin()
  ],
  css: {
    preprocessorOptions: {
      scss: {
        sourceMap: false,
        additionalData(source: any, fp: any) {
          if (fp.endsWith('variables.scss')) return source;

          return `@import "@/assets/css/_variables.scss"; ${source}`;
        },
      },
    },
  },
  server: {
    hmr: {
      host: 'localhost',
      protocol: 'ws',
      clientPort: 3036,
    },
  },
});
