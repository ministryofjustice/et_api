require 'csv'
module EtApi
  module Test
    module NormalizeCsvDataHelper
      def normalize_claimants_from_file(file: File.absolute_path(File.join('../../fixtures/simple_user_with_csv_group_claims.csv'), __dir__))
        claimants_array = []
        CSV.foreach file, headers: true do |row|
          claimants_array << {
            title: row['Title'],
            first_name: row['First name'].try(:downcase),
            last_name: row['Last name'].try(:downcase),
            date_of_birth: Date.parse(row['Date of birth']),
            address: {
              building: row['Building number or name'].try(:downcase),
              street: row['Street'].try(:downcase),
              locality: row['Town/city'].try(:downcase),
              county: row['County'].try(:downcase),
              post_code: row['Postcode'].try(:downcase)
            }
          }
        end
        claimants_array
      end
    end
  end
end
RSpec.configure do |c|
  c.include ::EtApi::Test::NormalizeCsvDataHelper
end
