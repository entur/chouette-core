module TimeDuration
  # `earlier` and `later` are times. Get the duration between those times and
  # check whether it's longer than the given `duration`.
  #
  # Example:
  #   TimeDuration.exceeds_gap?(
  #     4.hours,
  #     Time.now,
  #     Time.now + 2.hours
  #   )
  def self.exceeds_gap?(duration, earlier, later)
    duration < self.duration_without_24_hour_cycles(later - earlier)
  end

  private

  def self.duration_without_24_hour_cycles(duration)
    duration % 24.hours
  end
end
