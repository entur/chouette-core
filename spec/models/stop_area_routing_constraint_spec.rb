require 'rails_helper'

RSpec.describe StopAreaRoutingConstraint, type: :model do
  subject { create(:stop_area_routing_constraint) }

  it 'should validate that both stops are in the same referential and different' do
    stop_1 = build :stop_area
    stop_2 = build :stop_area
    sarc = StopAreaRoutingConstraint.new from: stop_1, to: stop_2
    expect(sarc).to_not be_valid
    stop_2.stop_area_referential = stop_1.stop_area_referential
    expect(sarc).to be_valid
    sarc = StopAreaRoutingConstraint.new from: stop_1, to: stop_1
    expect(sarc).to_not be_valid
  end

  describe 'checksum' do
    it_behaves_like 'checksum support'
  end

  describe '#with_stop' do
    let!(:constraint){ create :stop_area_routing_constraint }
    let!(:other_constraint){ create :stop_area_routing_constraint }
    let!(:common_constraint){ create :stop_area_routing_constraint, from_stop_area: constraint.to }

    it 'should filter StopAreaRoutingConstraints' do
      expect(StopAreaRoutingConstraint.with_stop(constraint.from)).to match_array [constraint]
      expect(StopAreaRoutingConstraint.with_stop(constraint.to)).to match_array [constraint, common_constraint]
    end
  end
end
