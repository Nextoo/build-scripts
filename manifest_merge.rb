#!/usr/bin/env ruby20

class Package
	attr :name
	
	def initialize(block)
		@literal = block
		
		#parse name out of literal
	end
	
	def to_s
		@literal
	end
	
	
end

class Header
	
	def initialize(header)
		@literal = header
	end
end

class Manifest
	
	def initialize(file_path)
		@packages = Array.new
		parse(file_path)
	end
	
	def parse(file_path)
		blocks = File.read(file_path).split("\n\n")
		@header = Header.new blocks.shift
		
		blocks.each do | block |
			@packages << Package.new(block)
		end
	end
end

def main
	if ARGV.length < 3
		puts 'ERROR: too few arguments.'
		exit
	end
	
	# Read in arguments
	file_a, file_b, output = ARGV[0], ARGV[1], ARGV[2]
	
	puts file_a
	puts file_b
	puts output
	
	man_a = Manifest.new file_a
	
end

# Only call main if this file was invoked directly
if $0 == __FILE__
	main
end