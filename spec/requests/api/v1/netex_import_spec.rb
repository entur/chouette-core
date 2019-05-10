# RSpec.describe "Import::Netex", type: :request do

#   describe 'POST netex_imports' do

#     let( :referential ){ create :workbench_referential }
#     let( :workbench ){ referential.workbench }
#     let( :workbench_import ){ create :workbench_import }

#     let( :file_path ){ fixtures_path 'single_reference_import.zip' }
#     let( :file ){ fixture_file_upload( file_path ) }

#     let( :post_request ) do
#       -> (attributes) do
#         post api_v1_netex_imports_path(format: :json),
#           attributes,
#           authorization
#       end
#     end

#     let( :legal_attributes ) do
#       {
#         name: 'offre1',
#         file: file,
#         workbench_id: workbench.id,
#         parent_id: workbench_import.id,
#         parent_type: workbench_import.class.name
#       }
#     end


#     context 'with correct credentials and correct request' do
#       let( :authorization ){ authorization_token_header( get_api_key.token ) }
#       #TODO Check why referential_id is nil
#       it 'succeeds' do
#         # skip "Problem with referential_id" do
#         create(:line, objectid: 'STIF:CODIFLIGNE:Line:C00108', line_referential: workbench.line_referential)
#         create(:line, objectid: 'STIF:CODIFLIGNE:Line:C00109', line_referential: workbench.line_referential)

#         post_request.(netex_import: legal_attributes)
#         expect( response ).to be_successful
#         expect( json_response_body ).to eq(
#           'id'             => Import::Netex.last.id,
#           'referential_id' => Referential.last.id,
#           'workbench_id'   => workbench.id
#         )
#         # end
#       end


#       it 'creates a NetexImport object in the DB' do
#         create(:line, objectid: 'STIF:CODIFLIGNE:Line:C00108', line_referential: workbench.line_referential)
#         create(:line, objectid: 'STIF:CODIFLIGNE:Line:C00109', line_referential: workbench.line_referential)

#         expect{ post_request.(netex_import: legal_attributes) }.to change{Import::Netex.count}.by(1)
#       end

#       it 'creates a correct Referential', pending: 'see #5073' do
#         create(:line, objectid: 'STIF:CODIFLIGNE:Line:C00108', line_referential: workbench.line_referential)
#         create(:line, objectid: 'STIF:CODIFLIGNE:Line:C00109', line_referential: workbench.line_referential)

#         legal_attributes # force object creation for correct to change behavior
#         expect{post_request.(netex_import: legal_attributes)}.to change{Referential.count}.by(1)
#         Referential.last.tap do | ref |
#           expect( ref.workbench_id ).to eq(workbench.id)
#           expect( ref.organisation_id ).to eq(workbench.organisation_id)
#         end
#       end
#     end


#     context 'with incorrect credentials and correct request', pending: "see #4311 & #5072" do
#       let( :authorization ){ authorization_token_header( "#{referential.id}-incorrect_token") }

#       it 'does not create any DB object and does not succeed' do
#         legal_attributes # force object creation for correct to change behavior
#         expect{ post_request.(netex_import: legal_attributes) }.not_to change{Referential.count}
#         expect( response.status ).to eq(401)
#       end

#     end

#     context 'with correct credentials and incorrect request' do
#       let( :authorization ){ authorization_token_header( get_api_key.token ) }

#       shared_examples_for 'illegal attributes' do |bad_attribute, illegal_value=nil|
#         context "missing #{bad_attribute}" do
#           let!( :illegal_attributes ){ legal_attributes.merge( bad_attribute => illegal_value ) }
#           it 'does not succeed' do
#             # TODO: Handle better when `ReferentialMetadataKludge` is reworked
#             create(:line, objectid: 'STIF:CODIFLIGNE:Line:C00108')
#             create(:line, objectid: 'STIF:CODIFLIGNE:Line:C00109')

#             post_request.(netex_import: illegal_attributes)
#             expect( response.status ).to eq(406)
#             expect( json_response_body['errors'][bad_attribute.to_s] ).not_to be_empty
#           end

#           it 'does not create an Import object' do
#             expect{ post_request.(netex_import: illegal_attributes) }.not_to change{Import::Base.count}
#           end

#           it 'might not create a referential' do
#             expect{ post_request.(netex_import: illegal_attributes) }.not_to change{Referential.count}
#           end
#         end
#       end

#       it_behaves_like 'illegal attributes', :workbench_id

#       # TODO Create a specific test when referential is not created
#       # context 'name already taken' do
#       #   before do
#       #     create :referential, name: 'already taken'
#       #   end
#       #   it_behaves_like 'illegal attributes', name: 'already taken'
#       # end
#     end
#   end
# end
