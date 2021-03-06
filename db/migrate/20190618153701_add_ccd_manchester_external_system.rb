class AddCcdManchesterExternalSystem < ActiveRecord::Migration[5.2]
  class ExternalSystem < ActiveRecord::Base
    self.table_name=:external_systems
  end

  class ExternalSystemConfiguration < ActiveRecord::Base
    self.table_name=:external_system_configurations
  end

  def up
    return if ExternalSystem.find_by(reference: 'ccd_manchester').present?
    ccd = ExternalSystem.create name: 'CCD Manchester',
                                 reference: 'ccd_manchester',
                                 enabled: true,
                                 export: false,
                                 export_queue: 'external_system_ccd',
                                 office_codes: Office.pluck(:code).to_a

    ExternalSystemConfiguration.create external_system_id: ccd.id,
                                       key: 'user_id', value: '22'
    ExternalSystemConfiguration.create external_system_id: ccd.id,
                                       key: 'user_role', value: 'caseworker,caseworker-test,caseworker-employment-tribunal-manchester,caseworker-employment,caseworker-employment-tribunal-manchester-caseofficer,caseworker-publiclaw-localAuthority'
    ExternalSystemConfiguration.create external_system_id: ccd.id,
                                       key: 'case_type_id', value: 'Manchester_Dev'
  end

  def down
    # Purposely do nothing - no point in going back on this
  end
end
