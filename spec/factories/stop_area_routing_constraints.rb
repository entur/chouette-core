FactoryGirl.define do
  factory :stop_area_routing_constraint do
    association :from, :factory => :stop_area
    association :to, :factory => :stop_area
    both_way true

    transient do
      stop_area_referential nil
    end

    before(:create) do |stop_area_routing_constraint, evaluator|
      stop_area_referential = evaluator.stop_area_referential || create(:stop_area_referential)
      stop_area_routing_constraint.from = create(:stop_area, stop_area_referential: stop_area_referential)
      stop_area_routing_constraint.to = create(:stop_area, stop_area_referential: stop_area_referential)
    end
  end
end
