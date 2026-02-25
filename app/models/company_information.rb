class CompanyInformation < ApplicationRecord
  DEFAULT_HOME_BANNER_TITLE = "Haubergerie de pontius".freeze
  DEFAULT_HOME_BANNER_SUBTITLE = "l’authentique armurerie du moyen âge".freeze
  DEFAULT_HOME_BANNER_PRIMARY_CTA_LABEL = "Mon histoire".freeze
  DEFAULT_HOME_BANNER_SECONDARY_CTA_LABEL = "Boutique".freeze
  DEFAULT_FOOTER_DESCRIPTION = "Artisan forgeron passionné, créateur de bijoux et armures médiévales authentiques. Chaque pièce est forgée avec soin et tradition.".freeze

  has_one_attached :home_banner_image

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
      additional_info: "",
      home_banner_title: "",
      home_banner_subtitle: "",
      home_banner_primary_cta_label: "",
      home_banner_secondary_cta_label: "",
      footer_description: ""
    )
  end

  def address_lines
    [address_line1.presence, address_line2.presence].compact
  end

  def location_line
    [zipcode.presence, city.presence, country.presence].compact.join(" ")
  end

  def home_banner_title_or_default
    home_banner_title.presence || DEFAULT_HOME_BANNER_TITLE
  end

  def home_banner_subtitle_or_default
    home_banner_subtitle.presence || DEFAULT_HOME_BANNER_SUBTITLE
  end

  def home_banner_primary_cta_label_or_default
    home_banner_primary_cta_label.presence || DEFAULT_HOME_BANNER_PRIMARY_CTA_LABEL
  end

  def home_banner_secondary_cta_label_or_default
    home_banner_secondary_cta_label.presence || DEFAULT_HOME_BANNER_SECONDARY_CTA_LABEL
  end

  def footer_description_or_default
    footer_description.presence || DEFAULT_FOOTER_DESCRIPTION
  end
end
