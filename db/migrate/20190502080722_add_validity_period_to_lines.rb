class AddValidityPeriodToLines < ActiveRecord::Migration[5.2]
  def change
    on_public_schema_only do
      add_column :lines, :active_from, :date
      add_column :lines, :active_until, :date
    end
  end
end
