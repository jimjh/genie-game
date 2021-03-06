# == Problem
# - +id+ is the usual primary key
# - +position+ is the position of this problem in the lesson. This is used by
#   +verify+ to submit solutions
# - +digest+ is the SHA256 digest of the problem text (in YAML)
#
# On push, if the digest has changed, we create a new problem. Otherwise, the
# existing problem is updated. Old problems that no longer exist are
# deactivated. As such, it's possible for users to have solutions pointing to an
# old problem.
class Problem < ActiveRecord::Base

  # relationships ------------------------------------------------------------
  belongs_to :lesson, inverse_of: :problems
  has_many   :answers, dependent: :destroy, inverse_of: :problem do
    def for_users(subset)
      where(user_id: subset)
    end
  end

  # attributes ---------------------------------------------------------------
  attr_accessible :solution, :digest, :position, :active
  attr_readonly   :lesson_id

  # validations --------------------------------------------------------------
  validates_presence_of  :digest, :position, :lesson
  validates_numericality_of :position

  # callbacks ----------------------------------------------------------------
  before_create :decode_solution

  def avg_incorrect_attempts(subset = nil)
    answers = subset ? self.answers.for_users(subset) : self.answers
    sum     = answers.map(&:incorrect_attempts).reduce(0, :+)
    sum.zero? ? 0 : sum/answers.count
  end

  private

  def decode_solution
    return unless solution.present?
    self.solution = Base64.urlsafe_decode64 self.solution
  end

end
