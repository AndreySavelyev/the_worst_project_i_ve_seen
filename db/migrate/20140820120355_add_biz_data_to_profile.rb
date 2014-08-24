class AddBizDataToProfile < ActiveRecord::Migration
  def change
    add_column :profiles, :company_reg_number, :string
    add_column :profiles, :contact_person_name, :string
    add_column :profiles, :contact_person_position, :string
    add_column :profiles, :contact_person_date_of_birth, :date
    add_column :profiles, :contact_person_phone, :string
  end
end
