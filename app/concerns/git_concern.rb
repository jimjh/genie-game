# Modular concern for dealing with git urls
module GitConcern

  GIT_SCHEMES = %w(ssh git http https ftp ftps rsync)
  GIT_SUFFIX  = '.git'

  # A weak test for remote URI.
  def url_is_remote?
    !(url =~ /localhost/ || url =~ /127\.0\.0\.1/ || url =~ /0\.0\.0\.0/)
  end

  def url_has_suffix?
    GIT_SUFFIX == File.extname(url)
  end

  # @return [Boolean] true if url does not have a scheme (scp-style) or can be
  #   parsed by ruby's URI.
  def url_matches?
    !(url =~ /\A\s*[^:]+:\/\//) || GIT_SCHEMES.include?(URI.parse(url).scheme)
  rescue URI::InvalidURIError
    false
  end

end
