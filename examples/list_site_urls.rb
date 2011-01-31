require '../lib/simplecrawler.rb'

# Set up a new crawler
sc = SimpleCrawler::Crawler.new(ARGV[0])
sc.skip_patterns = ["\\.doc$", "\\.pdf$", "\\.xls$", "\\.pdf$", "\\.zip$"]

sc.crawl { |document|

	# List links for entire site
	puts document.uri

}
