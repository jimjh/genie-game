require 'spec_helper'

describe SettingsHelper do

  describe '#status_class_for' do
    it 'returns a string' do
      helper.status_class_for(Lesson.new).should be_a String
    end
  end

end

