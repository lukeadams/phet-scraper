scrape = require 'scrape'
Future = require 'async-future'
fs = require 'fs'
_ = require 'underscore'

Util = require 'util'

prefix = 'https://phet.colorado.edu'

#Scrape the list of Phet sims
f = new Future()
scrape.request 'https://phet.colorado.edu/en/simulations', (err, $) ->
	sims = []
	if (err) then return console.error(err)

	$('.simulation-link').each (div) ->
		url = prefix + div.attribs.href
		name = div.find('.simulation-list-title').first().text

		sims.push {name: name, url: url}

	for sim in sims
		console.log "#{sim.name} @ #{sim.url}"
	f.return(sims)

#Scrape each sim page individually
f.then( (sims) ->
	urls = _.pluck sims, 'url'

	scrape.concurrent urls, 30, (url, next) ->
		if url
			localSim = _.findWhere sims, {url: url}

			console.log "Scraping simulation@: #{url}"
			scrape.request url, (err, $)->
				if err
					console.log err
				else
					#Get dl url, tags, image url
					localSim['download_url'] = $('.phet-button.sim-download.sim-button').first().attribs.href
					localSim['latest_version'] = $('.sim-version').first().text
					console.log localSim
				
			#next()




	return Future()

).then( (x)->
	return Future()
).done()


##
#sims = [
##{
#  name
#  url
#  #populated on individual scrape
#  download_url
#  image_url
#  latest_version
#  type
#  tags
##}
#]
##