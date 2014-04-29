class TagUseStatus
  include Mongoid::Document
  include Mongoid::Timestamps

  field :tag, type: String
  field :use_count, type: Integer
  field :last_use_at, type: DateTime
  
  belongs_to :scope

  def last_use_at_str
    last_use_at.strftime("%Y-%m-%d %H:%M:%S")
  end

  def to_hash
    {
      tag: tag,
      use_count: use_count,
      last_use_at: last_use_at_str
    }
  end

  def self.increment_use_count(scope, tag)
    us = scope.tag_use_statuses.find_or_initialize_by(tag: tag)
    us.use_count = 0 if us.use_count.blank?
    us.use_count += 1
    us.last_use_at = Time.now
    us.save
  end

  def self.decrement_use_count(scope, tag)
    us = scope.tag_use_statuses.find_by(tag: tag)
    return if us.blank?
    us.use_count -= 1
    us.save
  end

  def self.re_record_all_tag_use_status
    TagUseStatus.destroy_all
    kts = KeyTag.all
    count = kts.count
    kts.each_with_index do |key_tag, index|
      p "#{index+1}/#{count}"
      key_tag.tags_array.each do |tag|
        TagUseStatus.increment_use_count(key_tag.scope, tag)
      end
    end
  end

end