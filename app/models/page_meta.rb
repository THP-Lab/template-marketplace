class PageMeta < ApplicationRecord
  self.table_name = "page_metas"
  validates :page_key, presence: true, uniqueness: true

  def self.for(key)
    find_by(page_key: key.to_s)
  end
end
