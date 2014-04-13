#!/usr/bin/env ruby20
require_relative 'lib/nextoo/manifest'

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
	unless published_manifest_content.nil? || published_manifest_content.empty?
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