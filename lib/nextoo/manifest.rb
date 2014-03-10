require_relative 'header'
require_relative 'package'

class Manifest
	attr_reader :package_count
	attr_reader :packages
	attr_reader :header
	
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