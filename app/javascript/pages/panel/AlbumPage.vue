<template>
  <!-- <div class="absolute top-0 left-0 w-full h-full"> -->
  <div class="w-full h-full">
    <div
      class="relative w-full"
      :class="{ 'opacity-10 saturate-0': isUploadingPhoto || isShowingPhoto }"
    >
      <div class="flex justify-between mx-8 mt-4">
        <div class="label-text">
          {{ album.name }}
        </div>

        <div class="flex">
          <font-awesome-icon
            icon="fa-solid fa-ellipsis"
            class="m-2 text-xl text-slate-400"
            @click.prevent="toggleContextMenu"
          />
        </div>
      </div>
      <!-- Filter -->
      <div class="w-100 h-8 ml-3 mt-3 mb-1">
        <div v-if="selectedPhotoIds.length === 0" class="flex justify-between items-center h-full">
          <div class="flex items-center">
            <font-awesome-icon icon="fa-solid fa-calendar-days" class="mr-2 self-center" />
            <div class="text-slate-400">
              {{ formatDate(album.expiry_date) }}
            </div>
          </div>
          <div
            class="flex w-42 border border-solid border-slate-600 divide-x divide-solid divide-slate-600 text-slate-600 rounded-sm"
          >
            <div class="btn-filter w-12 px-2 py-0.5">
              <font-awesome-icon
                v-if="!isShowingResult"
                icon="fa-solid fa-eye"
                @click="isShowingResult = !isShowingResult"
              />
              <font-awesome-icon
                v-else
                icon="fa-solid fa-eye-slash"
                @click="isShowingResult = !isShowingResult"
              />
            </div>
            <div v-for="opt in filterReview" :key="opt.icon">
              <div
                class="btn-filter w-14 px-2 py-0.5"
                :class="{ 'btn-filter-selected': opt.selected }"
                @click="opt.selected = !opt.selected"
              >
                <font-awesome-icon :icon="`fa-solid fa-${opt.icon}`" />
                <div>({{ numberOfPhotosWithReview(opt.value) }})</div>
              </div>
            </div>
          </div>
        </div>
        <div v-else class="flex justify-between items-center h-full mr-3">
          <div class="flex justify-between items-center h-full w-20">
            <font-awesome-icon
              icon="fa-solid fa-xmark"
              class="p-2 cursor-pointer"
              @click.prevent="cancelSelectPhotos"
            />
            <div>{{ selectedPhotoIds.length }}</div>
          </div>
          <div class="flex justify-between w-20">
            <font-awesome-icon icon="fa-solid fa-share-from-square" />
            <font-awesome-icon
              v-if="isAlbumOwner"
              icon="fa-solid fa-trash-can"
              class="mr-4"
              @click.prevent="deletePhotos"
            />
          </div>
        </div>
      </div>

      <!-- Photos -->
      <!-- Icon view -->
      <div v-if="selectedAlbumViewIndex !== 1" class="grid grid-cols-4 gap-0.5 w-full">
        <div class="photo-container flex" @click.prevent="isUploadingPhoto = true">
          <font-awesome-icon icon="fa-solid fa-plus" class="m-auto text-violet-600" />
        </div>
        <div v-for="(photo, i) in photos" :key="i" class="relative cursor-pointer">
          <div
            class="photo-container flex justify-center cursor-pointer"
            @click.prevent="showPhoto(photo.id)"
          >
            <AdvancedImage
              :id="photo.image"
              :cldImg="getCloudinaryImage(photo.image, photo.angle)"
              class="object-cover"
              :class="getPhotoClass(photo)"
            />
          </div>
          <font-awesome-icon
            icon="fa-solid fa-circle-check"
            class="icon-circle-check"
            :class="{ 'icon-circle-check-selected': selectedPhotoIds.includes(photo.id) }"
            @click.prevent="toggleSelectPhoto(photo.id)"
          />
          <div v-if="isShowingResult" class="absolute top-0 right-1 text-violet-600">
            <font-awesome-icon :icon="`fa-solid fa-${getOverallIcon(photo.id)}`" />
          </div>
          <div v-if="isShowingResult" class="container-photo-reviews-all">
            <div v-for="review in filterReview.slice(0, 3)" :key="review.icon">
              <div class="container-photo-review bg-black bg-opacity-50">
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
      <div v-else class="items-center">
        <table class="w-full">
          <tbody>
            <tr v-for="(photo, i) in photos" :key="i" class="w-full h-11 cursor-pointer border-b">
              <td class="w-11 h-full">
                <div class="flex justify-center align-middle w-full h-full">
                  <font-awesome-icon
                    icon="fa-solid fa-circle-check"
                    class="icon-circle-check-viewList"
                    :class="{ 'icon-circle-check-selected': selectedPhotoIds.includes(photo.id) }"
                    @click.prevent="toggleSelectPhoto(photo.id)"
                  />
                </div>
              </td>
              <td class="w-11 h-11" @click.prevent="showPhoto(photo.id)">
                <AdvancedImage
                  :id="photo.image"
                  :cldImg="getCloudinaryImage(photo.image, photo.angle)"
                  class="object-cover h-full"
                  :class="getPhotoClass(photo)"
                />
              </td>
              <td @click.prevent="showPhoto(photo.id)">
                <div>{{ photo.name }}</div>
                <!-- TODO: Show original size -->
                <div class="text-xs text-slate-400"></div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- ContextMenu -->
    <div
      v-if="contextMenuIsOpen"
      :album="album"
      id="context-menu"
      @click.prevent="toggleContextMenu"
      @toogle-list-view="selectAlbumViewOption"
    >
      <div
        v-if="isAlbumOwner"
        class="container-context-menu container-context-border"
        @click.prevent="startEditingAlbum"
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
      <div class="container-context-menu" :class="{ 'container-context-border': isAlbumOwner }">
        <div></div>
        <div>Share</div>
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

    <AlbumEdit
      v-if="isEditing"
      :albumId="album.id"
      :albumName="album.name"
      :albumExpiryDate="album.expiry_date"
      :albumInvitees="album.invitees"
      class="absolute top-[-200px] left-0 w-full z-10"
      @close-edit-album="isEditing = false"
      @edited-album="
        (editedAlbum, invitees_were_removed) => updateAlbum(editedAlbum, invitees_were_removed)
      "
    />

    <PhotoUpload
      v-if="isUploadingPhoto"
      :album="album"
      class="absolute top-0 left-0 w-full h-full z-10"
      @uploaded-new-photo="(photos) => addPhoto(photos)"
      @close-upload-photo="isUploadingPhoto = false"
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
import { Cloudinary } from '@cloudinary/url-gen';
import { AdvancedImage } from '@cloudinary/vue';
import { byAngle } from '@cloudinary/url-gen/actions/rotate';
import type { AxiosResponse } from 'axios';
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
  last_upload_batch: number;
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
  const result = String((user.data as { id: number; type: string; attributes: {} }).id);
  return parseInt(result);
});

const album = ref<Album>({
  id: -1,
  name: '',
  user_id: 0,
  invitees: [],
  last_upload_batch: 0,
  expiry_date: new Date(),
});

onBeforeMount(async () => {
  showAlbumApi(Number(route.params.id))
    .then((response: AxiosResponse) => {
      album.value = response.data;
      // album.value.expiry_date = new Date(response.data.expiry_date);
      // TODO: improve, not bug - fix album date format to be YYYY-MM-DD when reloading page
    })
    .catch((error) => {
      console.log(error);
    });
});

const cld = new Cloudinary({
  cloud: {
    cloudName: 'djnvimner',
  },
});
const getCloudinaryImage = (publicId: String, angle: number) => {
  return cld.image(`photo_review/${publicId}`).rotate(byAngle(angle));
};

const albumId = computed(() => {
  const id = route.params.id;
  return typeof id === 'string' ? parseInt(id) : parseInt(id[0]);
});

const isUploadingPhoto = ref(false);

// Edit album
const isEditing = ref(false);
function startEditingAlbum() {
  isEditing.value = true;
}

function updateAlbum(editedAlbum: Album, inviteesWereRemoved: boolean) {
  if (inviteesWereRemoved) {
    loadReviews();
  }
  album.value = editedAlbum;
  isEditing.value = false;
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
function toggleSelectPhoto(photoId: number) {
  if (selectedPhotoIds.value.includes(photoId)) {
    const index = selectedPhotoIds.value.findIndex((x) => x === photoId);
    selectedPhotoIds.value.splice(index, 1);
  } else {
    selectedPhotoIds.value.push(photoId);
  }
}

function cancelSelectPhotos() {
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

  deletePhotosApi(selectedPhotoIds.value)
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

function addPhoto(photos: [Photo]) {
  photos.forEach((photo) => {
    // photosData.value.unshift(photo);
    photosData.value.push(photo);
  });
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
  { selected: false, value: 3, icon: 'check' },
  { selected: false, value: 2, icon: 'question' },
  { selected: false, value: 1, icon: 'xmark' },
  { selected: false, value: null, icon: 'exclamation' },
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
  const userReview = reviews.find((review) => review.user_id === currentUserId.value);
  // if user has not made a review, return null
  if (!userReview || userReview.review_id === null) {
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

// style
function getPhotoClass(photo: Photo) {
  let result = '';
  if (selectedFilterIds.value.length > 0) {
    // if photo has no review, and if filter has null,
    // or if photo overall review matches selected filter, show photo
    let overallReview = getOverallReview(photo.id);
    if (!overallReview) {
      const filterNull = filterReview.value.find((x) => x.value === null);
      if (filterNull && !filterNull.selected) {
        return 'opacity-10 saturate-0';
      }
    } else {
      if (!selectedFilterIds.value.includes(overallReview)) {
        result += ' opacity-10 saturate-0';
      }
    }
  }
  return result;
}
</script>

<style scoped>
/* @import '../assets/main.css'; */

.btn-filter {
  display: flex;
  justify-content: space-around;
  align-items: center;
  border-radius: 0.25rem;
  border-width: 1px;
  cursor: pointer;
}

.btn-filter-selected {
  background-color: white;
  color: var(--color-primary);
}

.icon-circle-check {
  position: absolute;
  top: 0.25rem;
  left: 0.25rem;
}

.icon-circle-check,
.icon-circle-check-viewList {
  z-index: 50;
  opacity: 0;
}

.icon-circle-check:hover,
.icon-circle-check-viewList:hover {
  opacity: 1;
  color: var(--slate-300);
}

.icon-circle-check-selected,
.icon-circle-check-selected:hover {
  opacity: 1;
  color: var(--color-primary);
  background-color: white;
  border-radius: 50%;
}

.container-photo-reviews-all {
  position: absolute;
  bottom: 0;
  left: 0;
  width: 100%;
  z-index: 10;
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  /* backdrop-filter: blur(4px);
  -webkit-backdrop-filter: blur(4px);
  background-blend-mode: overlay;
  mix-blend-mode: lighten; */
}

.container-photo-review {
  display: flex;
  gap: 0.25rem;
  justify-content: center;
  align-items: center;
}

/* Context menu */
#context-menu {
  position: absolute;
  top: 4rem;
  right: 0;
  width: 12rem;
  z-index: 10;
  background-color: white;
  border-radius: 0.25rem;
  border-width: 1px;
}

.container-context-menu {
  display: grid;
  grid-template-columns: 1fr 4fr 1fr;
  align-items: center;
  padding: 0.5rem;
  border-style: solid;
  border-color: var(--slate-200);
  cursor: pointer;
  color: var(--slate-800);
}

.container-context-menu:hover {
  background-color: var(--slate-200);
}

.container-context-border {
  border-bottom-width: 0.5rem;
}

.container-context-border-sub {
  border-bottom-width: 0.125rem;
}
</style>
