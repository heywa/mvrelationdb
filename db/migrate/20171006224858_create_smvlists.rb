class CreateSmvlists < ActiveRecord::Migration
  def change
    create_table :smvlists do |t|
      t.string :smvid
      t.string :smvtitle
      t.string :tags
      t.string :smvtime
      t.string :smvurl
      t.date :updatedate

      t.timestamps null: false
    end
  end
end
