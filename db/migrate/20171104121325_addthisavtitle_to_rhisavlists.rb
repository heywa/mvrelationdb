class AddthisavtitleToRhisavlists < ActiveRecord::Migration
  def change
      add_column :Thisavlists, :thisavtitle, :string
      add_column :Thisavlists, :thisavurl, :string

  end
end
