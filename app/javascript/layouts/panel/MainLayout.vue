<template>
  <BaseLayout>
    <div class="wrapper">
      <!-- <div class="section"> -->
      <div class="navbar">
        <MainMenu />
      </div>
      <div class="container">
        <router-view />
      </div>
    </div>
  </BaseLayout>
</template>

<script setup lang="ts">
import BaseLayout from '../BaseLayout.vue';
import MainMenu from './MainMenu.vue';
</script>

// if mobile: only container, nav bar at the bottom // if desktop: top nav bar, container
