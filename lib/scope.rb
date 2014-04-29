class Scope
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String

  has_many :key_values
  has_many :key_tags
  has_many :tag_use_statuses

  belongs_to :user_store

  def set(key, value)
    record = get_record(key)
    record.value = value;
    record.save
    value
  end

  def get(key)
    get_record(key).value
  end

  def set_key_tag(key, tags)
    record = get_key_tag_record(key)
    record.tags = tags
    record.save
    record
  end

  def get_key_tag(key)
    get_key_tag_record(key)
  end

  def get_key_tag_of_keys(keys)
    keys.split(",").map do |key|
      get_key_tag_record(key)
    end
  end

  def find_key_tag_by_tags(tags_array)
    self.key_tags.tagged_with_all(tags_array)
  end

  def hot_tags(count)
    self.tag_use_statuses.order_by(use_count: -1).limit(count)
  end

  def recent_tags(count)
    self.tag_use_statuses.order_by(last_use_at: -1).limit(count)
  end

  private

  def get_record(key)
    self.key_values.find_or_initialize_by(key: key)
  end

  def get_key_tag_record(key)
    self.key_tags.find_or_initialize_by(key: key)
  end
end
