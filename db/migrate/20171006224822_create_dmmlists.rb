class CreateDmmlists < ActiveRecord::Migration
  def change
    create_table :dmmlists do |t|
      t.string :dmmid
      t.string :dmmtitle
      t.string :genre
      t.string :thumburl
      t.string :afiriurl
      t.string :sampremovieurl
      t.string :sampleumageurl
      t.string :actressname
      t.string :direcrtorname
      t.date :instoredate
      t.date :updatedate

      t.timestamps null: false
    end
  end
end
