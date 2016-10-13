class RegistrationsController < Devise::RegistrationsController
  prepend_before_action :require_no_authentication, only: [:new, :create, :cancel]
  prepend_before_action :authenticate_scope!, only: [:edit, :security, :update, :destroy]
  prepend_before_action :set_minimum_password_length, only: [:new, :edit]

  before_action :configure_account_update_params, only: [:update]

  def create
    build_resource(sign_up_params)
    if resource.save
      yield resource if block_given?
      if resource.persisted?
        if resource.active_for_authentication?
          # set_flash_message! :notice, :signed_up
          sign_up(resource_name, resource)
          # Slack Notification for Sign Up
          if Rails.env == "production"
            notifier = Slack::Notifier.new "https://hooks.slack.com/services/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", channel: '#signups', username: 'Milo', icon_emoji: ':moneybag:'
            user_count = User.all.count
            notifier.ping "#{current_user.email} just signed up! Milo currently has #{user_count} users!"
          end
          # add user to Dwolla
          Dwolla.create_user(current_user)

          # send welcome email
          UserMailer.welcome_email(current_user).deliver_now
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
        redirect_to new_user_registration_path, :flash => {:alert => resource.errors.full_messages.join(", ")}
      end
    end
  end

  def edit
    super
  end

  def accounts
    render :accounts
  end

  def update
    super
  end

  protected

  def update_resource(resource, params)
    resource.update_without_password(params)
  end

  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [:mobile_number])
  end

  # Route user to next registration path
  def after_sign_up_path_for(resource)
    super
  end

  # Route to direct user after profile update
  def after_update_path_for(resource)
    edit_user_registration_path
  end

  private

  def sign_up_params
    params.require(:user).permit(:referral_code, :name, :zip, :email, :password, :invited, :agreement, :mobile_number, :is_verified, :on_demand)
  end

  def account_update_params
    params.require(:user).permit(:referral_code, :name, :address, :city, :state, :zip, :email, :password, :password_confirmation, :current_password, :invited, :agreement, :mobile_number, :is_verified, :on_demand)
  end

end
