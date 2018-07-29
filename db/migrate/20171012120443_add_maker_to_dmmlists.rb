class AddMakerToDmmlists < ActiveRecord::Migration
  def change
    add_column :dmmlists, :maker, :string
  end
end
