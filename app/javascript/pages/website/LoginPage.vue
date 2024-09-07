<template>
  <div
    v-if="!loggedIn"
    class="min-h-screen w-screen bg-gray-900 flex flex-col justify-center items-center px-4"
  >
    <div class="max-w-md w-full bg-gray-800 rounded-lg shadow-lg p-8">
      <div class="text-center mb-8">
        <h2 class="text-2xl font-semibold text-white">Log in</h2>
      </div>

      <form @submit.prevent="submit">
        <div class="mb-4">
          <input
            v-model="user.email"
            type="email"
            placeholder="Email"
            class="w-full px-3 py-2 bg-gray-700 text-white border border-gray-600 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 placeholder-gray-400"
            required
          />
        </div>

        <div class="mb-6">
          <input
            v-model="user.password"
            type="password"
            placeholder="Password"
            class="w-full px-3 py-2 bg-gray-700 text-white border border-gray-600 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 placeholder-gray-400"
            required
          />
        </div>

        <button
          type="submit"
          class="w-full bg-violet-500 text-white py-2 rounded-md hover:bg-violet-600 transition duration-300"
        >
          Log In
        </button>
      </form>

      <div class="mt-6 text-center">
        <!-- <a href="#" class="text-violet-400 hover:underline">Forgot email or password?</a> -->
      </div>

      <div class="mt-8 border-t border-gray-700 pt-6 text-center">
        <p class="text-gray-400">Don't have an account?</p>
        <span class="text-violet-400 hover:underline">
          <router-link :to="{ name: 'signup' }">Create yours now.</router-link>
        </span>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { reactive, onMounted, computed } from 'vue';
import { useAuthStore } from '@/stores/auth.store';
import { IUserLogin } from '@/types/general';
import { showToast } from '@/utils/showToast';

const authStore = useAuthStore();

const user = reactive<IUserLogin>({
  email: '',
  password: '',
});

const redirectToPanel = () => {
  window.location.href = '/panel/';
};

const loggedIn = computed(() => authStore.isAuthenticated);

onMounted(() => {
  if (loggedIn.value) {
    redirectToPanel();
  }
});

const submit = () => {
  authStore
    .login(user)
    .then(() => {
      redirectToPanel();
    })
    .catch((error) => {
      showToast(error, 'error');
    });
};

console.log('Login Page', import.meta.env);
</script>
