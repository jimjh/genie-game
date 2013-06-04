require 'spec_helper'

describe FayeHelper do

  describe '#faye' do
    it 'returns a URI string' do
      %w[http https].should include URI(helper.faye).scheme
    end
  end

  describe '#faye_js' do
    it 'returns a URI string' do
      %w[http https].should include URI(helper.faye_js).scheme
    end
  end

end
