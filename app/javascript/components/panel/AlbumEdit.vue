<template>
  <div class="container-modal-album bg-glass-blur">
    <div class="modal-album bg-glass-dark rounded-xl">
      <div v-if="props.action !== 'share'" class="w-full">
        <div class="flex place-content-between">
          <input
            v-model="name"
            type="text"
            required
            placeholder="Album name"
            class="w-full px-2 py-1 text-xl text-black rounded"
          />
        </div>
        <div class="h-8">
          <p v-if="!nameExists">Required</p>
        </div>
      </div>

      <div v-if="props.action !== 'share'" class="flex place-content-between mb-4">
        <label for="expiry-date" class="self-center text-lg">Expiry date</label>
        <div>
          <input
            v-model="expiryDate"
            type="date"
            :min="today"
            class="pl-1 rounded text-lg text-black"
          />
          <div class="h-8">
            <p v-if="!expiryDate">Invalid date</p>
          </div>
        </div>
      </div>

      <div class="flex place-content-between mb-4">
        <label for="invitee" class="text-lg">Invitee</label>
        <div class="tag-input ml-2.5">
          <input
            v-model="newInvitee"
            type="email"
            class="w-full py-1 px-2 text-lg text-black rounded"
            @keydown.enter="addInvitee"
            @keydown.prevent.tab="addInvitee"
            @keydown.space="addInvitee"
            @keyup.,="addInvitee"
            @keyup.;="addInvitee"
            @keydown.delete="newInvitee.length || removeInvitee(0)"
          />
          <div class="h-8">
            <p v-if="!emailIsValid">Invalid email format</p>
          </div>
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
          class="w-full mt-4 py-3 bg-violet-600 text-slate-200 rounded text-xl font-bold"
          :disabled="!canSubmit"
          :class="{ 'opacity-50 cursor-not-allowed': !canSubmit }"
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
    type: String,
    default: new Date(new Date().setDate(new Date().getDate() + 7)).toISOString().split('T')[0], // seven days from today
  },
  albumInvitees: {
    type: Array<string>,
    default: [],
  },
});

const name = ref(props.albumName);
const nameExists = computed(() => name.value && name.value.length > 0);

const today = new Date().toISOString().slice(0, 10);
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

const emailIsValid = computed(() => {
  const emailRegex = /^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$/;
  return (
    emailRegex.test(newInvitee.value) ||
    (newInvitee.value === '' && invitees.value.every((invitee) => emailRegex.test(invitee)))
  );
});

function addInvitee() {
  if (newInvitee.value !== '') {
    newInvitee.value = newInvitee.value.replace(/[,.;\s]+$/, '');
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

const canSubmit = computed(() => {
  return nameExists.value && expiryDate.value;
});

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
  if (!nameExists.value) {
    return;
  }

  createAlbumApi({
    name: name.value,
    expiry_date: toDate(expiryDate.value),
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
  if (!nameExists.value) {
    return;
  }
  updateAlbumApi(props.albumId, {
    name: name.value,
    expiry_date: toDate(expiryDate.value),
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

function toDate(dateStr: string) {
  const parts = dateStr.split('-');
  return new Date(Number(parts[0]), Number(parts[1]) - 1, Number(parts[2]) + 1);
}
</script>

<style scoped>
.container-modal-album {
  position: absolute;
  top: 0;
  width: 100%;
  height: 100%;
  z-index: 10;
}

.modal-album {
  position: relative;
  margin: 0 auto;
  top: 25%;
  padding: 4rem 1.5rem 2rem 1.5rem;
  width: fit-content;
}

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
