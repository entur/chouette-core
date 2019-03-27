class AddReferentialSuiteToReferentials < ActiveRecord::Migration[4.2]
  def change
    add_reference :referentials, :referential_suite,
      index: true,
      foreign_key: true,
      type: :bigint
  end
end
