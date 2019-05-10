# coding: utf-8

module ReferentialSaveWithLock
  def save(options = {})
    super(options)
  rescue ActiveRecord::StatementInvalid => e
    if e.message.include?('PG::LockNotAvailable')
      raise TableLockTimeoutError.new(e)
    else
      raise
    end
  end
end

class Referential < ApplicationModel
  prepend ReferentialSaveWithLock

  include DataFormatEnumerations
  include ObjectidFormatterSupport

  STATES = %i(pending active failed archived)

  validates_presence_of :name
  validates_presence_of :slug
  validates_presence_of :prefix
  # Fixme #3657
  # validates_presence_of :time_zone
  # validates_presence_of :upper_corner
  # validates_presence_of :lower_corner

  validates_uniqueness_of :slug

  validates_format_of :slug, with: %r{\A[a-z][0-9a-z_]+\Z}
  validates_format_of :prefix, with: %r{\A[0-9a-zA-Z_]+\Z}
  # validates_format_of :upper_corner, with: %r{\A-?[0-9]+\.?[0-9]*\,-?[0-9]+\.?[0-9]*\Z}
  # validates_format_of :lower_corner, with: %r{\A-?[0-9]+\.?[0-9]*\,-?[0-9]+\.?[0-9]*\Z}
  validate :slug_excluded_values

  attr_accessor :upper_corner
  attr_accessor :lower_corner

  attr_accessor :from_current_offer
  attr_accessor :urgent

  has_one :user
  has_many :import_resources, class_name: 'Import::Resource', dependent: :destroy
  has_many :compliance_check_sets, dependent: :nullify
  has_many :clean_ups, dependent: :destroy

  belongs_to :organisation
  validates_presence_of :organisation
  validate def validate_consistent_organisation
    return true if workbench_id.nil?
    ids = [workbench.organisation_id, organisation_id]
    return true if ids.first == ids.last
    errors.add(:inconsistent_organisation,
               I18n.t('referentials.errors.inconsistent_organisation',
                      indirect_name: workbench.organisation.name,
                      direct_name: organisation.name))
  end, if: :organisation

  belongs_to :line_referential
  validates_presence_of :line_referential

  belongs_to :created_from, class_name: 'Referential'
  has_many :associated_lines, through: :line_referential, source: :lines
  has_many :companies, through: :line_referential
  has_many :group_of_lines, through: :line_referential
  has_many :networks, through: :line_referential
  has_many :metadatas, class_name: "ReferentialMetadata", inverse_of: :referential, dependent: :delete_all
  accepts_nested_attributes_for :metadatas

  belongs_to :stop_area_referential
  validates_presence_of :stop_area_referential
  has_many :stop_areas, through: :stop_area_referential

  belongs_to :workbench

  belongs_to :referential_suite

  scope :pending, -> { where(ready: false, failed_at: nil, archived_at: nil) }
  scope :active, -> { where(ready: true, failed_at: nil, archived_at: nil) }
  scope :failed, -> { where.not(failed_at: nil) }
  scope :archived, -> { where.not(archived_at: nil) }

  scope :ready, -> { where(ready: true) }
  scope :exportable, -> {
    joins("LEFT JOIN public.referential_suites ON referentials.referential_suite_id = referential_suites.id").where("ready = ? AND merged_at IS NULL AND (referential_suite_id IS NULL OR referential_suites.current_id = referentials.id)", true)
  }
  scope :autocomplete, ->(q) {
    if q.present?
      where("name ILIKE '%#{sanitize_sql_like(q)}%'")
    else
      all
    end
  }

  scope :in_periode, ->(periode) { where(id: referential_ids_in_periode(periode)) }
  scope :include_metadatas_lines, ->(line_ids) { joins(:metadatas).where('referential_metadata.line_ids && ARRAY[?]::bigint[]', line_ids) }
  scope :order_by_validity_period, ->(dir) { joins(:metadatas).order(Arel.sql("unnest(periodes) #{dir}")) }
  scope :order_by_lines, ->(dir) { joins(:metadatas).group("referentials.id").order(Arel.sql("sum(array_length(referential_metadata.line_ids,1)) #{dir}")) }
  scope :order_by_organisation_name, ->(dir) { joins(:organisation).order(Arel.sql("lower(organisations.name) #{dir}")) }
  scope :not_in_referential_suite, -> { where referential_suite_id: nil }
  scope :blocked, -> { where('ready = ? AND created_at < ?', false, 4.hours.ago) }
  scope :created_before, -> (date) { where('created_at < ? ', date) }

  after_save :notify_state

  def self.order_by_state(dir)
    states = ["ready #{dir}", "archived_at #{dir}", "failed_at #{dir}"]
    states.reverse! if dir == 'asc'
    Referential.order(*states)
  end

  def self.force_register_models_with_checksum
    paths = Rails.application.paths['app/models'].to_a
    Rails.application.railties.each do |tie|
      next unless tie.respond_to? :paths
      paths += tie.paths['app/models'].to_a
    end

    paths.each do |path|
      next unless File.directory?(path)
      Dir.chdir path do
        Dir['**/*.rb'].each do |src|
          next if src =~ /^concerns/
          # thanks for inconsistent naming ...
          if src == "route_control/zdl_stop_area.rb"
            RouteControl::ZDLStopArea
            next
          end
          Rails.logger.info "Loading #{src}"
          begin
            src[0..-4].classify.safe_constantize
          rescue => e
            Rails.logger.info "Failed: #{e.message}"
            nil
          end
        end
      end
    end
  end

  def self.register_model_with_checksum klass
    @_models_with_checksum ||= []
    @_models_with_checksum << klass
  end

  def self.models_with_checksum
    @_models_with_checksum || []
  end

  OPERATIONS = [Import::Netex, Import::Gtfs]

  def last_operation
    operations = []
    Referential::OPERATIONS.each do |klass|
      operations << klass.for_referential(self).limit(1).select("'#{klass.name}' as kind, id, created_at").order('created_at DESC').to_sql
    end
    sql = "SELECT * FROM ((#{operations.join(') UNION (')})) AS subquery ORDER BY subquery.created_at DESC"
    res = ActiveRecord::Base.connection.execute(sql).first
    if res
      res["kind"].constantize.find(res["id"])
    end
  end

  def notify_state
    Notification.create! channel: "/referentials/#{self.id}", payload: {state: self.state}
  end

  def contains_urgent_offer?
    metadatas.any?{|m| m.urgent? }
  end

  def flagged_urgent_at
    metadatas.pluck(:flagged_urgent_at).compact.max
  end

  def flag_not_urgent!
    metadatas.update_all(flagged_urgent_at: nil)
  end

  def lines
    if metadatas.blank?
      workbench ? workbench.lines : associated_lines
    else
      metadatas_lines
    end
  end

  def lines_outside_of_scope
    return lines.none unless workbench
    func_scope = workbench.workbench_scopes.lines_scope(associated_lines).pluck(:objectid)
    lines.where.not(objectid: func_scope)
  end

  def clean_routes_if_needed
    return unless persisted?
    line_ids = self.metadatas.pluck(:line_ids).flatten.uniq
    if self.switch { routes.where.not(line_id: line_ids).exists? }
      CleanUp.create!(referential: self, original_state: self.state)
      pending! && save!
    end
  end

  def slug_excluded_values
    if ! slug.nil?
      if slug.start_with? "pg_"
        errors.add(:slug,I18n.t("referentials.errors.pg_excluded"))
      end
      if slug == 'public'
        errors.add(:slug,I18n.t("referentials.errors.public_excluded"))
      end
      if slug == self.class.connection_config[:username]
        errors.add(:slug,I18n.t("referentials.errors.user_excluded", user: slug))
      end
    end
  end

  def viewbox_left_top_right_bottom
    [  lower_corner.lng, upper_corner.lat, upper_corner.lng, lower_corner.lat ].join(',')
  end

  def human_attribute_name(*args)
    self.class.human_attribute_name(*args)
  end

  def full_name
    if in_referential_suite?
      name
    else
      "#{self.class.model_name.human.capitalize} #{name}"
    end
  end

  def access_points
    Chouette::AccessPoint.all
  end

  def access_links
    Chouette::AccessLink.all
  end

  def time_tables
    Chouette::TimeTable.all
  end

  def time_table_dates
    Chouette::TimeTableDate.all
  end

  def connection_links
    Chouette::ConnectionLink.all
  end

  def vehicle_journeys
    Chouette::VehicleJourney.all
  end

  def vehicle_journey_frequencies
    Chouette::VehicleJourneyFrequency.all
  end

  def vehicle_journey_at_stops
    Chouette::VehicleJourneyAtStop.all
  end

  def routing_constraint_zones
    Chouette::RoutingConstraintZone.all
  end

  def purchase_windows
    Chouette::PurchaseWindow.all
  end

  def routes
    Chouette::Route.all
  end

  def journey_patterns
    Chouette::JourneyPattern.all
  end

  def stop_points
    Chouette::StopPoint.all
  end

  def footnotes
    Chouette::Footnote.all
  end

  def workgroup
    @workgroup = begin
      workgroup = workbench&.workgroup
      if referential_suite
        workgroup ||= Workgroup.where(output_id: referential_suite.id).last
      end
      workgroup
    end
  end

  def circulation_start
    time_tables.used.order('start_date ASC').select(:start_date).first&.start_date
  end

  def circulation_end
    time_tables.used.order('end_date ASC').select(:end_date).last&.end_date
  end

  before_validation :define_default_attributes

  def define_default_attributes
    self.time_zone ||= Time.zone.name
    self.objectid_format ||= workbench.objectid_format if workbench
  end

  before_save :set_metadatas_urgency
  def set_metadatas_urgency
    return if urgent.nil?

    if urgent
      metadatas.each {|m| m.flagged_urgent_at ||= Time.now }
    else
      metadatas.each {|m| m.flagged_urgent_at = nil }
    end
  end

  def switch(verbose: true, &block)
    raise "Referential not created" if new_record?

    unless block_given?
      Rails.logger.debug "Referential switch to #{slug}" if verbose
      Apartment::Tenant.switch! slug
      self
    else
      result = nil
      Apartment::Tenant.switch slug do
        Rails.logger.debug "Referential switch to #{slug}" if verbose
        result = yield
      end
      Rails.logger.debug "Referential back" if verbose
      result
    end
  end

  def self.new_from(from, workbench)
    clone = Referential.new(
      name: I18n.t("activerecord.copy", name: from.name),
      organisation: workbench.organisation,
      prefix: from.prefix,
      time_zone: from.time_zone,
      bounds: from.bounds,
      line_referential: from.line_referential,
      stop_area_referential: from.stop_area_referential,
      created_from: from,
      objectid_format: from.objectid_format,
      metadatas: from.metadatas.map { |m| ReferentialMetadata.new_from(m, workbench) },
      ready: false
    )
    clone.metadatas = clone.metadatas.select(&:valid?)
    clone
  end

  def self.available_srids
    [
      [ "RGF 93 Lambert 93 (2154)", 2154 ],
      [ "RGF93 CC42 (zone 1) (3942)", 3942 ],
      [ "RGF93 CC43 (zone 2) (3943)", 3943 ],
      [ "RGF93 CC44 (zone 3) (3944)", 3944 ],
      [ "RGF93 CC45 (zone 4) (3945)", 3945 ],
      [ "RGF93 CC46 (zone 5) (3946)", 3946 ],
      [ "RGF93 CC47 (zone 6) (3947)", 3947 ],
      [ "RGF93 CC48 (zone 7) (3948)", 3948 ],
      [ "RGF93 CC49 (zone 8) (3949)", 3949 ],
      [ "RGF93 CC50 (zone 9) (3950)", 3950 ],
      [ "NTF Lambert Zone 1 Nord (27561)", 27561 ],
      [ "NTF Lambert Zone 2 Centre (27562)", 27562 ],
      [ "NTF Lambert Zone 3 Sud (27563)", 27563 ],
      [ "NTF Lambert Zone 4 Corse (27564)", 27564 ],
      [ "NTF Lambert 1 Carto (27571)", 27571 ],
      [ "NTF Lambert 2 Carto (27572)", 27572 ],
      [ "NTF Lambert 3 Carto (27573)", 27573 ],
      [ "NTF Lambert 4 Carto (27574)", 27574 ] ,
      [ "Réunion RGR92 - UTM 40S (2975)", 2975 ],
      [ "Antilles Françaises RRAF1991 - UTM 20N - IGN (4559)", 4559 ],
      [ "Guyane RGFG95 - UTM 22N (2972)", 2972 ],
      [ "Guyane RGFG95 - UTM 21N (3312)", 3312 ]
    ]
  end

  def projection_type_label
    self.class.available_srids.each do |a|
      if a.last.to_s == projection_type
        return a.first.split('(').first.rstrip
      end
    end
    projection_type || ""
  end

  before_validation :assign_line_and_stop_area_referential, on: :create, if: :workbench
  before_validation :assign_slug, on: :create
  before_validation :assign_prefix, on: :create

  # Lock the `referentials` table to prevent duplicate referentials from being
  # created simultaneously in separate transactions. This must be the last hook
  # to minimise the duration of the lock.
  before_save :lock_table, on: [:create, :update]

  before_create :create_schema

  # Don't use after_commit because of inline_clone (cf created_from)
  after_create :clone_schema, if: :created_from
  after_create :active!, unless: :created_from
  after_create :create_from_current_offer, if: :from_current_offer

  before_destroy :destroy_schema
  before_destroy :destroy_jobs

  def referential_read_only?
    !ready? || in_referential_suite? || archived?
  end

  def in_referential_suite?
    referential_suite_id.present?
  end

  def in_workbench?
    workbench_id.present?
  end

  def init_metadatas(attributes = {})
    if metadatas.blank?
      date_range = attributes.delete :default_date_range
      metadata = metadatas.build attributes
      metadata.periodes = [date_range] if date_range
    end
  end

  def associated_stop_areas
    ids = routes.joins(:stop_points).select('stop_area_id').uniq.pluck(:stop_area_id)
    stop_areas.where(id: ids)
  end

  def metadatas_period
    query = "select min(lower), max(upper) from (select lower(unnest(periodes)) as lower, upper(unnest(periodes)) as upper from public.referential_metadata where public.referential_metadata.referential_id = #{id}) bounds;"

    row = self.class.connection.select_one(query)
    lower, upper = row["min"], row["max"]

    if lower and upper
      Range.new(Date.parse(lower), Date.parse(upper)-1)
    end
  end
  alias_method :validity_period, :metadatas_period

  def metadatas_lines
    if metadatas.present?
      associated_lines.where(id: metadatas.pluck(:line_ids).flatten)
    else
      Chouette::Line.none
    end
  end

  def self.referential_ids_in_periode(range)
    subquery = "SELECT DISTINCT(public.referential_metadata.referential_id) FROM public.referential_metadata, LATERAL unnest(periodes) period "
    subquery << "WHERE period && '#{range_to_string(range)}'"
    query = "SELECT * FROM public.referentials WHERE referentials.id IN (#{subquery})"
    self.connection.select_values(query).map(&:to_i)
  end

  # Copied from Rails 4.1 activerecord/lib/active_record/connection_adapters/postgresql/cast.rb
  # TODO: Relace with the appropriate Rais 4.2 / 5.x helper if one is found.
  def self.range_to_string(object)
    from = object.begin.respond_to?(:infinite?) && object.begin.infinite? ? '' : object.begin
    to   = object.end.respond_to?(:infinite?) && object.end.infinite? ? '' : object.end
    "[#{from},#{to}#{object.exclude_end? ? ')' : ']'}"
  end

  def overlapped_referential_ids
    return [] unless metadatas.present?

    line_ids = metadatas.first.line_ids
    periodes = metadatas.first.periodes

    return [] unless line_ids.present? && periodes.present?

    not_myself = "and referential_id != #{id}" if persisted?

    periods_query = periodes.map do |periode|
      "period && '[#{periode.min},#{periode.max + 1.day})'"
    end.join(" OR ")

    query = "select distinct(public.referential_metadata.referential_id) FROM public.referential_metadata, unnest(line_ids) line, LATERAL unnest(periodes) period
    WHERE public.referential_metadata.referential_id
    IN (SELECT public.referentials.id FROM public.referentials WHERE referentials.workbench_id = #{workbench_id} and referentials.archived_at is null and referentials.referential_suite_id is null #{not_myself} AND referentials.failed_at IS NULL)
    AND line in (#{line_ids.join(',')}) and (#{periods_query});"

    self.class.connection.select_values(query).map(&:to_i)
  end

  def metadatas_overlap?
    overlapped_referential_ids.present?
  end

  validate :detect_overlapped_referentials, unless: :in_referential_suite?

  def detect_overlapped_referentials
    self.class.where(id: overlapped_referential_ids).each do |referential|
      Rails.logger.info "Referential #{referential.id} #{referential.metadatas.inspect} overlaps #{metadatas.inspect}"
      errors.add :metadatas, I18n.t("referentials.errors.overlapped_referential", :referential => referential.name)
    end
  end

  def create_from_current_offer
    CurrentOfferCloningWorker.fill_from_current_offer self
  end

  attr_accessor :inline_clone
  def clone_schema
    cloning = ReferentialCloning.new source_referential: created_from, target_referential: self

    if inline_clone
      cloning.clone!
    else
      cloning.save!
    end
  end

  def create_schema
    return if created_from

    report = Benchmark.measure do
      Apartment::Tenant.create slug
    end

    check_migration_count(report)
    # raise "Wrong migration count: #{migration_count}" if migration_count < 300
  end

  def check_migration_count(report)
    Rails.logger.info("Schema create benchmark: '#{slug}'\t#{report}")
    Rails.logger.info("Schema migrations count for Referential #{slug}: #{migration_count || '-'}")
  end

  def migration_count
    raw_value =
      if self.class.connection.table_exists?("#{slug}.schema_migrations")
        self.class.connection.select_value("select count(*) from #{slug}.schema_migrations;")
      end

    raw_value.to_i
  end

  def assign_slug(time_reference = Time)
    self.slug ||= begin
      prefix = name.parameterize.split('-').map { |p| p.gsub(/[^a-z]/, '').presence }
      prefix = prefix.compact.join('_')[0..12].presence || "referential"
      "#{prefix}_#{time_reference.now.to_i}"
    end if name
  end

  def assign_prefix
    self.prefix ||= workbench.prefix
  end

  def assign_line_and_stop_area_referential
    self.line_referential = workbench.line_referential
    self.stop_area_referential = workbench.stop_area_referential
  end

  def destroy_schema
    return unless ActiveRecord::Base.connection.schema_names.include?(slug)
    Apartment::Tenant.drop slug
  end

  def destroy_jobs
    true
  end

  # Archive
  def archived?
    archived_at != nil
  end

  def archive!
    # self.archived = true
    touch :archived_at
    notify_state
  end
  def unarchive!
    return false unless can_unarchive?
    # self.archived = false
    update_column :archived_at, nil
    notify_state
  end

  def can_unarchive?
    not metadatas_overlap?
  end

  def merged?
    merged_at.present?
  end

  def self.not_merged
    where merged_at: nil
  end

  def self.mergeable
    active.not_merged.not_in_referential_suite
  end

  ### STATE

  def state
    return :failed if failed_at.present?
    return :archived if archived_at.present?
    return :pending unless ready?
    :active
  end

  def light_update vals
    if self.persisted?
      update_columns vals
    else
      assign_attributes vals
    end
    notify_state
  end

  def pending!
    light_update ready: false, failed_at: nil, archived_at: nil
  end

  def failed!
    light_update ready: false, failed_at: Time.now, archived_at: nil
  end

  def active!
    light_update ready: true, failed_at: nil, archived_at: nil, merged_at: nil
  end

  alias_method :rollbacked!, :active!

  def archived!
    light_update failed_at: nil, archived_at: Time.now
  end

  def merged!
    now = Time.now
    update_columns failed_at: nil, archived_at: now, merged_at: now, ready: true
    notify_state
  end

  def unmerged!
    # always change merged_at
    update_column :merged_at, nil
    # change archived_at if possible
    update archived_at: nil
  end

  STATES.each do |s|
    define_method "#{s}?" do
      state == s
    end
  end

  def pending_while
    if pending?
      yield
      return
    end

    vals = attributes.slice(*%w(ready archived_at failed_at))
    pending!
    begin
      yield
    ensure
      update vals
    end
  end

  def update_stats!
    Stat::JourneyPatternCoursesByDate.compute_for_referential(self)
  end

  private

  def lock_table
    # No explicit unlock is needed as it will be released at the end of the
    # transaction.
    ActiveRecord::Base.connection.execute(
      'LOCK public.referentials IN EXCLUSIVE MODE'
    )
  end
end
