class CreateParticipationRules < ActiveRecord::Migration[6.0]
  def change
    create_table :participation_rules do |t|
      t.references :organization, null: false, foreign_key: true
      t.string :age_group, null: false
      t.integer :minimum_age, null: false
      t.integer :maximum_age, null: false
      t.boolean :enabled, default: true
      t.boolean :requires_parental_consent, default: false
      t.string :content_filtering_level, default: 'minimal'
      t.jsonb :participation_restrictions, default: []
      t.text :description
      t.jsonb :settings, default: {}
      
      t.timestamps
    end
    
    add_index :participation_rules, [:organization_id, :age_group], unique: true
    add_index :participation_rules, :enabled
    add_index :participation_rules, :requires_parental_consent
    add_index :participation_rules, :content_filtering_level
  end
end 