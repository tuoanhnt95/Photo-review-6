<template>
  <div class="container-album-page" @click="handleContainerClick">
    <div class="bg-menu-dark container-top-fixed">
      <div class="header-album">
        <slot v-if="!isSelecting">
          <a class="container-back" @click.stop="goBackToAlbums">
            <font-awesome-icon icon="fa-solid fa-chevron-left" />
            <p style="margin-top: -4px">Albums</p>
          </a>

          <!-- empty placeholder to keep grid layout -->
          <p v-if="isLargeScreen"></p>

          <div class="container-select-toggle-menu w-24">
            <button type="button" class="btn-select btn-menu" @click.stop="toggleSelecting">
              Select
            </button>
            <ButtonMenu @toggle-menu="toggleContextMenu" />
          </div>
        </slot>
        <slot v-else>
          <div class="w-24">
            <button
              type="button"
              class="btn-select btn-menu"
              @click.prevent="toggleSelectAllPhotos"
            >
              {{ selectedPhotoIds.length > 0 ? 'Deselect All' : 'Select All' }}
            </button>
          </div>
          <div v-if="isLargeScreen" class="flex-center-center">
            <p class="w-8 font-bold">
              {{ selectedPhotoIds.length }}
            </p>
            of {{ filteredPhotos.length }} photos selected
          </div>
          <div class="container-select-toggle-menu w-36">
            <!-- TODO: send photo to someone by notification or email, with a message -->
            <slot v-if="isLargeScreen">
              <button
                type="button"
                class="btn-select btn-menu"
                :class="{ unselectable: selectedPhotoIds.length === 0 }"
                @click.stop.prevent="rotatePhotos"
              >
                <font-awesome-icon icon="fa-solid fa-rotate-left" />
              </button>
              <button
                type="button"
                class="btn-select btn-menu"
                :class="{ unselectable: !isAlbumOwner || selectedPhotoIds.length === 0 }"
                @click.prevent="deletePhotos"
              >
                <font-awesome-icon icon="fa-solid fa-trash-can" />
              </button>
            </slot>
            <button
              type="button"
              class="btn-select btn-menu"
              :class="{ unselectable: selectedPhotoIds.length === 0 }"
              @click.prevent="saveChangePhotos"
            >
              Save
            </button>
            <button type="button" class="btn-select btn-menu" @click.prevent="cancelSelectPhotos">
              Cancel
            </button>
          </div>
        </slot>
      </div>

      <div class="container-album-name">
        <div class="label-text md">
          {{ album.name }}
        </div>
      </div>
      <!-- Filter -->
      <div class="container-filter">
        <div class="container-date">
          <font-awesome-icon icon="fa-solid fa-calendar-days" />
          <slot v-if="isLargeScreen">
            <strong>{{ `Due: ${formatDate(album.expiry_date)} ` }}</strong>
            ({{
              filteredPhotos.length > 1
                ? filteredPhotos.length + ' photos'
                : filteredPhotos.length + ' photo'
            }})
          </slot>
          <strong v-else>{{ formatDate(album.expiry_date) }}</strong>
        </div>
        <div class="container-buttons-filter">
          <slot v-if="!isSelecting">
            <button
              v-for="opt in filterReview"
              :key="opt.icon"
              :class="{ selected: opt.selected }"
              @click.stop.prevent="opt.selected = !opt.selected"
            >
              <font-awesome-icon :icon="`fa-solid fa-${opt.icon}`" />
              <div style="font-size: 11pt">({{ numberOfPhotosWithReview(opt.value) }})</div>
            </button>
          </slot>
          <slot v-else>
            <button
              v-for="opt in filterReview.slice(0, 3)"
              :key="opt.icon"
              :class="{
                selected: ratedReview === opt.value,
                unselectable: selectedPhotoIds.length === 0,
              }"
              style="height: 22px"
              @click.stop.prevent="reviewPhotos(opt.value)"
            >
              <font-awesome-icon :icon="`fa-solid fa-${opt.icon}`" />
            </button>
          </slot>
        </div>
      </div>

      <div
        class="overlay"
        :class="{ active: contextMenuIsOpen }"
        @click.stop="toggleContextMenu"
      ></div>
    </div>

    <!-- Photos -->
    <div class="mt-36">
      <!-- Icon view -->
      <div
        v-if="selectedAlbumViewIndex !== 1"
        class="container-photos-icon"
        @click.stop="handleContainerClick"
      >
        <div class="photo-container upload" @click.stop.prevent="isUploadingPhoto = true">
          <font-awesome-icon icon="fa-solid fa-plus" class="m-auto text-violet-600" />
        </div>
        <div
          v-for="(photo, i) in photos"
          :key="i"
          class="relative h-fit"
          @click.stop="handlePhotoClick(photo.id)"
        >
          <div
            class="photo-container flex justify-center"
            :class="{ 'cursor-pointer': filteredPhotos.map((x) => x.id).includes(photo.id) }"
          >
            <AdvancedImage
              :id="photo.image"
              :cldImg="getCloudinaryImage(photo.image, photo.angle)"
              :class="getPhotoClass(photo)"
            />
          </div>
          <div v-if="selectedPhotoIds.includes(photo.id)" class="container-icon-circle">
            <font-awesome-icon icon="fa-solid fa-circle-check" class="icon-circle-check" />
          </div>
          <slot v-if="isShowingResult">
            <div class="icon-result-overall">
              <font-awesome-icon :icon="`fa-solid fa-${getOverallIcon(photo.id)}`" />
            </div>
            <div class="container-photo-reviews-all">
              <div v-for="review in filterReview.slice(0, 3)" :key="review.icon">
                <div class="container-photo-review">
                  <font-awesome-icon
                    :icon="`fa-solid fa-${review.icon}`"
                    :class="{
                      'opacity-0': numberOfReviewsWithResult(photo.id, review.value) === 0,
                    }"
                  />
                  <div
                    :class="{
                      'opacity-0': numberOfReviewsWithResult(photo.id, review.value) === 0,
                    }"
                  >
                    {{ numberOfReviewsWithResult(photo.id, review.value) }}
                  </div>
                </div>
              </div>
            </div>
          </slot>
        </div>
      </div>
      <!-- Photos list view -->
      <div v-else class="flex justify-center">
        <table class="bg-menu">
          <thead>
            <tr>
              <th></th>
              <th></th>
              <th class="text-left">Name</th>
              <th>
                <div class="flex gap-2 w-32 justify-start">
                  Average result
                  <div class="flex items-center">
                    <font-awesome-icon
                      :icon="`fa-solid fa-eye${isShowingResult ? '' : '-slash'}`"
                      class="cursor-pointer"
                      @click.stop="isShowingResult = !isShowingResult"
                    />
                  </div>
                </div>
              </th>
              <slot v-for="review in filterReview.slice(0, 3)" :key="review.icon">
                <th>
                  <font-awesome-icon :icon="`fa-solid fa-${review.icon}`" class="self-center" />
                </th>
              </slot>
            </tr>
          </thead>
          <tbody>
            <tr v-for="(photo, i) in photos" :key="i" class="w-full h-11 pt-3">
              <td
                class="w-11 h-full align-middle cursor-pointer"
                @click.stop.prevent="handlePhotoClick(photo.id)"
              >
                <div class="flex justify-center w-full h-full">
                  <font-awesome-icon
                    v-if="selectedPhotoIds.includes(photo.id)"
                    icon="fa-solid fa-circle-check"
                    class="self-center icon-circle-check"
                  />
                </div>
              </td>
              <td class="w-11 h-11 cursor-pointer" @click.stop.prevent="showPhoto(photo.id)">
                <AdvancedImage
                  :id="photo.image"
                  :cldImg="getCloudinaryImage(photo.image, photo.angle)"
                  class="w-11 h-11"
                  :class="getPhotoClass(photo)"
                />
              </td>
              <td
                class="w-56 h-full align-middle text-wrap cursor-pointer"
                @click.stop.prevent="showPhoto(photo.id)"
              >
                <div class="ml-3 h-full">{{ photo.name }}</div>
              </td>
              <td class="w-8 h-full align-middle pr-6">
                <div
                  v-show="isShowingResult"
                  class="flex justify-center gap-2 w-full h-full text-xl font-bold"
                >
                  <font-awesome-icon
                    :icon="`fa-solid fa-${getOverallIcon(photo.id)}`"
                    class="self-center"
                  />
                </div>
              </td>
              <slot v-for="review in filterReview.slice(0, 3)" :key="review.icon">
                <td class="td-reviews">
                  <div v-show="isShowingResult" class="td-review">
                    {{ numberOfReviewsWithResult(photo.id, review.value) }}
                  </div>
                </td>
              </slot>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Bottom bar if small screen -->
    <slot v-if="!isLargeScreen">
      <div class="container-bottom bg-menu">
        <button
          type="button"
          class="btn-select btn-menu"
          :class="{ unselectable: selectedPhotoIds.length === 0 }"
          @click.stop.prevent="rotatePhotos"
        >
          <font-awesome-icon icon="fa-solid fa-rotate-left" />
        </button>
        <p v-if="!isSelecting" class="flex-center-center">{{ filteredPhotos.length }} photos</p>
        <div v-else class="flex justify-center">
          <div class="w-37 self-center flex">
            <div class="flex justify-center align-center w-8 font-bold">
              {{ selectedPhotoIds.length }}
            </div>
            of {{ filteredPhotos.length }} photos selected
          </div>
        </div>
        <button
          type="button"
          class="btn-select btn-menu"
          :class="{ unselectable: !isAlbumOwner || selectedPhotoIds.length === 0 }"
          @click.stop.prevent="deletePhotos"
        >
          <font-awesome-icon icon="fa-solid fa-trash-can" />
        </button>
      </div>
    </slot>

    <!-- ContextMenu -->
    <div
      :album="album"
      id="context-menu"
      class="bg-menu menu-shadow"
      :class="{ show: contextMenuIsOpen }"
      @click.stop.prevent="toggleContextMenu"
      @toogle-list-view="selectAlbumViewOption"
    >
      <div
        v-if="isAlbumOwner"
        class="container-context-menu container-context-border"
        @click.stop.prevent="action = 'edit'"
      >
        <div></div>
        <div>Edit</div>
        <font-awesome-icon icon="fa-solid fa-pen" class="self-center mr-2" />
      </div>
      <div class="container-context-border">
        <div
          v-for="(opt, i) in albumViewOptions"
          :key="opt.name"
          class="container-context-menu"
          :class="[
            i === albumViewOptions.length - 1
              ? 'container-context-border'
              : 'container-context-border-sub',
          ]"
          @click.stop.prevent="selectAlbumViewOption(i)"
        >
          <font-awesome-icon
            :class="{ 'opacity-0': i !== selectedAlbumViewIndex }"
            icon="fa-solid fa-check"
          />
          <div>{{ opt.name }}</div>
          <font-awesome-icon :icon="opt.icon" class="mr-2" />
        </div>
      </div>
      <!-- change display fit mode -->
      <div class="container-context-border">
        <div
          v-for="(mode, i) in displayFitModes"
          :key="mode.value"
          class="container-context-menu"
          :class="[
            i === displayFitModes.length - 1
              ? 'container-context-border'
              : 'container-context-border-sub',
          ]"
          @click.stop.prevent="selectedDisplayFitMode = mode.value"
        >
          <font-awesome-icon
            :class="{ 'opacity-0': selectedDisplayFitMode !== mode.value }"
            icon="fa-solid fa-check"
          />
          <div>{{ mode.name }}</div>
          <font-awesome-icon :icon="mode.icon" class="self-center mr-2" />
        </div>
      </div>
      <div
        class="container-context-menu container-context-border"
        @click.stop="isShowingResult = !isShowingResult"
      >
        <font-awesome-icon :class="{ 'opacity-0': !isShowingResult }" icon="fa-solid fa-check" />
        <div>Show votes</div>
        <font-awesome-icon icon="fa-solid fa-eye" class="self-center mr-2" />
      </div>
      <div
        class="container-context-menu"
        :class="{ 'container-context-border': isAlbumOwner }"
        @click.stop.prevent="action = 'share'"
      >
        <div></div>
        <div>Share album</div>
        <font-awesome-icon icon="fa-solid fa-user-plus" class="self-center mr-2" />
      </div>
      <div
        v-if="isAlbumOwner"
        class="container-context-menu"
        @click.stop.prevent="deleteAlbum(album.name, album.id)"
      >
        <div></div>
        <div>Delete</div>
        <font-awesome-icon icon="fa-solid fa-trash-can" class="self-center mr-2" />
      </div>
    </div>
    <div
      class="overlay"
      :class="{ active: contextMenuIsOpen }"
      @click.stop="toggleContextMenu"
    ></div>

    <AlbumEdit
      v-if="action.length > 0"
      :action="action"
      :albumId="album.id"
      :albumName="album.name"
      :numberOfPhotos="photos.length"
      :albumExpiryDate="album.expiry_date.toString()"
      :albumInvitees="album.invitees"
      class="absolute left-0 w-full z-10"
      @close-edit-album="action = ''"
      @edited-album="(editedAlbum: Album) => editAlbum(editedAlbum)"
    />

    <PhotoUpload
      v-if="isUploadingPhoto"
      :album="album"
      :albumPhotoNames="photos.map((photo) => photo.name)"
      class="absolute top-0 left-0 w-full h-full"
      style="z-index: 2"
      @uploaded-new-photo="(photo) => addPhoto(photo)"
      @close-upload-photo="closeUploadPhoto"
    />

    <Photo
      v-if="isShowingPhoto && photoShowing"
      :photo="photoShowing"
      :photos="filteredPhotos"
      class="overlay dark active z-10"
      @reviewed-photo="(photo: Photo) => updatePhoto(photo)"
      @navigate-photo="(photoId: Number) => showPhoto(photoId)"
      @close-review-photo="closeReviewPhoto"
    />
  </div>
</template>

<script setup lang="ts">
import { computed, onBeforeMount, onMounted, onUnmounted, ref } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { AdvancedImage } from '@cloudinary/vue';
import type { AxiosResponse } from 'axios';
import ButtonMenu from '../../components/panel/ButtonMenu.vue';
import { getCloudinaryImage } from '@/services/cloudinary.service';
import {
  showAlbumApi,
  deleteAlbumApi,
  getPhotosApi,
  deletePhotosApi,
  getReviewsApi,
  updatePhotosApi,
} from '@/apis/panel.api';

// components
import AlbumEdit from '../../components/panel/AlbumEdit.vue';
import Photo from '../../components/panel/Photo.vue';
import PhotoUpload from '../../components/panel/PhotoUpload.vue';
import { useAuthStore } from '@/stores/auth.store';

const route = useRoute();
const router = useRouter();
const authStore = useAuthStore();
const { user } = authStore;

interface Album {
  id: number;
  name: string;
  user_id: number;
  invitees: string[];
  expiry_date: Date;
}

interface Photo {
  id: number;
  name: string;
  image: string;
  angle: number;
  album_id: number;
  review_id: number | null;
  created_at: Date;
  updated_at: Date;
}

interface PhotoUserReview {
  id: number;
  photo_id: number;
  user_id: number;
  review_id: number;
  created_at: Date;
  updated_at: Date;
}

const currentUserId = computed(() => {
  if (!user || !user.data) {
    return 0;
  }
  const result = String((user!.data as { id: number; type: string; attributes: {} }).id);
  return parseInt(result);
});

const album = ref<Album>({
  id: -1,
  name: '',
  user_id: 0,
  invitees: [],
  expiry_date: new Date(),
});

onBeforeMount(async () => {
  showAlbumApi(Number(route.params.id))
    .then((response: AxiosResponse) => {
      album.value = response.data;
    })
    .catch((error) => {
      console.log(error);
    });
});

const albumId = computed(() => {
  const id = route.params.id;
  return typeof id === 'string' ? parseInt(id) : parseInt(id[0]);
});

const isUploadingPhoto = ref(false);
function closeUploadPhoto() {
  isUploadingPhoto.value = false;
}

// Resize
const resizePoint = 670;
const isLargeScreen = ref(window.innerWidth >= resizePoint);

// Edit album, share album
const action = ref('');
function editAlbum(editedAlbum: Album) {
  loadReviews();
  album.value = editedAlbum;
  action.value = '';
}

// Photo display size
const displayFitModes = [
  { value: 1, name: 'Fill photo', icon: 'fa-solid fa-up-right-and-down-left-from-center' },
  { value: 2, name: 'Fit photo', icon: 'fa-solid fa-down-left-and-up-right-to-center' },
];
const selectedDisplayFitMode = ref(1); // 1: cover, 2: contain

// Selecting photos
const isSelecting = ref(false);
function toggleSelecting() {
  isSelecting.value = !isSelecting.value;
}

// Context menu
const contextMenuIsOpen = ref(false);
function toggleContextMenu() {
  contextMenuIsOpen.value = !contextMenuIsOpen.value;
}

const albumViewOptions = [
  { name: 'Icons', icon: 'fa-solid fa-border-all' },
  { name: 'List', icon: 'fa-solid fa-list' },
];
const selectedAlbumViewIndex = ref(0);
function selectAlbumViewOption(index: number) {
  selectedAlbumViewIndex.value = index;
}
// Todo: show contextmenu when clicking option
// TODO: Add list view, with album name, date, number of photos, and expiry date
// TODO: Add option to sort by date, name, number of photos, and expiry date
// TODO: Add option to filter by date, name, number of photos, and expiry date
// TODO: Add option to search by name

const isAlbumOwner = computed(() => {
  return album.value.user_id === currentUserId.value;
});

const deleteAlbum = async (albumName: string, albumId: number) => {
  if (!isAlbumOwner.value) {
    return;
  }

  if (confirm(`Delete album "${albumName}"?`) === false) {
    return;
  }
  deleteAlbumApi(albumId)
    .then(() => {
      router.push({ name: 'Albums' });
    })
    .catch((error) => {
      console.log(error);
    });
};

// Select photos for option
const selectedPhotoIds = ref<number[]>([]);
const isCommandKeyPressed = ref(false);
const isShiftKeyPressed = ref(false);
const lastSelectedPhoto = ref(0);

const handlePhotoClick = (photoId: number) => {
  if (isSelecting.value) {
    if (!isLargeScreen.value) {
      toggleSelectPhoto(photoId);
    } else {
      if (isShiftKeyPressed.value && lastSelectedPhoto.value > 0) {
        const start = photosData.value.findIndex((item) => item.id === lastSelectedPhoto.value);
        const end = photosData.value.findIndex((item) => item.id === photoId);
        const range = photosData.value
          .slice(Math.min(start, end), Math.max(start, end) + 1)
          .map((item) => item.id);

        if (isCommandKeyPressed.value) {
          // Add range to existing selection
          selectedPhotoIds.value = [...new Set([...selectedPhotoIds.value, ...range])];
        } else {
          // Replace selection with range
          selectedPhotoIds.value = range;
        }
      } else if (isCommandKeyPressed.value) {
        toggleSelectPhoto(photoId);
      } else {
        // Select only the clicked item when Command/Control is not pressed
        selectedPhotoIds.value = [photoId];
      }

      lastSelectedPhoto.value = photoId;
    }
  } else {
    showPhoto(photoId);
  }
};

const handleKeyDown = (event: KeyboardEvent) => {
  if (event.metaKey || event.ctrlKey) {
    isCommandKeyPressed.value = true;
  }
  if (event.shiftKey) {
    isShiftKeyPressed.value = true;
  }
};

const handleKeyUp = (event: KeyboardEvent) => {
  if (!event.metaKey && !event.ctrlKey) {
    isCommandKeyPressed.value = false;
  }
  if (!event.shiftKey) {
    isShiftKeyPressed.value = false;
  }
};

function handleContainerClick() {
  if (isSelecting.value) {
    toggleSelecting();
    selectedPhotoIds.value = [];
    lastSelectedPhoto.value = 0;
  }
}

onMounted(() => {
  window.addEventListener('keydown', handleKeyDown);
  window.addEventListener('keyup', handleKeyUp);
});

onUnmounted(() => {
  window.removeEventListener('keydown', handleKeyDown);
  window.removeEventListener('keyup', handleKeyUp);
});

function toggleSelectAllPhotos() {
  // if there is anything selected, deselect all
  if (selectedPhotoIds.value.length > 0) {
    selectedPhotoIds.value = [];
  } else {
    // select all the photos that are shown in the filtered list
    selectedPhotoIds.value = filteredPhotos.value.map((photo) => photo.id);
  }
}
function toggleSelectPhoto(photoId: number) {
  if (selectedPhotoIds.value.includes(photoId)) {
    const index = selectedPhotoIds.value.findIndex((x) => x === photoId);
    selectedPhotoIds.value.splice(index, 1);
    if (selectedPhotoIds.value.length === 0) {
      ratedReview.value = null;
    }
  } else if (filteredPhotos.value.map((x) => x.id).includes(photoId)) {
    selectedPhotoIds.value.push(photoId);
  }
}

function saveChangePhotos() {
  if (selectedPhotoIds.value.length > 0) {
    const photosToBeUpdated: Photo[] = [];
    selectedPhotoIds.value.forEach((photoId) => {
      const photo = photosData.value.find((x) => x.id === photoId);
      const photoOriginal = photosOriginal.find((x) => x.id === photoId);
      if (
        photoOriginal &&
        photo &&
        (photo.angle !== photoOriginal.angle || ratedReview.value !== photoOriginal.review_id)
      ) {
        photo.review_id = ratedReview.value;
        photosToBeUpdated.push(photo);
      }
    });
    saveReview(photosToBeUpdated);
    selectedPhotoIds.value = [];
  }
}

function cancelSelectPhotos() {
  isSelecting.value = false;
  selectedPhotoIds.value = [];
  ratedReview.value = null;
}

function saveReview(photos: Photo[]) {
  updatePhotosApi(
    album.value.id,
    photos.map((photo) => ({
      id: photo.id,
      angle: photo.angle,
      review_id: photo.review_id,
    })),
  )
    .then(() => {
      loadPhotos();
      loadReviews();
    })
    .catch((error) => {
      console.log(error);
    });
}

async function deletePhotos() {
  if (!isAlbumOwner.value) {
    return;
  }
  let message = '';
  if (selectedPhotoIds.value.length === 1) {
    const selectedPhoto = photos.value.find((x: Photo) => x.id === selectedPhotoIds.value[0]);
    message = `Delete '${selectedPhoto?.name}'?`;
  } else {
    message = `Delete ${selectedPhotoIds.value.length} photos?`;
  }
  if (confirm(message) === false) {
    return;
  }

  deletePhotosApi(album.value.id, selectedPhotoIds.value)
    .then(() => {
      selectedPhotoIds.value.forEach((photoId) => {
        removePhoto(photoId);
      });
    })
    .catch((error) => {
      console.log(error);
    });
}

function removePhoto(photoId: number) {
  const index = photosData.value.findIndex((photo: Photo) => photo.id === photoId);
  photosData.value.splice(index, 1);
}

function addPhoto(photo: Photo) {
  photosData.value.unshift(photo);
}

function formatDate(date: Date) {
  date = new Date(date);
  if (isNaN(date.getTime())) {
    return '';
  }
  return date.toISOString().split('T')[0];
}

const photos = computed(() => {
  return photosData.value;
});

const photosData = ref([<Photo>{}]);
onBeforeMount(() => {
  loadPhotos();
});

async function loadPhotos() {
  getPhotosApi(albumId.value)
    .then((response: AxiosResponse) => {
      photosData.value = response.data;
      photosOriginal = JSON.parse(JSON.stringify(photosData.value));
    })
    .catch((error) => {
      console.log(error);
    });
}

// filter
const filterMode = ref(1); // 1: blur, 2: hide
const filterModes = [
  { value: 1, name: 'blur' },
  { value: 2, name: 'hide' },
];

const isShowingResult = ref(false);
const ratedReview = ref<number | null>(null);
const filterReview = ref([
  { selected: true, value: 3, icon: 'check' },
  { selected: true, value: 2, icon: 'question' },
  { selected: true, value: 1, icon: 'xmark' },
  { selected: true, value: null, icon: 'exclamation' },
]); // Yes Maybe No
const selectedFilterIds = computed(() => {
  return filterReview.value.filter((x) => x.selected).map((x) => x.value);
});
function reviewPhotos(reviewId: number | null) {
  if (selectedPhotoIds.value.length === 0) {
    return;
  }

  if (ratedReview.value === reviewId) {
    ratedReview.value = null;
    return;
  }
  ratedReview.value = reviewId;
  saveReview(photosData.value);
}

const photosReviewsData = ref([<PhotoUserReview>{}]);
onBeforeMount(loadReviews);

async function loadReviews() {
  getReviewsApi(albumId.value)
    .then((response: AxiosResponse) => {
      photosReviewsData.value = response.data;
    })
    .catch((error) => {
      console.log(error);
    });
}

function numberOfPhotosWithReview(val: number | null) {
  if (!photosReviewsData.value || photosReviewsData.value.length === 0) {
    return 0;
  }

  // get all reviews for this album's photos with their average results and who reviews what
  interface ReviewResult {
    photo_id: number;
    review_id: number | null;
  }
  const photoIds = photosData.value.map((photo) => photo.id);
  var results: ReviewResult[] = [];
  photoIds.forEach((photoId) => {
    const photoReviews = getPhotoReviews(photoId);
    if (photoReviews.length === 0) {
      results.push({ photo_id: photoId, review_id: null });
    } else {
      const review_result = getOverallReview(photoId);
      results.push({ photo_id: photoId, review_id: review_result });
    }
  });

  return results.filter((x) => x.review_id === val).length;
}

function numberOfReviewsWithResult(photoId: number, val: number | null) {
  const reviews = getPhotoReviews(photoId);
  return reviews.filter((x) => x.review_id === val).length;
}

function getPhotoReviews(photoId: number) {
  return photosReviewsData.value.filter((x) => x.photo_id === photoId);
}

function getOverallReview(photoId: number) {
  const reviews = getPhotoReviews(photoId);
  const reviewIds = reviews.map((review) => review.review_id);
  // const userReview = reviews.find((review) => review.user_id === currentUserId.value);
  // // if user has not made a review, return null
  // if (!userReview || userReview.review_id === null) {
  //   return null;
  if (reviewIds.length === 0) {
    return null;
  } else if (reviewIds.every((value) => value === 1)) {
    return 1;
  } else if (reviewIds.every((value) => value === 3)) {
    return 3;
  } else {
    return 2;
  }
}

function getOverallIcon(photoId: number) {
  const reviewInFilter =
    filterReview.value.find((x) => x.value === getOverallReview(photoId)) || null;

  return reviewInFilter ? reviewInFilter.icon : 'exclamation';
}

const filteredPhotos = computed(() => {
  const result: Photo[] = [];
  photosData.value.forEach((photo) => {
    let overallReview = getOverallReview(photo.id);
    if (
      (selectedFilterIds.value.includes(null) && !overallReview) ||
      selectedFilterIds.value.includes(overallReview)
    ) {
      result.push(photo);
    }
  });
  return result;
});

// photo review
const isShowingPhoto = ref(false);
const photoShowing = ref<Photo>();

function showPhoto(photoId: Number) {
  photoShowing.value = photosData.value.find((x) => x.id === photoId);
  isShowingPhoto.value = true;
}
function updatePhoto(photo: Photo) {
  const index = photosData.value.findIndex((x) => x.id === photo.id);
  photosData.value[index] = photo;
}

function closeReviewPhoto() {
  isShowingPhoto.value = false;
  loadReviews();
}

// Rotate photos
var photosOriginal: Photo[] = [];

function rotatePhotos() {
  if (selectedPhotoIds.value.length === 0) {
    return;
  }
  selectedPhotoIds.value.forEach((photoId) => {
    const index = photosData.value.findIndex((x) => x.id === photoId);
    if (photosData.value[index].angle % 360 === 0) {
      photosData.value[index].angle = 90;
    } else {
      photosData.value[index].angle = photosData.value[index].angle + 90;
    }
  });
}

// style
function getPhotoClass(photo: Photo) {
  let result = '';
  if (!filteredPhotos.value.map((x) => x.id).includes(photo.id)) {
    result += ' opacity-10 saturate-0';
  } else if (isSelecting.value && selectedPhotoIds.value.includes(photo.id)) {
    result += ' opacity-50';
  }
  // if mode is contain, add class
  if (selectedDisplayFitMode.value === 2) {
    result += ' object-contain';
  } else {
    result += ' object-cover';
  }

  return result;
}

// Navigate
function goBackToAlbums() {
  router.go(-1);
  // router.push({ name: 'Albums' });
}
</script>

<style scoped>
@import '../../assets/css/panel.scss';

.btn-select {
  padding: 0.25rem 0.5rem;
  border: 0.5px solid var(--color-text-light-1);
  border-radius: 1rem;
  font-size: 0.75rem; /* 12px */
  color: white;
}
.container-icon-circle {
  position: absolute;
  top: 0;
  left: 0;
  display: flex;
  justify-content: center;
  align-items: center;
  width: 100%;
  height: 100%;
}

.icon-circle-check {
  opacity: 1;
  color: var(--color-primary);
  background-color: var(--color-text);
  border-radius: 50%;
}

.icon-circle-check-viewList {
  z-index: 3;
  opacity: 0;
  cursor: pointer;
}

.icon-circle-check-viewList:hover {
  opacity: 1;
  color: var(--slate-300);
}

.icon-result-overall {
  position: absolute;
  top: 0;
  right: 1px;
  display: flex;
  justify-content: center;
  align-items: center;
  width: 1rem;
  height: 1rem;
  border-radius: 50%;
  background-color: var(--color-menu-light);
  backdrop-filter: blur(2px);
}

.container-album-page {
  display: flex;
  flex-direction: column;
  width: 100%;
  height: 100vh;
}

.container-top-fixed {
  position: fixed;
  top: 0;
  left: 0;
  z-index: 2;
  width: 100%;
}

.header-album {
  display: flex;
  justify-content: space-between;
  padding: 2.5rem 1rem 0.5rem 1rem; /* pt-4 pb-2 px-4 */
  width: 100%;
}

.container-album-name {
  display: flex;
  padding: 0 1rem;
}

.container-back {
  display: flex;
  gap: 0.5rem; /* gap-2 */
  align-items: start;
  color: #8b5cf6; /* text-violet-500 */
  cursor: pointer;
}

.container-select-toggle-menu {
  display: flex;
  gap: 0.5rem; /* gap-2 */
  justify-content: flex-end;
}

.flex-center-center {
  display: flex;
  justify-content: center;
  align-items: center;
}

.container-filter {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin: 0 0 0.25rem 0.75rem;
  height: 2rem;
}

.container-date {
  display: flex;
  gap: 0.25rem;
  align-items: center;
  margin-top: 0.75rem;
  font-size: 0.75rem; /* text-xs */
  color: var(--color-text-light-1);
}

.container-buttons-filter {
  display: flex;
  margin-top: 0.5rem;
  background: var(--color-menu);
  color: var(--color-text-light-1);
  border-radius: 0.25rem;

  button {
    display: flex;
    justify-content: center;
    align-items: center;
    gap: 4px;
    padding: 0 1.75rem;
    width: 3.25rem;
    border-radius: 0;
    border-right: 1px solid var(--black-raven);

    &.selected {
      background-color: var(--color-primary);
      color: white;
    }
  }

  button:first-child {
    border-top-left-radius: 0.25rem;
    border-bottom-left-radius: 0.25rem;
  }

  button:last-child {
    border-top-right-radius: 0.25rem;
    border-bottom-right-radius: 0.25rem;
    border-right: none;
  }
}

.container-photo-reviews-all {
  position: absolute;
  bottom: 0;
  left: 0;
  display: grid;
  z-index: 2;
  grid-template-columns: repeat(3, 1fr);
  width: 100%;
}

.container-photo-reviews-all::after {
  content: '';
  position: absolute;
  inset: 0;
  z-index: -1;
  background: var(--color-menu-light);
  mask: linear-gradient(to bottom, transparent, black 35%);
  backdrop-filter: blur(2px);
}

.container-photo-review {
  display: flex;
  gap: 0.25rem;
  justify-content: center;
  align-items: center;
  z-index: 9;
  font-size: 11pt;
  color: var(--color-text-light-2);

  svg {
    font-size: 0.625rem;
  }
  svg.fa-xmark {
    font-size: 0.75rem;
  }
  svg.fa-question {
    margin-top: -2px;
  }
}

.container-photos-icon {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(5rem, 1fr));
  gap: 0.125rem; /* gap-0.5 */
  width: 100%;
  padding-bottom: 3.5rem;
  color: lighten(var(--color-primary), 50%);
}

.photo-container.upload {
  display: flex;
  background: var(--color-menu);
  cursor: pointer;
}

table {
  width: 100vw;
  border-collapse: collapse;
}

thead tr {
  height: 2.5rem;
  align-self: center;
  border-bottom: 1px solid var(--color-border);
  background-color: var(--color-menu-light);
  color: var(--color-text-light-1);

  th {
    vertical-align: middle;
    padding: 0.5rem;
    font-size: 0.75rem;
    font-weight: 500;
    text-align: start;
  }
}

tbody tr:nth-child(odd) {
  background-color: var(--color-menu);
}

.td-reviews {
  width: 2rem;
  height: 100%;
  vertical-align: middle;
  padding-right: 0.75rem;
}

.td-review {
  display: flex;
  justify-content: space-around;
  width: 100%;
  height: 100%;
  font-size: 11pt;
  color: var(--color-text-light-2);
}

/* Context menu */
#context-menu {
  position: fixed;
  top: 4.5rem;
  right: 0;
  z-index: 10;
  width: 12rem;
  opacity: 0;
  visibility: hidden;
  transition: opacity 0.32s cubic-bezier(0.4, 0, 0.6, 1);
  /* border-radius: var(--rounded); */
  border-width: 1px;
  box-shadow:
    0 10px 15px -3px rgb(0 0 0 / 0.1),
    0 4px 6px -4px rgb(0 0 0 / 0.1);
}

.container-bottom {
  position: fixed;
  bottom: 0;
  left: 0;
  display: flex;
  justify-content: space-between;
  width: 100%;
  height: 3.5rem;
  padding: 1rem;
}

#context-menu.show {
  visibility: visible;
  opacity: 1;
}

.container-context-menu {
  display: grid;
  grid-template-columns: 1fr 4fr 1fr;
  align-items: center;
  padding: 0.5rem;
  color: var(--color-text-light-1);
  border-style: solid;
  border-color: var(--black-raven);
  cursor: pointer;
}

.container-context-menu:hover {
  color: var(--color-text);
  background-color: var(--black-piano);
}

.container-context-border {
  border-bottom-width: 0.125rem;
}

@media (min-width: 670px) {
  table {
    width: 60vw;
    /* max-width: 60rem; */
  }

  .container-filter {
    margin-right: 0.75rem;
    .container-buttons-filter button {
      padding: 0.125rem 2.5rem;
      width: 3.25rem;
    }
  }
}

@media (min-width: 780px) {
  .container-photos-icon {
    grid-template-columns: repeat(auto-fill, minmax(8rem, 1fr));
  }
}
</style>
