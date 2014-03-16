#!/usr/bin/env ruby20
require_relative 'lib/nextoo/header'
require_relative 'lib/nextoo/manifest'

def main
	if ARGV.length < 3
		puts 'ERROR: too few arguments.'
		exit
	end
	
	# Read in arguments
	input_file, output_file, uri = ARGV[0], ARGV[1], ARGV[2]

	if File.exist?(input_file)
		published_manifest_content = Manifest.new File.read(input_file)
	else
		puts 'ERROR: input file does not exist: ' + input_file
	end
	
	published_manifest_content.header.set_header_uri uri
	
	File.write(output_file, published_manifest_content.to_s())
	
end

# Only call main if this file was invoked directly
if $0 == __FILE__
	main
end