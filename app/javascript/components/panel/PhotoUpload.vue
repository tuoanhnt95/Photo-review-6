<template>
  <div class="flex justify-center" style="align-items: center">
    <div
      class="absolute px-6 pt-10 pb-8 bg-white dark:bg-slate-800 rounded"
      style="min-height: 432px"
    >
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
        <span class="text-red-500">
          Include
          <span class="underline cursor-pointer" @click="toggleInvalidList">invalid format!</span>
        </span>
        <div v-if="showInvalidFileList" class="mt-2">
          <ul>
            <li v-for="file in invalidFiles" :key="file.name">
              {{ file.name }}
            </li>
          </ul>
          <span> VALID: </span>
          <div class="inline-block m-1">
            {{ validFileExtensionsString }}
          </div>
        </div>
      </div>

      <span v-if="duplicateFiles.length > 0" class="text-xs text-red-500">
        Include duplicate files!
      </span>

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
      <div class="mt-2">
        <div
          v-if="uploads.length > 0"
          class="flex justify-center bg-gray-200 text-slate-600 cursor-pointer"
          @click="toggleUploads"
        >
          <font-awesome-icon icon="fa-solid fa-grip-lines" />
        </div>
        <div v-if="isExpanded" class="border w-full max-h-40 overflow-auto">
          <div v-for="(upload, i) in inWaitingUploads" :key="i" class="px-2">
            <div class="flex justify-between mb-1">
              <span
                :class="{
                  'text-red-500':
                    isDuplicateFile(upload.name) ||
                    isInvalidFile(getFileFromInputFiles(upload.name)),
                }"
              >
                {{ upload.name }}
              </span>
              <!-- <font-awesome-icon
                v-if="canRemoveInputFiles"
                icon="fa-solid fa-times"
                class="self-center cursor-pointer"
                @click="removeFileFromInputFiles(i)"
              /> -->
            </div>
            <div class="mb-4 h-1 rounded bg-gray-200">
              <div
                class="h-1 animate-pulse rounded bg-violet-400"
                :style="`width: ${upload.progress}%`"
              ></div>
            </div>
          </div>
          <div v-if="uploadIsComplete">Upload Complete!</div>
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
import type { AxiosResponse } from 'axios';
import { createPhotoApi, getUploadProgressApi, cancelUploadApi } from '@/apis/panel.api';

interface Album {
  id: number;
  name: string;
  expiry_date: Date;
}

const props = defineProps({
  album: {
    type: Object as PropType<Album>,
    required: true,
  },
  albumPhotoNames: {
    type: Array as PropType<string[]>,
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
  return (
    inputFiles.value.length > 0 &&
    invalidFiles.value.length === 0 &&
    duplicateFiles.value.length === 0
  );
});
const showInvalidFileList = ref(false);
function toggleInvalidList() {
  showInvalidFileList.value = !showInvalidFileList.value;
}

// const showDuplicateFileList = ref(false);
// function toggleDuplicateList() {
//   showDuplicateFileList.value = !showDuplicateFileList.value;
// }

const photoUploadOption = ref(1);
const inputFiles = ref([] as File[]);

function getFileExtension(fileName: string) {
  return fileName ? fileName.split('.').pop()?.toLowerCase() ?? '' : '';
}

function getFileNameWithoutExtension(fileName: string) {
  return fileName.split('.').slice(0, -1).join('.');
}

function getFileFromInputFiles(fileName: string) {
  return inputFiles.value.find((file: File) => file.name === fileName);
}

function isInvalidFile(file: File | undefined) {
  if (!file) {
    return false;
  }
  const ext = '.' + getFileExtension(file.name);
  return !validFileExtensions.includes(ext) || !mimeType.includes(file.type);
}

// list of files that are invalid in the inputFiles
const invalidFiles = computed(() => {
  return inputFiles.value.filter((file: File) => {
    const ext = '.' + getFileExtension(file.name);
    return !validFileExtensions.includes(ext) || !mimeType.includes(file.type);
  });
});

function isDuplicateFile(fileName: string) {
  const fileNameWithoutExtension = getFileNameWithoutExtension(fileName);
  const isDuplicateUploadedFiles = props.albumPhotoNames.includes(fileNameWithoutExtension);
  const isDuplicateInputFiles = inputFiles.value.some((inputFile: File) => {
    getFileNameWithoutExtension(inputFile.name) === fileNameWithoutExtension;
  });
  return isDuplicateUploadedFiles || isDuplicateInputFiles;
}

// list of files that are duplicate in the inputFiles and photoData
const duplicateFiles = computed(() => {
  return inputFiles.value.filter((file: File) => isDuplicateFile(file.name));
});

function onChangeUploadPhoto(event: any) {
  hasInvalidFile.value = false;

  [...event.target.files].forEach((file: File) => {
    const ext = '.' + getFileExtension(file.name);
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
  // canRemoveInputFiles.value = false;

  inputFiles.value.forEach((file: File) => {
    if (inputFiles.value.length === 0) {
      return;
    }
    getProgressUntilComplete(file);
    createPhotoApi(props.album.id, photoUploadOption.value, file)
      .then((response: AxiosResponse) => {
        $emit('uploaded-new-photo', response.data);
      })
      .catch((error) => {
        if (error.response.data.error === 'Invalid file type.') {
          hasInvalidFile.value = true;
        }
        console.log(error.response.data);
      });
  });
};

// upload progress
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

interface Upload {
  name: string;
  type: string;
  progress: number;
  is_cancelled?: boolean;
  uploaded_photo?: Photo;
}

const uploads = ref([] as Upload[]);
watch(inputFiles, () => {
  uploads.value = [...inputFiles.value].map((file: File) => ({
    name: file.name,
    type: file.type,
    progress: 0,
  }));
});

// const canRemoveInputFiles = ref(true);
// function removeFileFromInputFiles(i: number) {
//   inputFiles.value.splice(i, 1);
//   uploads.value.splice(i, 1);
// }

const inWaitingUploads = computed(() => {
  return uploads.value.filter((upload: Upload) => upload.progress < 100);
});

const inProgressUploads = computed(() => {
  return uploads.value.filter((upload: Upload) => upload.progress < 100 && upload.progress > 0);
});

const uploadIsComplete = computed(() => {
  return (
    uploads.value.length > 0 && uploads.value.every((upload: Upload) => upload.progress === 100)
  );
});

function getProgressUntilComplete(file: File) {
  const upload = uploads.value.find((upload: Upload) => upload.name === file.name);
  const getProgressRepeatedly = setInterval(() => {
    if (
      (upload && upload.progress === 100) ||
      inputFiles.value.length === 0 ||
      hasInvalidFile.value
    ) {
      clearInterval(getProgressRepeatedly);
      return;
    }
    getProgress(file);
  }, 1000);
}

async function getProgress(file: File) {
  getUploadProgressApi(props.album.id, file.name, file.type)
    .then((response: AxiosResponse) => {
      const upload = uploads.value.find((upload: Upload) => upload.name === response.data.name);
      upload!.progress = response.data.progress;
    })
    .catch((error) => {
      if (error.response.data.error === 'Invalid file type.') {
        hasInvalidFile.value = true;
      }
      console.log(error.response.data);
    });
}

const isExpanded = ref(true);
function toggleUploads() {
  isExpanded.value = !isExpanded.value;
}

function cancelUpload() {
  // make a call to backend to cancel the upload
  // find all uploads that are in progress and cancel them
  if (inProgressUploads.value.length > 0) {
    cancelUploadApi(props.album.id);
  }
  inputFiles.value = [];
}

const closeUploadPhoto = () => {
  if (inProgressUploads.value.length > 0) {
    if (confirm('Are you sure you want to cancel uploading?')) {
      cancelUpload();
      $emit('close-upload-photo');
    }
  } else {
    $emit('close-upload-photo');
  }
};
</script>
