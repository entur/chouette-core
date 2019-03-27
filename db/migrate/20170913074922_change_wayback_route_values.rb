class ChangeWaybackRouteValues < ActiveRecord::Migration[4.2]
  def up
    execute "UPDATE routes SET wayback = 'outbound' WHERE routes.wayback = 'straight_forward';"
    execute "UPDATE routes SET wayback = 'inbound' WHERE routes.wayback = 'backward';"
  end

  def down
    execute "UPDATE routes SET wayback = 'straight_forward' WHERE routes.wayback = 'outbound';"
    execute "UPDATE routes SET wayback = 'backward' WHERE routes.wayback = 'inbound';"
  end

end
