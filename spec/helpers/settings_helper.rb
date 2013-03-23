require 'spec_helper'

describe SettingsHelper do

  describe '#class_for' do
    it 'returns a string' do
      helper.class_for('failed').should be_a String
    end
  end

end

