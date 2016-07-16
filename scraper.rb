require 'bundler/setup'
require 'scraperwiki'
require 'twitter'
require 'pry'

def twitter
  @twitter ||= Twitter::REST::Client.new do |config|
    if ENV.key? 'MORPH_TWITTER_TOKENS'
      consumer_key, consumer_secret, access_token, access_secret = ENV['MORPH_TWITTER_TOKENS'].split('|')
    end
    config.consumer_key        = ENV['MORPH_TWITTER_CONSUMER_KEY']        || consumer_key
    config.consumer_secret     = ENV['MORPH_TWITTER_CONSUMER_SECRET']     || consumer_secret
    config.access_token        = ENV['MORPH_TWITTER_ACCESS_TOKEN']        || access_token
    config.access_token_secret = ENV['MORPH_TWITTER_ACCESS_TOKEN_SECRET'] || access_secret
  end
end

twitter.list_members('lechinoise', 'politic-arg').each do |person|
  data = {
    id: person.id,
    name: person.name,
    twitter: person.screen_name,
  }
  data[:image] = person.profile_image_url_https(:original).to_s unless person.default_profile_image?
  ScraperWiki.save_sqlite([:id], data)
end
