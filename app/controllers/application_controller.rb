class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  
  include Pundit
  
  # Pundit authorization
  after_action :verify_authorized, except: :index, unless: :devise_controller?
  after_action :verify_policy_scoped, only: :index, unless: :devise_controller?
  
  # Handle Pundit authorization errors
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  
  protected
  
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [
      :first_name, :last_name, :date_of_birth, :phone_number, 
      :organization_id, :bio, :avatar_url
    ])
    devise_parameter_sanitizer.permit(:account_update, keys: [
      :first_name, :last_name, :date_of_birth, :phone_number, 
      :organization_id, :bio, :avatar_url
    ])
  end
  
  private
  
  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_back(fallback_location: root_path)
  end
  
  def require_organization_admin
    unless current_user&.organization_admin?
      flash[:alert] = "You must be an organization admin to perform this action."
      redirect_back(fallback_location: root_path)
    end
  end
  
  def require_organization_member
    unless current_user&.organization_member?
      flash[:alert] = "You must be a member of an organization to perform this action."
      redirect_back(fallback_location: root_path)
    end
  end
  
  def check_age_verification
    if current_user&.minor? && !current_user.parental_consent&.approved?
      flash[:warning] = "Parental consent is required for your age group."
      redirect_to parental_consent_path
    end
  end
end
