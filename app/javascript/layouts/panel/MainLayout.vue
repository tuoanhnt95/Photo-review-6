<template>
  <BaseLayout>
    <div class="wrapper">
      <div class="navbar">
        <MainMenu />
      </div>
      <div class="container-panel">
        <router-view />
      </div>
    </div>
  </BaseLayout>
</template>

<script setup lang="ts">
import BaseLayout from '../BaseLayout.vue';
import MainMenu from './MainMenu.vue';
</script>
