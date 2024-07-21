<template>
  <button @click="toggleMenu">
    <svg
      width="26"
      height="26"
      viewBox="0 0 26 26"
      class="btn-menu"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
    >
      <circle cx="13" cy="13" r="12" stroke="currentColor" stroke-width="0.5" />
      <circle cx="8" cy="13" r="1.5" fill="currentColor" />
      <circle cx="13" cy="13" r="1.5" fill="currentColor" />
      <circle cx="18" cy="13" r="1.5" fill="currentColor" />
    </svg>
  </button>
</template>

<script setup lang="ts">
const $emit = defineEmits(['toggle-menu']);

function toggleMenu() {
  $emit('toggle-menu');
}
</script>
