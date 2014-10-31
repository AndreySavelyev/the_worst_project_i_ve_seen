class AddRefPushToProfile < ActiveRecord::Migration
  def change
    add_reference :push_tokens, :profile, index: true
  end
end
