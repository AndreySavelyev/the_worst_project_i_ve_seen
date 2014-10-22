class ChangeComissionInFeed < ActiveRecord::Migration
  def change
    change_column :feeds, :trans_commission_id, :float
    rename_column :feeds, :trans_commission_id, :comission_value
  end
end
