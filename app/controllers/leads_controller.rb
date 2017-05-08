# ================================================
# RUBY->CONTROLLER->LEADS-CONTROLLER =============
# ================================================
class LeadsController < ApplicationController

  # ==============================================
  # ACTIONS ======================================
  # ==============================================

  # ----------------------------------------------
  # NEW ------------------------------------------
  # ----------------------------------------------
  def new
    @lead = Lead.new
  end

  # ----------------------------------------------
  # CREATE ---------------------------------------
  # ----------------------------------------------
  def create
    @lead = Lead.new(params[:lead])
    @lead.request = request
    if @lead.deliver
      # Slack notification on new lead
      notifier = Slack::Notifier.new "https://hooks.slack.com/services/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", channel: '#leads', username: 'New Works Lead', icon_emoji: ':piggy:'
      user_count = User.where.not(business_id: nil).count
      notifier.ping "#{@lead.lead_name} (#{@lead.lead_email}) has referred #{@lead.company} for Shift Works.\n========================\n\nCompany: #{@lead.company}\nContact: #{@lead.company_contact_name}\nEmail: #{@lead.company_contact_email}\nNotes:\n#{@lead.message}"

      flash.now[:notice] = 'Thank you for your message. We will contact your employer soon!'
      render "works/index"
    else
      flash.now[:error] = 'Cannot send message.'
      render :new
    end
  end

end
