class AddRoutesJorneyPatternsPermissionsToUsers < ActiveRecord::Migration[4.2]
  def change
    User.find_each do |user|
      user.permissions = ['routes.create', 'routes.edit', 'routes.destroy', 'journey_patterns.create', 'journey_patterns.edit', 'journey_patterns.destroy']
      user.save!
    end
  end
end
