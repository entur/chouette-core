class MakeReferentialsSlugsUniqueAgain < ActiveRecord::Migration[4.2]
  def change
    on_public_schema_only do
      add_index :referentials, :slug, unique: true
    end
  end
end
