RSpec.describe Export::Netex, type: [:model] do

  let( :boiv_iev_uri ){  URI("#{Rails.configuration.iev_url}/boiv_iev/referentials/exporter/new?id=#{subject.id}")}

  before do
    allow(Thread).to receive(:new).and_yield
  end

  context 'options' do
    it 'should validate the options' do
      e = build(:netex_export)

      expect(e).to be_valid, e.errors.inspect

      e.export_type = nil
      expect(e).to_not be_valid

      e.export_type = :full
      e.duration = nil
      expect(e).to_not be_valid
      e.duration = 60
      expect(e).to be_valid
      e.duration = 0
      expect(e).to_not be_valid
      e.duration = 61
      expect(e).to_not be_valid

      e.export_type = :line
      e.duration = nil
      expect(e).to_not be_valid
      e.duration = 365
      expect(e).to be_valid
      e.duration = 0
      expect(e).to_not be_valid
      e.duration = 366
      expect(e).to_not be_valid
    end
  end

  context 'with referential' do
    subject{ build( :netex_export, id: random_int ) }

    it 'will trigger the Java API' do
      with_stubbed_request(:get, boiv_iev_uri) do |request|
        subject.save!
        expect(request).to have_been_requested
      end
    end
  end
end
