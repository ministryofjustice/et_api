require 'rails_helper'

RSpec.describe BuildRespondentCommand do
  subject(:command) { described_class.new(uuid: uuid, data: data) }

  let(:uuid) { SecureRandom.uuid }
  let(:data) { build(:json_respondent_data, :full).as_json }
  let(:root_object) { Response.new }

  describe '#apply' do
    it 'applies the data to the root object' do
      # Act
      command.apply(root_object)

      # Assert
      expect(root_object.respondent).to have_attributes(data.except(:work_address_attributes, :address_attributes)).
        and(have_attributes(address: an_object_having_attributes(data[:address_attributes]))).
        and(have_attributes(work_address: an_object_having_attributes(data[:work_address_attributes])))
    end
  end
end
