module SettingsHelper

  def status_class(status)
    case status
    when 'published'  then 'green'
    when 'publishing' then 'yellow'
    when 'failed'     then 'red'
    end
  end

  def active_class(path)
    current_page?(path) ? 'active' : ''
  end

end
