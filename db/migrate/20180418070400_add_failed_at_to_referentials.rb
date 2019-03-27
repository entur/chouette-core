class AddFailedAtToReferentials < ActiveRecord::Migration[4.2]
  def change
    add_column :referentials, :failed_at, :datetime
  end
end
