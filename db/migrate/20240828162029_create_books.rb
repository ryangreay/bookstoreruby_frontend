class CreateBooks < ActiveRecord::Migration[7.2]
  def change
    create_table :books do |t|
      t.integer :pkbookid
      t.string :bookname
      t.string :authorname
      t.float :price

      t.timestamps
    end
  end
end
