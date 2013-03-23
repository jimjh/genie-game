module SettingsHelper

  CLASS_STATUS = {
    'publishing' => 'disabled',
    'published' => 'disabled',
    'failed' => 'alert disabled'
  }

  def class_for(status)
    CLASS_STATUS[status]
  end

end
