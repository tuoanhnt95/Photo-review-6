<template>
  <BaseLayout>
    <div class="wrapper">
      <div class="container-panel">
        <router-view />
      </div>
    </div>
  </BaseLayout>
</template>

<script setup lang="ts">
import BaseLayout from '../BaseLayout.vue';
</script>
