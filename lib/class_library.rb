class String
	def del(regexp)
		gsub(regexp,'')
	end
	
	def del!(regexp)
		gsub(regexp,'')
	end
end
