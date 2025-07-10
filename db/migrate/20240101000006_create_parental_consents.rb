class CreateParentalConsents < ActiveRecord::Migration[6.0]
  def change
    create_table :parental_consents do |t|
      t.references :parent, null: false, foreign_key: { to_table: :users }, index: false
      t.references :child, null: false, foreign_key: { to_table: :users }, index: false
      t.boolean :approved, default: false
      t.date :consent_date, null: false
      t.date :expiry_date, null: false
      t.references :approved_by, foreign_key: { to_table: :users }, index: false
      t.datetime :approved_at
      t.references :revoked_by, foreign_key: { to_table: :users }, index: false
      t.datetime :revoked_at
      t.text :notes
      t.jsonb :consent_details, default: {}
      
      t.timestamps
    end
    
    # Add unique constraint on child_id
    add_index :parental_consents, :child_id, unique: true
    add_index :parental_consents, :approved
    add_index :parental_consents, :expiry_date
    add_index :parental_consents, :consent_date
  end
end 