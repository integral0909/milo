module RegistrationsHelper

  def mobile_verification_button
    # Return an empty string unless the user needs to be verified
    return '' unless current_user.needs_mobile_number_verifying?
    html = <<-HTML
      #{form_tag(verifications_path, method: "post")}
      #{button_tag('Send Verification Code', type: "submit", class: "button -blue")}
      </form>
    HTML
    html.html_safe
  end

  def verify_mobile_number_form
    return '' if current_user.verification_code.blank?
    p current_user.verification_code.blank?
    html = <<-HTML
      #{form_tag(verifications_path, method: "patch")}
        <fieldset class="form-group">
          <label>Verification Code</label>
          #{text_field_tag('verification_code', "", class: "form-control")}
        </fieldset>
        #{button_tag('Confirm', type: "submit", class: "button -blue")}
      </form>
    HTML
    html.html_safe
  end

end
