require 'spec_helper'

describe 'vanity routes' do

  it 'routes :user/:lesson/:path' do
    { get: '/jimjh/floating-point/images/binary.png' }.
      should route_to(
        controller: 'lessons',
        action: 'show',
        path: 'images/binary',
        format: 'png',
        user: 'jimjh',
        lesson: 'floating-point'
      )
  end

  it 'defaults :path to index.inc' do
    { get: '/jimjh/floating-point' }.
      should route_to(
        controller: 'lessons',
        action: 'show',
        path: 'index.inc',
        user: 'jimjh',
        lesson: 'floating-point'
      )
  end

end
