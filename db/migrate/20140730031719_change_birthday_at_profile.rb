class ChangeBirthdayAtProfile < ActiveRecord::Migration
  def change
    remove_column( :profiles, :birthday, )
    add_column( :profiles, :birthday, :date )
    end
end
