module Chouette
  module WorkgroupFromClass
    def workgroup
      self.class.current_workgroup || super
    end
  end

  class Company < Chouette::ActiveRecord
    has_metadata

    prepend WorkgroupFromClass

    include CompanyRestrictions
    include LineReferentialSupport
    include ObjectidSupport
    include CustomFieldsSupport

    has_many :lines, dependent: :nullify

    # validates_format_of :registration_number, :with => %r{\A[0-9A-Za-z_-]+\Z}, :allow_nil => true, :allow_blank => true
    validates_presence_of :name

    # Cf. #8132
    # validates_format_of :url, :with => %r{\Ahttps?:\/\/([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?\Z}, :allow_nil => true, :allow_blank => true

    def self.nullable_attributes
      [:organizational_unit, :operating_department_name, :code, :phone, :fax, :email, :url, :time_zone]
    end
  end
end
