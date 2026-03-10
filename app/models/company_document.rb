class CompanyDocument < ApplicationRecord
  belongs_to :company_information
  has_one_attached :file

  validates :title, presence: true
  validate :file_presence
  validate :file_must_be_pdf

  scope :ordered, -> { order(created_at: :desc, title: :asc) }

  private

  def file_presence
    errors.add(:file, "doit être ajouté") unless file.attached?
  end

  def file_must_be_pdf
    return unless file.attached?

    return if file.blob.content_type == "application/pdf"

    errors.add(:file, "doit être au format PDF")
  end
end
