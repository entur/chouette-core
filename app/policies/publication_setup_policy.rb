class PublicationSetupPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def create?
    workgroup_owner? && user.has_permission?('publication_setups.create')
  end

  def update?
    workgroup_owner? && user.has_permission?('publication_setups.update')
  end

  def destroy?
    workgroup_owner? && user.has_permission?('publication_setups.destroy')
  end

  def workgroup_owner?
    return true unless record.respond_to?(:workgroup)
    
    user.belongs_to_workgroup_owner? record&.workgroup
  end
end
