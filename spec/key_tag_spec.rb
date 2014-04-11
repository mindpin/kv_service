require "spec_helper"

describe KeyTag do
  before :all do
    post "/login", login: "test@mindpin.com", password: "123456"
    @secret = UserStore.find_by(email: CGI.unescape("test@mindpin.com")).secret
    @secret.should_not == nil
  end

  it{
    get "/read_tags", secret: @secret, scope: "spec", key: "1"
    json = JSON.parse(last_response.body)
    json.should == {"key"=>"1", "tags"=>[], "user_id"=>"9479", "user_name"=>"mindpin_test", "scope"=>"spec"}

    post "/write_tags", secret: @secret, scope: "spec", key: "1", tags: "a,b,c"
    json = JSON.parse(last_response.body)
    json.should == {"key"=>"1", "tags"=>["a","b","c"], "user_id"=>"9479", "user_name"=>"mindpin_test", "scope"=>"spec"}

    get "/read_tags", secret: @secret, scope: "spec", key: "1"
    json = JSON.parse(last_response.body)
    json.should == {"key"=>"1", "tags"=>["a","b","c"], "user_id"=>"9479", "user_name"=>"mindpin_test", "scope"=>"spec"}    


    post "/write_tags", secret: @secret, scope: "spec", key: "2", tags: "a,b,d"
    json = JSON.parse(last_response.body)
    json.should == {"key"=>"2", "tags"=>["a","b","d"], "user_id"=>"9479", "user_name"=>"mindpin_test", "scope"=>"spec"}

    get "/read_tags", secret: @secret, scope: "spec", key: "2"
    json = JSON.parse(last_response.body)
    json.should == {"key"=>"2", "tags"=>["a","b","d"], "user_id"=>"9479", "user_name"=>"mindpin_test", "scope"=>"spec"}    



    post "/write_tags", secret: @secret, scope: "spec", key: "3", tags: "a"
    json = JSON.parse(last_response.body)
    json.should == {"key"=>"3", "tags"=>["a"], "user_id"=>"9479", "user_name"=>"mindpin_test", "scope"=>"spec"}

    get "/read_tags", secret: @secret, scope: "spec", key: "3"
    json = JSON.parse(last_response.body)
    json.should == {"key"=>"3", "tags"=>["a"], "user_id"=>"9479", "user_name"=>"mindpin_test", "scope"=>"spec"}    



    post "/write_tags", secret: @secret, scope: "spec2", key: "1", tags: "a,b,d"
    json = JSON.parse(last_response.body)
    json.should == {"key"=>"1", "tags"=>["a","b","d"], "user_id"=>"9479", "user_name"=>"mindpin_test", "scope"=>"spec2"}

    get "/read_tags", secret: @secret, scope: "spec2", key: "1"
    json = JSON.parse(last_response.body)
    json.should == {"key"=>"1", "tags"=>["a","b","d"], "user_id"=>"9479", "user_name"=>"mindpin_test", "scope"=>"spec2"}    


    get "find_by_tags", secret: @secret, scope: "spec", tags: "a,b"
    json = JSON.parse(last_response.body)


    json.should == {
      "input_tags"=>["a", "b"], 
      "scope"=>"spec", 
      "keys"=>[
        {"key"=>"1", "tags"=>["a", "b", "c"], "scope"=>"spec", "user_id"=>"9479", "user_name"=>"mindpin_test"}, 
        {"key"=>"2", "tags"=>["a", "b", "d"], "scope"=>"spec", "user_id"=>"9479", "user_name"=>"mindpin_test"}
      ]
    }

  }

end