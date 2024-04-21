// const Index = () => import('@/pages/panel/IndexPage.vue');
const Albums = () => import('@/pages/panel/AlbumsPage.vue');

const routes = [
  {
    path: '/',
    name: 'albums',
    components: {
      default: Albums,
    },
  },
];

export default routes;
