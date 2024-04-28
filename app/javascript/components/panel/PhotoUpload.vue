<template>
  <div class="flex justify-center" style="align-items: center">
    <div class="absolute px-6 pt-10 pb-8 bg-white dark:bg-slate-800 border rounded">
      <div class="mb-2 text-lg">Upload photos</div>

      <!-- Upload file -->
      <div class="flex justify-center mb-3">
        <input
          type="file"
          :accept="validFileExtensionsAndMimeTypesString"
          multiple
          @change="onChangeUploadPhoto($event)"
        />
      </div>

      <div v-if="hasInvalidFile" class="text-xs">
        <span class="underline text-red-500" @click="toggleInvalidList">
          Include invalid file format!
        </span>
        <div v-if="showInvalidFileList" class="mt-2">
          <span> VALID: </span>
          <div class="inline-block m-1">
            {{ validFileExtensionsString }}
          </div>
        </div>
      </div>

      <div class="flex place-content-between w-full mt-2">
        <div>Upload size:</div>
        <!-- Upload quality option -->
        <select v-model="photoUploadOption" class="text-slate-800">
          <option value="1">1080x720</option>
          <option value="2">1920x1080</option>
          <option value="3">1920x1350</option>
          <option value="4">2100x1600</option>
          <option value="5">2400x1600</option>
          <option value="6">6000x4000</option>
        </select>
      </div>

      <div>
        <button
          class="w-full mt-4 py-3 text-slate-200 bg-violet-600 rounded text-xl font-bold"
          :class="[canUpload ? 'cursor-pointer' : 'opacity-30 cursor-not-allowed']"
          @click="uploadPhoto"
        >
          Upload
        </button>
      </div>

      <!-- Upload progress -->
      <div v-if="canUpload" class="mt-2">
        <div
          class="flex justify-center bg-gray-200 text-slate-600 cursor-pointer"
          @click="toggleUploads"
        >
          <font-awesome-icon icon="fa-solid fa-grip-lines" />
        </div>
        <div v-if="isExpanded" class="border w-full max-h-40 overflow-auto">
          <div v-for="upload in uploads" :key="upload.name" class="px-2">
            <div class="flex justify-between mb-1">
              <div>{{ upload.name }}</div>
              <div>
                <font-awesome-icon
                  icon="fa-solid fa-x"
                  class="text-slate-400 cursor-pointer"
                  @click="cancelUpload()"
                />
              </div>
            </div>
            <div class="mb-4 h-1 rounded bg-gray-200">
              <div
                class="h-1 animate-pulse rounded bg-violet-400"
                :style="`width: ${upload.progress}%`"
              ></div>
            </div>
          </div>
        </div>
      </div>

      <!-- Close Upload menu -->
      <font-awesome-icon
        icon="fa-solid fa-x"
        class="absolute top-4 right-4 text-slate-400"
        @click="closeUploadPhoto()"
      />
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, type PropType, watch, computed } from 'vue';
// import axios from 'axios';
import type { AxiosResponse } from 'axios';
import { createPhotoApi, getUploadProgressApi } from '@/apis/panel.api';

interface Album {
  id: number;
  name: string;
  last_upload_batch: number;
  expiry_date: Date;
}

const props = defineProps({
  album: {
    type: Object as PropType<Album>,
    required: true,
  },
});

const $emit = defineEmits(['uploaded-new-photo', 'close-upload-photo']);

// validate file extension
const validFileExtensions = [
  '.arw',
  '.bmp',
  '.cr2',
  '.crw',
  '.dng',
  '.heic',
  '.jpg',
  '.jpeg',
  '.nef',
  '.nrw',
  '.orf',
  '.pef',
  '.png',
  '.raf',
  '.srw',
  '.tif',
  '.tiff',
];
const mimeType = [
  '',
  'image/jpeg',
  'image/png',
  'image/tiff',
  'image/bmp',
  'image/x-canon-cr2',
  'image/x-canon-crw',
  'image/x-dcraw',
  'image/x-adobe-dng',
  'image/x-fuji-raf',
  'image/x-nikon-nef',
  'image/x-nikon-nrw',
  'image/x-olympus-orf',
  'image/x-panasonic-raw',
  'image/x-pentax-pef',
  'image/x-sony-arw',
  'image/x-sony-srw',
  'image/heic',
  'image/ARW',
  'image/BMP',
  'image/CR2',
  'image/CRW',
  'image/DNG',
  'image/HEIC',
  'image/JPG',
  'image/JPEG',
  'image/NEF',
  'image/NRW',
  'image/ORF',
  'image/PEF',
  'image/PNG',
  'image/RAF',
  'image/SRW',
  'image/TIF',
  'image/TIFF',
];

const validFileExtensionsString = validFileExtensions.join(', ');
const validMimeTypesString = mimeType.join(', ');
const validFileExtensionsAndMimeTypesString =
  validFileExtensionsString + ', ' + validMimeTypesString;

const hasInvalidFile = ref(false);
const canUpload = computed(() => {
  return inputFiles.value.length > 0 && !hasInvalidFile.value;
});
const showInvalidFileList = ref(false);
function toggleInvalidList() {
  showInvalidFileList.value = !showInvalidFileList.value;
}

const photoUploadOption = ref(1);
const inputFiles = ref([] as File[]);

function onChangeUploadPhoto(event: any) {
  hasInvalidFile.value = false;

  [...event.target.files].forEach((file: File) => {
    const ext = '.' + file.name.match(/\.([^\.]+)$/)![1].toLowerCase();
    if (!validFileExtensions.includes(ext) || !mimeType.includes(file.type)) {
      hasInvalidFile.value = true;
      return;
    }
  });

  inputFiles.value = [...event.target.files];
}

const uploadPhoto = async () => {
  if (!canUpload.value) {
    return;
  }

  // getProgressUntilComplete();

  createPhotoApi(props.album.id, photoUploadOption.value, inputFiles.value)
    .then((response: AxiosResponse) => {
      $emit('close-upload-photo');
      $emit('uploaded-new-photo', response.data);
    })
    .catch((error) => {
      if (error.response.data.error === 'Invalid file type.') {
        hasInvalidFile.value = true;
      }
      console.log(error.response.data);
    });
};

const isExpanded = ref(true);
function toggleUploads() {
  isExpanded.value = !isExpanded.value;
}

function cancelUpload() {
  inputFiles.value = [];
}

const closeUploadPhoto = () => {
  cancelUpload();
  $emit('close-upload-photo');
};

// upload progress
interface Upload {
  name: string;
  type: string;
  progress: number;
}

const uploads = ref([] as Upload[]);
watch(inputFiles, () => {
  uploads.value = [...inputFiles.value].map((file: File) => ({
    name: file.name,
    type: file.type,
    progress: 0,
  }));
});

function getProgressUntilComplete() {
  const getProgressRepeatedly = setInterval(() => {
    if (uploads.value.every((upload) => upload.progress === 100) || hasInvalidFile.value) {
      clearInterval(getProgressRepeatedly);
      return;
    }
    getProgress();
  }, 1000);
}

async function getProgress() {
  // get all files that are not completed
  const uploadsInProgress = uploads.value.filter((upload: Upload) => upload.progress < 100);
  const filesInProgressName = uploadsInProgress.map((upload: Upload) => upload.name);
  const endcodedFileNames = encodeURIComponent(JSON.stringify(filesInProgressName));

  const filesInProgressType = uploadsInProgress.map((upload: Upload) => upload.type);
  const endcodedFileTypes = encodeURIComponent(JSON.stringify(filesInProgressType));

  const queryString = '?file_names=' + endcodedFileNames + '&file_types=' + endcodedFileTypes;

  getUploadProgressApi(props.album.id, queryString)
    .then((response: AxiosResponse) => {
      // update uploads for any file that is not completed
      response.data.forEach((element: Upload) => {
        const index = uploads.value.findIndex((upload: Upload) => upload.name === element.name);
        uploads.value[index].progress = element.progress;
      });
    })
    .catch((error) => {
      if (error.response.data.error === 'Invalid file type.') {
        hasInvalidFile.value = true;
      }
      console.log(error.response.data);
    });
}
</script>
