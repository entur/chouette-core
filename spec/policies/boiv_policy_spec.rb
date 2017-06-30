RSpec.describe BoivPolicy, type: :policy do

  let( :record ){ nil }

  permissions :index? do
    it_behaves_like 'permitted policy and same organisation', 'boiv:read-offer'
  end

  permissions :boiv_read_offer? do
    it_behaves_like 'permitted policy and same organisation', 'boiv:read-offer'
  end

  permissions :show? do
    it_behaves_like 'permitted policy and same organisation', 'boiv:read-offer'
  end
end
