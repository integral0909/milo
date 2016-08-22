module ApplicationHelper

  def active_control_class?(controller)
    return 'active' if (params["controller"] == controller)
    ''
  end

  def active_page_class?(test_path)
    return 'active' if request.path == test_path
    ''
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
end
