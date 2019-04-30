RSpec.describe StopAreasController, :type => :controller do
  login_user

  let(:stop_area_referential) { create :stop_area_referential, member: @user.organisation }
  let(:stop_area) { create :stop_area, stop_area_referential: stop_area_referential }

  describe "GET index" do
    it "filters by registration number" do
      registration_number = 'E34'

      matched = create(
        :stop_area,
        stop_area_referential: stop_area_referential,
        registration_number: registration_number
      )
      create(
        :stop_area,
        stop_area_referential: stop_area_referential,
        registration_number: "doesn't match"
      )

      get :index, params: {
        stop_area_referential_id: stop_area_referential.id,
        q: {
          name_or_objectid_or_registration_number_cont: registration_number
        }
      }

      expect(assigns(:stop_areas)).to eq([matched])
    end

    it "doesn't filter when the name filter is empty" do
      get :index, params: {
        stop_area_referential_id: stop_area_referential.id,
        q: {
          name_or_objectid_or_registration_number_cont: ''
        }
      }

      expect(assigns(:stop_areas)).to eq([stop_area])
    end
  end

  describe 'PUT deactivate' do
    let(:request){ put :deactivate, params: { id: stop_area.id, stop_area_referential_id: stop_area_referential.id }}

    it 'should respond with 403' do
      expect(request).to have_http_status 403
    end

    with_permission "stop_areas.change_status" do
      it 'returns HTTP success' do
        expect(request).to redirect_to [stop_area_referential, stop_area]
        expect(stop_area.reload).to be_deactivated
      end
    end
  end

  describe 'PUT activate' do
    let(:request){ put :activate, params: { id: stop_area.id, stop_area_referential_id: stop_area_referential.id }}
    before(:each){
      stop_area.deactivate!
    }
    it 'should respond with 403' do
      expect(request).to have_http_status 403
    end

    with_permission "stop_areas.change_status" do
      it 'returns HTTP success' do
        expect(request).to redirect_to [stop_area_referential, stop_area]
        expect(stop_area.reload).to be_activated
      end
    end
  end
end
