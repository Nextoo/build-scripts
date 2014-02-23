#!/usr/bin/env ruby20

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

class Header
	
	def initialize(header)
		@literal = header
	end
	
	def to_s
		return @literal
	end
end

class Manifest
	attr_reader :package_count
	attr_reader :packages
	
	def initialize(file_contents)
		@packages = Hash.new
		@package_count = 0
		parse(file_contents)
	end
	
	def parse(file_contents)
		blocks = file_contents.split("\n\n")
		@header = Header.new blocks.shift
		
		blocks.each do |block|
			new_package = Package.new(block)
			@packages[new_package.name()] = new_package
			@package_count += 1
		end
	end
	
	def to_s
		content = @header.to_s()
		
		@packages.each do |package, value|
			content += "\n\n" + value.to_s()
		end
		
		return content
	end
	
	def merge_in(man_b)
		@packages.merge!(man_b.packages)
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
	
	man_a = Manifest.new File.read(file_a)
	
	if File.exist?(file_b)
		man_b = Manifest.new File.read(file_b)
	end
	
	puts "\nManifest A:"
	puts man_a.to_s()
	
	puts "\nManifest B:"
	
	# If there is not a current Manifest on the webserver, just copy the new Manifest over
	unless man_b.nil?
		puts man_b.to_s()
		man_a.merge_in(man_b)
	end
	
	File.write(output, man_a.to_s())
	
end

# Only call main if this file was invoked directly
if $0 == __FILE__
	main
end