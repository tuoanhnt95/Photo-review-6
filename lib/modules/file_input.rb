module FileInput
  # extend ActiveSupport::Concern

  def get_file_extension(file_name)
    file_name.split('.').last.downcase
  end

  def file_extension_whitelist
    %w[arw bmp cr2 crw dng heic jpg jpeg nef nrw orf pef png raf srw tif tiff]
  end

  def file_type_whitelist
    %w[image/jpeg image/png image/tiff image/bmp image/x-canon-cr2 image/x-canon-crw image/x-dcraw image/x-adobe-dng image/x-fuji-raf image/x-nikon-nef image/x-nikon-nrw image/x-olympus-orf image/x-panasonic-raw image/x-pentax-pef image/x-sony-arw image/x-sony-srw image/heic image/ARW image/BMP image/CR2 image/CRW image/DNG image/HEIC image/JPG image/JPEG image/NEF image/NRW image/ORF image/PEF image/PNG image/RAF image/SRW image/TIF image/TIFF];
  end

  def check_file_type_whitelist!(file_name, file_type)
    # if file has extension, check if it's in whitelist
    if file_name.include?('.')
      return file_extension_whitelist.include?(get_file_extension(file_name))
    else
      # if file has no extension, check if its mime type is in whitelist
      file_type.in?(file_type_whitelist)
    end
  end
end
