class AddHighlightDocumentsToProducts < ActiveRecord::Migration[8.1]
  def change
    add_column :products, :highlight_1_document_enabled, :boolean, default: false, null: false
    add_column :products, :highlight_2_document_enabled, :boolean, default: false, null: false
    add_column :products, :highlight_3_document_enabled, :boolean, default: false, null: false

    add_reference :products,
                  :highlight_1_company_document,
                  foreign_key: { to_table: :company_documents, on_delete: :nullify },
                  index: true

    add_reference :products,
                  :highlight_2_company_document,
                  foreign_key: { to_table: :company_documents, on_delete: :nullify },
                  index: true

    add_reference :products,
                  :highlight_3_company_document,
                  foreign_key: { to_table: :company_documents, on_delete: :nullify },
                  index: true
  end
end
