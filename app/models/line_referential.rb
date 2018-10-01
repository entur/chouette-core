class LineReferential < ApplicationModel
  include ObjectidFormatterSupport
  extend NetexTransportModeEnumerations

  has_many :line_referential_memberships, dependent: :destroy
  has_many :organisations, through: :line_referential_memberships
  has_many :lines, class_name: 'Chouette::Line', dependent: :destroy
  has_many :group_of_lines, class_name: 'Chouette::GroupOfLine', dependent: :destroy
  has_many :companies, class_name: 'Chouette::Company', dependent: :destroy
  has_many :networks, class_name: 'Chouette::Network', dependent: :destroy
  has_many :line_referential_syncs, -> { order created_at: :desc }, dependent: :destroy
  has_many :workbenches, dependent: :nullify
  has_one  :workgroup, dependent: :nullify

  def add_member(organisation, options = {})
    attributes = options.merge organisation: organisation
    line_referential_memberships.build attributes unless organisations.include?(organisation)
  end

  validates :name, presence: true
  validates :sync_interval, presence: true
  # need to define precise validation rules
  validates_inclusion_of :sync_interval, :in => 1..30

  def operating_lines
    lines.where(deactivated: false)
  end

  def last_sync
    line_referential_syncs.last
  end
end
