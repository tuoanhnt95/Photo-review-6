<template>
  <BaseLayout>
    <MainMenu />
    <router-view />
  </BaseLayout>
</template>

<script setup lang="ts">
import BaseLayout from '../BaseLayout.vue';
import MainMenu from './MainMenu.vue';
</script>

<style scoped>
@import '../../../javascript/assets/css/base.css';
</style>
