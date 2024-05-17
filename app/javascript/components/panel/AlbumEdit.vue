<template>
  <div class="relative px-6 pt-16 pb-8 bg-white dark:bg-slate-800 border rounded">
    <div class="flex place-content-between w-full mb-6">
      <input
        v-model="name"
        type="text"
        required
        placeholder="Album name"
        class="w-full px-2 py-1 text-xl text-black rounded"
      />
    </div>

    <div class="flex place-content-between mb-4">
      <label for="expiry-date" class="self-center text-lg">Expiry date</label>
      <input v-model="expiryDate" type="date" class="pl-1 rounded text-lg text-black" />
    </div>

    <div class="flex place-content-between mb-4">
      <label for="invitee" class="text-lg">Invitee</label>
      <div class="tag-input ml-2.5">
        <!-- pattern="^([\w+-.%]+@[\w-.]+\.[A-Za-z]{2,4},*[\W]*)+$" -->
        <input
          v-model="newInvitee"
          type="email"
          class="w-full py-1 px-2 text-lg text-black rounded"
          @keydown.enter="addInvitee"
          @keydown.prevent.tab="addInvitee"
          @keydown.delete="newInvitee.length || removeInvitee(0)"
        />
        <ul class="tags">
          <li v-for="invitee in invitees" :key="invitee" class="tag">
            {{ invitee }}
            <font-awesome-icon
              icon="fa-solid fa-x"
              class="ml-2 cursor-pointer"
              @click="removeInvitee(invitees.indexOf(invitee))"
            />
          </li>
        </ul>
      </div>
    </div>

    <div class="w-full">
      <button
        class="w-full mt-4 py-3 bg-violet-600 text-slate-200 rounded text-xl font-bold cursor-pointer"
        @click="saveEditAlbum"
      >
        Save
      </button>
    </div>

    <font-awesome-icon
      icon="fa-solid fa-x"
      class="absolute top-4 right-4 text-slate-400"
      @click="closeEditAlbum()"
    />
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import type { AxiosResponse } from 'axios';
import { updateAlbumApi } from '@/apis/panel.api';

const $emit = defineEmits(['close-edit-album', 'edited-album']);

const props = defineProps({
  albumId: {
    type: Number,
    required: true,
  },
  albumName: {
    type: String,
    required: true,
  },
  albumExpiryDate: {
    type: Date,
    required: true,
  },
  albumInvitees: {
    type: Array<string>,
    required: true,
  },
});

const name = ref(props.albumName);
const expiryDate = ref(props.albumExpiryDate);
const invitees = ref([...props.albumInvitees]);
const newInvitee = ref('');

const addInvitee = () => {
  if (newInvitee.value) {
    invitees.value.unshift(newInvitee.value);
    newInvitee.value = '';
  }
};

const removeInvitee = (index: number) => {
  invitees.value.splice(index, 1);
};

const saveEditAlbum = async () => {
  updateAlbumApi(props.albumId, {
    name: name.value,
    expiry_date: expiryDate.value,
    invitees: invitees.value,
  })
    .then((response: AxiosResponse) => {
      $emit('edited-album', response.data);
    })
    .catch((error) => {
      console.log(error);
    });
};

const closeEditAlbum = () => {
  $emit('close-edit-album');
};
</script>

<style scoped>
.tag-input {
  width: 100%;
}
ul.tags {
  list-style: none;
  width: 100%;
  overflow-x: auto;
}
.tag {
  width: fit-content;
  margin-top: 8px;
  padding: 0 8px 2px 4px;
  border-radius: 4px;
  background: var(--color-primary);
  color: white;
  white-space: nowrap;
  transition: 0.1s ease background;
}
</style>
