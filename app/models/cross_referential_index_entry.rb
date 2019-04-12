class CrossReferentialIndexEntry < ActiveRecord::Base
  belongs_to :parent, polymorphic: true
  belongs_to :target, polymorphic: true

  scope :for_target, ->(target){ where(target: target, target_referential_slug: target.referential.slug) }

  def self.rebuild_index!
    CrossReferentialIndexEntry.delete_all

    ReferentialIndexSupport.target_relations.each do |rel|
      rebuild_index_for_relation(rel)
    end
  end

  def self.rebuild_index_for_relation(rel)
    ActiveRecord::Base.cache do
      CrossReferentialIndexEntry.bulk_insert do |worker|
        Referential.find_each do |referential|
          if rel.klass.respond_to?(:within_workgroup)
            rel.klass.within_workgroup(referential.workgroup) do
              rebuild_index_for_relation_in_referential rel, referential
            end
          else
            rebuild_index_for_relation_in_referential rel, referential
          end
        end
      end
    end
  end

  def self.rebuild_index_for_relation_in_referential(rel, referential)
    relation_name = rel.reciproque.name
    referential.switch do
      rel.klass.find_each do |target|
        parent_keys = rel.collection(target).map { |parent| { parent_type: parent.class.name, parent_id: parent.id } }
        key = { relation_name: relation_name, target_type: target.class.name, target_id: target.id, target_referential_slug: referential.slug }
        parent_keys.each do |k|
          worker.add key.dup.update(k)
        end
      end
    end
  end

  def self.update_index_with_relation_from_target(relation, target)
    scope = CrossReferentialIndexEntry.where(relation_name: relation.reciproque.name).for_target(target)

    parent_keys = relation.collection(target).map { |parent| { parent_type: parent.class.name, parent_id: parent.id } }
    return if scope.pluck(:parent_type, :parent_id).sort == parent_keys

    scope.delete_all

    key = { relation_name: relation.reciproque.name, target_type: target.class.name, target_id: target.id, target_referential_slug: target.referential.slug }
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
    CrossReferentialIndexEntry.where(relation_name: relation.name, parent: parent).pluck(:target_referential_slug).uniq.each do |slug|
      Referential.find_by(slug: slug).tap do |referential|
        referential.switch do
          yield referential
        end
      end
    end
  end

  def self.each_target_for(relation, parent, target_referential_slug)
    CrossReferentialIndexEntry.where(relation_name: relation.name, parent: parent, target_referential_slug: target_referential_slug).each do |entry|
      yield entry.target
    end
  end

  def self.all_targets_for(relation, parent, target_referential_slug)
    CrossReferentialIndexEntry.where(relation_name: relation.name, parent: parent, target_referential_slug: target_referential_slug).map &:target
  end
end
