require './lib/include'

auth = YAML.load_file File.dirname(__FILE__) + '/twitauth.yml'

term = '#nowplaying'

@client = Twitter.configure do |config|
	config.consumer_key = auth['consumer_key']
	config.consumer_secret = auth['consumer_secret']
	config.oauth_token = auth['access_token']
	config.oauth_token_secret = auth['access_token_secret']
end

mbauth = YAML.load_file File.dirname(__FILE__) + '/lib/mbauth.yml' # musicbrainz oauth - mbauth.yml contains =>  access_token: your_access_token 

set = @client.search(term, :count => 1).statuses.first; nil

name = set.user.screen_name
desc = set.user.description
str = set.text
# flag : if user name contains : radio, fm, play (or tweet contains #listenlive - sets flag to true else false

commercial = is_comm(name,str)
urls, str2 = url_cap(str)
hashtags = hash_cap(str2)
tweet_users, str2 = tweet_user_cap(str2) 
response = art_song_extract(str2)

max = response.length - 1

#mbset = mbsearch(artist_name, track_name, mbauth)


puts response
puts "",'actual text =>',""
puts set.text
puts ""," urls => ",""
puts urls
puts ""," hashtags => ",""
puts hashtags
puts ""," twitter usernames => ",""
puts tweet_users
puts ""," screen name => ",""
puts name
puts ""
puts "is this commercial => "
puts commercial
