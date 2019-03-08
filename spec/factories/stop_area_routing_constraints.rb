FactoryGirl.define do
  factory :stop_area_routing_constraint do
    association :from, :factory => :stop_area
    association :to, :factory => :stop_area
    both_way true
  end
end
