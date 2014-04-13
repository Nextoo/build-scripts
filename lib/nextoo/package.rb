class Package
	attr_reader :name
	
	def initialize(block)
		@literal = block
		
		#parse name out of literal
		@name = /CPV.*$/.match(@literal)[0][5..-1] unless block.empty?
	end
	
	def to_s
		@literal
	end
end