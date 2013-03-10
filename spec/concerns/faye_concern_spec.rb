require 'spec_helper'

describe FayeConcern do

  class FayeConcernedDummyClass; end

  before :each do
    @dummy = FayeConcernedDummyClass.new
    @dummy.extend FayeConcern
  end

  subject { @dummy }

  it 'invokes Faye::Client.new' do
    Faye::Client.expects(:new).twice.returns(stub(disconnect: true))
    t1 = Thread.new { 10.times { subject.faye_client } }
    t2 = Thread.new { 10.times { subject.faye_client } }
    t1.join
    t2.join
  end

end
