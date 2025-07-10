class ParentalConsent < ApplicationRecord
  belongs_to :parent, class_name: 'User'
  belongs_to :child, class_name: 'User'
  belongs_to :approved_by, class_name: 'User', optional: true
  belongs_to :revoked_by, class_name: 'User', optional: true
  
  validates :parent_id, presence: true
  validates :child_id, presence: true, uniqueness: true
  validates :approved, inclusion: { in: [true, false] }
  validates :consent_date, presence: true
  validates :expiry_date, presence: true
  validate :parent_must_be_adult
  validate :child_must_be_minor
  validate :expiry_date_after_consent_date
  
  scope :approved, -> { where(approved: true) }
  scope :pending, -> { where(approved: false) }
  scope :expired, -> { where('expiry_date < ?', Date.current) }
  scope :active, -> { approved.where('expiry_date >= ?', Date.current) }
  
  before_validation :set_default_dates
  after_create :notify_organization_admins
  after_update :notify_consent_status_change
  
  def self.create_for_minor(child, parent)
    return false unless child.minor? && parent.adult?
    
    create!(
      child: child,
      parent: parent,
      approved: false,
      consent_date: Date.current,
      expiry_date: 1.year.from_now.to_date
    )
  end
  
  def approved?
    approved && !expired?
  end
  
  def revoked?
    revoked_at.present?
  end
  
  # These methods are now handled by the belongs_to associations above
  
  def parent
    super
  end
  
  def child
    super
  end
  
  def expired?
    expiry_date < Date.current
  end
  
  def pending?
    !approved && !expired?
  end
  
  def days_until_expiry
    (expiry_date - Date.current).to_i
  end
  
  def needs_renewal?
    days_until_expiry <= 30
  end
  
  def can_be_renewed?
    expired? || needs_renewal?
  end
  
  def renew_consent
    return false unless can_be_renewed?
    
    update!(
      approved: false,
      consent_date: Date.current,
      expiry_date: 1.year.from_now.to_date
    )
  end
  
  def approve_consent(approved_by = nil)
    update!(
      approved: true,
      approved_by_id: approved_by&.id,
      approved_at: Time.current
    )
  end
  
  def revoke_consent(revoked_by = nil)
    update!(
      approved: false,
      revoked_by_id: revoked_by&.id,
      revoked_at: Time.current
    )
  end
  
  def consent_details
    details = super
    return {} if details.blank?
    details
  end
  
  private
  
  def set_default_dates
    self.consent_date ||= Date.current
    self.expiry_date ||= 1.year.from_now.to_date
  end
  
  def parent_must_be_adult
    if parent && parent.minor?
      errors.add(:parent, 'must be an adult')
    end
  end
  
  def child_must_be_minor
    if child && child.adult?
      errors.add(:child, 'must be a minor')
    end
  end
  
  def expiry_date_after_consent_date
    if expiry_date && consent_date && expiry_date <= consent_date
      errors.add(:expiry_date, 'must be after consent date')
    end
  end
  
  def notify_organization_admins
    return unless child.organization
    
    child.organization.users.joins(:roles).where(roles: { name: 'admin' }).each do |admin|
      # In a real application, you would send an email notification here
      Rails.logger.info "Parental consent request created for #{child.full_name} in #{child.organization.name}. Admin #{admin.email} notified."
    end
  end
  
  def notify_consent_status_change
    if approved_changed?
      status = approved? ? 'approved' : 'revoked'
      Rails.logger.info "Parental consent #{status} for #{child.full_name} by #{parent.full_name}"
    end
  end
end 