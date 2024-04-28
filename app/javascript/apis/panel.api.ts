import type { AxiosResponse } from 'axios';
import { http } from '@/services/http.service';

// Album
interface album {
  name: string;
  expiry_date: Date;
}

export const getAlbumsApi = (): Promise<AxiosResponse> => {
  return http.get('albums');
};

export const createAlbumApi = (album: album): Promise<AxiosResponse> => {
  return http.post('albums', { album });
};

export const showAlbumApi = (id: number): Promise<AxiosResponse> => {
  return http.get(`${id}`); // not 'albums/${id}' because of Rails' default behavior params_wrapper.
};

export const updateAlbumApi = (id: number, album: album): Promise<AxiosResponse> => {
  return http.put(`${id}`, { album });
};

export const deleteAlbumApi = (id: number): Promise<AxiosResponse> => {
  return http.delete(`albums/${id}`);
};

// Photo
interface photo {
  name: string;
  image: string;
}

export const getPhotosApi = (albumId: number): Promise<AxiosResponse> => {
  return http.get(`${albumId}/photos`);
};

export const createPhotoApi = (
  albumId: number,
  upload_option: number,
  files: File[],
): Promise<AxiosResponse> => {
  return http.post(
    `${albumId}/photos`,
    { upload_option, files },
    {
      headers: {
        'Content-Type': 'multipart/form-data',
      },
  });
};

export const showPhotoApi = (albumId: number, id: number): Promise<AxiosResponse> => {
  return http.get(`${albumId}/photos/${id}`);
};

export const updatePhotoApi = (
  albumId: number,
  id: number,
  photo: photo,
): Promise<AxiosResponse> => {
  return http.put(`${albumId}/photos/${id}`, { photo });
};

export const deletePhotoApi = (albumId: number, id: number): Promise<AxiosResponse> => {
  return http.delete(`${albumId}/photos/${id}`);
};

export const deletePhotosApi = (photoIds: number[]): Promise<AxiosResponse> => {
  return http.delete(`delete_photos`, { data: { photo_ids: photoIds } });
};

// Upload Progress
export const getUploadProgressApi = (
  albumId: number,
  queryString: string,
): Promise<AxiosResponse> => {
  return http.get(`${albumId}/upload_progress${queryString}`, {
    headers: {
      'Content-Type': 'application/json',
    },
  });
};