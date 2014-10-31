class AddIsDefaultToIbans < ActiveRecord::Migration
  def change
    add_column :ibans, :is_default, :boolean
  end
end
