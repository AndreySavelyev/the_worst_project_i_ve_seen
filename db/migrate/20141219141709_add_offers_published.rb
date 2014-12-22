class AddOffersPublished < ActiveRecord::Migration
  def change
    add_column :offers, :published, :integer
  end
end
