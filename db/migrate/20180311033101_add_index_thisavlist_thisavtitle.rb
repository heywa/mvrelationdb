class AddIndexThisavlistThisavtitle < ActiveRecord::Migration
  def change
    add_index :Thisavlists, [:thisavid, :thisavtitle  ]
  end
end
