class Import::Workbench < Import::Base
  after_commit :launch_worker, :on => :create


  option :automatic_merge, type: :boolean, default_value: false

  def launch_worker
    unless Import::Gtfs.accept_file?(file.path)
      WorkbenchImportWorker.perform_async_or_fail(self)
    else
      import_gtfs
    end
  end

  # def main_resource
  #   @resource ||= resources.find_or_create_by(name: self.name, resource_type: "workbench_import")
  # end

  def import_gtfs
    update_column :status, 'running'
    update_column :started_at, Time.now
    Import::Gtfs.create! parent_type: self.class.name, parent_id: self.id, workbench: workbench, file: File.new(file.path), name: self.name, creator: "Web service"

    # update_column :status, 'successful'
    # update_column :ended_at, Time.now
  rescue Exception => e
    Rails.logger.error "Error while processing GTFS file: #{e}"

    update_column :status, 'failed'
    update_column :ended_at, Time.now
    notify_state
  end


  def compliance_check_sets
    ComplianceCheckSet.where parent_id: self.id, parent_type: "Import::Workbench"
  end

  def done!
    if (successful? || warning?) && automatic_merge
      puts "*" * 20
      Merge.create creator: self.creator, workbench: self.workbench, referentials: self.resources.map(&:referential).compact, notification_target: self.notification_target, user: user
    end
  end
end
