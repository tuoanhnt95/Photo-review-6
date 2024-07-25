<template>
  <BaseLayout>
    <div>
      <div class="header-bar">
        <MainMenu />
      </div>

      <div>
        <router-view />
      </div>
    </div>
  </BaseLayout>
</template>

<script setup lang="ts">
import BaseLayout from '../BaseLayout.vue';
import MainMenu from './MainMenu.vue';
</script>
