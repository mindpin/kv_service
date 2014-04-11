class KeyValue
  include Mongoid::Document
  include Mongoid::Timestamps

  field :key,   type: String
  field :value, type: String

  validates :key, presence: true
  validates :key, format: {with: /[a-zA-Z0-9]+/}

  belongs_to :scope
end
