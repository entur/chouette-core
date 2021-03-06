class CompanyPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def create?
    user.has_permission?('companies.create')
  end

  def destroy?
    user.has_permission?('companies.destroy')
  end

  def update?
    user.has_permission?('companies.update')
  end
end
