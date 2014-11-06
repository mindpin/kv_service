require "spec_helper"

describe TagUseStatus do
  before do
    @token = "a1s3d8f0ji7oe5rt4l3ks2df4o"
  end

  def tag_use_count(scope, tag_name)
    Scope.get(@token, scope).tag_use_statuses.where(:tag => tag_name).first.use_count
  end

  it{
    # scope rspec1
    rspec1 = "rspec1"
    rspec2 = "rspec2"
    key1 = "key1"
    key2 = "key2"
    # add key key1  tag a,b,c
    Scope.get(@token, rspec1).set_key_tag(key1, "a,b,c")

    tag_use_count(rspec1, "a").should == 1
    tag_use_count(rspec1, "b").should == 1
    tag_use_count(rspec1, "c").should == 1
    # add key key2  tag a,c
    Scope.get(@token, rspec1).set_key_tag(key2, "a,c")
    tag_use_count(rspec1, "a").should == 2
    tag_use_count(rspec1, "b").should == 1
    tag_use_count(rspec1, "c").should == 2
    # change key key1  tag b,c,d
    Scope.get(@token, rspec1).set_key_tag(key1, "b,c,d")
    tag_use_count(rspec1, "a").should == 1
    tag_use_count(rspec1, "b").should == 1
    tag_use_count(rspec1, "c").should == 2
    tag_use_count(rspec1, "d").should == 1
    # change key key2  tag a,e,d
    Scope.get(@token, rspec1).set_key_tag(key2, "a,e,d")
    tag_use_count(rspec1, "a").should == 1
    tag_use_count(rspec1, "b").should == 1
    tag_use_count(rspec1, "c").should == 1
    tag_use_count(rspec1, "d").should == 2
    tag_use_count(rspec1, "e").should == 1
    # scope rspec2
    # add key key1  tag a,b,c
    Scope.get(@token, rspec2).set_key_tag(key1, "a,b,c")
    tag_use_count(rspec2, "a").should == 1
    tag_use_count(rspec2, "b").should == 1
    tag_use_count(rspec2, "c").should == 1
    # add key key2  tag a,c
    Scope.get(@token, rspec2).set_key_tag(key2, "a,c")
    tag_use_count(rspec2, "a").should == 2
    tag_use_count(rspec2, "b").should == 1
    tag_use_count(rspec2, "c").should == 2
    # change key key1  tag a,c,e
    Scope.get(@token, rspec2).set_key_tag(key1, "a,c,e")
    tag_use_count(rspec2, "a").should == 2
    tag_use_count(rspec2, "b").should == 0
    tag_use_count(rspec2, "c").should == 2
    tag_use_count(rspec2, "e").should == 1
    # change key key2  tag c,d,e
    Scope.get(@token, rspec2).set_key_tag(key2, "c,d,e")

    tag_use_count(rspec2, "a").should == 1
    tag_use_count(rspec2, "b").should == 0
    tag_use_count(rspec2, "c").should == 2
    tag_use_count(rspec2, "d").should == 1
    tag_use_count(rspec2, "e").should == 2
  }

  it{
    scope = "rspec"
    key1 = "key1"
    key2 = "key2"
    key3 = "key3"
    key4 = "key4"
    key5 = "key5"
    key6 = "key6"

    Scope.get(@token, scope).set_key_tag(key1, "a,b,c,d,e,f")
    Scope.get(@token, scope).set_key_tag(key2, "a,b,c,d,e")
    Scope.get(@token, scope).set_key_tag(key3, "a,b,c,d")
    Scope.get(@token, scope).set_key_tag(key4, "a,b,c")
    Scope.get(@token, scope).set_key_tag(key5, "a,b")
    Scope.get(@token, scope).set_key_tag(key6, "a")
    Scope.get(@token, scope).hot_tags(4).to_a.map do |ts|
      {tag: ts.tag, use_count: ts.use_count}
    end.should == [
      {:tag=>"a", :use_count=>6},
      {:tag=>"b", :use_count=>5},
      {:tag=>"c", :use_count=>4},
      {:tag=>"d", :use_count=>3}
    ]
  }


  it{
    scope = "rspec"
    key1 = "key1"
    key2 = "key2"
    key3 = "key3"
    key4 = "key4"
    key5 = "key5"
    key6 = "key6"

    Timecop.travel(Time.now - 6.day) do
      Scope.get(@token, scope).set_key_tag(key1, "a")
    end
    Timecop.travel(Time.now - 5.day) do
      Scope.get(@token, scope).set_key_tag(key2, "b")
    end
    Timecop.travel(Time.now - 4.day) do
      Scope.get(@token, scope).set_key_tag(key3, "c")
    end
    Timecop.travel(Time.now - 3.day) do
      Scope.get(@token, scope).set_key_tag(key4, "d")
    end
    Timecop.travel(Time.now - 2.day) do
      Scope.get(@token, scope).set_key_tag(key5, "e")
    end
    Timecop.travel(Time.now - 1.day) do
      Scope.get(@token, scope).set_key_tag(key6, "f")
    end

    Scope.get(@token, scope).recent_tags(4).to_a.map do |ts|
      {tag: ts.tag}
    end.should == [{:tag=>"f"}, {:tag=>"e"}, {:tag=>"d"}, {:tag=>"c"}]

  }
end
