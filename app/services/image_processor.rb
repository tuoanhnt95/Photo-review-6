# frozen_string_literal: true

require 'mini_magick'
require 'vips'
require 'cloudinary'

class ImageProcessor < ApplicationService
  def initialize(file, upload_option, upload_id) # rubocop:disable Lint/MissingSuper
    @file = file
    @upload_option = upload_option
    @upload = Upload.find(upload_id)
  end

  def call
    file_name_without_extension = @file.original_filename.split('.')[0]
    cloudinary_image = process_image
    url = cloudinary_image['secure_url']
    public_id = cloudinary_public_id(url)
    { img_name: file_name_without_extension, img_url: public_id }
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
    image = MiniMagick::Image.new(file_path).format 'jpg'
    @upload.update(progress: 20)
    p '---------------------------------'
    p 'converting to jpg'
    p @upload
    p '---------------------------------'
    @upload.update(progress: 30)
    p '---------------------------------'
    p 'reformatting to jpg'
    p @upload
    p '---------------------------------'
    # image.resize('4800x3600')
    image.resize("#{resized_width}x#{resized_height}")
    @upload.update(progress: 60)
    p '---------------------------------'
    p 'resizing'
    p @upload
    p '---------------------------------'
    result = upload_image_to_cloudinary(image.path)
    @upload.update(progress: 90)
    p '---------------------------------'
    p 'uploading to cloudinary 2'
    p @upload
    p '---------------------------------'
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
    "#{file_name.split('.')[0]}.jpg"
  end

  def image_extension(file_name)
    file_name.split('.')[1].downcase
  end

  def image_is_jpg(file_name)
    image_extension(file_name) == 'jpg' || image_extension(file_name) == 'jpeg'
  end

  def image_uses_magicload(file_name)
    magickload_formats = %w[arw cr2 crw dng heic nef nrw orf pef raf srw]
    # magickload_formats = %w[arw cr2 crw dng nef nrw orf pef raf srw rw2 x3f gpr]
    image_extension(file_name).in? magickload_formats
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
