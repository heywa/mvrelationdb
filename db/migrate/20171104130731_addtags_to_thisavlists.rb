class AddtagsToThisavlists < ActiveRecord::Migration
  def change
  add_column :Thisavlists, :tags, :string
  end
end
