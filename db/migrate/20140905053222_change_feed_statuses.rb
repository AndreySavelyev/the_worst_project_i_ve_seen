class ChangeFeedStatuses < ActiveRecord::Migration
  def change
    add_column :feeds, :status, :integer, default: 0 #статус запроса дружбы 0-new, 1-accepted, 2-declined
    add_column :feeds, :viewed, :integer, default: 0
    add_column :feeds, :type, :string, limit: 40, :default => 'Feed'
  end
end
