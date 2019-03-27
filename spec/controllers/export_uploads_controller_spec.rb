RSpec.describe ExportUploadsController, :type => :controller do
  let(:export)    { create(:netex_export, referential: first_referential) }

  describe 'POST #upload' do
    context "with the token" do
      it 'should be successful' do
        post :upload, params: { id: export.id, token: export.token_upload }
        expect(response).to be_successful
      end
    end

    context "without the token" do
      it 'should be unsuccessful' do
        post :upload, params: { id: export.id, token: "foo" }
        expect(response).to_not be_successful
      end
    end
  end
end
