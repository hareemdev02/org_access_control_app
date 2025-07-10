class ParticipationRulesController < ApplicationController
  before_action :set_organization
  before_action :set_participation_rule, only: [:show, :edit, :update, :destroy]
  before_action :require_organization_admin
  
  def index
    @participation_rules = @organization.participation_rules.includes(:organization)
  end
  
  def show
    authorize @participation_rule
  end
  
  def new
    @participation_rule = @organization.participation_rules.build
    authorize @participation_rule
  end
  
  def create
    @participation_rule = @organization.participation_rules.build(participation_rule_params)
    authorize @participation_rule
    
    if @participation_rule.save
      flash[:notice] = 'Participation rule created successfully.'
      redirect_to organization_participation_rules_path(@organization)
    else
      render :new
    end
  end
  
  def edit
    authorize @participation_rule
  end
  
  def update
    authorize @participation_rule
    
    if @participation_rule.update(participation_rule_params)
      flash[:notice] = 'Participation rule updated successfully.'
      redirect_to organization_participation_rules_path(@organization)
    else
      render :edit
    end
  end
  
  def destroy
    authorize @participation_rule
    
    @participation_rule.destroy
    flash[:notice] = 'Participation rule deleted successfully.'
    redirect_to organization_participation_rules_path(@organization)
  end
  
  def bulk_update
    authorize ParticipationRule
    
    params[:participation_rules].each do |rule_params|
      rule = @organization.participation_rules.find(rule_params[:id])
      rule.update!(
        enabled: rule_params[:enabled] == '1',
        requires_parental_consent: rule_params[:requires_parental_consent] == '1',
        content_filtering_level: rule_params[:content_filtering_level],
        participation_restrictions: rule_params[:participation_restrictions] || []
      )
    end
    
    flash[:notice] = 'Participation rules updated successfully.'
    redirect_to organization_participation_rules_path(@organization)
  end
  
  def reset_to_defaults
    authorize ParticipationRule
    
    @organization.participation_rules.destroy_all
    ParticipationRule.default_rules_for_organization(@organization)
    
    flash[:notice] = 'Participation rules reset to defaults successfully.'
    redirect_to organization_participation_rules_path(@organization)
  end
  
  private
  
  def set_organization
    @organization = Organization.find(params[:organization_id])
  end
  
  def set_participation_rule
    @participation_rule = @organization.participation_rules.find(params[:id])
  end
  
  def participation_rule_params
    params.require(:participation_rule).permit(
      :age_group, :minimum_age, :maximum_age, :enabled, :requires_parental_consent,
      :content_filtering_level, :participation_restrictions, :description, :settings
    )
  end
end 