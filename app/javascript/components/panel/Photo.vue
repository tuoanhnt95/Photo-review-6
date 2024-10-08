<template>
  <div class="container-photo-page">
    <!-- Top bar -->
    <div class="top-bar">
      <!-- Back to Album -->
      <div class="ml-5 btn-small" @click="backToAlbum">
        <font-awesome-icon icon="fa-solid fa-chevron-left" class="btn-small-icon" />
      </div>
      <!-- Vertical side-by-side -->
      <div class="mr-5 btn-small" @click="splitScreen(1)">
        <font-awesome-icon icon="fa-solid fa-table-columns" class="btn-small-icon" />
      </div>
    </div>

    <!-- Photo -->
    <div class="container-photos">
      <div
        v-for="(display, i) in displayPhotos"
        :key="display?.id"
        class="container-photo"
        :class="{
          'w-1/2 justify-end': splitScreenOption > 0 && i === 0,
          'w-1/2 justify-start': splitScreenOption > 0 && i === 1,
          'w-full justify-center': !splitScreenOption,
        }"
      >
        <!-- Rotate photo -->
        <div
          class="btn-rotate btn-small"
          :class="{
            'right-5': !splitScreenOption || (splitScreenOption > 0 && i === 1),
            'left-5': splitScreenOption > 0 && i === 0,
          }"
          @click="rotatePhoto(i)"
        >
          <font-awesome-icon icon="fa-solid fa-rotate-left" class="btn-small-icon" />
        </div>
        <AdvancedImage
          v-if="display"
          :cld-img="getCloudinaryImage(display.image, display.angle)"
          place-holder="predominant-color"
          class="photo"
        />
        <!-- Review -->
        <div class="absolute bottom-10 z-10 self-end flex w-full justify-center">
          <div
            v-for="opt in reviewDisplayOptions"
            :key="opt.value"
            class="btn-review"
            :class="{ 'btn-selected': reviewResult(i) === opt.value }"
          >
            <font-awesome-icon
              v-model="photo.review_id"
              :icon="`fa-solid fa-${opt.icon}`"
              @click="reviewPhoto(i, opt.value)"
            />
          </div>
        </div>
      </div>
    </div>

    <!-- Thumbnails -->
    <div class="thumbnails">
      <div
        v-for="(pho, i) in photos"
        :key="pho.id"
        class="container-thumbnail"
        :class="[currentIndex === i ? 'current-photo' : '']"
        @click="navigatePhoto(i - currentIndex)"
      >
        <AdvancedImage
          :cld-img="getCloudinaryImage(pho.image, pho.angle)"
          place-holder="predominant-color"
          class="thumbnail"
        />
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, type PropType, watch } from 'vue';
import { AdvancedImage } from '@cloudinary/vue';
import { getCloudinaryImage } from '@/services/cloudinary.service';
import { updateReviewApi } from '@/apis/panel.api';

const emit = defineEmits(['reviewed-photo', 'close-review-photo', 'navigate-photo']);

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

const props = defineProps({
  photo: {
    type: Object as PropType<Photo>,
    required: true,
  },
  photos: {
    type: Array as PropType<Photo[]>,
    required: true,
  },
});
const currentIndex = computed(() => {
  return photos.value.findIndex((pho: Photo) => pho.id === props.photo.id);
});

// if photo is the last photo => display it and the one before
const displayPhotos = computed(() => {
  if (splitScreenOption.value === 1) {
    if (currentIndex.value === photos.value.length - 1) {
      return [previousPhoto.value, photo.value];
    }
    return [photo.value, nextPhoto.value];
  } else {
    return [photo.value];
  }
});

const nextPhoto = computed(() => {
  // if this is the last photo, then nothing
  return currentIndex.value === photos.value.length - 1
    ? null
    : photos.value[currentIndex.value + 1];
});
const previousPhoto = computed(() => {
  // if this is the first photo, then nothing
  return currentIndex.value === 0 ? null : photos.value[currentIndex.value - 1];
});

const photoOriginal = props.photo;
const photo = ref(props.photo);
const photos = ref(props.photos);

// Review
function reviewResult(index: number) {
  const reviewedPhoto = displayPhotos.value?.[index];
  return reviewedPhoto ? reviewedPhoto.review_id : null;
}

function reviewPhoto(index: number, value: number) {
  if (value) {
    const reviewedPhoto = displayPhotos.value?.[index];
    if (reviewedPhoto) {
      reviewedPhoto.review_id = value;
    }
    if (splitScreenOption.value === 0) {
      navigatePhoto(1);
    }
  }
}

function displayedPhoto(index: number) {
  return displayPhotos.value?.[index];
}

function saveReview(index = 0) {
  const displayedPhoto = displayPhotos.value?.[index];

  if (!displayedPhoto) return;

  if (displayedPhoto?.review_id || photoOriginal.angle !== displayedPhoto.angle) {
    updateReviewApi(
      displayedPhoto.album_id,
      displayedPhoto.id,
      displayedPhoto.review_id,
      displayedPhoto.angle,
    )
      .then(() => {
        rotateCounters.value[index] = 0;
        return;
      })
      .catch((error) => {
        console.log(error);
      });
  }
}

// navigate
function navigatePhoto(value: number) {
  if (!canNavigate(value)) return;

  saveReview();

  if (
    (currentIndex.value === 0 && value === -1) ||
    (currentIndex.value === photos.value.length - 1 && value === 1)
  ) {
    return;
  } else {
    const photoToNavigate = photos.value[currentIndex.value + value];
    emit('navigate-photo', photoToNavigate.id);
  }
}

const isFirstPhoto = computed(() => {
  return currentIndex.value === 0;
});

const isLastPhoto = computed(() => {
  return currentIndex.value === photos.value.length - 1;
});

// back to album
function backToAlbum() {
  saveReview();
  emit('close-review-photo');
}

// split screen
const splitScreenOption = ref(0); // 0: no split, 1: horizontal, 2: vertical
function splitScreen(option: number) {
  if (splitScreenOption.value === option) {
    splitScreenOption.value = 0;
  } else {
    splitScreenOption.value = option;
  }
}

// value: 1 => next, -1 => previous
function canNavigate(value: number) {
  // if move back, first photo or split screen and photo after first -> cannot navigate
  if (value === -1) {
    if (isFirstPhoto.value) return false;
  }
  // if move next, last photo or split screen and photo before last -> cannot navigate
  if (value === 1) {
    if (
      isLastPhoto.value ||
      (splitScreenOption.value === 1 && currentIndex.value === photos.value.length - 2)
    ) {
      return false;
    }
  }
  return true;
}

// rotate photo
const rotateCounters = ref([0, 0]);
// const photoOriginalAngles = computed(() => {
//   if (!displayPhotos.value) return [];
//   // get the id of the photos in the displayPhotos
//   const ids = displayPhotos.value.map((pho) => pho?.id);
//   return props.photos.filter((pho) => ids.includes(pho.id)).map((pho) => pho?.angle || 0);
//   // return displayPhotos.value?.map(pho => pho?.angle || 0);
// });

function rotatePhoto(index = 0) {
  const displayPhoto = displayedPhoto(index);
  if (!displayPhoto) return;

  if (rotateCounters.value[index] === 3) {
    rotateCounters.value[index] = 0;
    displayPhoto.angle = photoOriginal.angle;
  } else {
    rotateCounters.value[index]++;
    displayPhoto.angle = photoOriginal.angle - rotateCounters.value[index] * 90;
  }
}

watch(
  () => props.photo,
  (newVal) => {
    photo.value = newVal;
  },
);

// display v-for
const reviewDisplayOptions = [
  { value: 1, icon: 'xmark' },
  { value: 2, icon: 'question' },
  { value: 3, icon: 'check' },
];
</script>

<style scoped>
/* @import '../assets/main.css'; */

/* Navigation */
.btn-navigate-photo {
  font-size: 40px;
}

/* Button */
.btn-review {
  display: flex;
  justify-content: center;
  align-items: center;
  margin: 5px;
  width: 5rem;
  height: 5rem;
  border-radius: 50%;
  font-size: 40px;
  background-color: transparent;
  cursor: pointer;
}
.btn-review:hover {
  background-color: rgb(203 213 225);
  color: rgb(31 41 55);
}

.btn-selected {
  background-color: rgb(71 85 105 / 50%);
}

.btn-small {
  margin-top: 1.25rem;
  padding: 0.5rem;
  width: fit-content;
  height: fit-content;
  color: rgb(148 163 184);
  cursor: pointer;
}

.btn-small-icon {
  font-size: 1.125rem;
  line-height: 1.75rem;
  opacity: 0.3;
}

.btn-small-icon:hover {
  opacity: 1;
}

/* Container */
.container-photo-page {
  display: flex;
  flex-direction: column;
  height: 100vh;
}

.top-bar {
  display: flex;
  justify-content: space-between;
  height: 4rem;
}

.container-photos {
  position: relative;
  flex-grow: 1;
  display: flex;
  justify-content: center;
  overflow: hidden;
}

.container-photo {
  position: relative;
  display: flex;
  align-items: center;
  height: auto;

  .photo {
    max-width: 100%;
    max-height: 100%;
    object-fit: contain;
  }
}

.btn-rotate {
  position: absolute;
  top: 0;
  z-index: auto;
}

.thumbnails {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  height: 8rem;
  overflow-x: scroll;

  .container-thumbnail {
    width: 3rem;
    height: 3rem;
    cursor: pointer;
    flex-shrink: 0;

    .thumbnail {
      width: 100%;
      height: 100%;
      object-fit: cover;
    }
  }

  .current-photo {
    border: 4px solid var(--color-menu);
  }
}
</style>
