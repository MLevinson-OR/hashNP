
def youtube_match(str, auth)
	client = Google::APIClient.new(
	  :application_name => 'purely academic',
	  :application_version => '0.0.1'
	)

	key = Google::APIClient::PKCS12.load_key('89fd701a1449c41e03ff91e169127a0621c91809-privatekey.p12','notasecret')
	client.authorization = Signet::OAuth2::Client.new(
	   :token_credential_uri => 'https://accounts.google.com/o/oauth2/token',
	   :audience => 'https://accounts.google.com/o/oauth2/token',
	   :scope => 'https://gdata.youtube.com',
	   :issuer => '1055828813887-fl1jqadlhcs4s5rho28njmb202udhfsp@developer.gserviceaccount.com',
	  :signing_key => key)
	client.authorization.fetch_access_token!
	search_term = str

	opts = Trollop::options do
	  opt :q, 'Search term', :type => String, :default => search_term
	  opt :maxResults, 'Max results', :type => :int, :default => 1	
	end

	youtube = client.discovered_api('youtube', 'v3')
        
	opts[:part] = 'id,snippet'
	opts['key'] = auth['api_key']
	temp = client.execute(
	  :api_method => youtube.search.list,
	  :parameters => opts
	).response.body

	
	out = Hashie::Mash.new
	
	
        if !(JSON[temp]["items"]).empty?
		out.title = JSON[temp]["items"].first["snippet"]["title"]
		out.videoId = JSON[temp]["items"].first["id"]["videoId"]	
	else 
		out.title = nil
		out.videoId = nil
	end	
	return [out]
end

def yt_match(str, auth)
	idx1, idx2 = idx_list(str)
	len = idx1.length 
	match = false
	if len == 0
		len = 1
	end	
	i = 0
	while (i < len && match != true)
		out = youtube_match("\"#{str[idx1[i]]} - #{str[idx2[i]]})\"", auth)[0]

		if (out.title != nil)
		if ( out[:title].jarowinkler_similar("#{str[idx1[i]]} - #{str[idx2[i]]}") > 0.5 )
			art_trk = out[:title]
			needs_sub = true
			j = i
			match = true			
		end
		end
		i += 1
	end
	if needs_sub
		artist, title, match = sub_match(art_trk)
	else
		artist, title = nil
	end
	return [artist, title, match, out]			
	
end

def sub_match(title)
	temp = art_song_extract(title, false)
	sleep(60.seconds) 
	puts 'next'
	artist, song, match = match_alg_artist(temp)
	return [artist, song, match]
end

def match_alg_artist(str)
	artist, song = nil
	str[2] = str[0]	
	set = []
	for i in 0..1
	   Echowrap.song_search(:title => str[i]).each do |set|

	   set = set.attrs			
		if (set[:title].jarowinkler_similar(str[i]) > 0.8)
		     	song = set[:title]
			if ( set[:artist_name].jarowinkler_similar(str[i + 1]) > 0.8) 
				artist = set[:artist_name]
				break
			end	
		end
	   end
	end
	if (artist != nil && song != nil)
		match = true
	else 
		match = false
	end
	return [artist, song, match]	
end
