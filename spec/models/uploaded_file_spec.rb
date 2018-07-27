require 'rails_helper'

RSpec.describe UploadedFile, type: :model do
  subject(:uploaded_file) { described_class.new }

  let(:fixture_file) { Rack::Test::UploadedFile.new(Rails.root.join('spec', 'fixtures', 'et1_first_last.pdf'), 'application/pdf') }

  describe '#file=' do
    it 'persists it in memory as an activestorage attachment' do
      uploaded_file.file = fixture_file

      expect(uploaded_file.file).to be_a_stored_file
    end
  end

  describe '#url' do
    around do |example|
      old_value = ActiveStorage::Current.host
      begin
        ActiveStorage::Current.host = 'http://example.com'
        example.call
        ActiveStorage::Current.host = old_value
      ensure
        ActiveStorage::Current.host = old_value
      end
    end
    it 'returns a minio server url as we are in test mode' do
      uploaded_file.file = fixture_file

      expect(uploaded_file.url).to start_with(ActiveStorage::Blob.service.bucket.url)
    end
  end

  describe '#download_blob_to' do
    it 'downloads a file to the specified location' do
      # Arrange - Setup with a fixture file and save
      uploaded_file.file = fixture_file
      uploaded_file.save

      Dir.mktmpdir do |dir|
        filename = File.join(dir, 'my_file.pdf')
        # Act - download the blob
        uploaded_file.download_blob_to filename

        # Assert - make sure its there
        expect(File.exist?(filename)).to be true
      end
    end

    it 'downloads the correct file to the specified location' do
      # Arrange - Setup with a fixture file and save
      uploaded_file.file = fixture_file
      uploaded_file.save

      Dir.mktmpdir do |dir|
        filename = File.join(dir, 'my_file.pdf')
        # Act - download the blob
        uploaded_file.download_blob_to filename

        # Assert - make sure its there
        expect(filename).to be_a_file_copy_of fixture_file.path
      end
    end
  end
end
