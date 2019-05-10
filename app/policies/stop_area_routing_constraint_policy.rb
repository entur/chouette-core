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
    user.workbenches.pluck(:stop_area_referential_id).include?(record.stop_area_referential.id)
  end

  def instance_permission permission
    user.has_permission?("stop_area_routing_constraints.#{permission}")
  end
end
