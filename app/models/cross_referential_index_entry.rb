class CrossReferentialIndexEntry < ActiveRecord::Base
  belongs_to :parent, polymorphic: true
  belongs_to :target, polymorphic: true

  scope :for_target, ->(target){ where(target: target, target_referential_slug: target.referential.slug) }

  def self.rebuild_index!
    ReferentialIndexSupport.target_relations.each do |rel|
      rebuild_index_for_relation(rel)
    end
  end

  def self.clean_index_for_referential!(referential)
    Rails.logger.info "Clean CrossReferentialIndex for referential #{referential.slug}"
    CrossReferentialIndexEntry.where(target_referential_slug: referential.slug).delete_all
  end

  def self.rebuild_index_for_referential!(referential)
    Rails.logger.info "Rebuild CrossReferentialIndex for referential #{referential.slug}"
    clean_index_for_referential!(referential)

    ReferentialIndexSupport.target_relations.each do |rel|
      ActiveRecord::Base.cache do
        rebuild_index_for_relation_in_referential rel, referential
      end
    end
  end

  def self.rebuild_index_for_relation(rel)
    CrossReferentialIndexEntry.where(relation_name: rel.name).delete_all

    ActiveRecord::Base.cache do
      Referential.find_each do |referential|
        rebuild_index_for_relation_in_referential rel, referential
      end
    end
  end

  def self.rebuild_index_for_relation_in_referential(rel, referential)
    CrossReferentialIndexEntry.bulk_insert do |worker|
      begin
        if rel.target_klass.respond_to?(:within_workgroup)
          rel.target_klass.within_workgroup(referential.workgroup) do
            do_rebuild_index_for_relation_in_referential rel, referential, worker
          end
        else
          do_rebuild_index_for_relation_in_referential rel, referential, worker
        end
      rescue => e
        Rails.logger.warn "Unable to rebuild index for relation #{rel.klass.name}##{rel.name} in referential #{referential.slug}: #{e.message}"
      end
    end
  end

  def self.do_rebuild_index_for_relation_in_referential(rel, referential, worker)
    relation_name = rel.ascending.name
    referential.switch do
      collection = rel.index_collection
      collection ||= rel.klass
      collection.find_each do |target|
        parent_keys = rel.collection(target).map { |parent| { parent_type: parent.class.name, parent_id: parent.id } }
        key = { relation_name: relation_name, target_type: target.class.name, target_id: target.id, target_referential_slug: referential.slug }
        parent_keys.each do |k|
          worker.add key.dup.update(k)
        end
      end
    end
  end

  def self.update_index_with_relation_from_target(relation, target)
    scope = CrossReferentialIndexEntry.where(relation_name: relation.ascending.name).for_target(target)

    parent_keys = relation.collection(target).map { |parent| { parent_type: parent.class.name, parent_id: parent.id } }
    return if scope.pluck(:parent_type, :parent_id).sort == parent_keys

    scope.delete_all

    key = { relation_name: relation.ascending.name, target_type: target.class.name, target_id: target.id, target_referential_slug: target.referential.slug }
    CrossReferentialIndexEntry.bulk_insert do |worker|
      parent_keys.each do |k|
        worker.add key.dup.update(k)
      end
    end
  end

  def self.clean_index_from_target(target)
    CrossReferentialIndexEntry.for_target(target).delete_all
  end

  def self.clean_index_from_parent(parent)
    CrossReferentialIndexEntry.where(parent: parent).delete_all
  end

  def self.in_each_referential_for(relation, parent)
    CrossReferentialIndexEntry.where(relation_name: relation.ascending.name, parent: parent).pluck(:target_referential_slug).uniq.each do |slug|
      Referential.find_by(slug: slug).tap do |referential|
        referential.switch do
          yield referential
        end
      end
    end
  end

  def self.each_target_for(relation, parent, target_referential_slug)
    CrossReferentialIndexEntry.where(relation_name: relation.reciproque.ascending.name, parent: parent, target_referential_slug: target_referential_slug).each do |entry|
      yield entry.target
    end
  end

  def self.all_targets_for(relation, parent, target_referential_slug)
    CrossReferentialIndexEntry.where(relation_name: relation.reciproque.ascending.name, parent: parent, target_referential_slug: target_referential_slug).map &:target
  end

  def self.count_targets_for(relation, parent, target_referential_slug)
    CrossReferentialIndexEntry.where(relation_name: relation.reciproque.ascending.name, parent: parent, target_referential_slug: target_referential_slug).count
  end
end
