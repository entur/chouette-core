require 'apartment/adapters/abstract_adapter'

module Apartment
  module Tenant
    def adapter
      Thread.current[:apartment_adapter] ||= begin
        nulldb_adapter(config)
      end
    end

    def self.nulldb_adapter(config)
      adapter = Adapters::NulldbAdapter
      adapter.new(config)
    end
  end

  module Adapters
    # Default adapter when not using Postgresql Schemas
    class NulldbAdapter < AbstractAdapter
      def initialize config
        super
      end
    end
  end
end
