class AddAvatarToShopOffers < ActiveRecord::Migration
  def change
    add_attachment  :shops, :avatar
    add_attachment  :offers, :avatar
  end
end
