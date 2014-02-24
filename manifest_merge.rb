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
	
	def merge_in(new_manifest_content)
		@packages.merge!(new_manifest_content.packages)
	end
end

def main
	if ARGV.length < 3
		puts 'ERROR: too few arguments.'
		exit
	end
	
	# Read in arguments
	published_manifest_file, built_manifest_path, merged_manifest_file = ARGV[0], ARGV[1], ARGV[2]
	
	puts "Path to freshly built manifest:\t" + built_manifest_path
	puts "Path to currently published manifest:\t" + published_manifest_file
	puts "Path to store merged manifest:\t" + merged_manifest_file
	
	built_manifest_content = Manifest.new File.read(built_manifest_path)
	
	if File.exist?(published_manifest_file)
		published_manifest_content = Manifest.new File.read(published_manifest_file)
	end
	
	# If there is not a current Manifest on the webserver, just copy the new Manifest over
	unless published_manifest_content.nil?
		published_manifest_content.merge_in(built_manifest_content)
	else
		published_manifest_content = built_manifest_content
	end
	
	File.write(merged_manifest_file, published_manifest_content.to_s())
	
end

# Only call main if this file was invoked directly
if $0 == __FILE__
	main
end