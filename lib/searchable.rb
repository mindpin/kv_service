module Searchable
  extend ActiveSupport::Concern 

  included do
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks
    Searchable.enabled_models.add(self)
  end

  def self.enabled_models
    @_enabled_models ||= Set.new
  end

  def as_indexed_json(options={})
    as_json(except: [:id, :_id])
  end
end
