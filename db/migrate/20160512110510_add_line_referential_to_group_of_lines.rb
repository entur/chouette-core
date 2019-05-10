class AddLineReferentialToGroupOfLines < ActiveRecord::Migration[4.2]
  def change
    add_reference :group_of_lines, :line_referential, index: true
  end
end
