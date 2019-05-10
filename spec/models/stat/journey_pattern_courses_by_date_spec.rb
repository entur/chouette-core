require 'rails_helper'

RSpec.describe Stat::JourneyPatternCoursesByDate, type: :model do
  let(:journey_pattern) { create :journey_pattern }
  let(:line) { create :line }
  let(:route) { journey_pattern.route }
  let(:service) { JourneyPatternOfferService.new(journey_pattern) }
  let(:referential_metadatas_1) do
    create :referential_metadata, line_ids: [line.id], periodes: [(period_start..period_end.prev_day)]
  end
  let(:referential_metadatas_2) do
    create :referential_metadata, line_ids: [line.id], periodes: [(period_start.next..period_end)]
  end
  let(:referential)  { create :workbench_referential, metadatas: [referential_metadatas_1, referential_metadatas_2] }
  let(:period_start) { 1.month.ago.to_date }
  let(:period_end)   { 1.month.since.to_date }

  before(:each) do
    referential.switch
    journey_pattern.route.update line: line
  end

  describe '#populate_for_journey_pattern' do
    it 'should create nothing' do
      expect { Stat::JourneyPatternCoursesByDate.populate_for_journey_pattern(journey_pattern) }.to_not(
        change { Stat::JourneyPatternCoursesByDate.count }
      )
    end

    context 'with a vehicle_journey' do
      let!(:vehicle_journey) { create :vehicle_journey, journey_pattern: journey_pattern, time_tables: time_tables }
      let(:time_tables) { [time_table] }
      let(:time_table) { create :time_table, periods_count: 0, dates_count: 0 }
      let(:circulation_day) { period_start + 10 }
      context 'with no hole' do
        before do
          time_table.periods.create!(period_start: period_start, period_end: circulation_day)
          time_table.periods.create!(period_start: circulation_day.next, period_end: period_end)
          Stat::JourneyPatternCoursesByDate.populate_for_journey_pattern(journey_pattern)
        end

        it 'should create instances' do
          period_start.upto(period_end).each do |date|
            expect(
              Stat::JourneyPatternCoursesByDate.where(journey_pattern_id: journey_pattern.id, date: date).exists?
            ).to be_truthy
          end
        end
      end

      context 'with a hole' do
        before do
          time_table.periods.create!(period_start: period_start, period_end: circulation_day.prev_day)
          time_table.periods.create!(period_start: circulation_day.next, period_end: period_end)
          Stat::JourneyPatternCoursesByDate.populate_for_journey_pattern(journey_pattern)
        end

        it 'should create instances' do
          period_start.upto(circulation_day.prev_day).each do |date|
            expect(
              Stat::JourneyPatternCoursesByDate.where(journey_pattern_id: journey_pattern.id, date: date).exists?
            ).to be_truthy
          end
          circulation_day.next.upto(period_end).each do |date|
            expect(
              Stat::JourneyPatternCoursesByDate.where(journey_pattern_id: journey_pattern.id, date: date).exists?
            ).to be_truthy
          end
        end
      end
    end
  end

  describe '#fill_blanks_for_empty_line' do
    it "should fill with holes" do
      expect { Stat::JourneyPatternCoursesByDate.fill_blanks_for_empty_line(line, referential: referential) }.to(
        change { Stat::JourneyPatternCoursesByDate.count }.by(period_end - period_start + 1)
      )
      period_start.upto(period_end) do |date|
        expect(
          Stat::JourneyPatternCoursesByDate.where(line_id: line.id, date: date).last.count
        ).to be_zero
      end
    end
  end

  describe '#fill_blanks_for_empty_route' do
    it "should fill with holes" do
      expect { Stat::JourneyPatternCoursesByDate.fill_blanks_for_empty_route(route, referential: referential) }.to(
        change { Stat::JourneyPatternCoursesByDate.count }.by(period_end - period_start + 1)
      )
      period_start.upto(period_end) do |date|
        expect(
          Stat::JourneyPatternCoursesByDate.where(line_id: line.id, date: date).last.count
        ).to be_zero
      end
    end
  end

  describe '#fill_blanks_for_journey_pattern' do
    it "should fill with holes" do
      Stat::JourneyPatternCoursesByDate.populate_for_journey_pattern(journey_pattern)
      expect { Stat::JourneyPatternCoursesByDate.fill_blanks_for_journey_pattern(journey_pattern) }.to(
        change { Stat::JourneyPatternCoursesByDate.count }.by(period_end - period_start + 1)
      )
      period_start.upto(period_end) do |date|
        expect(
          Stat::JourneyPatternCoursesByDate.where(journey_pattern_id: journey_pattern.id, date: date).last.count
        ).to be_zero
      end
    end

    context 'with a vehicle_journey' do
      let!(:vehicle_journey) { create :vehicle_journey, journey_pattern: journey_pattern, time_tables: time_tables }
      let(:time_tables) { [time_table] }
      let(:time_table) { create :time_table, periods_count: 0, dates_count: 0 }
      let(:circulation_day) { period_start + 10 }
      context 'with no hole' do
        before do
          time_table.periods.create!(period_start: period_start, period_end: circulation_day)
          time_table.periods.create!(period_start: circulation_day.next, period_end: period_end)
          Stat::JourneyPatternCoursesByDate.populate_for_journey_pattern(journey_pattern)
        end

        it 'should do nothing' do
          expect { Stat::JourneyPatternCoursesByDate.fill_blanks_for_journey_pattern(journey_pattern) }.to_not(
            change { Stat::JourneyPatternCoursesByDate.count }
          )
        end
      end

      context 'with a hole' do
        before do
          time_table.periods.create!(period_start: period_start, period_end: circulation_day.prev_day)
          time_table.periods.create!(period_start: circulation_day.next, period_end: period_end)
          Stat::JourneyPatternCoursesByDate.populate_for_journey_pattern(journey_pattern)
        end

        it 'should create instances' do
          Stat::JourneyPatternCoursesByDate.fill_blanks_for_journey_pattern(journey_pattern)
          expect(
            Stat::JourneyPatternCoursesByDate.where(journey_pattern_id: journey_pattern.id, date: circulation_day).exists?
          ).to be_truthy

          expect(
            Stat::JourneyPatternCoursesByDate.where(journey_pattern_id: journey_pattern.id, date: circulation_day).last.count
          ).to be_zero
        end
      end

      context 'with a hole at the start' do
        before do
          time_table.periods.create!(period_start: circulation_day, period_end: period_end)
          Stat::JourneyPatternCoursesByDate.populate_for_journey_pattern(journey_pattern)
        end

        it 'should create instances' do
          expect { Stat::JourneyPatternCoursesByDate.fill_blanks_for_journey_pattern(journey_pattern) }.to(
            change { Stat::JourneyPatternCoursesByDate.count }.by(circulation_day - period_start)
          )
          period_start.upto(period_end) do |date|
            expect(
              Stat::JourneyPatternCoursesByDate.where(journey_pattern_id: journey_pattern.id, date: date)
            ).to be_exists
          end
          period_start.upto(circulation_day.prev_day) do |date|
            expect(
              Stat::JourneyPatternCoursesByDate.where(journey_pattern_id: journey_pattern.id, date: date).last.count
            ).to be_zero
          end
          circulation_day.upto(period_end) do |date|
            expect(
              Stat::JourneyPatternCoursesByDate.where(journey_pattern_id: journey_pattern.id, date: date).last.count
            ).to eq 1
          end
        end
      end

      context 'with a hole at the end' do
        before do
          time_table.periods.create!(period_start: period_start, period_end: circulation_day)
          Stat::JourneyPatternCoursesByDate.populate_for_journey_pattern(journey_pattern)
        end

        it 'should create instances' do
          expect { Stat::JourneyPatternCoursesByDate.fill_blanks_for_journey_pattern(journey_pattern) }.to(
            change { Stat::JourneyPatternCoursesByDate.count }.by(period_end - circulation_day)
          )
          period_start.upto(period_end) do |date|
            expect(
              Stat::JourneyPatternCoursesByDate.where(journey_pattern_id: journey_pattern.id, date: date)
            ).to be_exists
          end
          period_start.upto(circulation_day) do |date|
            expect(
              Stat::JourneyPatternCoursesByDate.where(journey_pattern_id: journey_pattern.id, date: date).last.count
            ).to eq 1
          end
          circulation_day.next.upto(period_end) do |date|
            expect(
              Stat::JourneyPatternCoursesByDate.where(journey_pattern_id: journey_pattern.id, date: date).last.count
            ).to be_zero
          end
        end
      end
    end
  end
end
