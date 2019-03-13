class StopAreaRoutingConstraint < ApplicationModel
  include ChecksumSupport

  belongs_to :from, class_name: 'Chouette::StopArea'
  belongs_to :to, class_name: 'Chouette::StopArea'

  belongs_to_array_in_many :vehicle_journeys, class_name: 'Chouette::VehicleJourney', array_name: :ignored_stop_area_routing_constraints

  add_light_belongs_to :from
  add_light_belongs_to :to

  validates :from, presence: true
  validates :to, presence: true

  validate :both_stops_in_the_same_referential
  validate :different_stops

  def update_vehicle_journey_checksums
    each_vehicle_journey &:update_checksum!
  end

  after_save :update_vehicle_journey_checksums

  def clean_ignored_stop_area_routing_constraint_ids
    each_vehicle_journey do |vj|
      vj.update ignored_stop_area_routing_constraint_ids: vj.ignored_stop_area_routing_constraint_ids - [self.id]
    end
  end
  
  after_commit :clean_ignored_stop_area_routing_constraint_ids, on: :destroy

  scope :with_stop, ->(stop_id){
    stop_id = stop_id.id if stop_id.respond_to?(:id)
    where('from_id = :stop_id OR to_id = :stop_id', stop_id: stop_id)
  }

  def self.ransackable_scopes(auth_object = nil)
    %i[with_stop]
  end

  def both_stops_in_the_same_referential
    return unless from && to
    return if from.stop_area_referential == to.stop_area_referential

    errors.add(:from_id, :must_be_in_same_referential)
    errors.add(:to_id, :must_be_in_same_referential)
  end

  def different_stops
    return unless from && to
    return if from != to

    errors.add(:to_id, :must_be_a_different_stop)
  end

  def stop_area_referential
    from.stop_area_referential
  end

  def name
    separator = both_way? ? '<>' : '>'
    "#{from_light.name} #{separator} #{to_light.name}"
  end

  def checksum_attributes(db_lookup = true)
    [
      [from_id, to_id, both_way]
    ]
  end

  def referentials
    Referential.where(stop_area_referential_id: stop_area_referential.id)
  end

  def each_vehicle_journey
    referentials.each do |r|
      r.switch do
        vehicle_journeys.each do |vj|
          yield vj
        end
      end
    end
  end
end
