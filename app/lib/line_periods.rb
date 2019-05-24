class LinePeriods

  def initialize
    @periods_by_line = Hash.new { |h,k| h[k] = [] }
  end

  def add(line_id, period)
    @periods_by_line[line_id] << period
  end

  def each(&block)
    @periods_by_line.each do |line_id, periods|
      yield line_id, periods
    end
  end

  def periods(line_id)
    @periods_by_line[line_id]
  end

  def self.from_metadatas(metadatas)
    line_periods = new

    metadatas.each do |metadata|
      metadata.line_ids.each do |line_id|
        metadata.periodes.each do |period|
          line_periods.add(line_id, period)
        end
      end
    end

    line_periods
  end

end
