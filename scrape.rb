require 'nokogiri'
require 'open-uri'
require 'yaml'
require 'pp'
require 'ruby-progressbar'
require 'retryable'
require 'fileutils'
require 'digest'
require 'mechanize'
#Java from here 
# => http://www.oracle.com/technetwork/java/javase/downloads/jre8-downloads-2133155.html

#The flash ones make you download a jar file. Hmm
module Scraper
	#Returns type of simulation gives a list of class names
	def Scraper.get_type(classes)
		case classes
			when /sim-badge-html/
				return :html
			when /sim-badge-java/
				return :java
			when /sim-badge-flash/
				return :flash
			else
				return :unknown
		end
	end
	#Downloads new simulations
	def Scraper.update
		FileUtils.rm_rf './bundle'
		prefix = 'https://phet.colorado.edu/'
		FileUtils.touch './config.yml'
		list = YAML.load IO.read './config.yml'

		_sim_page = Nokogiri::HTML(open(URI.join prefix, 'en/simulations'))

		_sim_items = _sim_page.css(".simulation-list-item")
		_sim_count = _sim_items.length

		bar = ProgressBar.create({:total=>_sim_count, :length=>80, :format=>"[%c/%C]|(%t)"})

		sims = _sim_items.map do |item|
			#Generates a rudimentary list
			_ret = {}
			_ret[:name] = item.css('.simulation-list-title').text
			_ret[:type]	= get_type item.css('.sim-display-badge').first.attribute('class').value
			_ret[:url]	= URI.join(prefix, item.css('.simulation-link').first.attribute('href').value).to_s
			_ret[:url_hash] = Digest::SHA1.hexdigest _ret[:url]

			bar.title = _ret[:name]

			_simpage = nil
			Retryable.retryable(:tries => 3, :on => OpenURI::HTTPError) do #Tries three times.
				_simpage = Nokogiri::HTML(open _ret[:url])
			end

			_ret[:download_url]		= (
				if _ret[:type] == :flash then
					URI.join(prefix, _simpage.css('#simulation-main-link-run-main').attribute('href').value).to_s
				elsif _dl = _simpage.css('.sim-download').first then 
					URI.join(prefix, _dl.attribute('href').value).to_s else :no_url 
				end
			)
			_ret[:image_url]		= URI.join(prefix, _simpage.css('.simulation-main-screenshot').first.attribute('src').value).to_s
			_ret[:version]			= _simpage.css('.sim-version').text.split(' ')[1].to_s
			###
			# => Get the files
			### 
			unless _ret[:download_url] == :no_url then
				_sim_dir = File.join './bundle', _ret[:url_hash] 
				FileUtils.mkdir_p _sim_dir	#Create dir for this sim

				Retryable.retryable(:tries => 3, :on => OpenURI::HTTPError) do #Tries three times. Probably should modify the error for mechanize
					_file = (Mechanize.new).get _ret[:download_url]		#dl the file
					_ret[:file_name]		= _file.filename 			#Need to store the filename for launch
					_file.save File.join(_sim_dir, _ret[:file_name])	#Save the sim file
				end

			end

			bar.increment

			_ret #return it!

		end

		IO.write './config.yml', sims.to_yaml
	end
end
