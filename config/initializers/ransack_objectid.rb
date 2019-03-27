module RansackNodesGroupingWithObjectId
  def method_missing name, *args
    if name =~ /short_id/ && args == []
      cleaned_name = name.to_s.gsub /^short_id_or_/, ''
      cleaned_name = cleaned_name.gsub /_or_short_id/, ''
      if respond_to?(cleaned_name)
        return self.send(cleaned_name)
      end
    end
    super name, *args
  end
end

class Ransack::Nodes::Grouping
  prepend RansackNodesGroupingWithObjectId
end
