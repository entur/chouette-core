require 'spec_helper'

describe Chouette::JourneyPattern, :type => :model do

  subject { create(:journey_pattern) }

  describe 'checksum' do
    it_behaves_like 'checksum support'

    context "when a stop_point is updated" do
      it "should update checksum" do
        expect do
          subject.stop_points.first.update position: subject.stop_points.size
        end.to(change{subject.reload.checksum})
      end
    end

    context "when the costs are updated" do
      it "should update checksum" do
        expect do
          subject.update costs:  {"1-2" => {distance: 12}}
        end.to(change{subject.reload.checksum})
      end
    end

    context "when the costs are updated but do not actually change" do
      it "should not update checksum" do
        subject.update costs:  {"1-2" => {distance: 12}}

        [
          {"1-2" => {distance: 12, time: nil}},
          {"1-2" => {distance: 12, time: 0}},
          {"1-2" => {distance: 12, time: "0"}},
          {"1-2" => {distance: 12, time: nil}, "3-4" => {}},
          {"1-2" => {distance: 12, time: nil}, "3-4" => {distance: 0}},
        ].each do |costs|
          expect{ subject.update(costs:  costs) }.to_not(change{ subject.reload.checksum })
        end
      end
    end
  end

  describe 'when the stop_points are modified' do
    let(:journey_pattern) { create :journey_pattern }
    let(:vehicle_journey) { create :vehicle_journey, journey_pattern: journey_pattern }

    describe 'when a stop_point is removed' do
      it 'should remove it from its vehicle_journeys' do
        expect(vehicle_journey.vehicle_journey_at_stops.count).to eq journey_pattern.stop_points.count
        journey_pattern.reload

        expect { journey_pattern.stop_points.delete(journey_pattern.stop_points.last) }.to(
          change { vehicle_journey.reload.vehicle_journey_at_stops.count }.by(-1)
        )
      end
    end

    describe 'when a stop_point is added' do
      let(:stop_point) { create :stop_point }
      it 'should remove it from its vehicle_journeys' do
        expect(vehicle_journey.vehicle_journey_at_stops.count).to eq journey_pattern.stop_points.count
        journey_pattern.reload

        expect { journey_pattern.stop_points << stop_point }.to(
          change { vehicle_journey.reload.vehicle_journey_at_stops.count }.by(1)
        )
      end
    end
  end

  describe 'costs' do
    let(:journey_pattern) { create :journey_pattern }

    context "with a negative distance" do
      before(:each){
        journey_pattern.costs = generate_journey_pattern_costs(->(i){i == 1 ? -1 : 10}, 10)
      }
      it 'should not be valid' do
        expect(journey_pattern).to_not be_valid
      end
    end

    context "with a negative time" do
      before(:each){
        journey_pattern.costs = generate_journey_pattern_costs(10, ->(i){i == 1 ? -1 : 10})
      }
      it 'should not be valid' do
        expect(journey_pattern).to_not be_valid
      end
    end
  end

  describe "full_schedule?" do
    let(:journey_pattern) { create :journey_pattern }
    subject{ journey_pattern.full_schedule? }
    context "when no time is set" do
      it { should be_falsy }
    end

    context "when the costs are incomplete" do
      context "with a missing time" do
        before(:each){
          journey_pattern.costs = generate_journey_pattern_costs(10, ->(i){i == 1 ? nil : 10})
        }
        it { should be_falsy }
      end
    end

    context "when all the times are set" do
      before(:each){
        journey_pattern.costs = generate_journey_pattern_costs(10, 10)
      }
      it { should be_truthy }
    end

    context "with a missing distance" do
      before(:each){
        journey_pattern.costs = generate_journey_pattern_costs(->(i){i == 1 ? nil : 10}, 10)
      }
      it { should be_truthy }
    end

    context "with a zeroed distance" do
      before(:each){
        journey_pattern.costs = generate_journey_pattern_costs(->(i){i == 1 ? 0 : 10}, 10)
      }
      it { should be_truthy }
    end
  end

  describe "distance_to" do
    let(:journey_pattern) { create :journey_pattern }
    before do
      journey_pattern.costs = generate_journey_pattern_costs(10, 10)
    end
    subject{ journey_pattern.distance_to stop}
    context "for the first stop" do
      let(:stop){ journey_pattern.stop_points.first }
      it { should eq 0 }
    end

    context "for the last stop" do
      let(:stop){ journey_pattern.stop_points.last }
      it { should eq 40 }
    end
  end

  describe "set_distances" do
    let(:journey_pattern) { create :journey_pattern }
    let(:distances){ [] }
    it "should raise an error" do
      expect{journey_pattern.set_distances(distances)}.to raise_error(RuntimeError)
    end

    context "with consistent data" do
      let(:distances){ [0, 100, "200", 500, 1000] }

      it "should set costs" do
        expect{journey_pattern.set_distances(distances)}.to_not raise_error
        start, stop = journey_pattern.stop_points[0..1]
        expect(journey_pattern.costs_between(start, stop)[:distance]).to eq 100
        start, stop = journey_pattern.stop_points[1..2]
        expect(journey_pattern.costs_between(start, stop)[:distance]).to eq 100
        start, stop = journey_pattern.stop_points[2..3]
        expect(journey_pattern.costs_between(start, stop)[:distance]).to eq 300
        start, stop = journey_pattern.stop_points[3..4]
        expect(journey_pattern.costs_between(start, stop)[:distance]).to eq 500
      end
    end
  end

  describe "state_update" do
    def journey_pattern_to_state jp
      jp.attributes.slice('name', 'published_name', 'registration_number').tap do |item|
        item['object_id']   = jp.objectid
        item['stop_points'] = jp.stop_points.map do |sp|
          { 'id' => sp.stop_area_id, 'position' => sp.position, 'checked' => '1' }
        end
        item['costs'] = jp.costs
      end
    end

    let(:route) { create :route, stop_points_count: 5 }
    let(:journey_pattern) { create :journey_pattern, route: route }
    let(:state) { journey_pattern_to_state(journey_pattern) }
    let!(:vehicle_journey) { create :vehicle_journey, journey_pattern: journey_pattern }

    it 'should delete unchecked stop_points' do
      expect(journey_pattern.stop_points.count).to eq(5)
      expect(vehicle_journey.reload.vehicle_journey_at_stops.count).to eq(5)
      # Of 5 stop_points 2 are checked
      state['stop_points'].each{|sp| sp['checked'] = false}
      state['stop_points'].take(2).each{|sp| sp['checked'] = true}
      journey_pattern.state_stop_points_update(state)
      expect(journey_pattern.stop_points.count).to eq(2)
      expect(vehicle_journey.reload.vehicle_journey_at_stops.count).to eq(2)
    end

    it 'should attach checked stop_points' do
      # Make sure journey_pattern has no stop_points
      state['stop_points'].each{|sp| sp['checked'] = false}
      journey_pattern.state_stop_points_update(state)
      expect(journey_pattern.reload.stop_points).to be_empty
      expect(vehicle_journey.reload.vehicle_journey_at_stops).to be_empty

      state['stop_points'].each{|sp| sp['checked'] = true}
      journey_pattern.state_stop_points_update(state)

      expect(journey_pattern.reload.stop_points.count).to eq(5)
      expect(vehicle_journey.reload.vehicle_journey_at_stops.count).to eq(5)
    end

    it 'should build a journey_pattern' do
      new_state = journey_pattern_to_state(build(:journey_pattern, objectid: nil, route: route, stop_points: route.stop_points))
      expect {
        Chouette::JourneyPattern.state_create_instance(route, new_state)
      }.to change{Chouette::JourneyPattern.count}.by(1)
      expect(new_state['object_id']).to be_truthy
      expect(new_state['new_record']).to be_truthy
    end

    it 'should create journey_pattern with state_update' do
      jp = build(:journey_pattern, objectid: nil, route: route)
      jp.stop_points = jp.route.stop_points
      new_state = journey_pattern_to_state(jp)
      collection = [new_state]
      jp.delete
      expect {
        Chouette::JourneyPattern.state_update route, collection
      }.to change{ Chouette::JourneyPattern.count }.by(1)
    end

    it 'should delete journey_pattern' do
      state['deletable'] = true
      collection = [state]
      expect {
        Chouette::JourneyPattern.state_update route, collection
      }.to change{Chouette::JourneyPattern.count}.from(1).to(0)

      expect(collection).to be_empty
    end

    it 'should delete multiple journey_pattern' do
      Chouette::JourneyPattern.delete_all
      collection = 5.times.collect{journey_pattern_to_state(create(:journey_pattern, route: route))}
      collection.map{|i| i['deletable'] = true}

      expect {
        Chouette::JourneyPattern.state_update route, collection
      }.to change{Chouette::JourneyPattern.count}.from(5).to(0)
    end

    it 'should validate journey_pattern on update' do
      journey_pattern.name = ''
      collection = [state]
      Chouette::JourneyPattern.state_update route, collection
      expect(collection.first['errors']).to have_key(:name)
    end

    it 'should validate journey_pattern on create' do
      new_state  = journey_pattern_to_state(build(:journey_pattern, name: '', objectid: nil, route: route))
      collection = [new_state]
      expect {
        Chouette::JourneyPattern.state_update route, collection
      }.to_not change{Chouette::JourneyPattern.count}

      expect(collection.first['errors']).to have_key(:name)
      expect(collection.first).to_not have_key('object_id')
    end

    it 'should not save any journey_pattern of collection if one is invalid' do
      journey_pattern.name = ''
      valid_state   = journey_pattern_to_state(build(:journey_pattern, objectid: nil, route: route))
      invalid_state = journey_pattern_to_state(journey_pattern)
      collection    = [valid_state, invalid_state]

      expect {
        Chouette::JourneyPattern.state_update route, collection
      }.to_not change{Chouette::JourneyPattern.count}

      expect(collection.first).to_not have_key('object_id')
    end
  end

  describe "#stop_point_ids" do
    context "for a journey_pattern using only route's stop on odd position" do
      let!(:journey_pattern){ create( :journey_pattern_odd)}
      let!(:vehicle_journey){ create( :vehicle_journey_odd, :journey_pattern => journey_pattern)}

      # workaroud
      #subject { journey_pattern}
      subject { Chouette::JourneyPattern.find(vehicle_journey.journey_pattern_id)}

      context "when a all route's stop have been removed from journey_pattern" do
        before(:each) do
          subject.stop_point_ids = []
        end
        it "should remove all vehicle_journey_at_stop" do
          vjas_stop_ids = Chouette::VehicleJourney.find(vehicle_journey.id).vehicle_journey_at_stops
          expect(vjas_stop_ids.count).to eq(0)
        end
        it "should keep departure and arrival shortcut up to date to nil" do
          expect(subject.arrival_stop_point_id).to be_nil
          expect(subject.departure_stop_point_id).to be_nil
        end
      end

      context "when a route's stop has been removed from journey_pattern" do
        let!(:last_stop_id){ subject.stop_point_ids.last}
        before(:each) do
          subject.stop_point_ids = subject.stop_point_ids - [last_stop_id]
        end
        it "should remove vehicle_journey_at_stop for last stop" do
          vjas_stop_ids = Chouette::VehicleJourney.find(vehicle_journey.id).vehicle_journey_at_stops.map(&:stop_point_id)
          expect(vjas_stop_ids.count).to eq(subject.stop_point_ids.size)
          expect(vjas_stop_ids).not_to include( last_stop_id)
        end
        it "should keep departure and arrival shortcut up to date" do
          ordered = subject.stop_points.sort { |a,b| a.position <=> b.position}

          expect(subject.arrival_stop_point_id).to eq(ordered.last.id)
          expect(subject.departure_stop_point_id).to eq(ordered.first.id)
        end
      end

      context "when a route's stop has been added in journey_pattern" do
        let!(:new_stop){ subject.route.stop_points[1]}
        before(:each) do
          subject.stop_point_ids = subject.stop_point_ids + [new_stop.id]
        end
        it "should add a new vehicle_journey_at_stop for that stop" do
          vjas_stop_ids = Chouette::VehicleJourney.find(vehicle_journey.id).vehicle_journey_at_stops.map(&:stop_point_id)
          expect(vjas_stop_ids.count).to eq(subject.stop_point_ids.size)
          expect(vjas_stop_ids).to include( new_stop.id)
        end
        it "should keep departure and arrival shortcut up to date" do
          ordered = subject.stop_points.sort { |a,b| a.position <=> b.position}

          expect(subject.arrival_stop_point_id).to eq(ordered.last.id)
          expect(subject.departure_stop_point_id).to eq(ordered.first.id)
        end
      end
    end
  end
end
