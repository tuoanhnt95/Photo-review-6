<template>
  <div class="relative px-6 pt-16 pb-8 bg-white dark:bg-slate-800 border rounded">
    <div v-if="props.action !== 'share'" class="flex place-content-between w-full mb-6">
      <input
        v-model="name"
        type="text"
        required
        placeholder="Album name"
        class="w-full px-2 py-1 text-xl text-black rounded"
      />
    </div>

    <div v-if="props.action !== 'share'" class="flex place-content-between mb-4">
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
        <div class="tags">
          <div
            v-for="(invitee, i) in invitees"
            :key="i"
            class="tag"
            :class="{ 'tag-existing': !editableInvitees.includes(invitee) }"
          >
            {{ invitee }}
            <font-awesome-icon
              v-if="editableInvitees.includes(invitee)"
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
        @click="saveAlbum"
      >
        {{ props.action === 'create' ? 'Create' : 'Save' }}
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
import { createAlbumApi, updateAlbumApi, addInviteesApi } from '@/apis/panel.api';

const $emit = defineEmits(['close-edit-album', 'added-new-album', 'edited-album']);

const props = defineProps({
  action: {
    type: String,
    required: true,
  },
  albumId: {
    type: Number,
    default: -1,
  },
  albumName: {
    type: String,
    default: '',
  },
  albumExpiryDate: {
    type: Date,
    default: new Date(),
  },
  albumInvitees: {
    type: Array<string>,
    default: [],
  },
});

const name = ref(props.albumName);
const expiryDate = ref(props.albumExpiryDate);

const myInvitees = ref<Array<string>>([]);
const newInvitee = ref('');
const invitees = ref([...props.albumInvitees]);
const editableInvitees = computed(() => {
  if (props.action !== 'share') {
    return invitees.value;
  }
  return myInvitees.value;
});

function addInvitee() {
  if (newInvitee.value !== '') {
    myInvitees.value.unshift(newInvitee.value);
    invitees.value.unshift(newInvitee.value);
    newInvitee.value = '';
  }
}

const removeInvitee = (index: number) => {
  if (props.action !== 'share' || myInvitees.value.includes(invitees.value[index])) {
    const invitee = invitees.value[index];
    invitees.value.splice(index, 1);
    if (index === 0) {
      myInvitees.value.splice(0, 1);
    } else {
      const myInviteeIndex = myInvitees.value.indexOf(invitee);
      myInvitees.value.splice(myInviteeIndex, 1);
    }
  }
};

function saveAlbum() {
  switch (props.action) {
    case 'create':
      saveCreateAlbum();
      break;
    case 'edit':
      saveUpdateAlbum();
      break;
    case 'share':
      saveShareAlbum();
      break;
    default:
      break;
  }
}

async function saveCreateAlbum() {
  createAlbumApi({
    name: name.value,
    expiry_date: expiryDate.value,
    invitees: invitees.value,
  })
    .then((response: AxiosResponse) => {
      $emit('added-new-album', response.data);
    })
    .catch((error) => {
      console.log(error);
    });
}

async function saveUpdateAlbum() {
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
}

async function saveShareAlbum() {
  addInviteesApi(props.albumId, {
    invitees: invitees.value,
  })
    .then((response: AxiosResponse) => {
      $emit('edited-album', response.data);
    })
    .catch((error) => {
      console.log(error);
    });
}

function closeEditAlbum() {
  $emit('close-edit-album');
}
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
