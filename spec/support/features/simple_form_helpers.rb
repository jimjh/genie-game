module Features
  module SimpleFormHelpers

    def have_validation_errors
      have_message 'simple_form.error_notification.default_message'
    end

  end
end
