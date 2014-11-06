require "spec_helper"

describe KeyTag do
  before :all do
    @token = "a1s3d8f0ji7oe5rt4l3ks2df4o"
  end

  it{
    get "/read_tags", token: @token, scope: "spec", key: "1"
    json = JSON.parse(last_response.body)
    json.should == {"key"=>"1", "tags"=>[], "scope"=>"spec"}

    post "/write_tags", token: @token, scope: "spec", key: "1", tags: "a,b,c"
    json = JSON.parse(last_response.body)
    json.should == {"key"=>"1", "tags"=>["a","b","c"], "scope"=>"spec"}

    get "/read_tags", token: @token, scope: "spec", key: "1"
    json = JSON.parse(last_response.body)
    json.should == {"key"=>"1", "tags"=>["a","b","c"], "scope"=>"spec"}    


    post "/write_tags", token: @token, scope: "spec", key: "2", tags: "a,b,d"
    json = JSON.parse(last_response.body)
    json.should == {"key"=>"2", "tags"=>["a","b","d"], "scope"=>"spec"}

    get "/read_tags", token: @token, scope: "spec", key: "2"
    json = JSON.parse(last_response.body)
    json.should == {"key"=>"2", "tags"=>["a","b","d"], "scope"=>"spec"}    



    post "/write_tags", token: @token, scope: "spec", key: "3", tags: "a"
    json = JSON.parse(last_response.body)
    json.should == {"key"=>"3", "tags"=>["a"], "scope"=>"spec"}

    get "/read_tags", token: @token, scope: "spec", key: "3"
    json = JSON.parse(last_response.body)
    json.should == {"key"=>"3", "tags"=>["a"], "scope"=>"spec"}    



    post "/write_tags", token: @token, scope: "spec2", key: "1", tags: "a,b,d"
    json = JSON.parse(last_response.body)
    json.should == {"key"=>"1", "tags"=>["a","b","d"], "scope"=>"spec2"}

    get "/read_tags", token: @token, scope: "spec2", key: "1"
    json = JSON.parse(last_response.body)
    json.should == {"key"=>"1", "tags"=>["a","b","d"], "scope"=>"spec2"}    


    get "find_by_tags", token: @token, scope: "spec", tags: "a,b"
    json = JSON.parse(last_response.body)


    json.should == {
      "input_tags"=>["a", "b"], 
      "scope"=>"spec", 
      "keys"=>[
        {"key"=>"1", "tags"=>["a", "b", "c"], "scope"=>"spec"}, 
        {"key"=>"2", "tags"=>["a", "b", "d"], "scope"=>"spec"}
      ]
    }

  }

  describe "read_tags_of_keys" do
    before{
      post "/write_tags", token: @token, scope: "spec", key: "1", tags: "a,b,c"
      post "/write_tags", token: @token, scope: "spec", key: "2", tags: "b,c"
    }

    it{
      get "/read_tags_of_keys", token: @token, scope: "spec", key: "1,3"
      last_response.status.should == 500
      JSON.parse(last_response.body)["error"].should == "undefined method `split' for nil:NilClass"
    }


    it{
      get "/read_tags_of_keys", token: @token, scope: "spec", keys: "1,3"
      JSON.parse(last_response.body).should == {
        "scope"=> "spec", 
        "keys"=>[
          {
            "key"=>"1", 
            "tags"=>["a", "b", "c"], 
            "scope"=>"spec"
          }, 
          {
            "key"=>"3", 
            "tags"=>[], 
            "scope"=>"spec"
          }
        ]
      }
    }
  end

end