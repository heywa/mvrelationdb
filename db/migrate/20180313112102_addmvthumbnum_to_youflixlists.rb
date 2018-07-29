class AddmvthumbnumToYouflixlists < ActiveRecord::Migration
  def change
      add_column :Youflixlists, :thumbnum, :string
  end
end
