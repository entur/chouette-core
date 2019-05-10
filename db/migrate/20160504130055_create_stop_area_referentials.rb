class CreateStopAreaReferentials < ActiveRecord::Migration[4.2]
  def change
    create_table :stop_area_referentials do |t|
      t.string :name

      t.timestamps
    end

    create_table :stop_area_referential_memberships do |t|
      t.belongs_to :organisation
      t.belongs_to :stop_area_referential
      t.boolean :owner
    end
  end
end
