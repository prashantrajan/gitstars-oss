FactoryGirl.define do

  # User
  factory :user, :class => User do
    sequence(:login) { |n| "person#{n}" }
    sequence(:github_uid) { |n| n }
    gravatar_id 'f9511f3a58eab78303f74b197d4fb94d'

    factory :real_github_user do
      login 'gitstars'
      github_uid 2108436
      github_oauth_token '50e0e4dd43280a3a12315120757e6ee32b61cc9a'
    end

    factory :pre_seeded_user do
      login 'gitstars'
      github_uid 2108436
      github_oauth_token nil
    end
  end

  # Repo
  factory :repo, :class => Repo do
    sequence(:github_identifier) { |n| n }
    sequence(:name) { |n| "repo#{n}" }
    sequence(:owner_login) { |n| "user#{n}" }
    full_name { "#{owner_login}/#{name}" }
    github_url { "https://github.com/#{owner_login}/#{name}" }
  end

  # RepoUser
  factory :repo_user, :class => RepoUser do
    association :user, :factory => :user
    association :repo, :factory => :repo
  end

  # Tag
  factory :tag, :class => Tag do
    sequence(:name) { |n| "tag#{n}"}
    slug { name.parameterize }
  end

  # Tagging
  factory :tagging, :class => Tagging do
    association :repo_user, :factory => :repo_user
    association :tag, :factory => :tag
  end

end
