# == Answer
# An answer is a student's attempt at a problem
class Answer < ActiveRecord::Base

  # relationships ------------------------------------------------------------
  belongs_to :problem
  belongs_to :user

  # attributes ---------------------------------------------------------------
  attr_accessible :content

  # validations --------------------------------------------------------------
  validates_presence_of :content
  validates_existence_of :problem
  validates_existence_of :user

end
