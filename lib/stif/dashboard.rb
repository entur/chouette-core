module Stif
  class Dashboard < ::Dashboard
    def workbench
      if current_organisation.workbenches.length > 1
        Rails.logger.error("Organisation #{current_organisation.name} should have only one workbench")
      end
      @workbench ||= current_organisation.workbenches.first
    end

    def workgroup
      workbench.workgroup
    end

    def referentials
      @referentials ||= self.workbench.all_referentials
    end

    def calendars
      workbench.calendars
    end
  end
end
