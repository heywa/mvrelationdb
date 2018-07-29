class AddSmvupdateToSmvlists < ActiveRecord::Migration
  def change
    add_column :smvlists, :smvupdate, :string
  end
end
