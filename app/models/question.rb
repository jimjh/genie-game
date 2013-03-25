# == Question
# - +id+ is the usual primary key
# - +position+ is the position of this question in the lesson. This is used by
#   +verify+ to submit answers
# - +digest+ is the SHA256 digest of the question text (in YAML)
#
# On push, if the digest has changed, we create a new question. Otherwise, the
# existing questions is updated. Old questions that no longer exist are
# deactivated. As such, it's possible for users to have answers pointing to an
# old question.
class Question < ActiveRecord::Base

  # relationships ------------------------------------------------------------
  belongs_to :lesson

  # attributes ---------------------------------------------------------------
  attr_accessible :answer, :digest, :position, :active

  # validations --------------------------------------------------------------
  validates_existence_of :lesson
  validates_presence_of  :digest, :position
  validates_numericality_of :position

end
