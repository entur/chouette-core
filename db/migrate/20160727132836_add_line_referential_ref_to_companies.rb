class AddLineReferentialRefToCompanies < ActiveRecord::Migration[4.2]
  def change
    add_reference :companies, :line_referential, index: true
  end
end
