<template>
  <div class="flex h-screen">
    <div
      ref="menuRef"
      class="side-menu-container"
      :class="[{ 'fixed-menu': !isLargeScreen, open: isMenuOpen && !isLargeScreen }]"
    >
      <div class="side-menu">
        <div>
          <div class="current-user">
            <div class="text-xl font-bold">
              {{ currentUserName }}
            </div>
            <div>
              {{ currentUser.email }}
            </div>
          </div>
          <div>
            <div
              v-for="item in menuItems"
              :key="item.text"
              class="sidemenu-item"
              @mouseenter="item.isHovering = true"
              @mouseleave="item.isHovering = false"
            >
              <div class="sidemenu-item1">
                <font-awesome-icon :icon="item.icon" />
                {{ item.text }}
              </div>
              <font-awesome-icon v-if="item.isHovering" icon="fa-solid fa-chevron-right" />
            </div>
          </div>
        </div>
        <div class="sidemenu-item logout" @click="logout">
          <font-awesome-icon icon="fa-solid fa-arrow-right-from-bracket" />
          Log out
        </div>
      </div>
    </div>
    <div class="overlay" :class="{ active: isMenuOpen && !isLargeScreen }" @click="closeMenu"></div>
    <div class="albums-container">
      <div>
        <div v-if="!isLargeScreen" class="h-11">
          <button @click="toggleMenu">
            <svg
              width="24"
              height="24"
              viewBox="0 0 24 24"
              class="btn-menu"
              fill="none"
              xmlns="http://www.w3.org/2000/svg"
            >
              <circle cx="12" cy="12" r="11" stroke="currentColor" stroke-width="0.5" />
              <circle cx="7" cy="12" r="1.5" fill="currentColor" />
              <circle cx="12" cy="12" r="1.5" fill="currentColor" />
              <circle cx="17" cy="12" r="1.5" fill="currentColor" />
            </svg>
          </button>
        </div>
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
        <div class="albums">
          <div v-for="album in albums" :key="album.id">
            <div class="relative w-36 h-46 md:w-40 md:h-48 lg:w-56 lg:h-60 cursor-pointer">
              <RouterLink :to="{ name: 'Album', params: { id: album.id } }">
                <div class="photo-container album h-36 md:h-40 lg:h-56 mb-2">
                  <AdvancedImage
                    v-if="album.cover && album.cover.length > 0"
                    :cld-img="getCloudinaryImage(album.cover, album.angle)"
                    place-holder="predominant-color"
                    class="object-cover w-36 h-36 md:w-40 md:h-40 lg:w-56 lg:h-56 rounded"
                  />
                  <div v-else class="placeholder-album">
                    <font-awesome-icon icon="fa-regular fa-images" class="h-1/5" />
                  </div>
                </div>
                <div class="title-album-name">
                  {{ album.name }}
                </div>
                <div class="title-album-expiry">Due: {{ album.expiry_date }}</div>
              </RouterLink>
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
import { ref, computed, watch, onBeforeMount, onMounted, onUnmounted } from 'vue';
import { RouterLink } from 'vue-router';
import { AdvancedImage } from '@cloudinary/vue';
import type { AxiosResponse } from 'axios';
import AlbumEdit from '../../components/panel/AlbumEdit.vue';
import { getCloudinaryImage } from '@/services/cloudinary.service';
import { getAlbumsApi } from '@/apis/panel.api';
import { useAuthStore } from '@/stores/auth.store';
const authStore = useAuthStore();
const logout = () => {
  authStore.logout();
};

interface Album {
  id: number;
  name: string;
  expiry_date: Date;
  invitees: string[];
  cover: string;
  angle: number;
}

const currentUser = JSON.parse(localStorage.user).data.attributes;
const currentUserName = currentUser.email.split('@')[0];

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

// side menu
const isMenuOpen = ref(false);
// const resizePoint = 768;
const resizePoint = 600;
const isLargeScreen = ref(window.innerWidth >= resizePoint);
const menuRef = ref(null);

const toggleMenu = () => {
  if (!isLargeScreen.value) {
    isMenuOpen.value = !isMenuOpen.value;
  }
};

const closeMenu = () => {
  if (!isLargeScreen.value) {
    isMenuOpen.value = false;
  }
};

const handleResize = () => {
  isLargeScreen.value = window.innerWidth >= resizePoint;
  isLargeScreen.value = window.innerWidth >= resizePoint;
  if (isLargeScreen.value) {
    isMenuOpen.value = true;
  }
};

onMounted(() => {
  window.addEventListener('resize', handleResize);
  handleResize();
});

onUnmounted(() => {
  window.removeEventListener('resize', handleResize);
});

watch(isLargeScreen, (newValue) => {
  if (newValue) {
    isMenuOpen.value = true;
  } else {
    isMenuOpen.value = false;
  }
});

const menuItems = ref([
  { icon: 'fa-solid fa-circle-user', text: 'Profile', isHovering: false },
  { icon: 'fa-solid fa-chart-column', text: 'Monthly usage', isHovering: false },
  { icon: 'fa-solid fa-bell', text: 'Notifications', isHovering: false },
]);
</script>

<style scoped>
@import '../../assets/css/panel.scss';

.side-menu-container {
  z-index: 9;
  width: 250px;
  min-width: 250px;
  height: 100%;
  opacity: 0.8;
  background: rgba(22, 22, 23, 0.8);
  backdrop-filter: blur(12px);

  .side-menu {
    display: flex;
    flex-direction: column;
    justify-content: space-between;
    width: 100%;
    height: 100%;
    padding: 1.5rem 0;

    .sidemenu-item {
      display: flex;
      align-items: center;
      padding: 0.75rem 1.5rem;
      line-height: 1.75rem;
      cursor: pointer;
      color: rgba(255, 255, 255, 0.8);
      transition: color 0.32s cubic-bezier(0.4, 0, 0.6, 1);

      .sidemenu-item1 {
        display: flex;
        align-items: center;
        gap: 0.5rem;
        font-size: 1.125rem;
        font-weight: 700;
      }
    }

    .sidemenu-item:not(.logout):hover {
      justify-content: space-between;
      color: rgba(255, 255, 255, 1);
      /* background: var(--gray-raven); */
    }

    .current-user {
      padding-left: 1.5rem;
      padding-bottom: 0.75rem;
      border-bottom-width: 1px;
      /* border-bottom-style: solid; */
      /* border-bottom-color: #404040; */
    }

    .logout {
      gap: 0.5rem;
      color: #8b5cf6;
      font-size: 1.125rem;
      transition: font-weight 0.32s cubic-bezier(0.4, 0, 0.6, 1);
    }

    .logout:hover {
      font-weight: 600;
    }
  }
}

.fixed-menu {
  position: fixed;
  top: 0;
  left: -100%;
  transition: left 0.32s cubic-bezier(0.4, 0, 0.6, 1);

  .side-menu {
    opacity: 0;
    transform: translateX(-20px);
    transition:
      opacity 0.32s cubic-bezier(0.4, 0, 0.6, 1) 80ms,
      transform 0.32s cubic-bezier(0.4, 0, 0.6, 1) 80ms;

    .current-user div,
    .sidemenu-item {
      opacity: 0;
      transform: translateX(-20px);
      transition:
        opacity 0.32s cubic-bezier(0.4, 0, 0.6, 1) 240ms,
        transform 0.32s cubic-bezier(0.4, 0, 0.6, 1) 240ms;
    }
  }
}

.fixed-menu.open {
  left: 0;

  .side-menu {
    opacity: 1;
    transform: translateX(0);

    .current-user div,
    .sidemenu-item {
      opacity: 1;
      transform: translateX(0);
    }
  }
}

.overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  width: 100%;
  height: 100%;
  z-index: 8;
  background-color: rgba(0, 0, 0, 0.5);
  backdrop-filter: blur(12px);
  opacity: 0;
  visibility: hidden;
  transition:
    opacity 0.3s cubic-bezier(0.4, 0, 0.6, 1),
    visibility 0.32s cubic-bezier(0.4, 0, 0.6, 1);
}

.overlay.active {
  opacity: 1;
  visibility: visible;
}

.btn-menu {
  box-shadow: 4px 0px rgba(0, 0, 0, 0.25);
  transition: all 0.32s cubic-bezier(0.4, 0, 0.6, 1);
  backdrop-filter: blur(5px);
  -webkit-backdrop-filter: blur(5px);

  &:hover {
    transform: scale(1.1);
  }
}

.albums-container {
  display: flex;
  height: 100%;
  width: 100%;
  justify-content: center;
  padding-top: 2.5rem;
  overflow-y: auto;
}

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
  border-top-left-radius: var(--rounded-xl);
  border-top-right-radius: var(--rounded-xl);
}

.sort-menu-item:last-child {
  border-bottom-left-radius: var(--rounded-xl);
  border-bottom-right-radius: var(--rounded-xl);
}

.sort-selected {
  color: var(--color-text);
}

.albums {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 0.75rem;
  row-gap: 1rem;
  margin-left: auto;
  margin-right: auto;
  margin-bottom: 1.5rem;
  z-index: 0;
}

.placeholder-album {
  display: flex;
  justify-content: center;
  align-items: center;
  width: 100%;
  background: var(--black-raven);
  color: var(--dark-violet);
  border-radius: var(--rounded);
  cursor: pointer;
}

.photo-container.album {
  display: flex;
  justify-content: center;
  opacity: 0.8;
  transition: opacity 0.32s cubic-bezier(0.4, 0, 0.6, 1);
}

.photo-container.album:hover {
  opacity: 1;
}

.title-album-name {
  padding-left: 0.25rem;
  font-size: 1rem;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  font-weight: 500;
  color: #ffffff;
}

.title-album-name:hover {
  text-decoration: underline;
  text-underline-offset: 2px;
}

.title-album-expiry {
  padding-left: 0.25rem;
  font-size: 0.75rem;
  color: #94a3b8;
}

@media (min-width: 768px) {
  .albums {
    grid-template-columns: repeat(3, minmax(0, 1fr));
    gap: 3rem;
    row-gap: 4rem;
  }
}

@media (min-width: 1280px) {
  .albums {
    grid-template-columns: repeat(4, minmax(0, 1fr));
  }
}
</style>
