class ReferenceCreatedHandler
  def handle(root, command:)
    reference = ReferenceService.next_number
    office = OfficeService.lookup_postcode(command.post_code)
    root[:reference] = "#{office.code}#{reference}00"
    root[:office] = office
  end
end
