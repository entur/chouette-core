require 'spec_helper'

describe Chouette::Route, :type => :model do
  subject { create(:route) }

  describe ".includes_first_and_last_stop_area" do
    it "joins Chouette::StopArea and includes only the first & last stops" do
      expected_route = create(:route)

      route = Chouette::Route.includes_first_and_last_stop_area.first

      expect(route.stop_points.length).to eq(1)
      expect(route.stop_points.first.position).to eq(0)
    end
  end

  describe '#objectid' do
    subject { super().objectid }
    it { is_expected.to be_kind_of(Chouette::ObjectId) }
  end

  it { is_expected.to enumerize(:direction).in(:straight_forward, :backward, :clockwise, :counter_clockwise, :north, :north_west, :west, :south_west, :south, :south_east, :east, :north_east) }
  it { is_expected.to enumerize(:wayback).in(:straight_forward, :backward) }

  #it { is_expected.to validate_presence_of :name }
  it { is_expected.to validate_presence_of :line }
  it { is_expected.to validate_uniqueness_of :objectid }
  #it { is_expected.to validate_presence_of :wayback_code }
  #it { is_expected.to validate_presence_of :direction_code }
  it { is_expected.to validate_inclusion_of(:direction).in_array(%i(straight_forward backward clockwise counter_clockwise north north_west west south_west south south_east east north_east)) }
  it { is_expected.to validate_inclusion_of(:wayback).in_array(%i(straight_forward backward)) }

  context "reordering methods" do
    let( :bad_stop_point_ids){subject.stop_points.map { |sp| sp.id + 1}}
    let( :ident){subject.stop_points.map(&:id)}
    let( :first_last_swap){ [ident.last] + ident[1..-2] + [ident.first]}

    describe "#reorder!" do
      context "invalid stop_point_ids" do
        let( :new_stop_point_ids) { bad_stop_point_ids}
        it { expect(subject.reorder!( new_stop_point_ids)).to be_falsey}
      end

      context "swaped last and first stop_point_ids" do
        let!( :new_stop_point_ids) { first_last_swap}
        let!( :old_stop_point_ids) { subject.stop_points.map(&:id) }
        let!( :old_stop_area_ids) { subject.stop_areas.map(&:id) }

        it "should keep stop_point_ids order unchanged" do
          expect(subject.reorder!( new_stop_point_ids)).to be_truthy
          expect(subject.stop_points.map(&:id)).to eq( old_stop_point_ids)
        end
        # This test is no longer relevant, as reordering is done with Reactux
        # it "should have changed stop_area_ids order" do
        #   expect(subject.reorder!( new_stop_point_ids)).to be_truthy
        #   subject.reload
        #   expect(subject.stop_areas.map(&:id)).to eq( [old_stop_area_ids.last] + old_stop_area_ids[1..-2] + [old_stop_area_ids.first])
        # end
      end
    end

    describe "#stop_point_permutation?" do
      context "invalid stop_point_ids" do
        let( :new_stop_point_ids) { bad_stop_point_ids}
        it { is_expected.not_to be_stop_point_permutation( new_stop_point_ids)}
      end
      context "unchanged stop_point_ids" do
        let( :new_stop_point_ids) { ident}
        it { is_expected.to be_stop_point_permutation( new_stop_point_ids)}
      end
      context "swaped last and first stop_point_ids" do
        let( :new_stop_point_ids) { first_last_swap}
        it { is_expected.to be_stop_point_permutation( new_stop_point_ids)}
      end
    end
  end

  describe "#stop_points_attributes=" do
      let( :journey_pattern) { create( :journey_pattern, :route => subject )}
      let( :vehicle_journey) { create( :vehicle_journey, :journey_pattern => journey_pattern)}
      def subject_stop_points_attributes
          {}.tap do |hash|
              subject.stop_points.each_with_index { |sp,index| hash[ index.to_s ] = sp.attributes }
          end
      end
      context "route having swapped a new stop" do
          let( :new_stop_point ){build( :stop_point, :route => subject)}
          def added_stop_hash
            subject_stop_points_attributes.tap do |h|
                h["4"] = new_stop_point.attributes.merge( "position" => "4", "_destroy" => "" )
            end
          end
          let!( :new_route_size ){ subject.stop_points.size+1 }

          it "should have added stop_point in route" do
              subject.update_attributes( :stop_points_attributes => added_stop_hash)
              expect(Chouette::Route.find( subject.id ).stop_points.size).to eq(new_route_size)
          end
          it "should have added stop_point in route's journey pattern" do
              subject.update_attributes( :stop_points_attributes => added_stop_hash)
              expect(Chouette::JourneyPattern.find( journey_pattern.id ).stop_points.size).to eq(new_route_size)
          end
          it "should have added stop_point in route's vehicle journey at stop" do
              subject.update_attributes( :stop_points_attributes => added_stop_hash)
              expect(Chouette::VehicleJourney.find( vehicle_journey.id ).vehicle_journey_at_stops.size).to eq(new_route_size)
          end
      end
      context "route having swapped stop" do
          def swapped_stop_hash
            subject_stop_points_attributes.tap do |h|
                h[ "1" ][ "position" ] = "3"
                h[ "3" ][ "position" ] = "1"
            end
          end
          let!( :new_stop_id_list ){ subject.stop_points.map(&:id).tap {|array| array.insert( 1, array.delete_at(3)); array.insert( 3, array.delete_at(2) )} }

          it "should have swap stop_points from route" do
              subject.update_attributes( :stop_points_attributes => swapped_stop_hash)
              expect(Chouette::Route.find(subject.id).stop_points.map(&:id).sort).to eq(new_stop_id_list.sort)
          end
          it "should have swap stop_points from route's journey pattern" do
              subject.update_attributes( :stop_points_attributes => swapped_stop_hash)
              expect(Chouette::JourneyPattern.find( journey_pattern.id ).stop_points.map(&:id).sort).to eq(new_stop_id_list.sort)
          end
          it "should have swap stop_points from route's vehicle journey at stop" do
              subject.update_attributes( :stop_points_attributes => swapped_stop_hash)
              expect(Chouette::VehicleJourney.find( vehicle_journey.id ).vehicle_journey_at_stops.map(&:stop_point_id)).to match_array(new_stop_id_list)
          end
      end
      context "route having a deleted stop" do
          def removed_stop_hash
            subject_stop_points_attributes.tap do |h|
                h[ "1" ][ "_destroy" ] = "1"
            end
          end
          let!( :new_stop_id_list ){ subject.stop_points.map(&:id).tap {|array| array.delete_at(1) } }

          it "should ignore deleted stop_point from route" do
              subject.update_attributes( :stop_points_attributes => removed_stop_hash)
              expect(Chouette::Route.find( subject.id ).stop_points.map(&:id).sort).to eq(new_stop_id_list.sort)
          end
          it "should ignore deleted stop_point from route's journey pattern" do
              subject.update_attributes( :stop_points_attributes => removed_stop_hash)
              expect(Chouette::JourneyPattern.find( journey_pattern.id ).stop_points.map(&:id).sort).to eq(new_stop_id_list.sort)
          end
          it "should ignore deleted stop_point from route's vehicle journey at stop" do
              subject.update_attributes( :stop_points_attributes => removed_stop_hash)
              expect(Chouette::VehicleJourney.find( vehicle_journey.id ).vehicle_journey_at_stops.map(&:stop_point_id).sort).to match_array(new_stop_id_list.sort)
          end
      end
  end

  describe "#stop_points" do
    context "#find_by_stop_area" do
      context "when arg is first quay id" do
        let(:first_stop_point) { subject.stop_points.first}
        it "should return first quay" do
          expect(subject.stop_points.find_by_stop_area( first_stop_point.stop_area_id)).to eq( first_stop_point)
        end
      end
    end
  end
  describe "#stop_areas" do
    let(:line){ create(:line)}
    let(:route_1){ create(:route, :line => line)}
    let(:route_2){ create(:route, :line => line)}
    it "should retreive all stop_area on route" do
      route_1.stop_areas.each do |sa|
        expect(sa.stop_points.map(&:route_id).uniq).to eq([route_1.id])
      end
    end

    context "when route is looping: last and first stop area are the same" do
      it "should retreive same stop_area one last and first position" do
        route_loop = create(:route, :line => line)
        first_stop = Chouette::StopPoint.where( :route_id => route_loop.id, :position => 0).first
        last_stop = create(:stop_point, :route => route_loop, :position => 4, :stop_area => first_stop.stop_area)

        expect(route_loop.stop_areas.size).to eq(6)
        expect(route_loop.stop_areas.select {|s| s.id == first_stop.stop_area.id}.size).to eq(2)
      end
    end
  end
end
