require 'rails_helper'

RSpec.describe BuildPrimaryRespondentCommand do
  subject(:command) { described_class.new(uuid: uuid, data: data) }

  let(:uuid) { SecureRandom.uuid }
  let(:data) { build(:json_respondent_data, :full).as_json }
  let(:root_object) { Claim.new }

  describe '#apply' do
    it 'applies the data to the root object' do
      # Act
      command.apply(root_object)

      # Assert
      expect(root_object.respondents.first).to have_attributes(data.except(:address_attributes, :work_address_attributes)).
        and(have_attributes(address: an_object_having_attributes(data[:address_attributes]))).
        and(have_attributes(work_address: an_object_having_attributes(data[:work_address_attributes])))
    end
  end
end
