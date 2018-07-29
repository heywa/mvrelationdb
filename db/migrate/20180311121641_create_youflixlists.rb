class CreateYouflixlists < ActiveRecord::Migration
  def change
    create_table :youflixlists do |t|
      t.string :youflixid
      t.string :youflixtitle
      t.string :tags
      t.string :youflixtime
      t.string :youflixurl
      t.date :updatedate
      t.string :youflixupdate
      t.text :explanation

      t.timestamps null: false
    end
  end
end
