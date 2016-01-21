#PhET Scraper
Scrapes PhET sim information.
It also:
 - Downloads the latest sims (+thumbnails)
 - Encodes information about each simulation (latest version, type, etc.)
 - Downloads them in their proper format: java=>.jar, flash=>.swf, html5=>.html

##Usage
`bundle install` (in repo root)  
`rake update`
 - places each sim in its own dir (hashes of sim url)
 	- refer to config.yml for what folder is for what sim

##WHY RUBY
Initially I was going to use Coffee+Gulp but Ruby+Rake is much more concise for this task. sry.
