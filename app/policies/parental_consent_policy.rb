class ParentalConsentPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.minor?
        ParentalConsent.where(child: user)
      else
        ParentalConsent.where(parent: user)
      end
    end
  end

  def index?
    true
  end

  def show?
    record.parent == user || record.child == user
  end

  def create?
    true
  end

  def new?
    true
  end

  def update?
    record.parent == user || record.child == user
  end

  def edit?
    update?
  end

  def approve?
    record.parent == user && user.adult?
  end

  def revoke?
    record.parent == user && user.adult?
  end

  def renew?
    record.child == user && record.can_be_renewed?
  end
end 