class DashboardController < ApplicationController
  skip_after_action :verify_policy_scoped, only: :index
  
  def index
    authorize :dashboard
    
    @user = current_user
    @organization = @user.organization
    
    if @organization
      @analytics = @organization.organization_analytics.recent.first
      @participation_rules = @organization.participation_rules.enabled
      @members_count = @organization.member_count
      @admin_count = @organization.admin_count
    end
    
    @parental_consent = @user.parental_consent if @user.minor?
    @pending_consents = @user.parental_consents.pending if @user.adult?
    
    # Check if user needs parental consent
    if @user.minor? && !@user.parental_consent&.approved?
      flash[:warning] = "Parental consent is required for your age group. Please request consent from a parent or guardian."
    end
  end
end 