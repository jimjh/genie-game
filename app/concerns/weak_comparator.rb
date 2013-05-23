# Moular concern that provides a rich comparison with weak-typing.
# @see #same?
module WeakComparator
  extend self

  # Compares +submitted+ against +saved+ and returns a simple diff. Assumes
  # that:
  # - +saved+ is a ruby-marshalled value that carries rich type information
  # - +submitted+ is a user-submitted value that is either a string or an
  #   hash
  #
  # === Booleans
  # If +saved+ is +true+, then it will accept any +submitted+ value that
  # begins with 'T' or 't'. Similarly, if +saved+ is +false+, then it will
  # accept any +submitted+ value that begins with 'F' or 'f'.
  #
  # === Numerics
  # If +saved+ is a numeric, then it will accept any +submitted+ value that
  # is numerically equivalent to +saved+. For example, if +saved+ is 0,
  # then both +'0.0'+ and +'0'+ will be accepted.
  #
  # @param [String, Hash] submitted
  # @param [String, Numeric, Boolean, Hash] saved
  # @return [Boolean, Hash] diff
  def same?(submitted, saved)
    case saved
    when Hash
      Hash === submitted and same_hash? submitted, saved
    when String then saved == submitted
    when Numeric then saved == JSON.parse(%|[#{submitted}]|).first
    when TrueClass, FalseClass then saved.to_s[0] == submitted.downcase[0]
    else false
    end
  rescue false
  end

  private

  # Compares two hashes and returns a simple diff. It checks that both
  # +submitted+ and +saved+ have the same number of keys, and then
  # compares all key-value pairs in order.
  #
  # @param [Hash] submitted
  # @param [Hash] saved
  # @return [Boolean, Hash] diff
  # @see #same?
  def same_hash?(submitted, saved)
    saved.count == submitted.count and
      Hash[saved.map { |key, value| [key, same?(submitted[key], value)] }]
  end

end
