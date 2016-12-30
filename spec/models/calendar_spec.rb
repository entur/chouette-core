require 'rails_helper'

RSpec.describe Calendar, :type => :model do

  it { should belong_to(:organisation) }

  it { is_expected.to validate_presence_of(:organisation) }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:short_name) }
  it { is_expected.to validate_uniqueness_of(:short_name) }

  describe 'validations' do
    it 'validates that dates and date_ranges do not overlap' do
      calendar = build(:calendar, dates: [Date.today], date_ranges: [Date.today..Date.tomorrow])
      expect {
        calendar.save!
      }.to raise_error(ActiveRecord::RecordInvalid)
      expect(calendar.errors.messages[:dates]).to eq([I18n.t('activerecord.errors.models.calendar.attributes.dates.date_in_date_ranges')])
    end
  end

  describe 'Period' do

    subject { period }

    def period(attributes = {})
      return @period if attributes.empty? and @period
      Calendar::Period.new(attributes).tap do |period|
        @period = period if attributes.empty?
      end
    end

    it 'should support mark_for_destruction (required by cocoon)' do
      period.mark_for_destruction
      expect(period).to be_marked_for_destruction
    end

    it 'should support _destroy attribute (required by coocon)' do
      period._destroy = true
      expect(period).to be_marked_for_destruction
    end

    it 'should support new_record? (required by cocoon)' do
      expect(Calendar::Period.new).to be_new_record
      expect(period(id: 42)).not_to be_new_record
    end

    it 'should cast begin as date attribute' do
      expect(period(begin: '2016-11-22').begin).to eq(Date.new(2016,11,22))
    end

    it 'should cast end as date attribute' do
      expect(period(end: '2016-11-22').end).to eq(Date.new(2016,11,22))
    end

    it { is_expected.to validate_presence_of(:begin) }
    it { is_expected.to validate_presence_of(:end) }

    it 'should validate that end is greather than or equlals to begin' do
      expect(period(begin: '2016-11-21', end: '2016-11-22')).to be_valid
      expect(period(begin: '2016-11-21', end: '2016-11-21')).to be_valid
      expect(period(begin: '2016-11-22', end: '2016-11-21')).to_not be_valid
    end

    describe 'intersect?' do

      it 'should detect date in common with other date_ranges' do
        november = period(begin: '2016-11-01', end: '2016-11-30')
        mid_november_mid_december = period(begin: '2016-11-15', end: '2016-12-15')
        expect(november.intersect?(mid_november_mid_december)).to be(true)
      end

      it 'should not intersect when no date is in common' do
        november = period(begin: '2016-11-01', end: '2016-11-30')
        december = period(begin: '2016-12-01', end: '2016-12-31')

        expect(november.intersect?(december)).to be(false)

        january = period(begin: '2017-01-01', end: '2017-01-31')
        expect(november.intersect?(december, january)).to be(false)
      end

      it 'should not intersect itself' do
        period = period(id: 42, begin: '2016-11-01', end: '2016-11-30')
        expect(period.intersect?(period)).to be(false)
      end

    end

  end

  describe 'before_validation' do
    let(:calendar) { create(:calendar, date_ranges: []) }

    it 'shoud fill date_ranges with date ranges' do
      expected_ranges = [
        Range.new(Date.today, Date.tomorrow)
      ]
      expected_ranges.each_with_index do |range, index|
        calendar.date_ranges << Calendar::Period.from_range(index, range)
      end
      calendar.valid?

      expect(calendar.date_ranges.map { |period| period.begin..period.end }).to eq(expected_ranges)
    end
  end

end

