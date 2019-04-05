class PublicationApiPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def create?
    workgroup_owner? && user.has_permission?('publication_apis.create')
  end

  def update?
    workgroup_owner? && user.has_permission?('publication_apis.update')
  end

  def destroy?
    workgroup_owner? && user.has_permission?('publication_apis.destroy')
  end

  def workgroup_owner?
    user.belongs_to_workgroup_owner? record&.workgroup
  end
end
