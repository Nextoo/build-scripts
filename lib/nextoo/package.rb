class Package
	attr_reader :name
	
	def initialize(block)
		@literal = block
		
		#parse name out of literal
		@name = /CPV.*$/.match(@literal)[0][5..-1]
	end
	
	def to_s
		return @literal
	end
end