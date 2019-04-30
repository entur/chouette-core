class TimeTableCombination

  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :source_id, :combined_type, :operation, :time_table_id, :calendar_id

  validates_presence_of  :source_id, :combined_type, :operation

  validates :time_table_id, presence: true, if: ->{ calendar_id.blank? }
  validates :calendar_id, presence: true, if:  ->{ time_table_id.blank? }

  validates_inclusion_of :combined_type, :in => %w(time_table calendar)
  validates_inclusion_of :operation, :in =>  %w(union intersection disjunction), :allow_nil => true

  def clean
    self.source_id     = nil
    self.time_table_id = nil
    self.calendar_id   = nil
    self.combined_type = nil
    self.operation     = nil
    self.errors.clear
  end

  def self.operations
    %w(union intersection disjunction)
  end

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def persisted?
    false
  end

  def target
    id     = self.send("#{combined_type}_id")
    klass  = combined_type == "calendar" ? Calendar : Chouette::TimeTable
    target = klass.find id
    target = target.convert_to_time_table unless target.is_a? Chouette::TimeTable
    target
  end

  def combine
    source   = Chouette::TimeTable.find source_id
    combined = self.target

    case operation
    when 'union'
      source.merge! combined
    when 'intersection'
      source.intersect! combined
    when 'disjunction'
      source.disjoin! combined
    else
      raise "unknown operation"
    end
    source
  end

end
