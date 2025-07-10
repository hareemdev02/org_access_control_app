class OrganizationAnalytics < ApplicationRecord
  belongs_to :organization
  
  validates :total_members, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :admin_count, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :participation_rate, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :generated_at, presence: true
  
  scope :recent, -> { order(generated_at: :desc) }
  scope :by_date_range, ->(start_date, end_date) { where(generated_at: start_date..end_date) }
  
  def self.generate_daily_report(organization)
    analytics = organization.generate_analytics
    
    # Calculate additional metrics safely
    begin
      analytics.update!(
        active_users_7_days: organization.users.joins(:user_roles).joins(:roles).where('user_roles.created_at >= ?', 7.days.ago).distinct.count,
        active_users_30_days: organization.users.joins(:user_roles).joins(:roles).where('user_roles.created_at >= ?', 30.days.ago).distinct.count,
        new_members_this_month: organization.users.where('created_at >= ?', 1.month.ago).count,
        members_by_role: organization.users.joins(:user_roles).joins(:roles).group('roles.name').count,
        average_age: organization.users.average(:age)&.round(1) || 0,
        minor_percentage: organization.users.count > 0 ? (organization.users.minors.count.to_f / organization.users.count * 100).round(2) : 0
      )
    rescue => e
      Rails.logger.error "Error updating daily report metrics: #{e.message}"
    end
    
    analytics
  end
  
  def self.generate_weekly_report(organization)
    start_date = 1.week.ago.beginning_of_week
    end_date = start_date.end_of_week
    
    analytics = organization.organization_analytics.create!(
      total_members: organization.member_count,
      admin_count: organization.admin_count,
      age_group_breakdown: organization.member_count_by_age_group,
      participation_rate: organization.calculate_participation_rate,
      generated_at: Time.current,
      report_period: 'weekly',
      period_start: start_date,
      period_end: end_date,
      new_members_count: organization.users.where(created_at: start_date..end_date).count,
      active_members_count: organization.users.joins(:user_roles).joins(:roles).where('user_roles.created_at >= ?', start_date).distinct.count
    )
    
    analytics
  end
  
  def self.generate_monthly_report(organization)
    start_date = 1.month.ago.beginning_of_month
    end_date = start_date.end_of_month
    
    analytics = organization.organization_analytics.create!(
      total_members: organization.member_count,
      admin_count: organization.admin_count,
      age_group_breakdown: organization.member_count_by_age_group,
      participation_rate: organization.calculate_participation_rate,
      generated_at: Time.current,
      report_period: 'monthly',
      period_start: start_date,
      period_end: end_date,
      new_members_count: organization.users.where(created_at: start_date..end_date).count,
      active_members_count: organization.users.joins(:user_roles).joins(:roles).where('user_roles.created_at >= ?', start_date).distinct.count
    )
    
    analytics
  end
  
  def growth_rate
    return 0 if total_members.zero?
    
    previous_analytics = organization.organization_analytics
      .where('generated_at < ?', generated_at)
      .order(generated_at: :desc)
      .first
    
    return 0 unless previous_analytics
    
    previous_members = previous_analytics.total_members
    return 0 if previous_members.zero?
    
    ((total_members - previous_members).to_f / previous_members * 100).round(2)
  end
  
  def participation_trend
    previous_analytics = organization.organization_analytics
      .where('generated_at < ?', generated_at)
      .order(generated_at: :desc)
      .first
    
    return 0 unless previous_analytics
    
    previous_rate = previous_analytics.participation_rate
    return 0 if previous_rate.zero?
    
    ((participation_rate - previous_rate).to_f / previous_rate * 100).round(2)
  end
  
  def age_group_percentages
    return {} if total_members.zero?
    
    age_group_breakdown.transform_values do |count|
      (count.to_f / total_members * 100).round(2)
    end
  end
  
  def report_summary
    {
      total_members: total_members,
      admin_count: admin_count,
      participation_rate: participation_rate,
      growth_rate: growth_rate,
      participation_trend: participation_trend,
      age_group_breakdown: age_group_breakdown,
      age_group_percentages: age_group_percentages,
      generated_at: generated_at,
      report_period: report_period
    }
  end
end 