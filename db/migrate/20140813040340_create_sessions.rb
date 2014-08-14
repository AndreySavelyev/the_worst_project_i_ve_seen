class CreateSessions < ActiveRecord::Migration
  def change
    create_table :sessions do |t|
      t.string :SessionId, :null => false, :uniq => true
      t.datetime :TimeToDie
      t.belongs_to :profile, index: true
      t.belongs_to :application, index: true

      t.timestamps
    end
  end
end
