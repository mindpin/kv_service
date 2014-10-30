class UserStore
  include Mongoid::Document
  include Mongoid::Timestamps

  field :secret, type: String

  has_many :scopes

  def scope(scope_name = nil)
    scope = self.scopes.find_or_initialize_by(name: scope_name)
    scope.save if scope.new_record?
    scope
  end

  def self.find_by_secret(secret)
    store = self.find_or_initialize_by(secret: secret)
    store.save if store.new_record?
    store
  end

end
