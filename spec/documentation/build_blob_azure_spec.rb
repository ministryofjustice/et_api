require 'rails_helper'
require 'rspec_api_documentation/dsl'
resource 'Blob Resource (Azure mode)' do
  explanation "Signed Blob resource - azure mode"

  header "Content-Type", "application/json"
  header "Accept", "application/json"

  post '/api/v2/build_blob' do

    parameter :uuid, "A unique ID produced by the client to refer to this command", type: :string, with_example: true, in: :body
    parameter :data, "No data is required for this command", with_example: true, in: :body
    parameter :command, type: :string, enum: ['BuildBlob'], with_example: true, in: :body

    context "200" do
      include_context 'with cloud provider switching', cloud_provider: :azure
      example 'Create a signed azure url' do
        request =  build(:json_build_blob_command).as_json

        # It's also possible to extract types of parameters when you pass data through `do_request` method.
        do_request(request)

        expect(rspec_api_documentation_client.send(:last_response).status).to eq(202)
      end
    end
  end
end