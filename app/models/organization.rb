class Organization < ApplicationRecord
  has_many :users, dependent: :nullify
  has_many :roles, as: :resource, dependent: :destroy
  has_many :participation_rules, dependent: :destroy
  has_many :organization_analytics, class_name: 'OrganizationAnalytics', dependent: :destroy
  
  validates :name, presence: true, uniqueness: true
  validates :domain, presence: true, uniqueness: true
  validates :participation_type, inclusion: { in: %w[public private restricted] }
  
  scope :public_participation, -> { where(participation_type: 'public') }
  scope :private_participation, -> { where(participation_type: 'private') }
  scope :restricted_participation, -> { where(participation_type: 'restricted') }
  
  def public_participation?
    participation_type == 'public'
  end
  
  def private_participation?
    participation_type == 'private'
  end
  
  def restricted_participation?
    participation_type == 'restricted'
  end
  
  def member_count
    users.count
  end
  
  def admin_count
    users.joins(:user_roles).joins(:roles).where(roles: { name: 'admin', resource: self }).count
  end
  
  def member_count_by_age_group
    {
      child: users.by_age_group(0, 12).count,
      teen: users.by_age_group(13, 17).count,
      young_adult: users.by_age_group(18, 25).count,
      adult: users.by_age_group(26, 64).count,
      senior: users.by_age_group(65, 120).count
    }
  end
  
  def participation_rules_for_age_group(age_group)
    participation_rules.find_by(age_group: age_group)
  end
  
  def can_user_participate?(user)
    return false unless user
    
    # Check if user is a member or if organization allows public participation
    return true if public_participation? || user.organization == self
    
    # Check age-based rules
    rule = participation_rules_for_age_group(user.age_group)
    return false unless rule&.enabled?
    
    # Check if user meets age requirements
    return false if user.age < rule.minimum_age || user.age > rule.maximum_age
    
    # Check if parental consent is required and provided
    if rule.requires_parental_consent? && user.minor?
      return false unless user.parental_consent&.approved?
    end
    
    true
  end
  
  def generate_analytics
    analytics = organization_analytics.create!(
      total_members: member_count,
      admin_count: admin_count,
      age_group_breakdown: member_count_by_age_group,
      participation_rate: calculate_participation_rate,
      generated_at: Time.current
    )
    analytics
  end
  
  def calculate_participation_rate
    total_eligible = users.count
    return 0 if total_eligible.zero?
    
    participating_users = users.joins(:user_roles).joins(:roles).where(roles: { name: 'participant' }).count
    rate = (participating_users.to_f / total_eligible * 100).round(2)
    [rate, 100.0].min  # Ensure rate never exceeds 100%
  end
  
  def active?
    self[:active] != false
  end
  
  def users
    super
  end
  
  def participation_rules
    super
  end
end 