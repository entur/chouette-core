class InsertDefaultOrganisation < ActiveRecord::Migration[4.2]
  class Organisation  < ApplicationModel
    attr_accessor :name
  end

  def up
    organisation = Organisation.find_or_create_by!(:name => "Chouette")
    Referential.where(  :organisation_id => nil).each do |r|
      r.update_attributes :organisation_id => organisation.id
    end
    User.where(  :organisation_id => nil).each do |r|
      r.update_attributes :organisation_id => organisation.id
    end
  end

  def down
    organisations = Organisation.where( :name => "Chouette")
    organisations.first.destroy unless organisations.empty?
  end
end

