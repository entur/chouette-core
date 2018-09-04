RSpec.describe WorkgroupsController, :type => :controller do
  login_user

  let(:workbench) { create :workbench, organisation: organisation }
  let(:workgroup) { workbench.workgroup }
  let(:organisation){ @user.organisation }
  let(:compliance_control_set) { create :compliance_control_set, organisation: organisation }
  let(:merge_id) { 2**64/2 - 1 } # Let's check we support Bigint


  describe "GET show" do
    let(:request){ get :show, id: workgroup.id }
    it_behaves_like 'checks current_organisation', success_code: 302
  end

  describe "GET edit" do
    let(:request){ get :edit, id: workgroup.id }
    it 'should respond with 403' do
      expect(request).to have_http_status 403
    end
    context "when belonging to the owner" do
      before do
        workgroup.update owner: @user.organisation
      end
      it_behaves_like 'checks current_organisation'
    end
  end

  describe 'PATCH update' do
    let(:params){
      {
        id: workgroup.id,
        workgroup: {
          workbenches_attributes: {
            "0" => {
              id: workbench.id,
              compliance_control_set_ids: {
                after_import_by_workgroup: compliance_control_set.id,
                after_merge_by_workgroup: merge_id
              }
            }
          }
        }
      }
    }
    let(:request){ patch :update, params }

    it 'should respond with 403' do
      expect(request).to have_http_status 403
    end

    context "when belonging to the owner" do
      before do
        workgroup.update owner: @user.organisation
      end
      it 'returns HTTP success' do
        expect(request).to be_redirect
        expect(workbench.reload.compliance_control_set(:after_import_by_workgroup)).to eq compliance_control_set
        expect(workbench.reload.owner_compliance_control_set_ids['after_merge_by_workgroup']).to eq merge_id.to_s
      end
    end
  end
end
