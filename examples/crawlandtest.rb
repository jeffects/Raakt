require 'net/http'
require 'uri'

class SiteCrawler

	def initialize(url)
		@site_uri = URI.parse(url)
		@site_uri.path = "/" if @site_uri.path == ""
		@visited = Hash.new
		@queue = Array.new
		addPath(@site_uri.path)
		puts "Initialized site crawl for #{@site_uri}"
	end


	def addPath(path)
		@queue.push path
		@visited[path] = false
	end
	
	
	def getPage(path)
		begin
			uri = @site_uri.clone
			uri.path = uri.path + path if path != "/"
			puts "getting #{uri}"
			response = Net::HTTP.get_response(uri)
		rescue Exception
			puts "Error: #{$!}"
			return ""
		end
		return response.body
	end
	
	
	def queueLocalLinks(html)
		html.scan(/<a href\s*=\s*["']([^"]+)"/i) {|w|
			uri = URI.parse("#{w}")
			if !@visited.has_key?(uri.path) and (uri.relative? or uri.host == @site_uri.host)
				addPath(uri.path)
			end
		}
	end
	
	
	def crawlSite()
		while (!@queue.empty?)
			uri = @queue.shift
			page = getPage(uri)
			yield uri, page
			queueLocalLinks(page)
			@visited[uri] = true
		end
	end
end


sc = SiteCrawler.new(ARGV[0])
@pages = Array.new
sc.crawlSite { |url, page_text|
	puts url
	@pages << url
	 # SITE_INDEX <<{ :url => url, :context => page_text }
}
