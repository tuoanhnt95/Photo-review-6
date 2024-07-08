<template>
  <div class="container-modal-album bg-glass-blur">
    <div class="modal-album bg-glass-grey box-shadow top-[15%] md:top-1/4">
      <div class="modal-info">
        <h3 class="label-text-md text-center mb-3">{{ title }}</h3>
        <div v-if="props.action !== 'share'" class="container-input-warning">
          <div class="flex place-content-between">
            <input
              v-model="name"
              type="text"
              required
              placeholder="Album name"
              class="bg-glass-dark box-shadow border-modal-input"
            />
          </div>
          <div class="container-warning">
            <span v-if="!nameExists" class="text-warning-small pl-1">Required</span>
          </div>
        </div>

        <div v-if="props.action !== 'share'">
          <div class="container-label-input bg-glass-dark box-shadow">
            <label for="expiry-date" class="self-center">Due date</label>
            <div>
              <input
                v-model="expiryDate"
                type="date"
                :min="today"
                class="bg-glass-dark flex justify-end"
              />
            </div>
          </div>
          <p v-if="!expiryDate" class="text-warning-small pl-1">Invalid date</p>
        </div>

        <div class="">
          <div class="container-label-input bg-glass-dark box-shadow">
            <label for="invitee" class="text-lg">Share</label>
            <div class="w-full ml-2.5">
              <input
                v-model="newInvitee"
                type="email"
                class="bg-glass-dark"
                @keydown.enter="addInvitee"
                @keydown.prevent.tab="addInvitee"
                @keydown.space="addInvitee"
                @keyup.,="addInvitee"
                @keyup.;="addInvitee"
                @keydown.delete="newInvitee.length || removeInvitee(0)"
              />
            </div>
          </div>
          <div class="container-warning">
            <p v-if="!emailIsValid" class="text-warning-small pl-1">Invalid email format</p>
          </div>
          <div class="tags">
            <div
              v-for="(invitee, i) in invitees"
              :key="i"
              class="tag"
              :class="{ 'tag-existing': !editableInvitees.includes(invitee) }"
            >
              <div class="container-email">
                {{ invitee }}
              </div>
              <div class="container-btn-x">
                <div class="btn-x">
                  <font-awesome-icon
                    v-if="editableInvitees.includes(invitee)"
                    icon="fa-solid fa-x"
                    class="cursor-pointer self-center text-xs"
                    @click="removeInvitee(i)"
                  />
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div class="container-btn-bottom">
        <button class="text-xl" @click="closeEditAlbum">Cancel</button>
        <button
          class="font-bold"
          :disabled="!canSubmit"
          :class="{ 'opacity-50 cursor-not-allowed': !canSubmit }"
          @click="saveAlbum"
        >
          {{ props.action === 'create' ? 'Create' : 'Save' }}
        </button>
      </div>
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

const title = computed(() => {
  switch (props.action) {
    case 'create':
      return 'New Album';
    case 'edit':
      return 'Edit Album';
    case 'share':
      return 'Share Album';
    default:
      return '';
  }
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
  if (!emailIsValid.value) {
    return;
  }
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
  position: fixed;
  top: 0;
  width: 100%;
  height: 100%;
  z-index: 10;
}

.modal-album {
  position: relative;
  /* top: 15%; */
  margin: 0 auto;
  width: 90%;
  min-width: 320px;
  max-width: 360px;
  border-radius: 0.75rem; /* 12px */
}

.modal-info {
  padding: 2rem 1.5rem 0 1.5rem;
}

.modal-info input,
.container-label-input {
  width: 100%;
  min-width: 190px;
  padding: 0.1rem 0.5rem;
  font-size: 1rem; /* 16px */
  border-radius: 0.5rem;
}

.container-input-warning {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
  width: 100%;
}

.container-warning {
  display: flex;
  align-self: start;
  height: 1.5rem;
}

.container-label-input {
  display: flex;
  justify-content: space-between;
  margin-bottom: 0.5rem;
}

::-webkit-calendar-picker-indicator {
  filter: invert(1);
}

.tags {
  display: flex;
  flex-wrap: wrap;
  margin-bottom: 8px;
  width: 100%;
  max-height: 200px;
  overflow-x: auto;
  overflow-y: scroll;
}
.tag {
  display: flex;
  justify-content: space-between;
  width: 100%;
  padding-left: 8px;
  white-space: wrap;
  transition: 0.1s ease background;

  .container-email {
    display: flex;
    align-items: center;
    width: calc(100% - 44px);
    white-space: nowrap;
    overflow-x: auto;
  }

  .container-btn-x {
    display: flex;
    justify-content: center;
    align-items: center;
    width: 44px;
    height: 44px;

    .btn-x {
      display: flex;
      justify-content: center;
      align-items: center;
      align-self: center;
      width: 20px;
      height: 20px;
      border-radius: 50%;
      background: var(--black-soft);
      color: var(--color-text-light-1);
    }
  }
}

.tag-existing {
  background: var(--color-secondary);
}

.container-btn-bottom {
  display: grid;
  grid-template-columns: 1fr 1fr;
  width: 100%;
  border-top: 1px solid var(--color-border);

  button {
    padding: 12px 16px;
    font-size: 1.25rem; /* 20px */
    line-height: 1.75rem; /* 28px */
    color: var(--color-primary);
  }

  button:first-child {
    border-right: 1px solid var(--color-border);
  }

  button:disabled {
    color: var(--color-text-light-1);
  }
}
</style>
