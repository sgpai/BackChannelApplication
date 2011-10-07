class CreateVotes < ActiveRecord::Migration
  def change
    create_table :votes do |t|
      t.integer :numberOfVotes

      t.references :user
      t.references :post
      t.timestamps
    end
  end
end
