class CompanyInformation < ApplicationRecord
  def self.instance
    first_or_create!(
      legal_name: "",
      address_line1: "",
      address_line2: "",
      zipcode: "",
      city: "",
      country: "",
      siret: "",
      vat_number: "",
      phone: "",
      email: "",
      additional_info: ""
    )
  end

  def address_lines
    [address_line1.presence, address_line2.presence].compact
  end

  def location_line
    [zipcode.presence, city.presence, country.presence].compact.join(" ")
  end
end
