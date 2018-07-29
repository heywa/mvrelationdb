class RelationtblDelete < ActiveRecord::Migration
  def change
    drop_table :relationtbls
  end
end
