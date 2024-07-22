<template>
  <div class="w-full h-full">
    <div class="header-album">
      <slot v-if="!isSelecting">
        <a class="container-back" @click="goBackToAlbums">
          <font-awesome-icon icon="fa-solid fa-chevron-left" />
          <p style="margin-top: -4px">Albums</p>
        </a>

        <!-- empty placeholder to keep grid layout -->
        <p v-if="isLargeScreen"></p>

        <div class="container-select-toggle-menu w-24">
          <button type="button" class="btn-select btn-menu" @click="toggleSelecting">Select</button>
          <ButtonMenu @toggle-menu="toggleContextMenu" />
        </div>
      </slot>
      <slot v-else>
        <div class="w-24">
          <button type="button" class="btn-select btn-menu" @click.prevent="toggleSelectAllPhotos">
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
          <button
            v-if="isLargeScreen"
            type="button"
            class="btn-select btn-menu"
            :class="{ unselectable: selectedPhotoIds.length === 0 }"
            @click.prevent=""
          >
            <font-awesome-icon icon="fa-solid fa-share-from-square" />
          </button>
          <button
            v-if="isLargeScreen"
            type="button"
            class="btn-select btn-menu"
            :class="{ unselectable: !isAlbumOwner || selectedPhotoIds.length === 0 }"
            @click.prevent="deletePhotos"
          >
            <font-awesome-icon icon="fa-solid fa-trash-can" />
          </button>
          <button type="button" class="btn-select btn-menu" @click.prevent="cancelSelectPhotos">
            Cancel
          </button>
        </div>
      </slot>
    </div>

    <div class="relative w-full">
      <div class="flex justify-between mx-8">
        <div class="label-text md">
          {{ album.name }}
        </div>
      </div>
      <!-- Filter -->
      <div class="container-filter">
        <div class="flex justify-between items-center h-full">
          <div class="flex gap-1 items-center text-xs text-slate-400">
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
          <div
            class="flex w-42 border border-solid border-slate-600 divide-x divide-solid divide-slate-600 text-slate-600 rounded-sm"
          >
            <div v-for="opt in filterReview" :key="opt.icon">
              <button
                class="btn-filter"
                :class="{ 'btn-filter-selected': opt.selected }"
                @click="opt.selected = !opt.selected"
              >
                <font-awesome-icon :icon="`fa-solid fa-${opt.icon}`" />
                <div>({{ numberOfPhotosWithReview(opt.value) }})</div>
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Photos -->
      <!-- Icon view -->
      <div v-if="selectedAlbumViewIndex !== 1" class="container-photos-icon">
        <div class="photo-container flex bg-menu" @click.prevent="isUploadingPhoto = true">
          <font-awesome-icon icon="fa-solid fa-plus" class="m-auto text-violet-600" />
        </div>
        <div
          v-for="(photo, i) in photos"
          :key="i"
          class="relative"
          @click.prevent="clickPhoto(photo.id)"
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
          <div v-if="isShowingResult" class="icon-result-overall">
            <font-awesome-icon :icon="`fa-solid fa-${getOverallIcon(photo.id)}`" />
          </div>
          <div v-if="isShowingResult" class="container-photo-reviews-all">
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
                      @click="isShowingResult = !isShowingResult"
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
                @click.prevent="clickPhoto(photo.id)"
              >
                <div class="flex justify-center w-full h-full">
                  <font-awesome-icon
                    v-if="selectedPhotoIds.includes(photo.id)"
                    icon="fa-solid fa-circle-check"
                    class="self-center icon-circle-check"
                  />
                </div>
              </td>
              <td class="w-11 h-11 cursor-pointer" @click.prevent="showPhoto(photo.id)">
                <AdvancedImage
                  :id="photo.image"
                  :cldImg="getCloudinaryImage(photo.image, photo.angle)"
                  class="w-11 h-11"
                  :class="getPhotoClass(photo)"
                />
              </td>
              <td
                class="w-56 h-full align-middle text-wrap cursor-pointer"
                @click.prevent="showPhoto(photo.id)"
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
          @click.prevent=""
        >
          <font-awesome-icon icon="fa-solid fa-share-from-square" />
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
          @click.prevent="deletePhotos"
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
      @click.prevent="toggleContextMenu"
      @toogle-list-view="selectAlbumViewOption"
    >
      <div
        v-if="isAlbumOwner"
        class="container-context-menu container-context-border"
        @click.prevent="action = 'edit'"
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
          @click.prevent="selectAlbumViewOption(i)"
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
          @click.prevent="selectedDisplayFitMode = mode.value"
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
        @click="isShowingResult = !isShowingResult"
      >
        <font-awesome-icon :class="{ 'opacity-0': !isShowingResult }" icon="fa-solid fa-check" />
        <div>Show votes</div>
        <font-awesome-icon icon="fa-solid fa-eye" class="self-center mr-2" />
      </div>
      <div
        class="container-context-menu"
        :class="{ 'container-context-border': isAlbumOwner }"
        @click.prevent="action = 'share'"
      >
        <div></div>
        <div>Share album</div>
        <font-awesome-icon icon="fa-solid fa-user-plus" class="self-center mr-2" />
      </div>
      <div
        v-if="isAlbumOwner"
        class="container-context-menu"
        @click.prevent="deleteAlbum(album.name, album.id)"
      >
        <div></div>
        <div>Delete</div>
        <font-awesome-icon icon="fa-solid fa-trash-can" class="self-center mr-2" />
      </div>
    </div>
    <div class="overlay" :class="{ active: contextMenuIsOpen }" @click="toggleContextMenu"></div>

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
      :photos="photos"
      class="absolute top-0 left-0 w-full z-50"
      @reviewed-photo="(photo: Photo) => updatePhoto(photo)"
      @navigate-photo="(photoId: Number) => showPhoto(photoId)"
      @close-review-photo="closeReviewPhoto"
    />
  </div>
</template>

<script setup lang="ts">
import { computed, onBeforeMount, ref } from 'vue';
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
  review_results: number | null;
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
  console.log('closeUploadPhoto');
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
const areAllFilteredPhotosSelected = computed(() => {
  return selectedPhotoIds.value.length === photosData.value.length;
});
function toggleSelectAllPhotos() {
  // if there is anything selected, deselect all
  if (selectedPhotoIds.value.length > 0) {
    selectedPhotoIds.value = [];
  } else {
    // select all the photos that are shown in the filtered list
    console.log('filteredPhotos.value', filteredPhotos.value);
    selectedPhotoIds.value = filteredPhotos.value.map((photo) => photo.id);
  }
}
function toggleSelectPhoto(photoId: number) {
  if (selectedPhotoIds.value.includes(photoId)) {
    const index = selectedPhotoIds.value.findIndex((x) => x === photoId);
    selectedPhotoIds.value.splice(index, 1);
  } else if (filteredPhotos.value.map((x) => x.id).includes(photoId)) {
    selectedPhotoIds.value.push(photoId);
  }
}

function cancelSelectPhotos() {
  isSelecting.value = false;
  selectedPhotoIds.value = [];
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
onBeforeMount(async () => {
  getPhotosApi(albumId.value)
    .then((response: AxiosResponse) => {
      photosData.value = response.data;
    })
    .catch((error) => {
      console.log(error);
    });
});

// filter
const filterMode = ref(1); // 1: blur, 2: hide
const filterModes = [
  { value: 1, name: 'blur' },
  { value: 2, name: 'hide' },
];

const isShowingResult = ref(false);

const filterReview = ref([
  { selected: true, value: 3, icon: 'check' },
  { selected: true, value: 2, icon: 'question' },
  { selected: true, value: 1, icon: 'xmark' },
  { selected: true, value: null, icon: 'exclamation' },
]); // Yes Maybe No
const selectedFilterIds = computed(() => {
  return filterReview.value.filter((x) => x.selected).map((x) => x.value);
});

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
    review_result: number | null;
  }
  const photoIds = photosData.value.map((photo) => photo.id);
  var results: ReviewResult[] = [];
  photoIds.forEach((photoId) => {
    const photoReviews = getPhotoReviews(photoId);
    if (photoReviews.length === 0) {
      results.push({ photo_id: photoId, review_result: null });
    } else {
      const review_result = getOverallReview(photoId);
      results.push({ photo_id: photoId, review_result: review_result });
    }
  });

  return results.filter((x) => x.review_result === val).length;
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

function clickPhoto(photoId: number) {
  if (isSelecting.value) {
    toggleSelectPhoto(photoId);
  } else {
    showPhoto(photoId);
  }
}

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

.btn-filter {
  display: flex;
  justify-content: space-around;
  align-items: center;
  width: 3.25rem;
  padding: 0.5rem 0.125rem;
  border-radius: 0.25rem;
}

.btn-filter-selected {
  background-color: white;
  color: var(--color-primary);
}

.btn-select {
  padding: 0.25rem 0.5rem;
  border: 0.5px solid var(--color-text-light-1);
  border-radius: 1rem;
  font-size: 0.75rem; /* 12px */
  line-height: 1rem; /* 16px */
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

.header-album {
  display: flex;
  justify-content: space-between;
  margin-left: 1rem; /* mx-4 */
  margin-right: 1rem;
  padding-top: 2.5rem; /* pt-4 */
  padding-bottom: 0.5rem;
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
  height: 2rem;
  margin: 0.75rem 0 0.25rem 0.75rem;
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
  gap: 0.125rem; /* gap-0.5 */
  width: 100%;
  grid-template-columns: repeat(auto-fill, minmax(5rem, 1fr));
  color: lighten(var(--color-primary), 50%);
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
  position: absolute;
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
}

@media (min-width: 780px) {
  .container-photos-icon {
    grid-template-columns: repeat(auto-fill, minmax(8rem, 1fr));
  }
}
</style>
