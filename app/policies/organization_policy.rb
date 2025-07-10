class OrganizationPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.organization_admin?
        Organization.all
      elsif user.organization_member?
        Organization.where(id: user.organization_id)
      else
        Organization.public_participation
      end
    end
  end

  def index?
    true
  end

  def show?
    user.organization_admin? || 
    user.organization == record || 
    record.public_participation?
  end

  def create?
    user.present?
  end

  def update?
    user.organization_admin? && user.organization == record
  end

  def destroy?
    user.organization_admin? && user.organization == record
  end

  def analytics?
    user.organization_admin? && user.organization == record
  end

  def members?
    user.organization_admin? && user.organization == record
  end

  def participation_rules?
    user.organization_admin? && user.organization == record
  end
end 