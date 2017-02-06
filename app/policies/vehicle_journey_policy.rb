class VehicleJourneyPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def create?
    user.has_permission?('vehicle_journeys.create') # organisation match via referential is checked in the view
  end

  def edit?
    organisation_match?(via_referential: true) && user.has_permission?('vehicle_journeys.edit')
  end

  def destroy?
    organisation_match?(via_referential: true) && user.has_permission?('vehicle_journeys.destroy')
  end

  def update?  ; edit? end
  def new?     ; create? end
end
