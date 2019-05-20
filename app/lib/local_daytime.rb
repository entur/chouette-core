class LocalDaytime
  def initialize val=nil
    if val
      if val.is_a?(String)
        @hours, @minutes, @seconds = val.gsub(/"/, '').split(':').map(&:to_i)
      end
      @time = val.to_time
    else
      @time = Time.now
      @hours = @time.hour
      @minutes = @time.min
      @seconds = @time.sec
    end
  end

  def seconds_since_midnight
    @seconds + @minutes * 60 + @hours * 3600
  end

  def -(other)
    seconds_since_midnight - other.seconds_since_midnight
  end

  def self.convert_to_db val
    "2000/01/01 #{val} UTC"
  end

  def strftime(*args)
    @time.strftime *args
  end
end
