declare global {
  interface ImportMeta {
    env: {
      VITE_API_URL: string;
      VITE_API_CLOUDINARY_NAME: string;
    };
  }
}

export const { VITE_API_URL: API_URL, VITE_API_CLOUDINARY_NAME: CLOUD_NAME } = import.meta.env;
