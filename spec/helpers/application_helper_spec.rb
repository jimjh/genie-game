require 'spec_helper'

describe ApplicationHelper do

  describe '#flash_for' do

    it "returns '' for notice messages" do
      helper.flash_for(:notice).should eq('')
    end

    it "returns 'alert' for error messages" do
      helper.flash_for(:alert).should eq('alert')
    end

    it "returns 'alert' for alert messages" do
      helper.flash_for(:alert).should eq('alert')
    end

    it "returns 'success' for success messages" do
      helper.flash_for(:success).should eq('success')
    end

    it "returns 'secondary' for other messages" do
      helper.flash_for(:whatever).should eq('secondary')
    end

  end

  describe '#cdn_js' do

    it 'returns an array' do
      helper.cdn_js.should be_kind_of Array
    end

    it 'returns an array of URI strings' do
      helper.cdn_js.each { |s| [nil, 'http', 'https'].should include URI(s).scheme }
    end

  end

end
