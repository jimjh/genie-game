class AccessRequest < ActiveRecord::Base

  # relationships ------------------------------------------------------------
  belongs_to :requester, class_name: User, inverse_of: :sent_access_requests
  belongs_to :requestee, class_name: User, inverse_of: :received_access_requests

  attr_readonly :requester_id, :requestee_id

  # validations --------------------------------------------------------------
  validates_presence_of :requester, :requestee
  validates_uniqueness_of :requestee_id, scope: :requester_id
  validate :must_not_have_granted_on, if: :granted_on_changed?

  def granted?
    granted_on != nil and granted_on <= Time.now
  end

  # Sets +granted_on+ to now and saves.
  # @return [Boolean] #save
  def grant
    self.granted_on = Time.now
    save
  end

  private

  # If +granted_on+ will be changed to a non-nil value, then previous value
  # must be be nil.
  def must_not_have_granted_on
    if granted_on.present? and granted_on_was != nil
      errors.add :base, :already_granted
    end
  end

end
