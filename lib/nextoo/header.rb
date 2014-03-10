class Header
	
	def initialize(header)
		@properties = Hash.new
		header.split("\n").each do |line|
			unless line.strip == ""
				k = line.split(':')
				key = k.shift
				value = k.join(':')
				puts key + ' ' if value.nil?
				@properties[key.downcase.to_sym] = value.strip
			end
		end
	end
	
	def set_header_uri(uri)
		@properties[:uri] = uri
	end
	
	def to_s
		s = String.new
		@properties.each do |key, value|
			s += key.to_s.upcase + ": " + value + "\n"
		end
		
		return s.strip
	end
end