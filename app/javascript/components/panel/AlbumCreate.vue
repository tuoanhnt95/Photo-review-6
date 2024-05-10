<template>
  <div class="relative px-6 pt-16 pb-8 bg-white dark:bg-slate-800 border rounded">
    <div class="flex place-content-between w-full mb-6">
      <input
        v-model="albumName"
        type="text"
        placeholder="Album name"
        class="w-full px-2 py-1 text-xl text-black rounded"
      />
    </div>

    <div class="flex place-content-between mb-4">
      <label for="expiry-date" class="self-center text-lg">Expiry date</label>
      <input v-model="albumExpiryDate" type="date" class="pl-1 rounded text-lg text-black" />
    </div>

    <div class="flex place-content-between w-full mb-4">
      <label for="invitee" class="self-center text-lg">Invitee</label>
      <input
        v-model="invitees"
        type="text"
        required
        placeholder=" reviewer@gmail.com,..."
        class="w-3/4 pl-1 rounded text-lg text-black"
      />
    </div>

    <div class="w-full">
      <button
        class="w-full mt-4 py-3 bg-violet-600 text-slate-200 rounded text-xl font-bold cursor-pointer"
        @click="createAlbum"
      >
        Save
      </button>
    </div>

    <font-awesome-icon
      icon="fa-solid fa-x"
      class="absolute top-4 right-4 text-slate-400"
      @click="closeCreateAlbum()"
    />
  </div>
</template>

<script setup lang="ts">
// import { ref, type PropType } from 'vue';
import { ref } from 'vue';
import type { AxiosResponse } from 'axios';
import { createAlbumApi } from '@/apis/panel.api';

// interface Album {
//   id: number;
//   name: string;
//   expiry_date: Date;
//   cover: string;
//   last_upload_batch: number;
// }

// TODO: add upload batch to all Album object.
// need upload batch to manage upload files

// const props = defineProps({
//   albums: {
//     type: Array as PropType<Album[]>,
//     required: true,
//   },
// });

const $emit = defineEmits(['close-create-album', 'added-new-album']);

const albumName = ref('');
const albumExpiryDate = ref(new Date());
const invitees = ref('');
// invitees: invitees.value,
const createAlbum = async () => {
  createAlbumApi({
    name: albumName.value,
    expiry_date: albumExpiryDate.value,
    invitees: invitees.value,
  })
    .then((response: AxiosResponse) => {
      closeCreateAlbum();
      $emit('added-new-album', response.data);
    })
    .catch((error) => {
      console.log(error);
    });
};

const closeCreateAlbum = () => {
  albumName.value = '';
  albumExpiryDate.value = new Date();
  invitees.value = '';
  $emit('close-create-album');
};
</script>

<style scoped></style>
