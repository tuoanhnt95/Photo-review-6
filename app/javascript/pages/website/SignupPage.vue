<template>
  <div class="min-h-screen w-screen bg-gray-900 flex flex-col justify-center items-center px-4">
    <h2 class="text-center mb-6 text-3xl font-extrabold text-violet-600">
      Create ShootSelect Account
    </h2>
    <div class="max-w-md w-full p-8 pt-10 bg-gray-800 rounded-lg shadow-lg">
      <form class="space-y-6" @submit.prevent="submit">
        <div>
          <input
            id="email"
            v-model="user.email"
            name="email"
            type="email"
            placeholder="Email"
            required
            class="w-full px-3 py-2 bg-gray-700 text-white border border-gray-600 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 placeholder-gray-400"
          />
        </div>

        <div class="mt-1">
          <input
            id="password"
            v-model="user.password"
            name="password"
            type="password"
            placeholder="Password"
            required
            class="w-full px-3 py-2 bg-gray-700 text-white border border-gray-600 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 placeholder-gray-400"
          />
        </div>

        <div>
          <input
            id="confirm-password"
            v-model="user.password_confirmation"
            name="confirm-password"
            type="password"
            placeholder="Confirm password"
            required
            class="w-full px-3 py-2 bg-gray-700 text-white border border-gray-600 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 placeholder-gray-400"
          />
        </div>

        <div>
          <button
            type="submit"
            class="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-violet-600 hover:bg-violet-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-violet-500 dark:bg-violet-500 dark:hover:bg-violet-600"
          >
            Create ShootSelect account
          </button>
        </div>
      </form>
      <div class="footer flex justify-center">
        <div class="flex gap-1 mt-8 border-t border-gray-700 pt-6 text-center">
          <p class="text-gray-400">Already have an account?</p>
          <span class="text-violet-400 hover:underline">
            <router-link :to="{ name: 'login' }">Log in.</router-link>
          </span>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { reactive } from 'vue';
import { useRouter } from 'vue-router';
import { useAuthStore } from '@/stores/auth.store';
import { IRegisterUser } from '@/types/general';
import { showToast } from '@/utils/showToast';

const router = useRouter();

const authStore = useAuthStore();

const user = reactive<IRegisterUser>({
  email: '',
  password: '',
  password_confirmation: '',
});

const submit = () => {
  authStore
    .register(user)
    .then(() => {
      router.push({ name: 'login' });
    })
    .catch((error) => {
      showToast(error, 'error');
    });
};
</script>
