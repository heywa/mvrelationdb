class AddIndexSmvlistSmvtitle < ActiveRecord::Migration
  def change
    add_index :Smvlists, [:smvid, :smvtitle  ]
  end
end
