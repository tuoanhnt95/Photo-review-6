<template>
  <div style="height: 100%; overflow: hidden">
    <div class="flex w-100 justify-center">
      <div>
        <div class="h-11">Settings</div>
        <div class="flex justify-between">
          <div class="label-text">Albums</div>
          <div class="container-sort">
            <div
              class="container-sort-label"
              :class="{ 'show-sort': isShowingSort }"
              @click="showSort"
            >
              {{ selectedSort }}
              <font-awesome-icon
                v-if="!isShowingSort"
                icon="fa-solid fa-angle-down"
                class="sort-icon"
              />
              <font-awesome-icon
                v-if="isShowingSort"
                icon="fa-solid fa-angle-up"
                class="sort-icon"
              />
            </div>
            <div v-if="isShowingSort" class="container-sort-menu">
              <div
                class="sort-menu bg-glass-blur shadow-lg divide-y divide-solid divide-neutral-700"
                :class="{ show: isShowingSort }"
              >
                <div
                  v-for="sort in sortMethods"
                  :key="sort.value"
                  class="sort-menu-item bg-glass-dark text-sm px-4 py-2"
                  :class="{ 'sort-selected pointer-events-none': sortMethod === sort.value }"
                  @click="sortMethod = sort.value"
                >
                  {{ sort.name }}
                </div>
              </div>
            </div>
          </div>
        </div>
        <div class="flex pb-4">
          <div class="grid grid-cols-2 md:grid-cols-4 gap-3 md:gap-4 mx-auto mb-6 z-0">
            <div v-for="album in albums" :key="album.id">
              <div class="relative w-36 h-46 md:w-48 md:h-56 cursor-pointer">
                <RouterLink :to="{ name: 'Album', params: { id: album.id } }">
                  <div class="photo-container flex justify-center h-36 md:h-48">
                    <AdvancedImage
                      v-if="album.cover && album.cover.length > 0"
                      :cld-img="getCloudinaryImage(album.cover, album.angle)"
                      place-holder="predominant-color"
                      class="object-cover w-36 h-36 md:w-48 md:h-48 rounded"
                    />
                  </div>
                  <div class="pl-1 text-md truncate font-medium text-slate-500 text-white">
                    {{ album.name }}
                  </div>
                  <div class="pl-1 text-xs text-slate-400">Due: {{ album.expiry_date }}</div>
                </RouterLink>
              </div>
            </div>
          </div>
        </div>
        <div @click="openAddAlbum()">
          <div class="btn-circle-add">
            <font-awesome-icon icon="fa-solid fa-plus" class="m-auto" />
          </div>
        </div>
      </div>
    </div>
    <AlbumEdit
      v-if="action.length > 0"
      :action="action"
      @close-edit-album="action = ''"
      @added-new-album="(editedAlbum: Album) => addAlbum(editedAlbum)"
    />
  </div>
</template>

<script setup lang="ts">
import { computed, onBeforeMount, ref } from 'vue';
import { RouterLink } from 'vue-router';
import { AdvancedImage } from '@cloudinary/vue';
import type { AxiosResponse } from 'axios';
import AlbumEdit from '../../components/panel/AlbumEdit.vue';
import { getCloudinaryImage } from '@/services/cloudinary.service';
import { getAlbumsApi } from '@/apis/panel.api';

interface Album {
  id: number;
  name: string;
  expiry_date: Date;
  invitees: string[];
  cover: string;
  angle: number;
}

const albumsData = ref<Album[]>([]);
onBeforeMount(async () => {
  getAlbumsApi()
    .then((response: AxiosResponse) => {
      albumsData.value = response.data;
    })
    .catch((error) => {
      console.log(error);
    });
});

const albums = computed(() => {
  const albumsDataCopy = albumsData.value;
  switch (sortMethod.value) {
    case 1:
      return albumsDataCopy.sort(
        (a, b) => new Date(a.expiry_date).getTime() - new Date(b.expiry_date).getTime(),
      );
    case 2:
      return albumsDataCopy.sort(
        (a, b) => new Date(b.expiry_date).getTime() - new Date(a.expiry_date).getTime(),
      );
    case 3:
      return albumsDataCopy.sort((a, b) => a.name.localeCompare(b.name));
    case 4:
      return albumsDataCopy.sort((a, b) => b.name.localeCompare(a.name));
    default:
      return albumsData.value;
  }
});

const action = ref('');
const openAddAlbum = () => {
  action.value = 'create';
  isShowingSort.value = false;
};

const addAlbum = (album: Album) => {
  action.value = '';
  album.cover = '';
  albumsData.value.unshift(album);
};

// sort methods: 0 album added order 1 far to close, 2 close to far, 3 alphabetical ascending, 4 alphabetical descending
const sortMethods = [
  { value: 0, name: 'Created: Earliest First' },
  { value: 1, name: 'Due: Earliest First' },
  { value: 2, name: 'Due: Latest First' },
  { value: 3, name: 'Album name: A to Z' },
  { value: 4, name: 'Album name: Z to A' },
];
const sortMethod = ref(0);
const isShowingSort = ref(false);
const selectedSort = computed(() => {
  const selected = sortMethods.find((x) => x.value === sortMethod.value);
  return selected ? selected.name : sortMethods[0].name;
});
const showSort = () => {
  isShowingSort.value = !isShowingSort.value;
};
</script>

<style scoped>
@import '../../assets/css/panel.scss';

.container-sort {
  position: relative;
  display: flex;
  justify-content: flex-end;
  align-items: center;
  height: 44px;
}

.container-sort-label {
  display: flex;
  justify-content: space-between;
  gap: 0.5rem;
  margin-left: 0.25rem;
  padding: 0 0.25rem;
  width: 150px;
  cursor: pointer;
  font-size: 12px;
  border: 1px solid var(--color-background);
  transition: border-color 0.1s ease-in-out;

  .sort-icon {
    align-self: center;
    font-size: 10px;
  }
}

.container-sort-label.show-sort {
  border-color: var(--color-primary);
}

.sort-menu {
  position: absolute;
  top: 16px;
  inset-inline-end: -9px;
  z-index: 10;
  width: 190px;
  color: var(--color-text-light-1);
  opacity: 0;
  transition: opacity 0.1s ease-in-out;
}

.container-sort-menu {
  position: relative;
}
.sort-menu.show {
  opacity: 1;
}

.sort-menu-item {
  cursor: pointer;
}

.sort-menu-item:hover {
  color: var(--color-primary);
}

.sort-menu-item:first-child {
  border-top-left-radius: var(--border-radius-lg);
  border-top-right-radius: var(--border-radius-lg);
}

.sort-menu-item:last-child {
  border-bottom-left-radius: var(--border-radius-lg);
  border-bottom-right-radius: var(--border-radius-lg);
}

.sort-selected {
  color: var(--color-text);
}
</style>
