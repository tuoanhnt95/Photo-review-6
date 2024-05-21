import { Cloudinary } from '@cloudinary/url-gen';
import { byAngle } from '@cloudinary/url-gen/actions/rotate';

const cld = new Cloudinary({
  cloud: {
    cloudName: import.meta.env.VITE_API_CLOUDINARY_NAME,
  },
});

const getCloudinaryImage = (publicId: string, angle: number) => {
  return cld.image(`photo_review/${publicId}`).rotate(byAngle(angle));
};

export { getCloudinaryImage };
