require 'spec_helper'

describe SettingsHelper do

  describe '#status_class' do
    it 'returns a string' do
      helper.status_class('failed').should be_a String
    end
  end

end

