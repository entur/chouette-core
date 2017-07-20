RSpec.describe WorkbenchImportWorker, type: [:worker, :request] do

  let( :worker ) { described_class.new }
  let( :import ){ build_stubbed :import }
  let( :workbench ){ import.workbench }
  let( :referential ){ import.referential }
  let( :api_key ){ build_stubbed :api_key, referential: referential }

  # /workbenches/:workbench_id/imports/:id/download
  let( :path ){ download_workbench_import_path(workbench, import) }
  let( :result ){ import.file.read }

  before do
    # That should be `build_stubbed's` job, no?
    allow(Import).to receive(:find).with(import.id).and_return(import)
  end
  xit 'downloads a zip file' do
    stub_request(:get, path)
      .with(headers: authorization_token_header(api_key))
      .to_return(body: result)
    worker.perform import.id
    expect( worker.downloaded ).to eq( result )
  end
end
