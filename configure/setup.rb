#!/usr/bin/env ruby
#
# This script will setup the project to be used by Captain. It will create a
# hooks directory at the root of the project and populate it with all of the
# selected hook scripts. It will also copy the selected hooks (pre-commit,
# post-commit, etc) into the .git/hooks directory. Lastly it will copy the
# Rakefile into the root of the project.
#
require 'fileutils'

@scriptDir = File.expand_path(File.dirname(__FILE__))

Dir.chdir(@scriptDir) do
	def selectHooks()
		hooks = Dir.entries('hooks').select {|f| !File.directory? f}

		if hooks.count > 1
			hooks = hooks.join(',')
		else
			hooks = hooks.first
		end

		puts "Plese select the hooks you would like to configure."
		puts "All selections should be comma separated."
		puts "The available hooks are:"
		puts "#{hooks.gsub(',', "\n")}"
		print 'Enter selection: '

		@hooksChosen = gets.chomp
		@hooksChosen = @hooksChosen.split(',')

	end
	selectHooks()

	def selectScripts()
		scriptsHash = Hash.new
		@chosen = Hash.new

		@hooksChosen.each do |hookScripts|
			hookScripts = hookScripts.gsub(/^\"|\"?$/, '')
			hooksDir = "../#{hookScripts}"
			scriptsHash[hookScripts] = Dir.entries(hooksDir).select {|f| !File.directory? f}
		end

		puts 'Please select the hook scripts to configure.'
		puts 'All hook scripts should be comma separated.'

		scriptsHash.each do |k,v|
			puts "The available hook scripts for #{k} are:"
			puts v.join(',').gsub(',',"\n")
			print 'Enter selection: '

			scriptsChosen = gets.chomp
			puts

			@chosen[k] = scriptsChosen.split(',')
		end
	end
	selectScripts()

	def buildStructure()
		Dir.chdir('../../') do
			@chosen.each do |k,v|
				FileUtils::mkdir_p("hooks/#{k}") unless File.directory?("hooks/#{k}")
			end
		end
	end
	buildStructure()

	def copyFiles()
		FileUtils.cp('Rakefile', '../../hooks')

		@chosen.each do |k,v|
			FileUtils.cp("hooks/#{k}", '../../.git/hooks')

			v.each do |script|
				FileUtils.cp("../#{k}/#{script}", "../../hooks/#{k}")
			end
		end
	end
	copyFiles()
end
