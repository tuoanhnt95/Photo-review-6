<template>
  <div class="relative px-6 pt-16 pb-8 bg-white dark:bg-slate-800 border rounded">
    <div class="flex place-content-between w-full mb-6">
      <input
        type="text"
        v-model="albumName"
        placeholder="Album name"
        class="w-full px-2 py-1 text-xl text-black rounded"
      />
    </div>

    <div class="flex place-content-between mb-4">
      <label for="expiry-date" class="self-center text-lg">Expiry date</label>
      <input type="date" v-model="albumExpiryDate" class="pl-1 rounded text-lg text-black" />
    </div>

    <div class="flex place-content-between w-full mb-4">
      <label for="invitee" class="self-center text-lg">Invitee</label>
      <input
        type="text"
        placeholder=" reviewer@gmail.com,..."
        v-model="invitees"
        class="w-3/4 pl-1 rounded text-lg text-black"
      />
    </div>

    <div class="w-full">
      <button
        @click="createAlbum"
        class="w-full mt-4 py-3 bg-violet-600 text-slate-200 rounded text-xl font-bold cursor-pointer"
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
import { ref, type PropType } from 'vue';
import axios from 'axios';
interface Album {
  id: number;
  name: string;
  expiry_date: Date;
  cover: string;
  last_upload_batch: number;
}

// TODO: add upload batch to all Album object.
// need upload batch to manage upload files

const props = defineProps({
  albums: {
    type: Array as PropType<Album[]>,
    required: true,
  },
});

const $emit = defineEmits(['closeCreateAlbum', 'addedNewAlbum']);

const albumName = ref('');
const albumExpiryDate = ref('');
const invitees = ref([]);

const createAlbum = async () => {
  await axios
    .post('http://localhost:3000/albums', {
      name: albumName.value,
      expiry_date: albumExpiryDate.value,
      invitees: invitees.value,
    })
    .then((response) => {
      closeCreateAlbum();
      $emit('addedNewAlbum', response.data);
    })
    .catch((error) => {
      console.log(error);
    });
};

const closeCreateAlbum = () => {
  albumName.value = '';
  albumExpiryDate.value = '';
  invitees.value = [];
  $emit('closeCreateAlbum');
};
</script>

<style scoped></style>
