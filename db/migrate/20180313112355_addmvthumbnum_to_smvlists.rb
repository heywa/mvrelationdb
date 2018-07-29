class AddmvthumbnumToSmvlists < ActiveRecord::Migration
  def change
          add_column :Smvlists, :thumbnum, :string
  end
end
