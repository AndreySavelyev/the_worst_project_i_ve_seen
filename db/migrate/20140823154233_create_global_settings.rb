class CreateGlobalSettings < ActiveRecord::Migration
  def change
    create_table :global_settings do |t|
      t.string :settings_key , :null => false, :uniq => true
      t.string :settings_value
      t.timestamps
    end
  end
end
