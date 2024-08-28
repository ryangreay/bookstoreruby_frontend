class CreateUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :users do |t|
      t.integer :pkuserid
      t.string :username
      t.string :password
      t.float :cash
      t.string :accesstoken

      t.timestamps
    end
  end
end
