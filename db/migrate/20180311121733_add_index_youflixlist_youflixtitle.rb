class AddIndexYouflixlistYouflixtitle < ActiveRecord::Migration
  def change
        add_index :Youflixlists, [:youflixid, :youflixtitle  ]
  end
end
