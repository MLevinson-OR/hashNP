

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
