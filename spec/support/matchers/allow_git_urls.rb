# ~*~ encoding: utf-8 ~*~
module Test
  module Matchers

    class AllowGitUrlsMatcher

      AllowValueMatcher = Shoulda::Matchers::ActiveModel::AllowValueMatcher
      GIT_SCHEMES = %w(ssh git http https ftp ftps rsync)

      def initialize
        urls = []
        GIT_SCHEMES.product(['user@', nil], [':123', nil], ['/', nil]).each do |s, u, p, sl|
          urls << "#{s}://#{u}host.xz#{p}/path/to/repo.git#{sl}"
        end
        ['user@', nil].product(['/', nil]).each do |u, sl|
          urls << "#{u}host.xz:path/to/repo.git#{sl}"
        end
        @allow_matcher = AllowValueMatcher.new(*urls)
      end

      def matches?(subject)
        @allow_matcher.matches?(subject)
      end

      def for(attribute)
        @allow_matcher.for(attribute)
      end

      def negative_failure_message
        @allow_matcher.failure_message
      end

      def failure_message
        @allow_matcher.negative_failure_message
      end

      def description
        'should allow various git URLs'
      end

      def allowed_types
        ''
      end

    end

    def allow_git_urls
      AllowGitUrlsMatcher.new
    end

  end
end
