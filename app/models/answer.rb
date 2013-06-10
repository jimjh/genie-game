require 'csv'
# == Answer
# An answer is a student's attempt at a problem.
class Answer < ActiveRecord::Base
  include WeakComparator

  serialize :content, Marshal

  # relationships ------------------------------------------------------------
  belongs_to :problem, inverse_of: :answers
  belongs_to :user, inverse_of: :answers

  # attributes ---------------------------------------------------------------
  attr_accessible :content
  attr_readonly   :problem_id, :user_id

  # validations --------------------------------------------------------------
  validates_presence_of :content, :problem, :user
  validate :lesson_must_be_published

  # scope --------------------------------------------------------------------
  scope :for_users, lambda { |ids| where(user_id: ids) }

  # callbacks ----------------------------------------------------------------
  before_save :verify_attempt

  def self.upsert(user_id, problem_id, attributes)
    ans = Answer.where(user_id: user_id, problem_id: problem_id).first_or_initialize
    ans.attributes = attributes
    ans
  end

  def self.to_csv(options={})
    CSV.generate(options) do |csv|
      csv << %w[id lesson_slug problem_position user_slug score]
      all.each do |a|
        csv << [a.id, a.problem.lesson.name, a.problem.position, a.user.slug, a.score]
      end
    end
  end

  private

  def lesson_must_be_published
    if problem.present? and problem.lesson.present? and !problem.lesson.published?
      errors.add(:base, :not_published)
    end
  end

  # Compares the given answer and the correct answer.
  def verify_attempt
    self.results = same? content, Marshal.load(problem.solution)
    self.score   = score_attempt results
  end

  # Sets score to 1 iff everything is correct.
  def score_attempt(r)
    case r
    when Hash
      r.inject(1) { |memo, pair| memo * score_attempt(pair[1]) }
    when TrueClass then 1
    else 0
    end
  end

end
