class CreateAfilinklists < ActiveRecord::Migration
  def change
    create_table :afilinklists do |t|
      t.string :afilinkurl
      t.string :afilinkasp
      t.text :memo

      t.timestamps null: false
    end
  end
end
