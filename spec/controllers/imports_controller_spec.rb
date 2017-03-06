require 'rails_helper'

RSpec.describe ImportsController, :type => :controller do
  login_user

  let(:workbench) { create :workbench }
  let(:import)    { create :import, workbench: workbench }

  describe 'GET #new' do
    it 'should be successful' do
      get :new, workbench_id: workbench.id
      expect(response).to be_success
    end
  end

  describe 'GET #download' do
    it 'should be successful' do
      get :download, workbench_id: workbench.id, id: import.id, token: import.token_download
      expect(response).to be_success
    end
  end
end
