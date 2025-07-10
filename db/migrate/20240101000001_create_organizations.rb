class CreateOrganizations < ActiveRecord::Migration[6.0]
  def change
    create_table :organizations do |t|
      t.string :name, null: false
      t.string :domain, null: false
      t.text :description
      t.string :participation_type, default: 'private'
      t.boolean :active, default: true
      t.jsonb :settings, default: {}
      
      t.timestamps
    end
    
    add_index :organizations, :name, unique: true
    add_index :organizations, :domain, unique: true
    add_index :organizations, :participation_type
    add_index :organizations, :active
  end
end 