class CreateOfferWorkbenches < ActiveRecord::Migration[4.2]
  def change
    create_table :offer_workbenches do |t|
      t.string :name
      t.references :organisation, index: true

      t.timestamps
    end
  end
end
