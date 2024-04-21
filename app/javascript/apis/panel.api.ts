import type { AxiosResponse } from 'axios';
import { http } from '@/services/http.service';

export const getAlbums = (): Promise<AxiosResponse> => {
  return http.get('albums');
};
