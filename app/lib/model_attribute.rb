class ModelAttribute
  attr_reader :klass, :name, :data_type

  def self.all
    @__all__ ||= []
  end

  def self.grouped_options(type)
    {}.tap do |el|
      group_by_class.each do |key, values|
        values.reject!{ |x| x.data_type != type }
        el[I18n.t("activerecord.models.#{key}.one")] = values.map do |i|
          [
            I18n.t("activerecord.attributes.#{i.klass}.#{i.name}"),
            "#{i.klass}\##{i.name}"
          ]
        end
      end
    end
  end

  def self.define(klass, name, data_type)
    all << new(klass, name, data_type)
  end

  def self.classes
    all
      .map(&:klass)
      .uniq
      .map(&:to_s)
      .map(&:camelize)
  end

  def self.group_by_class
    all.group_by(&:klass)
  end

  def self.from_code(code)
    klass, name = code.split('#').map(&:to_sym)

    methods_by_class(klass).select do |model_attr|
      model_attr.name == name
    end.first
  end

  def self.methods_by_class(klass)
    all.select do |model_attr|
      model_attr.klass == klass
    end
  end

  def self.methods_by_class_and_type(klass, type)
    methods_by_class(klass).select do |model_attr|
      model_attr.data_type == type
    end
  end

  def initialize(klass, name, data_type)
    @klass = klass
    @name = name
    @data_type = data_type
  end

  # Chouette::Route
  define :route, :name, :string
  define :route, :published_name, :string
  define :route, :wayback, :string

  # Chouette::JourneyPattern
  define :journey_pattern, :name, :string
  define :journey_pattern, :published_name, :string
  define :journey_pattern, :registration_number, :string

  # Chouette::VehicleJourney
  define :vehicle_journey, :published_journey_name, :string
  define :vehicle_journey, :published_journey_identifier, :string
  define :vehicle_journey, :mobility_restricted_suitability, :boolean
  define :vehicle_journey, :flexible_service, :boolean

  # Chouette::Footnote
  define :footnote, :code, :string
  define :footnote, :label, :string

  # Chouette::RoutingConstraintZone
  define :routing_constraint_zone, :name, :string

  def code
    "#{@klass}##{@name}"
  end

  def ==(other)
    self.class === other &&
      klass == other.klass &&
      name == other.name &&
      data_type == other.data_type
  end
end
