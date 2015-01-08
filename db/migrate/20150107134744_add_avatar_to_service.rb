class AddAvatarToService < ActiveRecord::Migration
  def change
      add_attachment  :services, :avatar
  end
end
