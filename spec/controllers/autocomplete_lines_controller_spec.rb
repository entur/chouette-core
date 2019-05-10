RSpec.describe AutocompleteLinesController, type: :controller do
  login_user

  describe "GET #index" do
    let(:referential) { Referential.first }
    let(:company) { create(:company, name: 'Standard Rail') }
    let!(:line) do
      create(
        :line,
        number: '15',
        name: 'Continent Express',
        company: company
      )
    end

    let!(:line_without_company) do
      create(
        :line,
        number: '15',
        name: 'Continent Express',
        company: nil
      )
    end

    let!(:other_line) do
      create(
        :line,
        number: '16',
        name: 'Foo Bar',
        company: nil
      )
    end

    before(:each) do
      excluded_company = create(:company, name: 'excluded company')
      create(
        :line,
        number: 'different',
        name: 'other',
        company: excluded_company
      )
    end

    it "filters by `number`" do
      get :index, params: {
        referential_id: referential.id,
        q: '15'
      }

      expect(assigns(:lines).order(:id)).to eq([line, line_without_company])
    end

    it "filters by `name`" do
      get :index, params: {
        referential_id: referential.id,
        q: 'Continent'
      }
      expect(assigns(:lines).order(:id)).to eq([line, line_without_company])
    end

    it "escapes the query" do
      get :index, params: {
        referential_id: referential.id,
        q: 'Continent%'
      }
      expect(assigns(:lines).order(:id)).to be_empty
    end

    it "filters by company `name`" do
      get :index, params: {
        referential_id: referential.id,
        q: 'standard'
      }
      expect(assigns(:lines).to_a).to eq([line])
    end

    it "doesn't error when no `q` is sent" do
      get :index, params: {
        referential_id: referential.id
      }
      expect(assigns(:lines).to_a).to be_empty
      expect(response).to be_successful
    end
  end
end
