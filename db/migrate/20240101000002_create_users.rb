class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      ## Database authenticatable
      t.string :email,              null: false, default: ""
      t.string :encrypted_password, null: false, default: ""

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## User profile fields
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.date :date_of_birth, null: false
      t.integer :age
      t.string :phone_number
      t.text :bio
      t.string :avatar_url
      
      ## Organization membership
      t.references :organization, null: true, foreign_key: true
      
      ## Verification fields
      t.boolean :email_verified, default: false
      t.boolean :phone_verified, default: false
      t.boolean :identity_verified, default: false
      
      ## Account status
      t.boolean :active, default: true
      t.datetime :last_login_at
      t.inet :last_login_ip
      
      t.timestamps null: false
    end

    add_index :users, :email,                unique: true
    add_index :users, :reset_password_token, unique: true
    add_index :users, :age
    add_index :users, :active
    add_index :users, :email_verified
    add_index :users, :identity_verified
  end
end 