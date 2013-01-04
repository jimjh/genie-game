class Lesson < ActiveRecord::Base
  extend FriendlyId

  # TODO: strings and messages
  # callbacks ----------------------------------------------------------------
  before_validation :default_values
  friendly_id :name, use: :slugged

  attr_accessible   :name, :url

  # relationships ------------------------------------------------------------
  belongs_to :user

  # validations --------------------------------------------------------------
  validates_presence_of   :name, :url, :user_id
  validate                :user_must_exist
  validate                :url_must_be_valid
  validates_uniqueness_of :name, scope: :user_id

  # @return [Pathname] path that is suitable for use as lesson path
  def path
    Pathname.new(user.slug) + self.slug
  end

  private

  def user_must_exist
    user_id.present? && User.find(user_id)
  rescue ActiveRecord::RecordNotFound
    errors.add :user, 'is not a registered user.'
  end

  # Checks if the given url is a valid git URL. Local paths with +file://+ are
  # not supported.
  # @note This is not foolproof, and a hacker and still supply a carefully
  #   crafted string to trick us into cloning a local repository.
  # @see http://www.kernel.org/pub/software/scm/git/docs/git-clone.html
  def url_must_be_valid
    url.blank? ||
      (url_is_remote? and url_has_suffix? and url_matches?) ||
      errors.add(:url, 'is not a valid git URL.')
  end

  GIT_SCHEMES = %w(ssh git http https ftp ftps rsync)
  GIT_SUFFIX  = '.git'

  # A weak test for remote URI.
  def url_is_remote?
    !(url =~ /localhost/ || url =~ /127\.0\.0\.1/ || url =~ /0\.0\.0\.0/)
  end

  def url_has_suffix?
    GIT_SUFFIX == File.extname(url)
  end

  # @return [Boolean] true if url does not have a scheme (scp-style) or can be
  #   parsed by ruby's URI.
  def url_matches?
    !(url =~ /\A\s*[^:]+:\/\//) || GIT_SCHEMES.include?(URI.parse(url).scheme)
  rescue URI::InvalidURIError
    false
  end

  # Sets default values.
  def default_values
    self.name ||= File.basename(url || '', GIT_SUFFIX)
  end

end
