require "rails_helper"

RSpec.describe ReferentialIndexSupport do

  let(:test_class) do
     child
     class TestClass
       include ReferentialIndexSupport
       has_many_scattered :children
     end
  end

  let(:child) {  Object.const_set(:Child, Class.new() { include ReferentialIndexSupport }) }

  it 'should raise an error when no reciproque relation is defined' do
    expect{ test_class }.to raise_error ReferentialIndexSupport::MissingReciproqueRelation
  end

  context 'with the reciproque relation' do
    let(:child) {  Object.const_set(:Child, Class.new() { include ReferentialIndexSupport; belongs_to_public :test_class  }) }

    it 'should not raise an error' do
      expect{ test_class }.to_not raise_error
    end
  end
end
