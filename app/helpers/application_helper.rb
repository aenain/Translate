module ApplicationHelper
  def exam_path_considering_session
    id = session[:current_exam_id]

    unless id.nil?
      exam_path(id)
    else
      new_exam_path
    end
  end
end
