require 'net/http'
require 'tempfile'
require 'uri'
# This module is included in any models that need to be able to upload a file from a remote url
#
module StoredFileRemoteUpload
  extend ActiveSupport::Concern

  # Imports a remote file
  #
  # @param [String] url The url of the file to import
  def import_file_url=(url)
    return if url.nil?
    file = Tempfile.new
    file.binmode
    response = HTTParty.get(url, stream_body: true) do |chunk|
      file.write chunk
    end
    file.flush
    self.file = ActionDispatch::Http::UploadedFile.new filename: filename || File.basename(url),
                                                       tempfile: file,
                                                       type: response.content_type
  end

  def import_from_key=(key)
    return if key.nil?
    adapter = ActiveStorage::Blob.service.class.name =~ /Azure/ ? Azure.new(self) : Amazon.new(self)
    adapter.import_from_key(key)
  end

  class Azure
    def initialize(model)
      self.model = model
    end

    def import_from_key(key)
      blob = ActiveStorage::Blob.new(blob_attributes_for(key))
      direct_upload_service.blobs.copy_blob(blob.service.container, blob.key, direct_upload_service.container, key)
      direct_upload_service.blobs.delete_blob(direct_upload_service.container, key)
      model.file.attach blob
    end

    private

    attr_accessor :model

    def blob_attributes_for(value)
      props = direct_upload_service.blobs.get_blob_properties(direct_upload_service.container, value)
      { filename: model.filename,
        byte_size: props.properties[:content_length],
        checksum: props.properties[:content_md5],
        content_type: props.properties[:content_type],
        metadata: {} }
    end

    def direct_upload_service
      @azure_direct_service ||= ActiveStorage::Service.configure :azure_direct_upload, Rails.configuration.active_storage.service_configurations
    end

  end

  class Amazon
    def initialize(model)
      self.model = model
    end

    def import_from_key(key)
      source_object = direct_upload_service.bucket.object(key)
      blob = ActiveStorage::Blob.new(blob_attributes_for(key))
      source_object.move_to key: blob.key, bucket: blob.service.bucket.name
      model.file.attach blob
    end

    private

    def blob_attributes_for(key)
      source_object = direct_upload_service.bucket.object(key)
      { filename: model.filename,
        byte_size: source_object.content_length,
        checksum: 'doesntseemtomatter',
        content_type: source_object.content_type,
        metadata: {} }
    end


    attr_accessor :model

    def direct_upload_service
      @direct_upload_service ||= ActiveStorage::Service.configure :amazon_direct_upload, Rails.configuration.active_storage.service_configurations
    end
  end
end
