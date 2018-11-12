require 'rails_helper'

RSpec.describe BuildRepresentativeCommand do
  subject(:command) { described_class.new(uuid: uuid, data: data) }

  let(:uuid) { SecureRandom.uuid }
  let(:data) { build(:json_representative_data, :full).as_json }
  let(:root_object) { Response.new }

  describe '#apply' do
    it 'applies the data to the root object' do
      # Act
      command.apply(root_object)

      # Assert
      expect(root_object.representative).to have_attributes(data.except(:address_attributes)).
        and(have_attributes(address: an_object_having_attributes(data[:address_attributes])))
    end
  end
end
