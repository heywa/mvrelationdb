class AddIndexDmmdvdlistDmmtitle < ActiveRecord::Migration
  def change
    add_index :Dmmdvdlists, [:dmmid, :dmmtitle  ]
  end
end
