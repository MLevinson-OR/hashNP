require 'oj'

def art_song_extract(str, retweet)
	if !retweet
	stop_array = %w[nonascii @  via  ; , nowplaying #nowplaying]
	else
	stop_array = %w[nonascii @  via  RT MT ; , nowplaying #nowplaying]
	end	
	stopwords_regex = /(?:#{ Regexp.union(stop_array).source }|\s::\s|\s-\s|(\s\s)|\son\s|\sby\s|(\splaying\s)|(listening to)|\/|\sfrom\s|(#[[:alnum:]]+))/i
	restemp = str.split(stopwords_regex).map(&:strip)
	response = []
	restemp.each do |res|
	if !(res.blank?)
		response += [res]
	end
	end
	return response

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
	len = idx1.length 
	if len == 0
		len = 1
	end
	match = false
	artist = nil
	title = nil
	needs_sub = false
	i = 0
	
	while (i < len && match != true)
		
		res1 = echosearch(str[idx1[i]], str[idx2[i]]) # most of the times this works, sometimes kicks out a type error #
		res1.each do |res|
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
	
	return [artist,title, match]
end



def match(str, gauth)
	artist, title, matche = match_alg(str)
	if !!matche
		puts 'found by echosearch'
	else 
		artist, title, matchy, youtube_data = yt_match(str, gauth)
		if !!matchy
			puts 'found by youtube'
		else
			puts 'no match'
			artist, title = nil
=begin
			artist, title, matchf = fuzzy_match(str)
			if !!matchf
				puts 'found by a fuzzy string match'
			else
				artist, title = nil
				puts 'no match'
			end
=end
		end	
	end  
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
  out = out.gsub('&amp;', '&')
  return out
end
