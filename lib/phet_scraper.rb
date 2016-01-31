require 'phet_scraper/version'

require 'nokogiri'
require 'open-uri'
require 'yaml'
require 'ruby-progressbar'
require 'retryable'
require 'fileutils'
require 'digest'
require 'mechanize'

module PhetScraper
    #Returns type of simulation gives a list of class names
	def PhetScraper.get_type(classes)
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
	def PhetScraper.fetch(bundle_dir)
		prefix = 'https://phet.colorado.edu/'
		#FileUtils.touch './config.yml'
		#list = YAML.load IO.read './config.yml'

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
			Retryable.retryable(:tries => 3, :on => Errno::ECONNREFUSED) do #Tries three times.
				_simpage = Nokogiri::HTML(open _ret[:url])
			end

			_ret[:download_url]		= (
				if _ret[:type] == :flash then #Flash is ... special :/
					Retryable.retryable(:tries => 3, :on => Errno::ECONNREFUSED) do #Tries three times.
						_play = URI.join(_ret[:url], _simpage.css('#simulation-main-link-run-main').attribute('href').value).to_s
						_flash_page = Mechanize.new.get(_play)
						(URI.join _play, _flash_page.at("embed").attribute('src').value).to_s

					end

				else
					begin #Try to get a url
						_dl = _simpage.css('#sim-download') #HTML + java are normal
						URI.join(prefix, _dl.attribute('href').value).to_s 		
					rescue NoMethodError => e
						return :no_url
					end	
				end			
			)


			_ret[:image_url]		= URI.join(prefix, _simpage.css('.simulation-main-screenshot').first.attribute('src').value).to_s
			_ret[:version]			= _simpage.css('.sim-version').text.split(' ')[1].to_s
			###
			# => Get the files
			### 
			_sim_dir = File.join bundle_dir, _ret[:url_hash] 
			FileUtils.mkdir_p _sim_dir	#Create dir for this sim
			unless _ret[:download_url] == :no_url then
				Retryable.retryable(:tries => 3, :on => Errno::ECONNREFUSED) do #Tries three times.
					_file = (Mechanize.new).get _ret[:download_url]		#dl the file
					_ret[:file_name]		= _file.filename 			#Need to store the filename for launch
					_file.save File.join(_sim_dir, _ret[:file_name])	#Save the sim file
				end
			end
			#Also need to download image
			Retryable.retryable(:tries => 3, :on => Errno::ECONNREFUSED) do 
				_image_file = (Mechanize.new).get _ret[:image_url]
				_ret[:image_file_name] 	= _image_file.filename
				_image_file.save File.join(_sim_dir, _ret[:image_file_name])
			end

			bar.increment
			_ret #return it!

		end
		IO.write File.join(bundle_dir, 'config.yml'), sims.to_yaml
	end
end
