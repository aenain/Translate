module ApplicationHelper
  def exam_path_considering_session
    id = session[:current_exam_id]

    unless id.nil?
      exam_path(id)
    else
      new_exam_path
    end
  end

  def menu_item_class(pattern)
    if controller_name =~ pattern
      'active'
    else
      ''
    end
  end
end
