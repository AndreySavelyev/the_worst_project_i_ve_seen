class ChangeChatTissueToProfileType < ActiveRecord::Migration
  def change
    remove_column :chat_tissues, :to_profile_id
    add_column :chat_tissues, :to_profile_id, :integer
  end
end
