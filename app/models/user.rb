class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  belongs_to :organization, optional: true
  has_many :user_roles, dependent: :destroy
  has_many :roles, through: :user_roles
  has_many :parental_consents, foreign_key: 'parent_id', class_name: 'ParentalConsent'
  has_one :parental_consent, foreign_key: 'child_id', class_name: 'ParentalConsent'
  
  validates :email, presence: true, uniqueness: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :date_of_birth, presence: true
  validates :age, numericality: { greater_than: 0, less_than: 120 }
  
  before_validation :calculate_age
  
  scope :minors, -> { where('age < ?', 18) }
  scope :adults, -> { where('age >= ?', 18) }
  scope :by_age_group, ->(min_age, max_age) { where(age: min_age..max_age) }
  
  def full_name
    "#{first_name} #{last_name}"
  end
  
  def full_name_with_age
    "#{first_name} #{last_name} (#{age} years old)"
  end
  
  def minor?
    age < 18
  end
  
  def adult?
    age >= 18
  end
  
  def age_group
    case age
    when 0..12
      'child'
    when 13..17
      'teen'
    when 18..25
      'young_adult'
    when 26..64
      'adult'
    else
      'senior'
    end
  end
  
  # Custom role management methods
  def add_role(role_name, resource = nil)
    UserRole.assign_role(self, role_name, resource)
  end
  
  def remove_role(role_name, resource = nil)
    UserRole.remove_role(self, role_name, resource)
  end
  
  def has_role?(role_name, resource = nil)
    UserRole.has_role?(self, role_name, resource)
  end
  
  def roles_for_resource(resource)
    user_roles.joins(:role).where(roles: { resource: resource })
  end
  
  def organization_admin?
    has_role?('admin', organization)
  end
  
  def organization_member?
    organization.present?
  end
  
  def can_participate_in_organization?(org)
    return false unless org
    return true if org.public_participation?
    organization_member? && organization == org
  end
  
  def active?
    self[:active] != false
  end
  
  def email_verified?
    self[:email_verified] == true
  end
  
  def last_sign_in_at
    self[:last_sign_in_at]
  end
  
  def parental_consent
    super
  end
  
  def organization
    super
  end
  
  private
  
  def calculate_age
    return unless date_of_birth
    
    today = Date.current
    self.age = today.year - date_of_birth.year - ((today.month > date_of_birth.month || (today.month == date_of_birth.month && today.day >= date_of_birth.day)) ? 0 : 1)
  end
end 