<template>
  <nav class="fixed w-full bg-menu color-menu">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
      <div class="flex items-center justify-between h-16">
        <div class="flex items-center">
          <div class="flex-shrink-0">
            <!-- <img class="h-8 w-auto" src="/path-to-your-logo.svg" alt="Shoot Select" /> -->
          </div>
          <router-link :to="{ name: 'index' }" class="ml-4 text-xl font-semibold cursor-pointer">
            ShootSelect
          </router-link>
        </div>
        <ul class="flex items-center gap-4">
          <li v-for="item in menuItems" :key="item.routeName">
            <router-link
              :to="{ name: item.routeName }"
              class="px-3 py-2 rounded-md text-sm font-medium hover:bg-gray-800 transition duration-150 ease-in-out"
              :class="{ 'bg-violet-500 hover:bg-violet-600': item.routeName === 'signup' }"
            >
              {{ item.title }}
            </router-link>
          </li>
        </ul>
      </div>
    </div>
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
</style>
