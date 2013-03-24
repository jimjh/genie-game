module SettingsHelper

  CLASS_STATUS = {
    'publishing' => 'disabled',
    'published' => 'disabled',
    'failed' => 'alert disabled'
  }

  def status_class(status)
    CLASS_STATUS[status]
  end

  def active_class(path)
    current_page?(path) ? 'active' : ''
  end

end
