import { setupEntryPoint } from './setupEntryPoint';
import App from '@/layouts/panel/MainLayout.vue';
import router from '@/routers/panel';
import '@/assets/css/style.scss';

setupEntryPoint(App, router);
