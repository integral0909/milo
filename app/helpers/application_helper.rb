module ApplicationHelper
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
