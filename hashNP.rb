require './lib/include'

auth = YAML.load_file File.dirname(__FILE__) + '/twitauth.yml'

term = '#nowplaying'

@client = Twitter.configure do |config|
	config.consumer_key = auth['consumer_key']
	config.consumer_secret = auth['consumer_secret']
	config.oauth_token = auth['access_token']
	config.oauth_token_secret = auth['access_token_secret']
end



MusicBrainz.configure do |c|
	c.app_name = "MyMatch"
	c.app_version = "0.1"
	c.contact = "my@email.com"
	c.query_interval = 1.2 # seconds
	c.tries_limit = 2
end

set = @client.search(term, :count => 1).statuses.first; nil
# in progress
str = set.text
stop_array = %w[- by #nowplaying http:// from # 'listening to']
stopwords_regex = /(?:#{ Regexp.union(stop_array).source })/i
response = str.split(stopwords_regex).map(&:strip)
puts response
puts 'actual text =>'
puts set.text
