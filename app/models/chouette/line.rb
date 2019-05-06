module Chouette
  class Line < Chouette::ActiveRecord
    has_metadata
    include LineRestrictions
    include LineReferentialSupport
    include ObjectidSupport
    include NetexTransportModeEnumerations
    include NetexTransportSubmodeEnumerations

    include ColorSupport
    open_color_attribute
    open_color_attribute :text_color

    belongs_to :company
    belongs_to :network
    belongs_to :line_referential

    # this 'light' relation prevents the custom fields loading
    belongs_to :company_light, -> { select(:id, :name, :line_referential_id, :objectid) }, class_name: "Chouette::Company", foreign_key: :company_id

    has_array_of :secondary_companies, class_name: 'Chouette::Company'

    has_many :routes
    has_many :journey_patterns, :through => :routes
    has_many :vehicle_journeys, :through => :journey_patterns
    has_many :routing_constraint_zones, through: :routes
    has_many :time_tables, -> { distinct }, through: :vehicle_journeys

    has_and_belongs_to_many :group_of_lines, :class_name => 'Chouette::GroupOfLine', :order => 'group_of_lines.name'

    has_many :footnotes, inverse_of: :line, validate: true
    accepts_nested_attributes_for :footnotes, reject_if: :all_blank, :allow_destroy => true

    attr_reader :group_of_line_tokens

    # validates_presence_of :network
    # validates_presence_of :company

    # validates_format_of :registration_number, :with => %r{\A[\d\w_\-]+\Z}, :allow_nil => true, :allow_blank => true
    validates_format_of :stable_id, :with => %r{\A[\d\w_\-]+\Z}, :allow_nil => true, :allow_blank => true

    # See #9510
    # validates_format_of :url, :with => %r{\A(https?:\/\/|www)([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?\Z}, :allow_nil => true, :allow_blank => true

    validates_presence_of :name

    validate :transport_mode_and_submode_match

    scope :by_text, ->(text) { where('lower(name) LIKE :t or lower(published_name) LIKE :t or lower(objectid) LIKE :t or lower(comment) LIKE :t or lower(number) LIKE :t',
      t: "%#{text.downcase}%") }

    scope :by_name, ->(name) {
      joins('LEFT OUTER JOIN public.companies by_name_companies ON by_name_companies.id = lines.company_id')
        .where('
          lines.number LIKE :q
          OR unaccent(lines.name) ILIKE unaccent(:q)
          OR unaccent(by_name_companies.name) ILIKE unaccent(:q)',
          q: "%#{sanitize_sql_like(name)}%"
        )
    }

    scope :for_workbench, ->(workbench){
      where(line_referential_id: workbench.line_referential_id)
    }

    scope :notifiable, -> (workbench) {
      where(id: workbench.notification_rules.pluck(:line_id))
    }

    scope :active, lambda { |*args|
      on_date = args.first || Time.now
      scope = not_deactivated.active_from(on_date).active_until(on_date)
    }

    scope :deactivated, -> { where(deactivated: true) }
    scope :not_deactivated, -> { where(deactivated: [nil, false]) }
    scope :active_from, ->(from_date) { where('active_from IS NULL OR active_from <= ?', from_date) }
    scope :active_until, ->(until_date) { where('active_until IS NULL OR active_until >= ?', until_date) }

    def self.nullable_attributes
      [:published_name, :number, :comment, :url, :color, :text_color, :stable_id]
    end

    def geometry_presenter
      Chouette::Geometry::LinePresenter.new self
    end

    def commercial_stop_areas
      Chouette::StopArea.joins(:children => [:stop_points => [:route => :line] ]).where(:lines => {:id => self.id}).distinct
    end

    def stop_areas
      Chouette::StopArea.joins(:stop_points => [:route => :line]).where(:lines => {:id => self.id})
    end

    def stop_areas_last_parents
      Chouette::StopArea.joins(:stop_points => [:route => :line]).where(:lines => {:id => self.id}).collect(&:root).flatten.uniq
    end

    def group_of_line_tokens=(ids)
      self.group_of_line_ids = ids.split(",")
    end

    def vehicle_journey_frequencies?
      self.vehicle_journeys.unscoped.where(journey_category: 1).count > 0
    end

    def full_display_name
      [self.get_objectid.short_id, number, name, company_light.try(:name)].compact.join(' - ')
    end

    def display_name
      full_display_name.truncate(50)
    end

    def companies
      line_referential.companies.where(id: ([company_id] + Array(secondary_company_ids)).compact)
    end

    # def deactivate
    #   self.deactivated = true
    # end
    #
    # def activate
    #   self.deactivated = false
    # end
    #
    # def deactivate!
    #   update_attribute :deactivated, true
    # end
    #
    # def activate!
    #   update_attribute :deactivated, false
    # end
    #

    def active?(on_date=Time.now)
      on_date = on_date.to_date

      return false if deactivated
      return false if active_from && active_from > on_date
      return false if active_until && active_until < on_date

      true
    end

    def status
      active? ? :activated : :deactivated
    end

    def code
      (stable_id.presence || number.presence || registration_number.presence || id).to_s.parameterize
    end
  end
end
