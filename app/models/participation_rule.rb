class ParticipationRule < ApplicationRecord
  belongs_to :organization
  
  validates :age_group, presence: true, inclusion: { in: %w[child teen young_adult adult senior] }
  validates :minimum_age, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 120 }
  validates :maximum_age, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 120 }
  validates :enabled, inclusion: { in: [true, false] }
  validates :requires_parental_consent, inclusion: { in: [true, false] }
  validate :maximum_age_greater_than_minimum_age
  
  scope :enabled, -> { where(enabled: true) }
  scope :by_age_group, ->(age_group) { where(age_group: age_group) }
  
  AGE_GROUPS = {
    child: { min: 0, max: 12 },
    teen: { min: 13, max: 17 },
    young_adult: { min: 18, max: 25 },
    adult: { min: 26, max: 64 },
    senior: { min: 65, max: 120 }
  }
  
  def self.default_rules_for_organization(organization)
    AGE_GROUPS.map do |age_group, age_range|
      organization.participation_rules.create!(
        age_group: age_group,
        minimum_age: age_range[:min],
        maximum_age: age_range[:max],
        enabled: true,
        requires_parental_consent: age_group == :child || age_group == :teen,
        content_filtering_level: content_filtering_for_age_group(age_group),
        participation_restrictions: restrictions_for_age_group(age_group)
      )
    end
  end
  
  def self.content_filtering_for_age_group(age_group)
    case age_group
    when :child
      'strict'
    when :teen
      'moderate'
    when :young_adult, :adult, :senior
      'minimal'
    end
  end
  
  def self.restrictions_for_age_group(age_group)
    case age_group
    when :child
      ['supervised_participation', 'limited_content_creation']
    when :teen
      ['moderated_content', 'limited_private_messaging']
    when :young_adult, :adult, :senior
      []
    end
  end
  
  def age_range
    "#{minimum_age}-#{maximum_age}"
  end
  
  def min_age
    minimum_age
  end
  
  def max_age
    maximum_age
  end
  
  def participation_allowed?
    enabled?
  end
  
  def parental_consent_required?
    requires_parental_consent?
  end
  
  def supervision_required?
    has_restriction?('supervised_participation')
  end
  
  def time_restrictions
    self[:time_restrictions]
  end
  
  def restrictions
    participation_restrictions.join(', ') if participation_restrictions.any?
  end
  
  def description
    self[:description]
  end
  
  def enabled?
    self[:enabled] != false
  end
  
  def organization
    super
  end
  
  def applies_to_user?(user)
    return false unless enabled?
    user.age >= minimum_age && user.age <= maximum_age
  end
  
  def requires_parental_consent?
    requires_parental_consent
  end
  
  def content_filtering_level
    self[:content_filtering_level] || 'minimal'
  end
  
  def participation_restrictions
    self[:participation_restrictions] || []
  end
  
  def has_restriction?(restriction)
    participation_restrictions.include?(restriction.to_s)
  end
  
  private
  
  def maximum_age_greater_than_minimum_age
    if maximum_age && minimum_age && maximum_age <= minimum_age
      errors.add(:maximum_age, 'must be greater than minimum age')
    end
  end
end 