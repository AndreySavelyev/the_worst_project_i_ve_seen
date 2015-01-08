class AddPublishedToService < ActiveRecord::Migration
  def change
    add_column :services, :published, :integer
  end
end
