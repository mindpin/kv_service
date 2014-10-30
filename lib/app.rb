require "bundler"
Bundler.setup(:default)
require "sinatra"
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

require "./lib/tag_use_status"
require "./lib/user_store"
require "./lib/scope"
require "./lib/key_value"
require "./lib/key_tag"

class KVService < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
  end

  set :root, File.expand_path("../../", __FILE__)
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

  helpers do
    def kv_res(&block)
      store = UserStore.find_by_secret(params[:secret])
      res = MultiJson.dump({
        key:       params[:key],
        value:     block.call(store),
        scope:     params[:scope]
      })
      content_type :json
      return res if !params[:callback]
      content_type :js
      "#{params[:callback]}(#{res})"
    end

    def key_tag_res(&block)
      store = UserStore.find_by_secret(params[:secret])

      key_tag = block.call(store)

      res = MultiJson.dump({
        key:       params[:key],
        tags:      key_tag.tags_array,
        scope:     params[:scope]
      })
      content_type :json
      return res if !params[:callback]
      content_type :js
      "#{params[:callback]}(#{res})"
    end

    def auth_around(&block)
      begin
        store = UserStore.find_by_secret(params[:secret])
        return block.call(store)
      rescue Exception => ex
        res = MultiJson.dump({
          secret:     params[:secret],
          error:      ex.message
        })
        content_type :json
        status 500
        return res
      end
    end
  end

  before do
    headers("Access-Control-Allow-Origin" => "*")
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
    store = UserStore.find_by_secret(params[:secret])

    tags_array = params[:tags].split(KeyTag.tags_separator).map(&:strip).reject(&:blank?)
    key_tags = store.scope(params[:scope]).find_key_tag_by_tags(tags_array)
    keys = key_tags.map do |key_tag|
      {
        key:       key_tag.key, 
        tags:      key_tag.tags_array,
        scope:     params[:scope]
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

  get "/read_tags_of_keys" do
    auth_around do |store|
      content_type :json
      key_tags = store.scope(params[:scope]).get_key_tag_of_keys(params[:keys])
      keys = key_tags.map do |key_tag|
        {
          key:       key_tag.key, 
          tags:      key_tag.tags_array,
          scope:     params[:scope]
        }
      end
      MultiJson.dump({
        scope:       params[:scope],
        keys:        keys
      })
    end
  end

  get "/read_hot_tags" do
    auth_around do |store|
      content_type :json
      tag_use_statuses = store.scope(params[:scope]).hot_tags(params[:count])
      MultiJson.dump({
        scope:       params[:scope],
        tags:        tag_use_statuses.map(&:to_hash)
      })
    end
  end

  get "/read_recent_tags" do
    auth_around do |store|
      content_type :json
      tag_use_statuses = store.scope(params[:scope]).recent_tags(params[:count])
      MultiJson.dump({
        scope:       params[:scope],
        tags:        tag_use_statuses.map(&:to_hash)
      })
    end
  end
end
