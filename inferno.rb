require 'rubygems'
require "bundler/setup"
Bundler.require(:default)

require "base64"
require 'cgi'

configure do; end
error do; end

$LOAD_PATH.unshift(File.dirname(__FILE__) + '/lib')
require 'database'
require 'feed'

helpers do; end

get '/' do
  erb :index
end

post '/' do
  Database.add_feed!(params[:slug], params[:url]) if params[:slug] and params[:url]

  erb :index
end

get '/rss/:slug' do
  slug = params[:slug].to_s
  feed_url = Database.get_feed(slug)["url"]

  @feed = FeedNormalizer::FeedNormalizer.parse open(feed_url)

  @feed.items.each do |item|
    item.content += pixel_for_guid(item.id)
  end

  content_type 'application/rss+xml'
  @feed.build_rss!
end

get '/pixel/:guid' do
  guid = Base64.decode64(params[:guid])

  Database.count_for_guid! guid

  expires 24*60*60, :public, :must_revalidate
  send_file 'pixel.gif',
    :type => 'image/gif',
    :disposition => 'inline'
end

def pixel_for_guid guid
  url = ENV['HOSTING_URL'].gsub(/\/$/, '') + "/pixel/" + Base64.encode64(guid)
  "<img src=\"#{url}\" />"
end
