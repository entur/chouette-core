class AddNameToPublicationSetups < ActiveRecord::Migration[4.2]
  def change
    add_column :publication_setups, :name, :string
  end
end
