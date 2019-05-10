class UpdateImportMessageCriticityTypeToString < ActiveRecord::Migration[4.2]
  def change
    change_column :import_messages, :criticity, :string

    def change_criticity_value criticity
      case criticity
      when 0 then "info"
      when 1 then "warning"
      when 2 then "error"
      else
        "info"
      end
    end
    Import::Message.all.each { |im| im.update_attribute(:criticity, change_criticity_value(im.criticity)) }
  end
end
