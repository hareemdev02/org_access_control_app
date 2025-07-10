class Role < ApplicationRecord
  has_many :user_roles, dependent: :destroy
  has_many :users, through: :user_roles
  belongs_to :resource, polymorphic: true, optional: true
  
  validates :name, presence: true
  
  # Default roles
  ROLES = %w[admin moderator participant viewer]
  
  def self.default_roles
    ROLES
  end
  
  def admin?
    name == 'admin'
  end
  
  def moderator?
    name == 'moderator'
  end
  
  def participant?
    name == 'participant'
  end
  
  def viewer?
    name == 'viewer'
  end
  
  def permissions
    case name
    when 'admin'
      %w[manage_users manage_roles manage_organization view_analytics manage_content]
    when 'moderator'
      %w[moderate_content view_analytics manage_participants]
    when 'participant'
      %w[create_content view_content participate]
    when 'viewer'
      %w[view_content]
    else
      []
    end
  end
  
  def has_permission?(permission)
    permissions.include?(permission.to_s)
  end
  
  def resource
    super
  end
end 