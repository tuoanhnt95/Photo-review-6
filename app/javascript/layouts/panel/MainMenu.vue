<template>
  <ul class="navbar-nav">
    <li class="nav-item" @click="goToHome">Home</li>
    <li class="nav-item">Settings</li>
    <li class="nav-item" @click="logout">Logout</li>
  </ul>
</template>

<script setup lang="ts">
import { useAuthStore } from '@/stores/auth.store';
const authStore = useAuthStore();

const logout = () => {
  authStore.logout();
};

const goToHome = () => {
  window.location.href = '/panel';
};
</script>
