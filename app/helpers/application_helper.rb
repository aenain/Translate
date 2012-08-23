module ApplicationHelper
  def on_mobile?
    request.user_agent =~ /mobile/i
  end

  def on_osx?
    request.user_agent =~ /mac\s?os\s?x/i
  end

  def prepend_css_class(new_class, classes = '')
    if new_class.is_a?(Array) && classes.is_a?(Array)
      new_class.concat(classes)
    elsif new_class.is_a?(Array) && classes.is_a?(String)
      new_class.join(' ').concat(' ').concat(classes).strip
    elsif new_class.is_a?(String) && classes.is_a?(Array)
      new_class.concat(' ').concat(classes.join(' ')).strip
    else
      new_class.concat(' ').concat(classes.to_s).strip
    end
  end

  def exam_path_considering_session
    id = session[:current_exam_id]

    unless id.nil?
      exam_path(id)
    else
      new_exam_path
    end
  end

  def menu_item_class(pattern, options = {})
    if self.send("#{options[:match] || 'controller'}_name") =~ pattern
      'active'
    else
      ''
    end
  end
end
