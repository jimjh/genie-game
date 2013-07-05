require 'csv'
# == Answer
# An answer is a student's attempt at a problem.
# - +results+: a boolean or a hash of booleans indicating comparison results
# - +content+: user's submission
# - +score+:   =1 iff everything in +results+ is +true+
# - +attempts+: number of attempts
class Answer < ActiveRecord::Base
  include WeakComparator

  serialize :content, Marshal

  # relationships ------------------------------------------------------------
  with_options inverse_of: :answers do |assoc|
    assoc.belongs_to :problem
    assoc.belongs_to :user
  end

  # attributes ---------------------------------------------------------------
  attr_accessible :content
  attr_readonly   :problem_id, :user_id

  # validations --------------------------------------------------------------
  validates_presence_of :content, :problem, :user
  validate :lesson_must_be_published

  # scope --------------------------------------------------------------------
  scope :for_users, lambda { |ids| where(user_id: ids) }
  scope :correct, where('score >= ?', 1)

  # callbacks ----------------------------------------------------------------
  before_save :verify_attempt

  # Find existing answer object or create one.
  def self.upsert(user_id, problem_id, attributes)
    ans = Answer.where(user_id: user_id, problem_id: problem_id).first_or_initialize
    ans.attributes = attributes
    ans.attempts  += 1
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

  def incorrect_attempts
    if first_correct_attempt
      self.first_correct_attempt - 1
    else
      self.attempts
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
    self.first_correct_attempt = attempts if score == 1 and first_correct_attempt.nil?
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
