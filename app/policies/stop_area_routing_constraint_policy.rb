class StopAreaRoutingConstraintPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def create?
    instance_permission(:create)
  end

  def destroy?
    stop_area_referential_match? && instance_permission(:destroy)
  end

  def update?
    stop_area_referential_match? && instance_permission(:update)
  end

  def stop_area_referential_match?
    user.workbenches.pluck(:stop_area_referential_id).includes?(record.stop_area_referential_id)
  end
end
