class CreateRequests < ActiveRecord::Migration
  def change
    create_table :requests do |t|
      t.integer :req_type
      t.integer :req_status
      t.integer :source
      t.integer :target

      t.timestamps
    end
  end
end
