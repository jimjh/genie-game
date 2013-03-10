require 'spec_helper'

describe LampConcern do

  class LampConcernedDummyClass; end

  before :each do
    @dummy = LampConcernedDummyClass.new
    @dummy.extend LampConcern
  end

  subject { @dummy }

  it 'invokes Lamp::RPC::Client.new' do
    Lamp::RPC::Client.expects(:new).twice.returns({})
    t1 = Thread.new { 10.times { subject.lamp_client } }
    t2 = Thread.new { 10.times { subject.lamp_client } }
    t1.join
    t2.join
  end

end
