class UpdateImportsNames < ActiveRecord::Migration[4.2]
  def change
    Import::Base.all.pluck(:type).uniq.each do |type|
      next if type =~ /^Import/
      Import::Base.where(type: type).update_all type: "Import::#{type.gsub 'Import', ''}"
    end

    Import::Base.all.pluck(:parent_type).uniq.compact.each do |type|
      next if type =~ /^Import/
      Import::Base.where(parent_type: type).update_all parent_type: "Import::#{type.gsub 'Import', ''}"
    end
  end
end
