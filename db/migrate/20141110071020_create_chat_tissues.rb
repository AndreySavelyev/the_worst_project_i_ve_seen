class CreateChatTissues < ActiveRecord::Migration
  def change
    create_table :chat_tissues do |t|
      t.string :[text
      t.integer :from_profile_id
      t.string :to]

      t.timestamps
    end
  end
end
