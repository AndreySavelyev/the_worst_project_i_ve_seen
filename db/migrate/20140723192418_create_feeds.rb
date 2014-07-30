class CreateFeeds < ActiveRecord::Migration
  def change
    create_table :feeds do |t|
      t.date :feedDate
      t.string :message
      t.string :feedType
      t.belongs_to :profile, index: true

      t.timestamps
    end
  end
end
