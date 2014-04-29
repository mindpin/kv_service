require "spec_helper"

describe TagUseStatus do
  before :all do
    post "/login", login: "test@mindpin.com", password: "123456"
    @secret = UserStore.find_by(email: CGI.unescape("test@mindpin.com")).secret
    @secret.should_not == nil
    @store = Auth.find_by_secret(@secret)
  end

  def tag_use_count(scope, tag_name)
    @store.scope(scope).tag_use_statuses.where(:tag => tag_name).first.use_count
  end

  it{
    # scope rspec1
    rspec1 = "rspec1"
    rspec2 = "rspec2"
    key1 = "key1"
    key2 = "key2"
    # add key key1  tag a,b,c
    @store.scope(rspec1).set_key_tag(key1, "a,b,c")

    tag_use_count(rspec1, "a").should == 1
    tag_use_count(rspec1, "b").should == 1
    tag_use_count(rspec1, "c").should == 1
    # add key key2  tag a,c
    @store.scope(rspec1).set_key_tag(key2, "a,c")
    tag_use_count(rspec1, "a").should == 2
    tag_use_count(rspec1, "b").should == 1
    tag_use_count(rspec1, "c").should == 2
    # change key key1  tag b,c,d
    @store.scope(rspec1).set_key_tag(key1, "b,c,d")
    tag_use_count(rspec1, "a").should == 1
    tag_use_count(rspec1, "b").should == 1
    tag_use_count(rspec1, "c").should == 2
    tag_use_count(rspec1, "d").should == 1
    # change key key2  tag a,e,d
    @store.scope(rspec1).set_key_tag(key2, "a,e,d")
    tag_use_count(rspec1, "a").should == 1
    tag_use_count(rspec1, "b").should == 1
    tag_use_count(rspec1, "c").should == 1
    tag_use_count(rspec1, "d").should == 2
    tag_use_count(rspec1, "e").should == 1
    # scope rspec2
    # add key key1  tag a,b,c
    @store.scope(rspec2).set_key_tag(key1, "a,b,c")
    tag_use_count(rspec2, "a").should == 1
    tag_use_count(rspec2, "b").should == 1
    tag_use_count(rspec2, "c").should == 1
    # add key key2  tag a,c
    @store.scope(rspec2).set_key_tag(key2, "a,c")
    tag_use_count(rspec2, "a").should == 2
    tag_use_count(rspec2, "b").should == 1
    tag_use_count(rspec2, "c").should == 2
    # change key key1  tag a,c,e
    @store.scope(rspec2).set_key_tag(key1, "a,c,e")
    tag_use_count(rspec2, "a").should == 2
    tag_use_count(rspec2, "b").should == 0
    tag_use_count(rspec2, "c").should == 2
    tag_use_count(rspec2, "e").should == 1
    # change key key2  tag c,d,e
    @store.scope(rspec2).set_key_tag(key2, "c,d,e")

    tag_use_count(rspec2, "a").should == 1
    tag_use_count(rspec2, "b").should == 0
    tag_use_count(rspec2, "c").should == 2
    tag_use_count(rspec2, "d").should == 1
    tag_use_count(rspec2, "e").should == 2
  }

  
end
