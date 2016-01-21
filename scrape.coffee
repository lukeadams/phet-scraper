scrape = require 'scrape'
Future = require 'async-future'
fs = require 'fs'
_ = require 'underscore'

Util = require 'util'

prefix = 'https://phet.colorado.edu'


##
#returns phet.json
readConfig = ()->
	console.log 'test'
	fs.readFileSync './phet.json'

writeConfig = (new_cfg)->
	fw.writeFileSync './phet.json', JSON.stringify new_cfg


toVersion = (vstring)->
	return vstring.replace(/[^0-9.]/g, '')


getSimType = (dom)->
	classes = dom.attribs.class
	if contains(classes, 'java-badge')
		return 'java'
	else if contains(classes, 'flash-badge')
		return 'flash'
	else if contains(classes, 'html-badge')
		return 'html'

contains = (parent, subs)->
	x = parent.indexOf subs
	if x >= 0
		return true
	else if x == -1
		return false


#cfg = readConfig()

#Scrape the list of Phet sims
f = new Future()
scrape.request 'https://phet.colorado.edu/en/simulations', (err, $) ->
	sims = []
	if (err) then return console.error(err)

	$('.simulation-link').each (div) ->
		url = prefix + div.attribs.href
		name = div.find('.simulation-list-title').first().text

		sims.push {name: name, url: url}

	#for sim in sims
	#	console.log "#{sim.name} @ #{sim.url}"
	console.log "#{sims.length} simulations"
	f.return(sims)

#Scrape each sim page individually
f.then( (sims) ->
	urls = _.pluck sims, 'url'
	failed = []

	scrape.concurrent urls, 5, (url, next) ->
		if url
			#Find the current sim by URL. findWhere->ref. Not a copy.
			_sim = _.findWhere sims, {url: url}

			#console.log "Scraping simulation@: #{url}"
			scrape.request url, (err, $)->
				if err
					console.log "#{err} #{_sim.name}"# Most often->connection failure
					failed.push _sim
				else
					

					#Extract information for this sim's page
					#idk why but some dont have a download link [...?]. Skip these.
					_sim['download_url'] 	= ($('#sim-download').first()?.attribs.href || (console.log("#{_sim.name}--no download url"); next())) #Skip if no download url.
					_sim['latest_version'] 	= toVersion $('.sim-version').first().text
					_sim['image_url']		= $('#simulation-main-screenshot-image').first().attribs.src
					_sim['type']			= getSimType $('.sim-page-badge').first()

					console.log "#{_sim.name} :: type –> #{_sim.type}"

				next()
		else #Called when done
			#return Future({failed: failed, sims: sims})
			for element in (_.pluck failed, 'name')
				console.log "Failed: #{element} "
			return f.return(sims)
).then( (sims)->
	#writeConfig({sims: sims})

	#console.log sims
)


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
#



