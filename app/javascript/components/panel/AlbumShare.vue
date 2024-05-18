<template>
  <div class="relative px-6 pt-16 pb-8 bg-white dark:bg-slate-800 border rounded">
    <div class="flex place-content-between mb-4">
      <label for="invitee" class="text-lg">Invitee</label>
      <div class="tag-input ml-2.5">
        <!-- pattern="^([\w+-.%]+@[\w-.]+\.[A-Za-z]{2,4},*[\W]*)+$" -->
        <input
          v-model="newInvitee.email"
          type="email"
          class="w-full py-1 px-2 text-lg text-black rounded"
          @keydown.enter="addInvitee"
          @keydown.prevent.tab="addInvitee"
          @keydown.delete="newInvitee.email.length || removeInvitee(0)"
        />
        <div class="tags">
          <div
            v-for="(invitee, i) in inviteesObject"
            :key="i"
            class="tag"
            :class="{ 'tag-existing': invitee.existing }"
          >
            {{ invitee.email }}
            <font-awesome-icon
              v-if="!invitee.existing"
              icon="fa-solid fa-x"
              class="ml-2 cursor-pointer"
              @click="removeInvitee(i)"
            />
          </div>
        </div>
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
import { computed, ref } from 'vue';
import type { AxiosResponse } from 'axios';
import { addInviteesApi } from '@/apis/panel.api';

const $emit = defineEmits(['close-share-album', 'edited-album']);

const props = defineProps({
  albumId: {
    type: Number,
    required: true,
  },
  albumInvitees: {
    type: Array<string>,
    required: true,
  },
});

interface Invitee {
  email: string;
  existing: boolean;
}

const myInvitees = ref<Array<Invitee>>([]);
const newInvitee = ref<Invitee>({ email: '', existing: false });
const existingInviteesObject = props.albumInvitees.map((invitee) => {
  return { email: invitee, existing: true };
});
const inviteesObject = computed(() => {
  return myInvitees.value.concat(existingInviteesObject);
});
const invitees = computed<Array<string>>(() =>
  inviteesObject.value.map((invitee) => invitee.email),
);

const addInvitee = () => {
  if (newInvitee.value.email !== '') {
    myInvitees.value.unshift(newInvitee.value);
    newInvitee.value = { email: '', existing: false };
  }
};

const removeInvitee = (index: number) => {
  if (inviteesObject.value[index].existing) {
    return;
  }
  myInvitees.value.splice(index, 1);
};

const saveEditAlbum = async () => {
  addInviteesApi(props.albumId, {
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
  $emit('close-share-album');
};
</script>

<style scoped>
.tag-input {
  width: 100%;
}
.tags {
  display: flex;
  gap: 6px;
  flex-wrap: wrap;
  width: 100%;
  overflow-x: auto;
}
.tag {
  width: fit-content;
  margin-top: 8px;
  padding: 0 10px 2px 8px;
  border-radius: 4px;
  background: var(--color-primary);
  color: white;
  white-space: nowrap;
  transition: 0.1s ease background;
}

.tag-existing {
  background: var(--color-secondary);
}
</style>
