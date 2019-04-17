module CleanUpMethods
  # EXTRA CLEANINGS, SELECTED FROM THE UI

  def clean_vehicle_journeys_without_time_table
    Chouette::VehicleJourney.without_any_time_table.clean!
  end

  def clean_journey_patterns_without_vehicle_journey
    Chouette::JourneyPattern.without_any_vehicle_journey.clean!
  end

  def clean_routes_without_journey_pattern
    Chouette::Route.without_any_journey_pattern.clean!
  end

  def clean_unassociated_timetables
    Chouette::TimeTable.not_associated.clean!
  end

  def clean_unassociated_purchase_windows
    Chouette::PurchaseWindow.not_associated.clean!
  end

  # DEFAULT CLEANINGS

  def clean_timetables_and_children
    return unless date_type.present?

    clean_time_tables
    clean_time_table_dates
    clean_time_table_periods

    self.overlapping_periods.each do |period|
      exclude_dates_in_overlapping_period(period)
    end
  end

  def clean_time_tables
    time_tables = case date_type.to_sym
    when :before
      Chouette::TimeTable.where('end_date < ?', self.begin_date)
    when :after
      Chouette::TimeTable.where('start_date > ?', self.begin_date)
    when :outside
      Chouette::TimeTable.where('start_date > ? OR end_date < ?', self.end_date, self.begin_date)
    when :between
      Chouette::TimeTable.where('start_date > ? AND end_date < ?', self.begin_date, self.end_date)
    end

    time_tables.clean!
  end

  def clean_time_table_dates
    dates = Chouette::TimeTableDate.in_dates
    dates = case date_type.to_sym
    when :before
      dates.where('date < ?', self.begin_date)
    when :after
      dates.where('date > ?', self.begin_date)
    when :outside
      dates.where('date < ? OR date > ?', self.begin_date, self.end_date)
    when :between
      dates.where('date > ? AND date < ?', self.begin_date, self.end_date)
    end

    dates.clean!
  end

  def clean_time_table_periods
    periods = Chouette::TimeTablePeriod
    periods = case date_type.to_sym
    when :before
      periods.where('period_end < ?', self.begin_date)
    when :after
      periods.where('period_start > ?', self.begin_date)
    when :outside
      periods.where('period_end < ? OR period_start > ?', self.begin_date, self.end_date)
    when :between
      periods.where('period_start > ? AND period_end < ?', self.begin_date, self.end_date)
    end

    periods.clean!
  end

  def clean_routes_outside_referential
    line_ids = referential.metadatas.pluck(:line_ids).flatten.uniq
    Chouette::Route.where(['line_id not in (?)', line_ids]).clean!
  end

  # CLEANUPS THAT CAN BE TRIGGERED PROGRAMATICALLY

  def clean_unassociated_vehicle_journeys
    Chouette::VehicleJourney.where("id not in (select distinct vehicle_journey_id from time_tables_vehicle_journeys)").clean!
  end

  def clean_unassociated_journey_patterns
    Chouette::JourneyPattern.where("id not in (select distinct journey_pattern_id from vehicle_journeys)").clean!
  end

  def clean_unassociated_routes
    Chouette::Route.where("id not in (select distinct route_id from journey_patterns)").clean!
  end

  def clean_unassociated_footnotes
    Chouette::Footnote.not_associated.clean!
  end

  def clean_unassociated_calendars
    clean_unassociated_timetables
    clean_unassociated_purchase_windows
  end

  def clean_irrelevant_data
    clean_unassociated_vehicle_journeys
    clean_unassociated_journey_patterns
    clean_unassociated_routes
    clean_unassociated_footnotes
  end
end
