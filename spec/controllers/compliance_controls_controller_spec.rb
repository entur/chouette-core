require 'rails_helper'

RSpec.describe ComplianceControlsController, type: :controller do
  login_user

  let(:compliance_control)     { create :compliance_control }
  let(:compliance_control_set) { compliance_control.compliance_control_set }

  describe "GET show" do
    it 'should be successful' do
      get :show, compliance_control_set_id: compliance_control_set.id, id: compliance_control.id
      expect(response).to be_success
    end
  end

  describe 'GET #edit' do
    it 'should be successful' do
      get :edit, compliance_control_set_id: compliance_control_set.id, id: compliance_control.id
      expect(response).to be_success
    end
  end

  describe 'GET #new' do
    it 'should be successful' do
      get :new, compliance_control_set_id: compliance_control_set.id
      expect(response).to be_success
    end
  end

  describe 'POST #create' do
    it 'should be successful' do
      post :create, compliance_control_set_id: compliance_control_set.id, compliance_control: build(:compliance_control).as_json
      expect(response).to have_http_status(302)
      expect(flash[:notice]).to eq(I18n.t('notice.compliance_control.created'))
    end
  end

  describe 'POST #update' do
    it 'should be successful' do
      post :update, compliance_control_set_id: compliance_control_set.id, id: compliance_control.id, compliance_control: compliance_control.as_json
      expect(response).to redirect_to compliance_control_set_compliance_control_path(compliance_control_set, compliance_control)
      expect(flash[:notice]).to eq(I18n.t('notice.compliance_control.updated'))
    end
  end

  describe 'DELETE #destroy' do
    it 'should be successful' do
      delete :destroy, compliance_control_set_id: compliance_control_set.id, id: compliance_control.id
      expect(flash[:notice]).to eq I18n.t('notice.compliance_control.destroyed')
    end
  end
end
