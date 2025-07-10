class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :roles, :assign_role, :remove_role]
  before_action :require_organization_admin, only: [:roles, :assign_role, :remove_role]
  
  def index
    @users = policy_scope(User).includes(:organization, :roles)
  end
  
  def new
    @user = User.new
    authorize @user
  end
  
  def create
    @user = User.new(user_params)
    authorize @user
    
    if @user.save
      flash[:notice] = 'User created successfully.'
      redirect_to @user
    else
      render :new
    end
  end
  
  def show
    authorize @user
    @roles = @user.roles.includes(:resource)
    @parental_consent = @user.parental_consent
  end
  
  def edit
    authorize @user
  end
  
  def update
    authorize @user
    
    if @user.update(user_params)
      flash[:notice] = 'Profile updated successfully.'
      redirect_to @user
    else
      render :edit
    end
  end
  
  def destroy
    authorize @user
    
    @user.destroy
    flash[:notice] = 'User deleted successfully.'
    redirect_to users_path
  end
  
  def roles
    authorize @user
    @available_roles = Role.default_roles
    @user_roles = @user.roles.includes(:resource)
  end
  
  def assign_role
    authorize @user
    
    role_name = params[:role_name]
    resource_type = params[:resource_type]
    resource_id = params[:resource_id]
    
    resource = nil
    if resource_type && resource_id
      resource = resource_type.constantize.find(resource_id)
    end
    
    @user.add_role(role_name, resource)
    
    flash[:notice] = "Role '#{role_name}' assigned successfully."
    redirect_to user_roles_path(@user)
  end
  
  def remove_role
    authorize @user
    
    role_name = params[:role_name]
    resource_type = params[:resource_type]
    resource_id = params[:resource_id]
    
    resource = nil
    if resource_type && resource_id
      resource = resource_type.constantize.find(resource_id)
    end
    
    @user.remove_role(role_name, resource)
    
    flash[:notice] = "Role '#{role_name}' removed successfully."
    redirect_to user_roles_path(@user)
  end
  
  def profile
    @user = current_user
    authorize @user
  end
  
  def update_profile
    @user = current_user
    authorize @user
    
    if @user.update(profile_params)
      flash[:notice] = 'Profile updated successfully.'
      redirect_to profile_path
    else
      render :profile
    end
  end
  
  private
  
  def set_user
    @user = User.find(params[:id])
  end
  
  def user_params
    params.require(:user).permit(
      :first_name, :last_name, :email, :date_of_birth, :phone_number,
      :organization_id, :bio, :avatar_url, :active
    )
  end
  
  def profile_params
    params.require(:user).permit(
      :first_name, :last_name, :email, :date_of_birth, :phone_number,
      :bio, :avatar_url
    )
  end
end 