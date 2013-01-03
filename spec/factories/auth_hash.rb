# ~*~ encoding: utf-8 ~*~
FactoryGirl.define do

  factory :auth_hash, class: Hash do
    provider    'GitHub'
    uid         { Random.rand(100).to_s }
    association :info,        factory: :auth_hash_info
    association :credentials, factory: :auth_hash_credentials
    association :extra,       factory: :auth_hash_extra
    initialize_with { attributes }
    to_create       {}
  end

  factory :auth_hash_info, class: Hash do
    name            { Faker::Name.name }
    nickname        { Faker::Name.first_name }
    initialize_with { attributes }
    to_create       {}
  end

  factory :auth_hash_credentials, class: Hash do
    token           'lk2j3lkjasldkjflk3ljsdf'
    initialize_with { attributes }
    to_create       {}
  end

  factory :auth_hash_extra, class: Hash do
    raw_info        'html_url' => 'http://github.com/x/y/z'
    initialize_with { attributes }
    to_create       {}
  end

end
