# == Answer
# An answer is a student's attempt at a problem
class Answer < ActiveRecord::Base

  serialize :content, Marshal

  # relationships ------------------------------------------------------------
  belongs_to :problem
  belongs_to :user

  # attributes ---------------------------------------------------------------
  attr_accessible :content

  # validations --------------------------------------------------------------
  validates_presence_of :content
  validates_existence_of :problem
  validates_existence_of :user

  def self.upsert(user_id, problem_id, attributes)
    ans = Answer.where(user_id: user_id, problem_id: problem_id).first_or_initialize
    ans.attributes = attributes
    ans
  end

end
