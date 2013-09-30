require './lib/include'

tauth = YAML.load_file File.dirname(__FILE__) + '/twitauth.yml'
#mbauth = YAML.load_file File.dirname(__FILE__) + '/mbauth.yml' # musicbrainz oauth - mbauth.yml contains =>  access_token: your_access_token 
echoauth = YAML.load_file File.dirname(__FILE__) + '/echoauth.yml'

term = '#nowplaying'

@client = Twitter.configure do |config|
	config.consumer_key = tauth['consumer_key']
	config.consumer_secret = tauth['consumer_secret']
	config.oauth_token = tauth['access_token']
	config.oauth_token_secret = tauth['access_token_secret']
end

Echowrap.configure do |config|
  config.api_key =       echoauth['api_key']
  config.consumer_key =  echoauth['consumer_key']
  config.shared_secret = echoauth['shared_secret']
end


set = @client.search(term, :count => 1, :lang => "en").statuses.first; nil

name = set.user.screen_name
desc = set.user.description
str = set.text


str = clean_text(str)

tweet_users, str2 = tweet_user_cap(str)
urls, str2 = url_cap(str2)
commercial = is_comm(name,str2,desc,urls)
retweet = is_rt(str2)
hashtags = hash_cap(str2)

response = art_song_extract(str2)

if !retweet && !commercial
	artist, song = match(response)
else
	artist, song = nil, nil
end

if (artist == nil || song == nil)
	matched = false
else
	matched = true
end

puts "" , set.text, ""
puts "artist: ", artist, "", "song: ", song, ""
puts ""," urls => ",""
puts urls
puts ""," hashtags => ",""
puts hashtags
puts ""," twitter usernames => ",""
puts tweet_users
puts ""," screen name => ","" 
puts name, "", "user description => ", desc, ""
puts "is this possibly commercial => "
puts commercial , ""
puts "is this a retweet => "
puts retweet

