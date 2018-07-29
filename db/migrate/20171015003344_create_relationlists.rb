class CreateRelationlists < ActiveRecord::Migration
  def change
    create_table :relationlists do |t|
      t.string :relationid
      t.string :frommvid
      t.string :tomvid
      t.string :fromtitle
      t.string :totitle
      t.date :updatedate

      t.timestamps null: false
    end
  end
end
