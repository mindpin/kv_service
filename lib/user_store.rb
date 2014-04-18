class UserStore
  include Mongoid::Document
  include Mongoid::Timestamps

  field :secret, type: String
  field :uid,    type: String
  field :name,   type: String
  field :email,  type: String
  field :avatar, type: String

  has_many :scopes

  def scope(scope_name = nil)
    scope = self.scopes.find_or_initialize_by(name: scope_name)
    scope.save if scope.new_record?
    scope
  end

end
