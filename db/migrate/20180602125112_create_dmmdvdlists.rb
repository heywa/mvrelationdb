class CreateDmmdvdlists < ActiveRecord::Migration
  def change
    create_table :dmmdvdlists do |t|
      t.string :dmmid
      t.string :dmmtitle
      t.string :series
      t.string :maker
      t.string :label
      t.string :images
      t.string :genre
      t.string :thumburl
      t.string :afiriurl
      t.string :sampremovieurl
      t.string :sampleumageurl
      t.string :actressname
      t.string :direcrtorname
      t.date :instoredate
      t.date :updatedate
      t.string :series
      t.string :maker
      t.string :label
      t.string :images
      t.string :makerid

      t.timestamps null: false
    end
  end
end
