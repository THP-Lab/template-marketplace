class AddButtonLabelToHomePages < ActiveRecord::Migration[8.1]
  def change
    add_column :home_pages, :button_label, :string
  end
end
