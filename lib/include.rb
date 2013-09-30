require 'twitter'
require 'tweetstream'
require 'hashie'
require 'pp'
require 'mongo'
require 'mongo_mapper'
require 'uri'
require 'hpricot'
require 'open-uri'
require 'yaml'
require 'oj'
require 'echowrap'


class String
	def del(regexp)
		gsub(regexp,'')
	end
	
	def del!(regexp)
		gsub(regexp,'')
	end
end

def urlst(str)
	if URI.extract(str).count > 1
		urls = URI.extract(str)
	else
		urls = URI.extract(str)[0]
	end
end

def hashext(str)
	str.scan(/(#[[:alnum:]]+)/)
end

def userext(str)
	str.scan(/(@[[:alnum:]]\S+)/)
end

def hashrem(str)
	str.del(/(#[[:alnum:]]+)/)
end

def userrem(str)
	str.del(/(@[[:alnum:]]\S+)/)
end

def is_comm(str, str2, str3, url)
	comm_words = %w[radio fm play dj broadcast]
	comm_regex1 = /(?:#{ Regexp.union(comm_words).source})/i
	comm_words2 = %w[radio dj broadcast]
	comm_regex2 = /(?:#{ Regexp.union(comm_words2).source})/i
	comm_word = %w[listenlive]
	comm_regex3 = /(?:#{ Regexp.union(comm_word).source})/i
	
	if (( str =~ comm_regex1) != nil || (str2 =~ comm_regex3) != nil) || ((str3 =~ comm_regex2) != nil)
		flag = true
	else
		flag = false
	end
=begin	
	if !!url
		if is_url_comm(url)
			flag = true
		end
	end
=end
	return flag
end
=begin ## causing error
def is_url_comm(url)
	doc = Hpricot(open(url))
	title = (doc/"title").inner_text
	comm_words2 = %w[radio dj broadcast]
	comm_regex2 = /(?:#{ Regexp.union(comm_words2).source})/i
	if ((title =~ comm_regex2) != nil)
		flag = true
	else
		flag = false
	end
	rescue OpenURI::HTTPError => ex	
	
	return flag
end
=end
def is_rt(str)
	rt_word = %w[RT MT]
	rt_regex = /(?:#{Regexp.union(rt_word).source})/
	flag = false
	if ( str =~ rt_regex) != nil
		flag = true
	end
	return flag
end

def art_song_extract(str)
	stop_array = %w[nonascii @ - via playing  ;]
	stopwords_regex = /(?:#{ Regexp.union(stop_array).source }|#nowplaying\S+|\s#NowPlaying|\?|\sby|(listening to)|\/|\sfrom|(#[[:alnum:]]+))/i
	restemp = str.split(stopwords_regex).map(&:strip)
	response = []
	restemp.each do |res|
	if res.blank?
	else
		response += [res]
	end
	end
	return response

end

# capture any urls
def url_cap(str)
	urls = urlst(str)
	if !!urls
		str2 = str.del(URI.regexp)
	else
		str2 = str	
	end
	return [urls, str2]
end
# capture 
def hash_cap(str)
	hashtags = hashext(str)
	return hashtags
end
# capture and remove usernames from tweet
def tweet_user_cap(str)
	tweet_users = userext(str)
	if !!tweet_users
		str2 = userrem(str)
	else
		str2 = str	
	end
	return [tweet_users, str2]
end

#### search MusicBrainz

def mbsearch(art,trk,mbauth)

	atoken = mbauth['access_token']

	base_uri = 'https://musicbrainz.org/ws/2/recording/'
	search_uri = URI.escape("?&offset=0&max=1000&fmt=json&query=artist:" + %Q{"#{art}"}+"and"+%Q{"#{trk}"} + "&access_token=#{atoken}")
	url = base_uri + search_uri
	out = Hashie::Mash[Oj.load(open(url).read)]

end

def echosearch(art,trk)
	Echowrap.song_search(:combined => "#{art} - #{trk}")
end

def idx_list(str)
	idx1 = []
	idx2 = []
	arr = (0..(str.length - 1)).to_a
	arr.combination(2) do |x,y|
		idx1 += [x]
		idx2 += [y]
	end
	return [idx1,idx2]
end

def match_alg(str)
	idx1, idx2 = idx_list(str)
	len = idx1.length - 1
	if len == 0
		len = 1
	end
	match = false
	artist = nil
	title = nil
	i = 0
	while (i < len && match != true)
		res = echosearch(str[idx1[i]], str[idx2[i]])
		res.each do |res|
			art_match  = str[idx1[i]].casecmp(res.attrs[:artist_name]).zero?
			if art_match
				title_match = str[idx2[i]].casecmp(res.attrs[:title]).zero?
			else 
				art_match  = str[idx2[i]].casecmp(res.attrs[:artist_name]).zero?
				if art_match
					title_match = str[idx1[i]].casecmp(res.attrs[:title]).zero?
				end
			end
			
			
			if (art_match && title_match)
				artist = res.attrs[:artist_name]
				title   = res.attrs[:title]
				break
			end
		end
		
		if ( artist != nil && title != nil)
			puts "#{artist} - #{title}"
			match = true
		end
		i += 1
	end
	
	return [artist,title]
end

def match(str)
	artist, title = match_alg(str)
	return [artist,title]
end

def clean_text(str)
  encoding_options = {
    :invalid           => :replace,  # Replace invalid byte sequences
    :undef             => :replace,  # Replace anything not defined in ASCII
    :replace           => 'nonascii',        # Use a blank for those replacements
    :universal_newline => true       # Always break lines with \n
  }
  out = str.encode Encoding.find('ASCII'), encoding_options
  return out
end	
