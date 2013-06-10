class AccessRequest < ActiveRecord::Base

  STATUSES = %w[pending granted denied]

  # relationships ------------------------------------------------------------
  belongs_to :requester, class_name: User, inverse_of: :sent_access_requests
  belongs_to :requestee, class_name: User, inverse_of: :received_access_requests

  # attributes ---------------------------------------------------------------
  attr_readonly :requester_id, :requestee_id

  # validations --------------------------------------------------------------
  validates_presence_of :requester, :requestee
  validates_uniqueness_of :requestee_id, scope: :requester_id
  validates_inclusion_of  :status, in: STATUSES

  # scopes -------------------------------------------------------------------
  scope :granted, where(status: 'granted')

  # Sets +status+ to granted and saves.
  # @return [Boolean] #save
  def grant
    self.status = 'granted'
    save
  end

  # Sets +status+ to denied and saves.
  # @return [Boolean] #save
  def deny
    self.status = 'denied'
    save
  end

  def granted?
    status == 'granted'
  end

  def denied?
    status == 'denied'
  end

  # Builds a request for requester to requestee with the given nickname.
  # @raise [ActiveRecord::RecordNotFound] if nickname does not exist.
  # @return [AccessRequest] request
  def self.build_with_nickname(requester, nickname) # TODO specs
    user = User.find_by_slug! nickname
    req  = requester.sent_access_requests.build
    req.requestee = user
    req
  end

  private

end
