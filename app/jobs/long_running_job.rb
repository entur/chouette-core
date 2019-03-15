LongRunningJob = Struct.new(:object, :method) do
  def perform
    object.send method
  end

  def max_run_time
    Delayed::Worker.max_run_time
  end
end
