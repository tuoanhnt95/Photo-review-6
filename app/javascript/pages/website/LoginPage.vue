<!-- <template>
  <div v-if="!loggedIn" class="form">
    <div class="form-box pt-25">
      <div class="form-bg py-30 px-50">
        <span class="header pb-25">Sign in to your account</span>

        <span v-if="showMessage" class="header pb-25"> You've clicked on Submit button </span>

        <form @submit.prevent="submit">
          <div class="field pb-25">
            <label for="email">Email</label>
            <input v-model="user.email" type="email" />
          </div>

          <div class="field pb-25">
            <label for="password">Password</label>
            <input v-model="user.password" type="password" />
          </div>

          <div class="field pb-25">
            <input class="submit" type="submit" name="submit" value="Continue" />
          </div>
        </form>

        <div class="footer pt-25 text-center">
          <span>
            Don't have an account? <router-link :to="{ name: 'signup' }">Sign up</router-link>
          </span>
        </div>
      </div>
    </div>
  </div>
  <div class="text-center">Redirecting to panel</div>
</template> -->

<template>
  <div class="min-h-screen w-screen bg-gray-900 flex flex-col justify-center items-center px-4">
    <div class="max-w-md w-full bg-gray-800 rounded-lg shadow-lg p-8">
      <div class="text-center mb-8">
        <img src="path/to/apple-logo.svg" alt="Shoot Select Logo" class="h-8 mx-auto mb-4 invert" />
        <h2 class="text-2xl font-semibold text-white">Sign in</h2>
      </div>

      <form @submit.prevent="handleSubmit">
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
          Sign In
        </button>
      </form>

      <div class="mt-6 text-center">
        <a href="#" class="text-violet-400 hover:underline">Forgot email or password?</a>
      </div>

      <div class="mt-8 border-t border-gray-700 pt-6 text-center">
        <p class="text-gray-400">Don't have an account?</p>
        <a href="#" class="text-violet-400 hover:underline">Create yours now.</a>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { reactive, ref, onMounted, computed } from 'vue';
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

const showMessage = ref(false);

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
</script>
