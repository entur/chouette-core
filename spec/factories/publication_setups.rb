FactoryGirl.define do
  factory :publication_setup do
    sequence(:name) { |n| "Publication #{n}" }
    workgroup { create(:workgroup) }
    export_type "Export::Gtfs"
    export_options { { duration: 200 } }
    enabled false
  end
end
