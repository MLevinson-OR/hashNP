
def is_comm(str, str2, str3, url)
	
	comm_words = %w[radio fm play dj broadcast air]
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
	return flag
=begin
	if !!url
		puts url
		if is_url_comm(url)
			flag = true
		end
	end

	return flag
end

def is_url_comm(url)
	begin
	flag = false
	doc = Hpricot(open(url))
	title = (doc/"title").inner_text
	comm_words2 = %w[radio dj broadcast]
	comm_regex2 = /(?:#{ Regexp.union(comm_words2).source})/i
	if ((title =~ comm_regex2) != nil)
		flag = true
	end
	rescue OpenURI::HTTPError => ex
	puts "Error on #{url} retrieval, page not accessible #{ex} "	
	end
	return flag

=end
end

def is_rt(str)
	rt_word = %w[RT MT]
	rt_regex = /(?:#{Regexp.union(rt_word).source})/
	flag = false
	if ( str =~ rt_regex) != nil
		flag = true
	end
	return flag
end


