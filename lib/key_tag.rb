class KeyTag
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Taggable
  include Searchable
  disable_tags_index!

  field :key,   type: String

  validates :key, presence: true
  validates :key, format: {with: /[a-zA-Z0-9]+/}

  belongs_to :scope

  before_save do |key_tag|
    tags_colle = key_tag.changes["tags_array"]
    next if tags_colle.blank?
    old_tags = tags_colle[0] || []
    new_tags = tags_colle[1] || []
    add_tags = new_tags - old_tags
    remove_tags = old_tags - new_tags

    add_tags.each { |tag| TagUseStatus.increment_use_count(scope, tag) }
    remove_tags.each { |tag| TagUseStatus.decrement_use_count(scope, tag) }
  end


  searchable :tags_array
end
