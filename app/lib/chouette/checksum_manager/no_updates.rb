module Chouette::ChecksumManager
  class NoUpdates < Base
    def watch object, _
    end

    def child_after_save object
    end
  end
end
