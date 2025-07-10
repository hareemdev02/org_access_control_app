class UserPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.organization_admin?
        User.where(organization: user.organization)
      elsif user.organization_member?
        User.where(organization: user.organization)
      else
        User.none
      end
    end
  end

  def index?
    user.organization_admin?
  end

  def show?
    user.organization_admin? || record == user
  end

  def create?
    user.organization_admin?
  end

  def update?
    user.organization_admin? || record == user
  end

  def destroy?
    user.organization_admin? && record.organization == user.organization
  end

  def roles?
    user.organization_admin? && record.organization == user.organization
  end

  def assign_role?
    user.organization_admin? && record.organization == user.organization
  end

  def remove_role?
    user.organization_admin? && record.organization == user.organization
  end

  def profile?
    true
  end

  def update_profile?
    record == user
  end
end 