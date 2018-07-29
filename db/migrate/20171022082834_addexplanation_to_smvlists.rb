class AddexplanationToSmvlists < ActiveRecord::Migration
  def change
        add_column :Smvlists, :explanation, :text
  end
end
