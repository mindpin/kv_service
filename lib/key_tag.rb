class KeyTag
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Taggable
  disable_tags_index!

  field :key,   type: String

  validates :key, presence: true
  validates :key, format: {with: /[a-zA-Z0-9]+/}

  embedded_in :scope
end