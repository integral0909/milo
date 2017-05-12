# ================================================
# RUBY->CONTROLLER->INVITATIONS-CONTROLLER =======
# ================================================
class InvitationsController < Devise::InvitationsController

  # ----------------------------------------------
  # LAYOUT ---------------------------------------
  # ----------------------------------------------
  layout "signup"

  # ----------------------------------------------
  # FILTERS --------------------------------------
  # ----------------------------------------------
  before_filter :configure_permitted_parameters, if: :devise_controller?

  # ==============================================
  # ACTIONS ======================================
  # ==============================================

  # ----------------------------------------------
  # NEW ------------------------------------------
  # ----------------------------------------------
  def new
    self.resource = resource_class.new
    render :new, layout: "application"
  end

  # ----------------------------------------------
  # CREATE ---------------------------------------
  # ----------------------------------------------
  def create
    self.resource = invite_resource
    resource_invited = resource.errors.empty?

    yield resource if block_given?

    if resource_invited
      if is_flashing_format? && self.resource.invitation_sent_at
        set_flash_message :notice, :send_instructions, :email => self.resource.email
      end
      if self.method(:after_invite_path_for).arity == 1
        respond_with resource, :location => after_invite_path_for(current_inviter)
      else
        respond_with resource, :location => after_invite_path_for(current_inviter, resource)
      end
    else
      respond_with_navigational(resource) { render :new, layout: "application" }
    end
  end

  # ----------------------------------------------
  # EDIT -----------------------------------------
  # ----------------------------------------------
  def edit
    set_minimum_password_length
    resource.invitation_token = params[:invitation_token]
    render :edit, layout: "signup"
  end

  # ----------------------------------------------
  # UPDATE ---------------------------------------
  # ----------------------------------------------
  def update
    raw_invitation_token = update_resource_params[:invitation_token]
    self.resource = accept_resource
    invitation_accepted = resource.errors.empty?

    yield resource if block_given?

    if invitation_accepted
      if Devise.allow_insecure_sign_in_after_accept
        flash_message = resource.active_for_authentication? ? :updated : :updated_not_active
        set_flash_message :notice, flash_message if is_flashing_format?
        sign_in(resource_name, resource)

        # Slack notification for sign up
        if Rails.env == "production"
          notifier = Slack::Notifier.new "https://hooks.slack.com/services/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", channel: '#signups', username: 'Shift Works', icon_emoji: ':moneybag:'
          notifier.ping "#{current_user.name} (#{current_user.email}) just signed up as an employee with #{current_user.business.name}!"
        end

        # Create first goal
        Goal.first_goal(current_user.id)

        respond_with resource, :location => after_accept_path_for(resource)
      else
        set_flash_message :notice, :updated_not_active if is_flashing_format?
        respond_with resource, :location => new_session_path(resource_name)
      end
    else
      resource.invitation_token = raw_invitation_token
      respond_with_navigational(resource){ render :edit }
    end
  end

  # ----------------------------------------------
  # AFTER-INVITE-PATH ----------------------------
  # ----------------------------------------------
  def after_invite_path_for(resource)
    employees_path
  end

  # ==============================================
  # PRIVATE ======================================
  # ==============================================
  private

  # ----------------------------------------------
  # CONFIGURE-PERMITTED-PARAMS -------------------
  # ----------------------------------------------
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:invite, keys: [:name, :email, :invitation_token, :address, :city, :state, :zip, :business_id, :invited])
    devise_parameter_sanitizer.permit(:accept_invitation, keys: [:name, :email, :password, :invitation_token, :zip, :agreement])
  end

end
