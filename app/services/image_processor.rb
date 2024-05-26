# frozen_string_literal: true

require 'mini_magick'
require 'vips'
require 'cloudinary'

class ImageProcessor < ApplicationService
  def initialize(file, upload_option, upload_id) # rubocop:disable Lint/MissingSuper
    @file = file
    @upload_option = upload_option
    @upload_id = upload_id
  end

  def call
    cloudinary_image = process_image
    return nil if cloudinary_image.nil?

    url = cloudinary_image['secure_url']
    public_id = cloudinary_public_id(url)
    { img_name: get_file_name_without_extension(@file.original_filename), img_url: public_id }
  end

  private

  def process_image
    file_path = @file.tempfile.path
    file_name = @file.original_filename
    resized_width, resized_height = get_image_resized(@upload_option)
    use_magicload = image_uses_magicload(@file.original_filename)
    if use_magicload
      process_magicload(file_path, resized_width, resized_height)
    else
      process_libvips(file_path, file_name, resized_width, resized_height)
    end
  end

  def process_magicload(file_path, resized_width, resized_height)
    return nil if Upload.find(@upload_id).is_cancelled

    image = MiniMagick::Image.new(file_path).format 'jpg'
    return nil if Upload.find(@upload_id).is_cancelled

    Upload.find(@upload_id).update(progress: 20)
    return nil if Upload.find(@upload_id).is_cancelled

    image.resize("#{resized_width}x#{resized_height}")
    Upload.find(@upload_id).update(progress: 40)
    return nil if Upload.find(@upload_id).is_cancelled

    Upload.find(@upload_id).update(progress: 60)
    return nil if Upload.find(@upload_id).is_cancelled

    result = upload_image_to_cloudinary(image.path)
    Upload.find(@upload_id).update(progress: 80, is_cancelled: false)
    result
  end

  def process_libvips(file_path, file_name, resized_width, resized_height)
    image = Vips::Image.new_from_file file_path, access: :sequential

    resized_image = Vips::Image.thumbnail image.filename, resized_width, height: resized_height
    jpg_converted_file_name = image_name(file_name)
    resized_image.write_to_file jpg_converted_file_name
    result = upload_image_to_cloudinary(jpg_converted_file_name)

    File.delete(jpg_converted_file_name)

    result
  end

  def upload_image_to_cloudinary(image_path)
    Cloudinary::Uploader.unsigned_upload(image_path, 'photo_review')
  end

  def cloudinary_public_id(cloudinary_url)
    cloudinary_url.split('/').last.split('.')[0]
  end

  # replace extension with '.jpg
  def image_name(file_name)
    return file_name if image_is_jpg(file_name)

    "#{get_file_name_without_extension(file_name)}.jpg"
  end

  def get_file_extension(file_name)
    file_name.split('.').last.downcase
  end

  def get_file_name_without_extension(file_name)
    # if image has multiple '.' in the name, split by the last '.' and join the rest
    return file_name.split('.')[0..-2].join('.').to_s if file_name.split('.').length > 2

    (file_name.split('.')[0]).to_s
  end

  def image_is_jpg(file_name)
    get_file_extension(file_name) == 'jpg' || get_file_extension(file_name) == 'jpeg'
  end

  def image_uses_magicload(file_name)
    magickload_formats = %w[arw cr2 crw dng heic nef nrw orf pef raf srw]
    # magickload_formats = %w[arw cr2 crw dng nef nrw orf pef raf srw rw2 x3f gpr]
    get_file_extension(file_name).in? magickload_formats
  end

  def get_image_resized(option)
    case option
    when 2
      [1920, 1080]
    when 3
      [1920, 1350]
    when 4
      [2100, 1600]
    when 5
      [2400, 1600]
    when 6
      [6000, 4000]
    else
      [1080, 720]
    end
  end

  def image_params
    params.permit(:image, :album_id, :upload_option, files: [])
  end
end
