class AddSeriesToDmmlists < ActiveRecord::Migration
  def change
    add_column :dmmlists, :series, :string
  end
end
