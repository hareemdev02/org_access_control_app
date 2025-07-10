class ParentalConsentsController < ApplicationController
  before_action :set_parental_consent, only: [:show, :edit, :update, :approve, :revoke]
  before_action :check_consent_permissions, only: [:show, :edit, :update, :approve, :revoke]
  skip_after_action :verify_policy_scoped, only: :index
  
  def index
    if current_user.minor?
      @parental_consent = current_user.parental_consent
      redirect_to parental_consent_path(@parental_consent) if @parental_consent
    else
      @parental_consents = policy_scope(ParentalConsent).includes(:child, :parent)
    end
  end
  
  def show
    authorize @parental_consent
  end
  
  def new
    if current_user.minor?
      @parental_consent = ParentalConsent.new(child: current_user)
    elsif current_user.has_role?(:admin)
      @parental_consent = ParentalConsent.new
    else
      @parental_consent = ParentalConsent.new(parent: current_user)
    end
    authorize @parental_consent
  end
  
  def create
    # Build parental consent from params
    @parental_consent = ParentalConsent.new(parental_consent_params)
    
    # Set the parent to current user if they're an adult and no parent is specified
    if current_user.adult? && @parental_consent.parent_id.blank?
      @parental_consent.parent = current_user
    end
    
    # Set the child if child_id is provided
    if params[:parental_consent][:child_id].present?
      child = User.find(params[:parental_consent][:child_id])
      @parental_consent.child = child
    end
    

    
    authorize @parental_consent
    
    if @parental_consent.save
      flash[:notice] = 'Parental consent created successfully.'
      redirect_to @parental_consent
    else
      render :new
    end
  end
  
  def edit
    authorize @parental_consent
  end
  
  def update
    authorize @parental_consent
    
    if @parental_consent.update(parental_consent_params)
      flash[:notice] = 'Parental consent updated successfully.'
      redirect_to @parental_consent
    else
      render :edit
    end
  end
  
  def approve
    authorize @parental_consent
    
    if @parental_consent.approve_consent(current_user)
      flash[:notice] = 'Parental consent approved successfully.'
    else
      flash[:alert] = 'Failed to approve parental consent.'
    end
    
    redirect_to @parental_consent
  end
  
  def revoke
    authorize @parental_consent
    
    if @parental_consent.revoke_consent(current_user)
      flash[:notice] = 'Parental consent revoked successfully.'
    else
      flash[:alert] = 'Failed to revoke parental consent.'
    end
    
    redirect_to @parental_consent
  end
  
  def renew
    @parental_consent = current_user.parental_consent
    authorize @parental_consent
    
    if @parental_consent.renew_consent
      flash[:notice] = 'Parental consent renewed successfully.'
    else
      flash[:alert] = 'Failed to renew parental consent.'
    end
    
    redirect_to @parental_consent
  end
  
  private
  
  def set_parental_consent
    @parental_consent = ParentalConsent.find(params[:id])
  end
  
  def check_consent_permissions
    unless current_user == @parental_consent.parent || current_user == @parental_consent.child
      flash[:alert] = 'You are not authorized to view this parental consent.'
      redirect_to parental_consents_path
    end
  end
  
  def parental_consent_params
    params.require(:parental_consent).permit(:child_id, :parent_id, :consent_date, :expiry_date, :notes, :consent_details)
  end
end 