class OrganizationsController < ApplicationController
  before_action :set_organization, only: [:show, :edit, :update, :destroy, :analytics, :members, :participation_rules]
  before_action :require_organization_admin, only: [:edit, :update, :destroy, :participation_rules]
  
  def index
    @organizations = policy_scope(Organization)
  end
  
  def show
    authorize @organization
    @members = @organization.users.includes(:roles)
    @analytics = @organization.organization_analytics.recent.first
  end
  
  def new
    @organization = Organization.new
    authorize @organization
  end
  
  def create
    @organization = Organization.new(organization_params)
    authorize @organization
    
    if @organization.save
      # Add current user as admin
      current_user.update!(organization: @organization)
      current_user.add_role('admin', @organization)
      
      # Create default participation rules
      ParticipationRule.default_rules_for_organization(@organization)
      
      flash[:notice] = 'Organization created successfully.'
      redirect_to @organization
    else
      render :new
    end
  end
  
  def edit
    authorize @organization
  end
  
  def update
    authorize @organization
    
    if @organization.update(organization_params)
      flash[:notice] = 'Organization updated successfully.'
      redirect_to @organization
    else
      render :edit
    end
  end
  
  def destroy
    authorize @organization
    
    @organization.destroy
    flash[:notice] = 'Organization deleted successfully.'
    redirect_to organizations_path
  end
  
  def analytics
    authorize @organization
    
    @analytics = @organization.organization_analytics.recent.limit(10)
    
    begin
      @daily_report = OrganizationAnalytics.generate_daily_report(@organization)
    rescue => e
      Rails.logger.error "Error generating daily report: #{e.message}"
      @daily_report = nil
    end
    
    begin
      @weekly_report = OrganizationAnalytics.generate_weekly_report(@organization)
    rescue => e
      Rails.logger.error "Error generating weekly report: #{e.message}"
      @weekly_report = nil
    end
    
    begin
      @monthly_report = OrganizationAnalytics.generate_monthly_report(@organization)
    rescue => e
      Rails.logger.error "Error generating monthly report: #{e.message}"
      @monthly_report = nil
    end
  end
  
  def members
    authorize @organization
    
    @users = @organization.users.includes(:roles, :parental_consent)
    @members_by_role = @users.joins(:roles).group('roles.name').count
    @members_by_age_group = @organization.member_count_by_age_group
  end
  
  def participation_rules
    authorize @organization
    
    @participation_rules = @organization.participation_rules.includes(:organization)
  end
  
  private
  
  def set_organization
    @organization = Organization.find(params[:id])
  end
  
  def organization_params
    params.require(:organization).permit(
      :name, :domain, :description, :participation_type, :active, :settings
    )
  end
end 