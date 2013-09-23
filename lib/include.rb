require 'twitter'
require 'tweetstream'
require 'hashie'
require 'pp'
require 'mongo'
require 'mongo_mapper'
require 'uri'
require 'open-uri'
require 'yaml'
require 'oj'


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
		str.scan(/(@[[:alnum:]]+)/)
	end

	def hashrem(str)
		str.del(/(#[[:alnum:]]+)/)
	end

	def userrem(str)
		str.del(/(@[[:alnum:]]+)/)
	end

	def is_comm(str, str2)
		comm_words = %w[radio fm play dj]
		comm_regex1 = /(?:#{ Regexp.union(comm_words).source})/i
		comm_word = %w[listenlive]
		comm_regex2 = /(?:#{ Regexp.union(comm_word).source})/i	
		if (( str =~ comm_regex1) != nil || (str2 =~ comm_regex2) != nil)
			flag = true
		else
			flag = false
		end	
		return flag
	end

	def art_song_extract(str)
		stop_array = %w[listening @ - via  nowplaying 'NowPlaying' ; ||]
		stopwords_regex = /(?:#{ Regexp.union(stop_array).source }|\sby|\sfrom|(#[[:alnum:]]+))/i
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
