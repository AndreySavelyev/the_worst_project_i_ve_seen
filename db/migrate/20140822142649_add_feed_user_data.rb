class AddFeedUserData < ActiveRecord::Migration

  def up
    remove_column(:feeds, :feedType)
    remove_column(:feeds, :profile_id)

    add_column :feeds,:privacy, :integer
    add_column :feeds,:likes, :integer
    add_column :feeds,:description, :string
    add_column :feeds,:from_profile_id, :integer
    add_column :feeds,:to_profile_id, :integer
    add_column :feeds,:fType, :integer
  end

  def down
    add_column :feeds, :feedType, :string
    add_column :feeds, :profile_id, :integer

    remove_column :feeds,:privacy
    remove_column :feeds,:likes
    remove_column :feeds,:description
    remove_column :feeds,:from_profile_id
    remove_column :feeds,:to_profile_id
    remove_column :feeds,:fType
  end
end
