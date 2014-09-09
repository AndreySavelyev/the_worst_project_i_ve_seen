class AddFeedAmount < ActiveRecord::Migration
  def change
    add_column :feeds, :amount, :int
    add_column :feeds, :currency, :string, :limit => 3
  end
end
