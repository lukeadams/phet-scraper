#PhET Scraper
##?
Scrapes PhET sim information.
It also:
 - Downloada the latest sims (+thumbnails)
 - Encode information about each simulation (latest version, type, etc.)
 - Downloads them as their proper format: java=>.jar, flash=>.swf, html5=>.html

##WHY RUBY
Initially I was going to use Coffee+Gulp but Ruby+Rake is much more concise for this task. sry.

##Usage
`rake update`
 - places each sim in its own dir (hashes of sim url)
 	- refer to config.yml for what folder is for what sim
