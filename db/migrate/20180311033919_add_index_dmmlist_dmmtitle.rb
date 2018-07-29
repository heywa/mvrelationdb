class AddIndexDmmlistDmmtitle < ActiveRecord::Migration
  def change
    add_index :Dmmlists, [:dmmid, :dmmtitle  ]
  end
end
