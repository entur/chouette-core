class CreateLineReferentials < ActiveRecord::Migration[4.2]
  def change
    create_table :line_referentials do |t|
      t.string :name

      t.timestamps
    end

    create_table :line_referential_memberships do |t|
      t.belongs_to :organisation
      t.belongs_to :line_referential
      t.boolean :owner
    end
  end
end
