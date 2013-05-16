require 'spec_helper'

describe Api::V1::NetworksController do
  let!(:network) { referential.networks.first || create(:network) }

  it_behaves_like "api key protected controller" do
    let(:data){network}
  end

  describe "GET #show" do
    context "when authorization provided and request.accept is json" do
      before :each do
        config_formatted_request_with_authorization( "application/json")
        get :show, :id => network.objectid
      end

      it "should assign expected network" do
        assigns[:network].should == network
      end
    end
  end
  describe "GET #index" do
    context "when authorization provided and request.accept is json" do
      before :each do
        config_formatted_request_with_authorization( "application/json")
        get :index
      end

      it "should assign expected networks" do
        assigns[:networks].should == [network]
      end
    end
  end

end
