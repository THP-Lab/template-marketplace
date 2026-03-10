class Product < ApplicationRecord
  HIGHLIGHT_DEFAULTS = [
    {
      title: "Garantie artisanale",
      description: "Chaque pièce est garantie 2 ans contre les défauts de fabrication"
    },
    {
      title: "Livraison soignée",
      description: "Expédition sous 2-3 jours dans un emballage médiéval"
    },
    {
      title: "Retour accepté",
      description: "30 jours pour changer d'avis"
    }
  ].freeze

  self.inheritance_column = :_type_disabled
  belongs_to :highlight_1_company_document, class_name: "CompanyDocument", optional: true
  belongs_to :highlight_2_company_document, class_name: "CompanyDocument", optional: true
  belongs_to :highlight_3_company_document, class_name: "CompanyDocument", optional: true
  has_many :cart_products, dependent: :destroy
  has_many :carts, through: :cart_products
  has_many :order_products, dependent: :restrict_with_error
  has_one_attached :image
  has_many_attached :images
  before_validation :normalize_highlight_document_fields
  validate :validate_highlight_document_links

  def gallery_images
    all_images = []
    all_images << image.attachment if image.attached?
    all_images.concat(images.attachments.to_a) if images.attached?
    all_images.uniq(&:id)
  end

  def primary_image
    gallery_images.first
  end

  def highlight_boxes
    HIGHLIGHT_DEFAULTS.each_with_index.map do |defaults, idx|
      number = idx + 1
      document = highlight_document_for(number)
      document = nil unless highlight_document_enabled?(number) && document&.file&.attached?

      {
        enabled: send("highlight_#{number}_enabled"),
        title: send("highlight_#{number}_title").presence || defaults[:title],
        description: send("highlight_#{number}_description").presence || defaults[:description],
        document: document
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

  def highlight_document_for(number)
    public_send("highlight_#{number}_company_document")
  end

  def highlight_document_enabled?(number)
    ActiveModel::Type::Boolean.new.cast(public_send("highlight_#{number}_document_enabled"))
  end

  private

  def normalize_highlight_document_fields
    (1..3).each do |number|
      highlight_enabled = ActiveModel::Type::Boolean.new.cast(public_send("highlight_#{number}_enabled"))
      document_enabled = ActiveModel::Type::Boolean.new.cast(public_send("highlight_#{number}_document_enabled"))

      unless highlight_enabled
        public_send("highlight_#{number}_document_enabled=", false)
        public_send("highlight_#{number}_company_document_id=", nil)
        next
      end

      public_send("highlight_#{number}_company_document_id=", nil) unless document_enabled
    end
  end

  def validate_highlight_document_links
    (1..3).each do |number|
      highlight_enabled = ActiveModel::Type::Boolean.new.cast(public_send("highlight_#{number}_enabled"))
      document_enabled = ActiveModel::Type::Boolean.new.cast(public_send("highlight_#{number}_document_enabled"))
      next unless highlight_enabled && document_enabled

      document = highlight_document_for(number)
      if document.blank?
        errors.add("highlight_#{number}_company_document_id", "doit être sélectionné")
        next
      end

      errors.add("highlight_#{number}_company_document_id", "n'a pas de fichier PDF") unless document.file.attached?
    end
  end
end
