class StopAreaRoutingConstraint < ActiveRecord::Base
  belongs_to :from, class_name: 'Chouette::StopArea'
  belongs_to :to, class_name: 'Chouette::StopArea'

  scope :with_stop, ->(stop){
    where('from_id = :stop_id OR to_id = :stop_id', stop_id: stop.id)
  }
end
