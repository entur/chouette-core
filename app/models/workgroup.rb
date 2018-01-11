class Workgroup < ActiveRecord::Base
  belongs_to :line_referential
  belongs_to :stop_area_referential

  has_many :workbenches
  has_many :organisations, through: :workbenches

  validates_uniqueness_of :name

  validates_presence_of :line_referential_id
  validates_presence_of :stop_area_referential_id

  has_many :custom_fields

  def custom_fields_definitions
    Hash[*custom_fields.map{|cf| [cf.code, cf]}.flatten]
  end
end