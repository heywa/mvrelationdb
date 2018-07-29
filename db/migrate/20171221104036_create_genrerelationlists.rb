class CreateGenrerelationlists < ActiveRecord::Migration
  def change
    create_table :genrerelationlists do |t|
      t.string :genrerelationid
      t.string :keyword
      t.string :medianame
      t.string :mvid
      t.datetime :posteddate

      t.timestamps null: false
    end
  end
end
