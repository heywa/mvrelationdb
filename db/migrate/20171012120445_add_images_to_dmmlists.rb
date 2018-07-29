class AddImagesToDmmlists < ActiveRecord::Migration
  def change
    add_column :dmmlists, :images, :string
  end
end
