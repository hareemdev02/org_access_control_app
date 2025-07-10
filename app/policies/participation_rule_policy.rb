class ParticipationRulePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.organization_admin?
        scope.where(organization: user.organization)
      else
        scope.none
      end
    end
  end

  def index?
    user.organization_admin? && user.organization == record.organization
  end

  def show?
    user.organization_admin? && user.organization == record.organization
  end

  def create?
    user.organization_admin? && user.organization == record.organization
  end

  def new?
    create?
  end

  def update?
    user.organization_admin? && user.organization == record.organization
  end

  def edit?
    update?
  end

  def destroy?
    user.organization_admin? && user.organization == record.organization
  end

  def bulk_update?
    user.organization_admin? && user.organization == record.organization
  end

  def reset_to_defaults?
    user.organization_admin? && user.organization == record.organization
  end
end 