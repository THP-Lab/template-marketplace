class Product < ApplicationRecord
  HIGHLIGHT_DEFAULTS = [
    {
      icon: "bi-shield-check",
      title: "Garantie artisanale",
      description: "Chaque pièce est garantie 2 ans contre les défauts de fabrication"
    },
    {
      icon: "bi-truck",
      title: "Livraison soignée",
      description: "Expédition sous 2-3 jours dans un emballage médiéval"
    },
    {
      icon: "bi-box-seam",
      title: "Retour accepté",
      description: "30 jours pour changer d'avis"
    }
  ].freeze

  self.inheritance_column = :_type_disabled
  has_many :cart_products, dependent: :destroy
  has_many :carts, through: :cart_products
  has_many :order_products, dependent: :restrict_with_error
  has_one_attached :image

  def highlight_boxes
    HIGHLIGHT_DEFAULTS.each_with_index.map do |defaults, idx|
      number = idx + 1
      {
        enabled: send("highlight_#{number}_enabled"),
        icon: defaults[:icon],
        title: send("highlight_#{number}_title").presence || defaults[:title],
        description: send("highlight_#{number}_description").presence || defaults[:description]
      }
    end.select { |box| box[:enabled] }
  end

  def highlight_column_class
    case highlight_boxes.size
    when 1
      "col-12"
    when 2
      "col-12 col-md-6"
    else
      "col-12 col-md-4"
    end
  end
end
