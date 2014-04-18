require "bundler"
Bundler.setup(:default)
require "sinatra"
require "sinatra/cookies"
require "sinatra/reloader"
require 'sinatra/assetpack'
require "pry"
require "sinatra"
require 'haml'
require 'sass'
require 'coffee_script'
require 'yui/compressor'
require 'sinatra/json'
require "rest_client"
require 'mongoid'
require "multi_json"
require 'mongoid_taggable'
require File.expand_path("../../config/env",__FILE__)

require "./lib/user_store"
require "./lib/scope"
require "./lib/key_value"
require "./lib/key_tag"
require "./lib/auth"

class KVService < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
  end

  set :views, ["templates"]
  set :root, File.expand_path("../../", __FILE__)
  set :cookie_options, :domain => nil
  register Sinatra::AssetPack

  assets {
    serve '/js', :from => 'assets/javascripts'
    serve '/css', :from => 'assets/stylesheets'

    js :application, "/js/application.js", [
      '/js/jquery-1.11.0.min.js',
      '/js/**/*.js'
    ]

    css :application, "/css/application.css", [
      '/css/**/*.css'
    ]

    css_compression :yui
    js_compression  :uglify
  }

  helpers Sinatra::Cookies

  helpers do
    def current_store
      Auth.current_store(self)
    end

    def kv_res(&block)
      store = Auth.find_by_secret(params[:secret])
      return 401 if !store
      res = MultiJson.dump({
        key:       params[:key],
        value:     block.call(store),
        user_id:   store.uid,
        user_name: store.name,
        scope:     params[:scope]
      })
      content_type :json
      return res if !params[:callback]
      content_type :js
      "#{params[:callback]}(#{res})"
    end

    def key_tag_res(&block)
      store = Auth.find_by_secret(params[:secret])
      return 401 if !store

      key_tag = block.call(store)

      res = MultiJson.dump({
        key:       params[:key],
        tags:      key_tag.tags_array,
        user_id:   store.uid,
        user_name: store.name,
        scope:     params[:scope]
      })
      content_type :json
      return res if !params[:callback]
      content_type :js
      "#{params[:callback]}(#{res})"
    end
  end

  before do
    headers("Access-Control-Allow-Origin" => "*")
  end

  get "/" do
    redirect to("/login") if !current_store
    haml :index
  end

  get "/login" do
    haml :login
  end

  post "/login" do
    begin
      Auth.new(params[:login], params[:password], self).login!
      200
    rescue
      401
    end
  end

  post "/write" do
    kv_res do |store|
      store.scope(params[:scope]).set(params[:key], params[:value])
    end
  end

  get "/read" do
    kv_res do |store|
      store.scope(params[:scope]).get(params[:key])
    end
  end


  post "/write_tags" do
    key_tag_res do |store|
      store.scope(params[:scope]).set_key_tag(params[:key], params[:tags])  
    end
  end

  get "/read_tags" do
    key_tag_res do |store|
      store.scope(params[:scope]).get_key_tag(params[:key])
    end
  end

  get "/find_by_tags" do
    store = Auth.find_by_secret(params[:secret])
    return 401 if !store

    tags_array = params[:tags].split(KeyTag.tags_separator).map(&:strip).reject(&:blank?)
    key_tags = store.scope(params[:scope]).find_key_tag_by_tags(tags_array)
    keys = key_tags.map do |key_tag|
      {
        key:       key_tag.key, 
        tags:      key_tag.tags_array,
        scope:     params[:scope],
        user_id:   store.uid,
        user_name: store.name
      }
    end

    res = MultiJson.dump({
      input_tags:  tags_array,
      scope:       params[:scope],
      keys:        keys
    })
    content_type :json
    return res if !params[:callback]
    content_type :js
    "#{params[:callback]}(#{res})"
  end


end
