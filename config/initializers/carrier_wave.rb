CarrierWave.configure do |config|
  config.cache_dir = Rails.root.join 'tmp/uploads'
end

CarrierWave.tmp_path = Dir.tmpdir
