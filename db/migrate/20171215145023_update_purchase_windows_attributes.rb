class UpdatePurchaseWindowsAttributes < ActiveRecord::Migration[4.2]
  def change
    add_column :purchase_windows, :objectid, :string
    add_column :purchase_windows, :checksum, :string
    add_column :purchase_windows, :checksum_source, :text

    remove_column :purchase_windows, :short_name, :string
    remove_column :purchase_windows, :dates, :date
    remove_column :purchase_windows, :organisation_id, :integer

    add_reference :purchase_windows, :referential, type: :bigint, index: true
  end
end
