class CreateOrganizationAnalytics < ActiveRecord::Migration[6.0]
  def change
    create_table :organization_analytics do |t|
      t.references :organization, null: false, foreign_key: true
      t.integer :total_members, null: false, default: 0
      t.integer :admin_count, null: false, default: 0
      t.jsonb :age_group_breakdown, default: {}
      t.decimal :participation_rate, precision: 5, scale: 2, null: false, default: 0
      t.datetime :generated_at, null: false
      t.string :report_period
      t.datetime :period_start
      t.datetime :period_end
      t.integer :new_members_count, default: 0
      t.integer :active_members_count, default: 0
      t.integer :active_users_7_days, default: 0
      t.integer :active_users_30_days, default: 0
      t.integer :new_members_this_month, default: 0
      t.jsonb :members_by_role, default: {}
      t.decimal :average_age, precision: 4, scale: 1
      t.decimal :minor_percentage, precision: 5, scale: 2
      t.jsonb :additional_metrics, default: {}
      
      t.timestamps
    end
    
    add_index :organization_analytics, :generated_at
    add_index :organization_analytics, :report_period
    add_index :organization_analytics, [:organization_id, :generated_at], name: 'index_org_analytics_on_org_id_and_generated_at'
  end
end 