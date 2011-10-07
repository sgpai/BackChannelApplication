class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.string :postString
      t.integer :parentPostID
      t.float :weight
      t.integer :totalVotes
      t.references :user
      t.timestamps
    end
  end
end
