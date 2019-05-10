module ReferentialHelper

  def first_referential
    Referential.find_by!(:slug => "first")
  end

  def first_organisation
    Organisation.find_by!(code: "first")
  end

  def first_workgroup
    Workgroup.find_by_name('IDFM')
  end

  def self.included(base)
    base.class_eval do
      extend ClassMethods
      base.let(:referential){ first_referential }
      base.let(:organisation){ first_organisation }
    end
  end

  module ClassMethods

    def assign_referential
      before(:each) do
        assign :referential, referential
      end
    end
    def assign_organisation
      before(:each) do
        assign :organisation, referential.organisation
      end
    end

  end

end

RSpec.configure do |config|
  config.include ReferentialHelper

  config.before(:suite) do
    # Clean all tables to start
    DatabaseCleaner.clean_with :truncation, except: %w[spatial_ref_sys]
    # Truncating doesn't drop schemas, ensure we're clean here, first *may not* exist
    Apartment::Tenant.drop('first') rescue nil
    # Create the default tenant for our tests
    organisation = Organisation.create!(code: "first", name: "first")

    line_referential = LineReferential.find_or_create_by(name: "first") do |referential|
      referential.objectid_format = "stif_codifligne"
      referential.add_member organisation, owner: true
    end
    stop_area_referential = StopAreaReferential.find_or_create_by(name: "first") do |referential|
      referential.objectid_format = "stif_reflex"
      referential.add_member organisation, owner: true
    end

    workgroup = FactoryGirl.create(
      :workgroup,
      name: "IDFM",
      line_referential: line_referential,
      stop_area_referential: stop_area_referential
    )

    workbench = FactoryGirl.create(
      :workbench,
      name: "Gestion de l'offre",
      organisation: organisation,
      workgroup: workgroup,
      line_referential: line_referential,
      stop_area_referential: stop_area_referential,
      prefix: organisation.code
    )
    referential = FactoryGirl.create(
      :referential,
      prefix: workbench.prefix,
      name: "first",
      slug: "first",
      organisation: organisation,
      workbench: workbench,
      objectid_format: "stif_netex"
    )
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
    # Switch into the default tenant
    first_referential.switch
  end

  config.before(:each, truncation: true) do
    DatabaseCleaner.strategy = :truncation, { except: %w[spatial_ref_sys] }
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    # Reset tenant back to `public`
    Apartment::Tenant.reset
    # Rollback transaction

    # we need the rescue, see https://github.com/rails/webpacker/issues/422
    DatabaseCleaner.clean rescue nil
  end

end
