require 'rails_helper'

RSpec.describe StopAreaReferential, :type => :model do
  it 'should have a valid factory' do
    expect(FactoryGirl.build(:stop_area_referential)).to be_valid
  end

  it { is_expected.to have_many(:stop_area_referential_syncs) }
  it { is_expected.to have_many(:workbenches) }
  it { should validate_presence_of(:objectid_format) }
  it { should allow_value('').for(:registration_number_format) }
  it { should allow_value('X').for(:registration_number_format) }
  it { should allow_value('XXXXX').for(:registration_number_format) }
  it { should_not allow_value('123').for(:registration_number_format) }
  it { should_not allow_value('ABC').for(:registration_number_format) }
end
