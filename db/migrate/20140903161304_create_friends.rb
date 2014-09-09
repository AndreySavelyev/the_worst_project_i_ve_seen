class CreateFriends < ActiveRecord::Migration
  #таблица фрэндов, заполняется по результатам принятия/отклонения запроса на дружбу
  def change
    create_table :friends, id: false, join_table_name: 'friends'  do |t|
      t.integer :profile_id
      t.integer :friend_id

      t.timestamps
    end
#todo ADD INDEXES
    add_column :profiles, :friends_count, :integer , default: 0
    add_column :profiles, :temp_account, :boolean , default: FALSE
  end
end
