import type { AxiosResponse } from 'axios';
import { http } from '@/services/http.service';

// Album
interface Album {
  name: string;
  expiry_date: Date;
  invitees: string[];
}

export const getAlbumsApi = (): Promise<AxiosResponse> => {
  return http.get('/panel/albums');
};

export const createAlbumApi = (album: Album): Promise<AxiosResponse> => {
  return http.post('/panel/albums', { album });
};

export const showAlbumApi = (id: number): Promise<AxiosResponse> => {
  return http.get(`/panel/albums/${id}.json`);
};

export const updateAlbumApi = (id: number, album: Album): Promise<AxiosResponse> => {
  return http.put(`/panel/albums/${id}`, { album });
};

export const addInviteesApi = (id: number, invitees: object): Promise<AxiosResponse> => {
  return http.put(`/panel/albums/${id}/add_invitees`, invitees);
};

export const deleteAlbumApi = (id: number): Promise<AxiosResponse> => {
  return http.delete(`/panel/albums/${id}`);
};

// Photo
interface Photo {
  name: string;
  image: string;
}

export const getPhotosApi = (albumId: number): Promise<AxiosResponse> => {
  return http.get(`/panel/albums/${albumId}/photos`);
};

export const createPhotoApi = (
  albumId: number,
  upload_option: number,
  file: File,
): Promise<AxiosResponse> => {
  return http.post(
    `/panel/albums/${albumId}/photos`,
    { upload_option, file },
    {
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    },
  );
};

export const showPhotoApi = (albumId: number, id: number): Promise<AxiosResponse> => {
  return http.get(`/panel/albums/${albumId}/photos/${id}`);
};

export const updatePhotoApi = (
  albumId: number,
  id: number,
  photo: Photo,
): Promise<AxiosResponse> => {
  return http.put(`/panel/albums/${albumId}/photos/${id}`, { photo });
};

export const deletePhotoApi = (albumId: number, id: number): Promise<AxiosResponse> => {
  return http.delete(`/panel/albums/${albumId}/photos/${id}`);
};

export const deletePhotosApi = (photoIds: number[]): Promise<AxiosResponse> => {
  return http.delete(`/panel/albums/delete_photos`, { data: { photo_ids: photoIds } });
};

// Upload Progress
export const getUploadProgressApi = (
  albumId: number,
  fileName: string,
  fileType: string,
): Promise<AxiosResponse> => {
  return http.get(`/panel/albums/${albumId}/upload_progress`, {
    params: { file_name: fileName, file_type: fileType },
    headers: {
      'Content-Type': 'application/json',
    },
  });
};

// Review
export const getReviewsApi = (album_id: number): Promise<AxiosResponse> => {
  return http.get(`/panel/albums/${album_id}/photo_user_reviews`);
};

export const updateReviewApi = (
  album_id: number,
  photo_id: number,
  review_id: number | null,
  angle: number,
): Promise<AxiosResponse> => {
  return http.put(`/panel/albums/${album_id}/photos/${photo_id}/photo_user_reviews`, {
    review_id,
    angle,
    controller: 'photo_user_reviews',
    action: 'update',
  });
};
