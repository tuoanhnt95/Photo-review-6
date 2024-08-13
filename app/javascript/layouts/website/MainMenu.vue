<template>
  <nav class="header-menu max-w-7xl px-4 sm:px-6 lg:px-8">
    <router-link
      :to="{ name: 'index' }"
      class="absolute top-6 left-8 text-xl font-semibold cursor-pointer"
    >
      ShootSelect
    </router-link>
    <ul class="flex items-center gap-4 absolute top-8 right-8">
      <li v-for="item in menuItems" :key="item.routeName">
        <router-link
          :to="{ name: item.routeName }"
          class="btn-website"
          :class="{ 'bg-violet-500 hover:bg-violet-600': item.routeName === 'signup' }"
        >
          {{ item.title }}
        </router-link>
      </li>
    </ul>
  </nav>
</template>

<script setup lang="ts">
const menuItems = [
  // { title: 'Index', routeName: 'index' },
  // { title: 'About', routeName: 'about' },
  { title: 'Log in', routeName: 'login' },
  { title: 'Sign up', routeName: 'signup' },
];
</script>

<style scoped>
@import '../../assets/css/base.css';
@import '../../assets/css/panel.scss';

/* TODO: fix variables from base.css */
.color-menu {
  background-color: rgba(42, 41, 46, 0.3);
}

.header-menu {
  display: flex;
  width: 100%;
}
</style>
