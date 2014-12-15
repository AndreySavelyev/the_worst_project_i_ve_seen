class AddOfferUrl < ActiveRecord::Migration
  def change
    add_column :offers, :url, :string
  end
end
