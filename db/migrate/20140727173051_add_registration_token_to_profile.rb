class AddRegistrationTokenToProfile < ActiveRecord::Migration
  def change
    add_column :profiles, :reg_token, :string
    add_column :profiles, :confirm_type, :integer
  end
end
