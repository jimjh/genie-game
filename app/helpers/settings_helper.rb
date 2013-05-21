module SettingsHelper

  def status_class(lesson)
    case lesson.try(:status)
    when 'published'  then 'green'
    when 'publishing' then 'yellow'
    when 'failed', 'deactivated' then 'red'
    end
  end

  def active_class(path)
    current_page?(path) ? 'active' : ''
  end

end
