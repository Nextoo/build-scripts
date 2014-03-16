require 'rubygems'
require 'bundler'
Bundler.setup(:default, :ci)

namespace :manifests do
	desc 'Regenerate all ebuild manifests'
	task :regenerate do
		FileList['../portage-overlay/**/**/*.ebuild'].each do |file|
			sh 'ebuild', file, 'manifest'
		end
	end
end
