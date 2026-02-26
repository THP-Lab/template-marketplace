module HomePagesHelper
  def home_block_image_attachment(home_page)
    return home_page.image if home_page.image.attached?

    source = home_page.source_record
    return unless source.respond_to?(:image) && source.image.attached?

    source.image
  end

  def home_block_button_label(home_page)
    return home_page.button_label if home_page.button_label.present?

    case home_page.bloc_type
    when "about" then "Découvrir"
    when "repair" then "Besoin d'une réparation ?"
    else "En savoir plus"
    end
  end

  def home_block_button_url(home_page)
    return unless home_page.show_button?

    case home_page.bloc_type
    when "about"
      about_pages_path
    when "repair"
      repair_pages_path
    end
  end
end
