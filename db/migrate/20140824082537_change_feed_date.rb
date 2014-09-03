class ChangeFeedDate < ActiveRecord::Migration

  def up
    remove_column(:feeds, :feedDate)
    add_column :feeds, :feed_date, :date
  end

  def down
    add_column :feeds, :feedDate, :date
    remove_column :feeds, :feed_date
  end
end
