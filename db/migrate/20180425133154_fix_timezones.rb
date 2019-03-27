class FixTimezones < ActiveRecord::Migration[4.2]
  def convert tz
    return unless tz.present?
    return tz unless ActiveSupport::TimeZone[tz].present?
    ActiveSupport::TimeZone[tz].tzinfo.name
  end

  def change
    if Apartment::Tenant.current == "public"
      Chouette::StopArea.where.not("time_zone LIKE '%/%'").find_each do |s|
        s.update_column :time_zone, convert(s.time_zone)
      end

      Chouette::Company.where.not("time_zone LIKE '%/%'").find_each do |c|
        c.update_column :time_zone, convert(c.time_zone)
      end
    end
  end
end
