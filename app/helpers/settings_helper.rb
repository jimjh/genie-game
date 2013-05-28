module SettingsHelper

  # @return [String] appropriate color code for given status
  def status_class_for(lesson)
    case lesson.try(:status)
    when 'published'  then 'green'
    when 'publishing' then 'yellow'
    when 'failed', 'deactivated' then 'red'
    end
  end

  # @return [Boolean] appropriate state for on/off switch
  def checked?(lesson)
    %w[published publishing].include? lesson.try(:status)
  end

  def active_class(path)
    current_page?(path) ? 'active' : ''
  end

end
