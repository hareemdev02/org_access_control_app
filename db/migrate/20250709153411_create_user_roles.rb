class CreateUserRoles < ActiveRecord::Migration[6.0]
  def change
    create_table :user_roles do |t|
      t.references :user, null: false, foreign_key: true
      t.references :role, null: false, foreign_key: true
      t.string :resource_type
      t.bigint :resource_id
      
      t.timestamps
    end
    
    add_index :user_roles, [:user_id, :role_id, :resource_type, :resource_id], unique: true, name: 'index_user_roles_on_user_role_resource'
    add_index :user_roles, [:resource_type, :resource_id]
  end
end
