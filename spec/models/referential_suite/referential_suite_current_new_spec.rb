RSpec.describe ReferentialSuite do

  describe 'Normalisation of current and new towards a proper Referential' do

    subject { create :referential_suite, new: nil, current: nil }

    describe 'valid' do
      context 'current and new nil' do
        it do
          expect_it.to be_valid
        end
      end

      context 'current nil and new pointing correctly back' do
        let( :child ){ create :referential, referential_suite: subject }
        it do
          subject.new_id = child.id
          expect_it.to be_valid
        end
      end

      context 'new nil and current pointing correctly back' do
        let( :child ){ create :referential, referential_suite: subject }
        it do
          subject.current_id = child.id
          expect_it.to be_valid
        end
      end

      context 'new and current pointing correctly back' do
        let( :child ){ create :referential, referential_suite: subject }
        let( :sibbling ){ create :referential, referential_suite: subject }
        it do
          subject.current_id = child.id
          subject.new_id = sibbling.id
          expect_it.to be_valid
        end
      end
    end

    describe 'invalid' do
      context 'current points to incorrect referential(not a child), new is nil' do
        let( :current ){ create :referential }
        it do
          subject.current_id = current.id
          expect_it.not_to be_valid
          expect( subject.errors.messages[:inconsistent_new] ).to be_empty
          expect( subject.errors.messages[:inconsistent_current].first ).to match(%r<#{current.name}>)
        end
      end
      context 'current points to correct referential, new to incorrect referential(not a child)' do
        let( :current ){ create :referential, referential_suite: subject }
        let( :new ){ create :referential, referential_suite: create( :referential_suite ) }
        it do
          subject.current_id = current.id
          subject.new_id = new.id
          expect_it.not_to be_valid
          expect( subject.errors.messages[:inconsistent_current] ).to be_empty
          expect( subject.errors.messages[:inconsistent_new].first ).to match(%r<#{new.name}>)
        end
      end
    end
  end
end
