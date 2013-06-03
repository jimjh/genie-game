module DateTimeHelper

  def time_ago_or_format(datetime)
    if datetime >= Time.now || datetime <= 1.year.ago
      l datetime, format: :short_dt
    else
      time_ago_in_words(datetime) + " ago"
    end
  end

end
