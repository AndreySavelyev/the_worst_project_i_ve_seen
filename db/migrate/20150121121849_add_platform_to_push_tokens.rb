class AddPlatformToPushTokens < ActiveRecord::Migration
  def change
    add_column :push_tokens, :platform, :string
    PushTokens.reset_column_information
    reversible do |dir|
      dir.up { PushTokens.update_all platform: 'ios' }
    end

  end
end
