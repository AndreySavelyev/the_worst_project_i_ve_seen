class LimitsChangeValueType < ActiveRecord::Migration
  def change
    remove_column :limits, :value
    add_column :limits, :value, :integer
  end
end
