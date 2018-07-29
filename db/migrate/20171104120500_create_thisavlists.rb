class CreateThisavlists < ActiveRecord::Migration
  def change
    create_table :thisavlists do |t|
      t.string :thisavid
      t.string :smvtitle
      t.date :updatedate

      t.timestamps null: false
    end
  end
end
