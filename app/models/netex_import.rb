require 'net/http'
class NetexImport < Import
  after_commit :launch_java_import, on: :create, unless: :aborted?

  validates_presence_of :parent

  def launch_java_import
    return if self.class.finished_statuses.include?(status)

    Thread.new do
      begin
        Net::HTTP.get(URI("#{Rails.configuration.iev_url}/boiv_iev/referentials/importer/new?id=#{id}"))
      rescue Exception => e
        logger.error "IEV server error : #{e.message}"
        logger.error e.backtrace.inspect
      end
    end
  end


  private

  def aborted?
    status == 'aborted'
  end
end
