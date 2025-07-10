class UserRole < ApplicationRecord
  belongs_to :user
  belongs_to :role
  
  validates :user_id, presence: true
  validates :role_id, presence: true
  validates :user_id, uniqueness: { scope: [:role_id, :resource_type, :resource_id] }
  
  scope :for_resource, ->(resource) { where(resource: resource) }
  scope :for_role_name, ->(role_name) { joins(:role).where(roles: { name: role_name }) }
  
  def self.assign_role(user, role_name, resource = nil)
    role = Role.find_or_create_by(name: role_name, resource: resource)
    create!(
      user: user,
      role: role,
      resource_type: resource&.class&.name,
      resource_id: resource&.id
    )
  rescue ActiveRecord::RecordNotUnique
    # Role already assigned
    find_by(user: user, role: role)
  end
  
  def self.remove_role(user, role_name, resource = nil)
    role = Role.find_by(name: role_name, resource: resource)
    where(user: user, role: role).destroy_all if role
  end
  
  def self.has_role?(user, role_name, resource = nil)
    role = Role.find_by(name: role_name, resource: resource)
    where(user: user, role: role).exists? if role
  end
end 