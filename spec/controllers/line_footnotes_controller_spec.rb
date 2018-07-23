RSpec.describe LineFootnotesController, :type => :controller do
  login_user permissions: []
  let(:route){ create :route, referential: referential }
  let(:line) { route.line }

  describe "GET edit" do
    let(:request){ get :edit, line_id: line.id, referential_id: referential.id }
    it 'should respond with 403' do
      expect(request).to have_http_status 403
    end

    with_permission "footnotes.update" do
      it 'returns HTTP success' do
        expect(request).to be_success
      end

      context "with an archived referential" do
        before(:each) do
          referential.archive!
        end
        it 'should respond with 403' do
          expect(request).to have_http_status 403
        end
      end
    end
  end

  describe "POST update" do
    let(:request){ post :update, line_id: line.id, referential_id: referential.id, line: {footnotes_attributes: {}} }
    it 'should respond with 403' do
      expect(request).to have_http_status 403
    end

    with_permission "footnotes.update" do
      it 'returns HTTP success' do
        expect(request).to be_redirect
      end
    end
  end
end
