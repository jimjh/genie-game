class AccessRequest < ActiveRecord::Base

  STATUSES = %w[pending granted denied]

  # relationships ------------------------------------------------------------
  belongs_to :requester, class_name: User, inverse_of: :sent_access_requests
  belongs_to :requestee, class_name: User, inverse_of: :received_access_requests

  attr_readonly :requester_id, :requestee_id

  # validations --------------------------------------------------------------
  validates_presence_of :requester, :requestee
  validates_uniqueness_of :requestee_id, scope: :requester_id
  validates_inclusion_of  :status, in: STATUSES

  # Sets +status+ to granted and saves.
  # @return [Boolean] #save
  def grant
    self.status = 'granted'
    save
  end

  # Builds a request for requester to requestee with the given nickname.
  # @raise [ActiveRecord::RecordNotFound] if nickname does not exist.
  # @return [AccessRequest] request
  def self.build_with_nickname(requester, nickname)
    user = Authorization.find_by_nickname!(nickname).user
    req  = requester.sent_access_requests.build
    req.requestee = user
    req
  end

  private

end
