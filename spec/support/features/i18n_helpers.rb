module Features
  module I18nHelpers

    def have_message(key)
      have_content I18n.t key
    end

  end
end
