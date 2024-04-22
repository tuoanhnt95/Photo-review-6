import type { AxiosResponse } from 'axios';
import { http } from '@/services/http.service';

// interface Album {
//   id: number;
//   name: string;
//   expiry_date: Date;
//   cover: string;
//   last_upload_batch: number;
// }

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

export const deleteAlbumApi = (id: number): Promise<AxiosResponse> => {
  return http.delete(`albums/${id}`);
};
