declare global {
  interface ImportMeta {
    env: {
      VITE_API_URL: string;
    };
  }
}

export const { VITE_API_URL: API_URL } = import.meta.env;
