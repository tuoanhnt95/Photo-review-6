<template>
  <div class="container-navigation border-gray-200 dark:bg-gray-700 dark:border-gray-600">
    <div class="bar-navigation">
      <router-link
        to="/"
        data-tooltip-target="tooltip-home"
        type="button"
        class="button-navigation"
      >
        <font-awesome-icon icon="fa-solid fa-house" class="icon-navigation" aria-hidden="true" />
      </router-link>

      <router-link
        to="/albums"
        data-tooltip-target="tooltip-noti"
        type="button"
        class="button-navigation"
      >
        <font-awesome-icon icon="fa-solid fa-bell" class="icon-navigation" aria-hidden="true" />
      </router-link>

      <router-link
        to="/"
        data-tooltip-target="tooltip-setting"
        type="button"
        class="button-navigation"
      >
        <font-awesome-icon icon="fa-solid fa-gear" class="icon-navigation" aria-hidden="true" />
      </router-link>

      <router-link
        to="/"
        data-tooltip-target="tooltip-user"
        type="button"
        class="button-navigation"
      >
        <font-awesome-icon icon="fa-solid fa-user" class="icon-navigation" aria-hidden="true" />
      </router-link>
    </div>
  </div>
</template>

<script setup lang="ts">
// import { ref } from 'vue'
import { RouterLink } from 'vue-router';
</script>

<style scoped>
/* https://flowbite.com/docs/components/bottom-navigation/ */
@import '../assets/main.css';

.container-navigation {
  width: 100%;
  height: var(--height-nav-bar);
  background-color: white;
  border-top: 1px solid #e5e7eb;
}

.bar-navigation {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  grid-template-rows: 1fr;
  grid-gap: 0px;
  grid-auto-flow: row;
  grid-auto-columns: minmax(0px, 1fr);
  grid-auto-rows: minmax(0px, 1fr);
  height: 100%;
  width: 100%;
  max-width: 64rem;
  margin: 0 auto;
  padding: 0 1rem;
  font-size: 0.75rem;
}

.button-navigation {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding-left: 1.25rem; /* 20px */
  padding-right: 1.25rem; /* 20px */
  border: none;
  background-color: transparent;
  cursor: pointer;
  transition: all 0.2s ease-in-out;
}

.button-navigation:hover {
  background-color: #f9fafb;
}

.icon-navigation {
  margin-bottom: 0.25rem;
  font-size: 1.25rem; /* 20px */
  color: #4b5563;
}

.icon-navigation:hover {
  color: var(--color-primary);
}

@media (prefers-color-scheme: dark) {
  .button-navigation:hover {
    background-color: #374151;
  }

  .icon-navigation {
    color: #d1d5db;
  }

  .icon-navigation:hover {
    color: var(--color-primary-dark);
  }
}
</style>
