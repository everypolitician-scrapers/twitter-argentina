require 'bundler/setup'
require 'scraperwiki'
require 'twitter'
require 'pry'

class TwitterList

  attr_accessor :user, :list, :client

  def initialize(user, list)
    @user = user
    @list = list
    @client = Twitter::REST::Client.new do |config|
      if ENV.key? 'MORPH_TWITTER_TOKENS'
        consumer_key, consumer_secret, access_token, access_secret = ENV['MORPH_TWITTER_TOKENS'].split('|')
      end
      config.consumer_key        = ENV['MORPH_TWITTER_CONSUMER_KEY']        || consumer_key
      config.consumer_secret     = ENV['MORPH_TWITTER_CONSUMER_SECRET']     || consumer_secret
      config.access_token        = ENV['MORPH_TWITTER_ACCESS_TOKEN']        || access_token
      config.access_token_secret = ENV['MORPH_TWITTER_ACCESS_TOKEN_SECRET'] || access_secret
    end
  end

  def people
    client.list_members(user, list).map do |person|
      data = {
        id: person.id,
        name: person.name,
        twitter: person.screen_name,
      }
      data[:image] = person.profile_image_url_https(:original).to_s unless person.default_profile_image?
      data
    end
  end
end

people = TwitterList.new('lechinoise', 'politic-arg').people
ScraperWiki.save_sqlite([:id], people)
