# == Lesson
# A lesson record in the database _should_ correspond to a lesson directory in
# the filesystem, although for performance reasons that's not enforced.
#
# - +slug+ is generated by friendly_id from +name+.
# - +name+ is the repositories identifier on the provider. It can be any string
#   value, although the controllers (with knowledge of GitHub's conventions)
#   might set this to the repository's name for easier web hooking. This is not
#   validated, because the model should be provider-independent. It defaults to
#   +basename url+.
# - +url+ is a cloneable url of the git repository.
# - +hook+ is the ID of a web hook registered with the provider.
# - +status+ is either
#   - +publishing+,
#   - +published+, or
#   - +failed+
#
# TODO faye
# TODO controller
class Lesson < ActiveRecord::Base
  extend FriendlyId
  include GitConcern

  STATUSES = %w[publishing published failed]

  # callbacks ----------------------------------------------------------------
  before_validation :default_values

  # attributes ---------------------------------------------------------------
  friendly_id       :name, use: :scoped, scope: [:user]
  attr_accessible   :name, :url
  attr_accessor     :action

  # relationships ------------------------------------------------------------
  belongs_to :user

  # validations --------------------------------------------------------------
  validates_presence_of   :name, :url, :user_id
  validates_uniqueness_of :name, scope: :user_id
  validates_inclusion_of  :status, in: STATUSES
  validate                :user_must_exist
  validate                :url_must_be_valid

  # @return [Pathname] path that is suitable for use as lesson path
  def path
    Pathname.new(user.slug) + self.slug
  end

  def failed
    self.status = 'failed'
    save!
    notify_observers :after_fail
  end

  def published(c_path, s_path)
    self.compiled_path = c_path
    self.solution_path = s_path
    self.status = 'published'
    save!
    notify_observers :after_publish
  end

  def pushed
    self.status = 'publishing'
    save!
    notify_observers :after_push
  end

  # Sets the status of the referenced lesson to +failed+.
  # @return [LEsson] lesson that has the given ID
  def self.failed(id)
    lesson = Lesson.find id
    lesson.failed
    lesson
  end

  # Updates the compiled and solution paths for the referenced lesson.
  # @return [Lesson] lesson that has the given ID
  def self.published(id, compiled_path, solution_path)
    lesson = Lesson.find id
    lesson.published compiled_path, solution_path
    lesson
  end

  # Updates the referenced lesson and triggers callbacks to recompile lesson.
  # @return [Lesson] lesson that belongs to +user_id+ and has +name+
  def self.pushed(user_id, name)
    lesson  = Lesson.find_by_user_id_and_name! user_id, name
    lesson.pushed
    lesson
  end

  private

  def user_must_exist
    if user_id.present? and not User.exists?(user_id)
      errors.add :user, 'is not a registerd user'
    end
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

  # Sets default values.
  def default_values
    self.name ||= File.basename(url || '', GitConcern::GIT_SUFFIX)
  end

end
