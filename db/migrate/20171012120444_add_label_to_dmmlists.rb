class AddLabelToDmmlists < ActiveRecord::Migration
  def change
    add_column :dmmlists, :label, :string
  end
end
