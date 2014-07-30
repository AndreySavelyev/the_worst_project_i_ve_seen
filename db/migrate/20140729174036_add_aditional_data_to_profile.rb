class AddAditionalDataToProfile < ActiveRecord::Migration
  def change
    add_column :profiles, :web_site, :string
    add_column :profiles, :address, :string
    add_column :profiles, :wallet_type, :int
  end
end
