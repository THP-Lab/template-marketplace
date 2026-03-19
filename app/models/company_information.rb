class CompanyInformation < ApplicationRecord
  DEFAULT_HOME_BANNER_TITLE = "Haubergerie de pontius".freeze
  DEFAULT_HOME_BANNER_SUBTITLE = "l’authentique armurerie du moyen âge".freeze
  DEFAULT_HOME_BANNER_PRIMARY_CTA_LABEL = "Mon histoire".freeze
  DEFAULT_HOME_BANNER_SECONDARY_CTA_LABEL = "Boutique".freeze
  HOME_HIGHLIGHT_DEFAULTS = [
    {
      title: "Savoir-faire Artisanal",
      description: "Chaque pièce est créée à la main avec passion et précision, dans le respect des techniques ancestrales."
    },
    {
      title: "Créations Uniques",
      description: "Bijoux et accessoires en maille, conçus pour durer et sublimer votre style médiéval."
    },
    {
      title: "Réparations & Entretien",
      description: "Service professionnel de restauration et personnalisation de vos pièces en maille."
    },
    {
      title: "Événements",
      description: "Retrouvez-nous lors des festivités et marchés médiévaux."
    }
  ].freeze
  DEFAULT_FOOTER_DESCRIPTION = "Artisan forgeron passionné, créateur de bijoux et armures médiévales authentiques. Chaque pièce est forgée avec soin et tradition.".freeze
  DEFAULT_ABOUT_PRINCIPAL_TITLE = "Bienvenue dans notre Haubergerie".freeze
  DEFAULT_ABOUT_PONTIUS_TITLE = "Le Parcours de Pontius".freeze
  DEFAULT_ABOUT_MON_PARCOURS_TITLE = "Mon Parcours".freeze
  DEFAULT_ABOUT_PRIMARY_TITLE = DEFAULT_ABOUT_PRINCIPAL_TITLE
  DEFAULT_ABOUT_SECONDARY_TITLE = DEFAULT_ABOUT_PONTIUS_TITLE
  DEFAULT_ABOUT_JOURNEY_TITLE = DEFAULT_ABOUT_MON_PARCOURS_TITLE
  DEFAULT_REPAIR_PARTNERS_SECTION_TITLE = "Nos partenaires".freeze
  DEFAULT_SHOP_PAGE_TITLE = "Boutique de Pontius".freeze
  DEFAULT_SHOP_PAGE_SUBTITLE = "Des produits de qualité supérieur, fait à la main dans un savoir faire authentique.".freeze
  DEFAULT_EVENTS_PAGE_TITLE = "Événements".freeze
  DEFAULT_EVENTS_PAGE_SUBTITLE = "Une question sur mes créations ? Un projet personnalisé ? N'hésitez pas à me contacter.".freeze
  DEFAULT_REPAIR_PAGE_TITLE = "Service de réparation".freeze
  DEFAULT_REPAIR_PAGE_SUBTITLE = "Donnez une nouvelle vie à vos pièces médiévales avec notre expertise artisanale".freeze
  DEFAULT_CONTACT_PAGE_TITLE = "Contactez l'Artisan".freeze
  DEFAULT_CONTACT_PAGE_SUBTITLE = "Une question sur mes créations ? Un projet personnalisé ? N'hésitez pas à me contacter.".freeze
  DEFAULT_TWITCH_POPUP_TITLE = "Pontius est en direct sur Twitch".freeze

  has_one_attached :home_banner_image
  has_many :company_documents, dependent: :destroy
  has_many :shipping_rates, -> { order(:max_weight, :id) }, dependent: :destroy

  accepts_nested_attributes_for :shipping_rates,
                                allow_destroy: true,
                                reject_if: proc { |attributes| attributes["max_weight"].blank? && attributes["price"].blank? }

  validates :vat_rate, numericality: { greater_than_or_equal_to: 0 }, allow_blank: true
  validates :twitch_channel_login,
            format: { with: /\A[a-zA-Z0-9_]+\z/, message: "doit contenir uniquement des lettres, chiffres ou _" },
            allow_blank: true
  validate :twitch_channel_login_presence_if_live_enabled

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
      vat_rate: 0,
      phone: "",
      email: "",
      additional_info: "",
      home_banner_title: "",
      home_banner_subtitle: "",
      home_banner_primary_cta_label: "",
      home_banner_secondary_cta_label: "",
      home_highlight_1_title: "",
      home_highlight_1_description: "",
      home_highlight_2_title: "",
      home_highlight_2_description: "",
      home_highlight_3_title: "",
      home_highlight_3_description: "",
      home_highlight_4_title: "",
      home_highlight_4_description: "",
      footer_description: "",
      about_principal_title: "",
      about_principal_description: "",
      about_pontius_title: "",
      about_pontius_description: "",
      about_mon_parcours_title: "",
      about_mon_parcours_description: "",
      repair_partners_section_title: "",
      shop_page_title: "",
      shop_page_subtitle: "",
      events_page_title: "",
      events_page_subtitle: "",
      repair_page_title: "",
      repair_page_subtitle: "",
      contact_page_title: "",
      contact_page_subtitle: "",
      twitch_live_enabled: false,
      twitch_channel_login: "",
      twitch_channel_display_name: "",
      twitch_broadcaster_id: "",
      twitch_popup_title: "",
      twitch_eventsub_online_subscription_id: "",
      twitch_eventsub_offline_subscription_id: "",
      twitch_last_sync_error: ""
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

  def home_highlights
    HOME_HIGHLIGHT_DEFAULTS.each_with_index.map do |defaults, index|
      number = index + 1
      {
        title: send("home_highlight_#{number}_title").presence || defaults[:title],
        description: send("home_highlight_#{number}_description").presence || defaults[:description]
      }
    end
  end

  def footer_description_or_default
    footer_description.presence || DEFAULT_FOOTER_DESCRIPTION
  end

  def about_principal_title_or_default
    about_principal_title.presence || DEFAULT_ABOUT_PRINCIPAL_TITLE
  end

  def about_pontius_title_or_default
    about_pontius_title.presence || DEFAULT_ABOUT_PONTIUS_TITLE
  end

  def about_mon_parcours_title_or_default
    about_mon_parcours_title.presence || DEFAULT_ABOUT_MON_PARCOURS_TITLE
  end

  def about_primary_title
    about_principal_title
  end

  def about_primary_title=(value)
    self.about_principal_title = value
  end

  def about_primary_description
    about_principal_description
  end

  def about_primary_description=(value)
    self.about_principal_description = value
  end

  def about_secondary_title
    about_pontius_title
  end

  def about_secondary_title=(value)
    self.about_pontius_title = value
  end

  def about_secondary_description
    about_pontius_description
  end

  def about_secondary_description=(value)
    self.about_pontius_description = value
  end

  def about_journey_title
    about_mon_parcours_title
  end

  def about_journey_title=(value)
    self.about_mon_parcours_title = value
  end

  def about_journey_description
    about_mon_parcours_description
  end

  def about_journey_description=(value)
    self.about_mon_parcours_description = value
  end

  def about_primary_title_or_default
    about_primary_title.presence || DEFAULT_ABOUT_PRIMARY_TITLE
  end

  def about_secondary_title_or_default
    about_secondary_title.presence || DEFAULT_ABOUT_SECONDARY_TITLE
  end

  def about_journey_title_or_default
    about_journey_title.presence || DEFAULT_ABOUT_JOURNEY_TITLE
  end

  def repair_partners_section_title_or_default
    repair_partners_section_title.presence || DEFAULT_REPAIR_PARTNERS_SECTION_TITLE
  end

  def shop_page_title_or_default
    shop_page_title.presence || DEFAULT_SHOP_PAGE_TITLE
  end

  def shop_page_subtitle_or_default
    shop_page_subtitle.presence || DEFAULT_SHOP_PAGE_SUBTITLE
  end

  def events_page_title_or_default
    events_page_title.presence || DEFAULT_EVENTS_PAGE_TITLE
  end

  def events_page_subtitle_or_default
    events_page_subtitle.presence || DEFAULT_EVENTS_PAGE_SUBTITLE
  end

  def repair_page_title_or_default
    repair_page_title.presence || DEFAULT_REPAIR_PAGE_TITLE
  end

  def repair_page_subtitle_or_default
    repair_page_subtitle.presence || DEFAULT_REPAIR_PAGE_SUBTITLE
  end

  def contact_page_title_or_default
    contact_page_title.presence || DEFAULT_CONTACT_PAGE_TITLE
  end

  def contact_page_subtitle_or_default
    contact_page_subtitle.presence || DEFAULT_CONTACT_PAGE_SUBTITLE
  end

  def twitch_popup_title_or_default
    twitch_popup_title.presence || DEFAULT_TWITCH_POPUP_TITLE
  end

  def twitch_live_configured?
    twitch_live_enabled? && twitch_channel_login.present?
  end

  def shipping_rates_ordered
    shipping_rates.ordered
  end

  def shipping_rate_for(total_weight)
    weight = total_weight.to_d
    return if weight <= 0

    ordered_rates = shipping_rates_ordered.to_a
    return if ordered_rates.empty?

    ordered_rates.find { |rate| rate.max_weight.to_d >= weight } || ordered_rates.last
  end

  def shipping_amount_for(total_weight)
    shipping_rate_for(total_weight)&.price.to_d || 0.to_d
  end

  def vat_rate_value
    vat_rate.to_d
  end

  private

  def twitch_channel_login_presence_if_live_enabled
    return unless twitch_live_enabled?
    return if twitch_channel_login.present?

    errors.add(:twitch_channel_login, "est requis pour activer le live Twitch")
  end
end
