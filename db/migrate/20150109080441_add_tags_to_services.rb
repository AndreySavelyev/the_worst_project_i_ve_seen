class AddTagsToServices < ActiveRecord::Migration
  def change
    add_column :services, :tags, :text, array:true
  end
end
