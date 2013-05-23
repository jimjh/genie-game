require 'spec_helper'

describe 'vanity routes for lessons' do

  it 'appends trailing slash to requests for lesson root' do
    { get: '/jimjh/floating-point' }.
      should route_to(
        controller: 'lessons',
        action: 'show',
        path: 'index.inc',
        user: 'jimjh',
        lesson: 'floating-point'
      )
  end

  it 'routes :user/:lesson/:path to the asset at :path' do
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

  it 'defaults :path to "index.inc"' do
    { get: '/jimjh/floating-point/' }.
      should route_to(
        controller: 'lessons',
        action: 'show',
        path: 'index.inc',
        user: 'jimjh',
        lesson: 'floating-point'
      )
  end

end

describe 'vanity routes for lesson settings' do

  it 'defaults :path to "default"' do
    { get: '/jimjh/floating-point/settings' }.
      should route_to(
        controller: 'lessons',
        action: 'settings',
        path: 'default',
        user: 'jimjh',
        lesson: 'floating-point'
      )
  end

end
