// const Index = () => import('@/pages/panel/IndexPage.vue');
const Albums = () => import('@/pages/panel/AlbumsPage.vue');
const Album = () => import('@/pages/panel/AlbumPage.vue');

const routes = [
  {
    path: '/',
    name: 'Albums',
    components: {
      default: Albums,
    },
  },
  {
    path: '/albums/:id',
    name: 'Album',
    components: {
      default: Album,
    },
  },
];

export default routes;
