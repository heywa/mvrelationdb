class AddpotdateToRelationlists < ActiveRecord::Migration
  def change
      add_column :Relationlists, :potdate, :date
  end
end
