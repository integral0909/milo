# ================================================
# RUBY->CONTROLLER->REGISTRATIONS-CONTROLLER =====
# ================================================
class RegistrationsController < Devise::RegistrationsController

  respond_to :json, :html

  # ----------------------------------------------
  # LAYOUT ---------------------------------------
  # ----------------------------------------------
  layout "signup"

  # ----------------------------------------------
  # FILTERS --------------------------------------
  # ----------------------------------------------
  prepend_before_action :require_no_authentication, only: [:new, :create, :cancel]
  prepend_before_action :authenticate_scope!, only: [:edit, :security, :update, :destroy]
  prepend_before_action :set_minimum_password_length, only: [:new, :edit]

  before_action :configure_account_update_params, only: [:update]

  # ==============================================
  # ACTIONS ======================================
  # ==============================================

  # ----------------------------------------------
  # CREATE ---------------------------------------
  # ----------------------------------------------
  def create
    build_resource(sign_up_params)
    if resource.save
      yield resource if block_given?
      if resource.persisted?
        if resource.active_for_authentication?
          # set_flash_message! :notice, :signed_up
          sign_up(resource_name, resource)
          # add user_id as business owner
          if resource.business_id
            Business.add_business_owner(current_user, resource.business_id)
          end
          # Slack Notification for Sign Up
          if Rails.env == "production"
            if current_user.business
              notifier = Slack::Notifier.new "https://hooks.slack.com/services/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", channel: '#signups', username: 'Milo Works', icon_emoji: ':moneybag:'
              user_count = User.where.not(business_id: nil).count
              notifier.ping "#{current_user.business.name} (#{current_user.email}) just signed up! Shift currently has #{user_count} businesses!"
            else
              notifier = Slack::Notifier.new "https://hooks.slack.com/services/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", channel: '#signups', username: 'Milo', icon_emoji: ':moneybag:'
              user_count = User.all.count
              notifier.ping "#{current_user.email} just signed up! Shift currently has #{user_count} users!"
            end
          end
          # send welcome email
          if current_user.invited.nil?
            UserMailer.welcome_email(current_user).deliver_now
          end
          # Create first goal
          Goal.first_goal(current_user.id)
          # Response After Sign Up
          respond_with resource, location: after_sign_up_path_for(resource)
        else
          # set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
          expire_data_after_sign_in!
          respond_with resource, location: after_inactive_sign_up_path_for(resource)
        end
      else
        clean_up_passwords resource
        set_minimum_password_length
        respond_with resource
      end
    else
      clean_up_passwords resource
      set_minimum_password_length
      if session[:referral]
        redirect_to new_user_registration_path(referral: session[:referral]), :flash => {:alert => resource.errors.full_messages.join(", ")}
      else
        redirect_to :back, :flash => {:alert => resource.errors.full_messages.join(", ")}
      end
    end
  end

  # ----------------------------------------------
  # EMPLOYER -------------------------------------
  # ----------------------------------------------
  def employer
    @user ||= User.new
    @user.build_business
  end

  # ----------------------------------------------
  # PHONE ----------------------------------------
  # ----------------------------------------------
  def phone
    render :phone
  end

  # ----------------------------------------------
  # ON-DEMAND ------------------------------------
  # ----------------------------------------------
  def on_demand
    render :on_demand
  end

  # ----------------------------------------------
  # EDIT ------------------------------------------
  # ----------------------------------------------
  def edit
    render layout: "application"
  end

  # ----------------------------------------------
  # ACCOUNTS -------------------------------------
  # ----------------------------------------------
  def accounts
    @accounts = Account.where(user_id: current_user.id).all
    if current_user.checking.present?
      @checking = Checking.find_by(user_id: current_user.id)
      @account = Account.find_by(plaid_acct_id: @checking.plaid_acct_id)
    end

    render layout: "application"
  end

  # ----------------------------------------------
  # SECURITY -------------------------------------
  # ----------------------------------------------
  def security
    render layout: "application"
  end

  # ----------------------------------------------
  # UPDATE ---------------------------------------
  # ----------------------------------------------
  def update
    if params['set_on_demand'] == "true"
      # Sign up users with Dwolla here since we get charged for all users we add. We only want to get charged if they are attaching a bank account and are completing the signup process.
      if @user.dwolla_id.blank?
        Dwolla.create_user(@user)
      end
    end

    super
  end

  # ==============================================
  # PROTECTED ====================================
  # ==============================================
  protected

  # ----------------------------------------------
  # UPDATE-RESOURCE ------------------------------
  # ----------------------------------------------
  def update_resource(resource, params)
    resource.update_without_password(params)
  end

  # ----------------------------------------------
  # CONFIGURE-ACCOUNT-UPDATE ---------------------
  # ----------------------------------------------
  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [:mobile_number])
  end

  # ----------------------------------------------
  # AFTER-SIGN-UP-PATH ---------------------------
  # ----------------------------------------------
  # Route user to next registration path
  def after_sign_up_path_for(resource)
    if current_user.invited
      signup_phone_path
    else
      authenticated_root_path
    end
  end

  # ----------------------------------------------
  # AFTER-UPDATE-PATH ----------------------------
  # ----------------------------------------------
  # Route to direct user after profile update
  def after_update_path_for(resource)
    authenticated_root_path
  end

  # ==============================================
  # PRIVATE ======================================
  # ==============================================
  private

  # ----------------------------------------------
  # SIGN-UP-PARAMS -------------------------------
  # ----------------------------------------------
  def sign_up_params
    params.require(:user).permit(:referral_code, :name, :first_name, :last_name, :zip, :email, :password, :invited, :agreement, :mobile_number, :is_verified, :on_demand, :budget, business_attributes: [:name, :address, :city, :state, :zip])
  end

  # ----------------------------------------------
  # ACCOUNT-UPDATE-PARAMS ------------------------
  # ----------------------------------------------
  def account_update_params
    params.require(:user).permit(:referral_code, :name, :first_name, :last_name, :address, :city, :state, :zip, :email, :password, :password_confirmation, :current_password, :invited, :agreement, :mobile_number, :is_verified, :on_demand, :budget, :avatar, business_attributes: [:id, :name, :address, :city, :state, :zip])
  end

end
