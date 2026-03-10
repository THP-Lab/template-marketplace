class CreateCompanyDocuments < ActiveRecord::Migration[8.1]
  def change
    create_table :company_documents do |t|
      t.references :company_information, null: false, foreign_key: true
      t.string :title, null: false

      t.timestamps
    end
  end
end
