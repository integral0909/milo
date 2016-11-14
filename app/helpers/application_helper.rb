# ================================================
# RUBY->APPLICATION-HELPER =======================
# ================================================
module ApplicationHelper

  # ----------------------------------------------
  # UTILITY->ACTIVE-CLASS ------------------------
  # ----------------------------------------------
  # Check active class on controller
  def active_control_class?(controller)
    return 'active' if (params["controller"] == controller)
    ''
  end
  # Check active class on path
  def active_page_class?(test_path)
    return 'active' if request.path == test_path
    ''
  end

  # ----------------------------------------------
  # UTILITY->BLOCK-TO-PARTIAL --------------------
  # ----------------------------------------------
  # https://www.igvita.com/2007/03/15/block-helpers-and-dry-views-in-rails/
  #
  # Usage Example:
  #
  # def rounded_box(title, options = {}, &block)
  #   block_to_partial('shared/rounded_box', options.merge(:title => title), &block)
  # end
  def block_to_partial(partial_name, options={}, &block)

    if block_given?
      options.merge!(body: capture(&block))
    end

    render partial: partial_name, locals: options
  end


  def bootstrap_class_for(flash_type)
    case flash_type
      when "success"
        "alert-success" #Green
      when "error"
        "alert-error"
      when "notice"
        "alert-info"
      when "alert"
        "alert-warning"
      else
        flash_type.to_s
      end
  end

  # ==============================================
  # PARTIAL-BLOCKS ===============================
  # ==============================================

  # ----------------------------------------------
  # PARTIAL-BLOCKS->FORM-ERRORS ------------------
  # ----------------------------------------------
  def form_errors(instance, options={}, &block)
    block_to_partial "shared/form_errors", options.reverse_merge({instance: instance}), &block
  end

end
