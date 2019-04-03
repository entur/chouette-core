class AddPublicOnPublicationApis < ActiveRecord::Migration
  def change
    on_public_schema_only do
      add_column :publication_apis, :public, :boolean, default: false
    end
  end
end
