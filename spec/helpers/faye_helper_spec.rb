require 'spec_helper'

describe FayeHelper do

  describe '#faye_url' do
    it 'returns a URI string' do
      %w[http https].should include URI(helper.faye_url).scheme
    end
  end

  describe '#faye_js' do
    it 'returns a URI string' do
      %w[http https].should include URI(helper.faye_js).scheme
    end
  end

end
