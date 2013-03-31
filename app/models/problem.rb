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
  belongs_to :lesson
  has_many   :answers, dependent: :destroy

  # attributes ---------------------------------------------------------------
  attr_accessible :solution, :digest, :position, :active

  # validations --------------------------------------------------------------
  validates_existence_of :lesson
  validates_presence_of  :digest, :position
  validates_numericality_of :position

  # callbacks ----------------------------------------------------------------
  before_create :decode_solution

  private

  def decode_solution
    return unless solution.present?
    self.solution = Base64.urlsafe_decode64 self.solution
  end

end
