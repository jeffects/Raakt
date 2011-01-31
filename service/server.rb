require 'rubygems'
require 'webrick'
include WEBrick
require 'erb'
require 'raakt'
require 'open-uri'
require 'fileutils'

module Raakt
	class ValidatorError < RuntimeError; end

	class Test
		attr_accessor :url

		def feedurl(url)
			url = url.strip
			self.url = url
			if url.length == 0
				raise "You called feedurl with a blank url. There is nothing to check."
			end

			#Clean the url and make sure protocol is available
			url = "http://" + url unless url[0..3] == "http"

			begin
				timeout(45) {
					open(url) { |f|
					@html = f.read || ""
				}
				}
			rescue Timeout::Error
				raise "Could not fetch html from #{url}. The server did not respond."
			end

			if @html.length == 0
				raise "Could not fetch html from the url #{url}. There is nothing to check."
			else
				Hpricot.buffer_size = 512288 #Allow for asp.net bastard-sized viewstate attributes...
				@doc = Hpricot(@html)
			end

		end
	end
end


# The Rakt web server interface
class RaaktServlet < WEBrick::HTTPServlet::AbstractServlet
	def do_GET(request, response)

		filepath = Dir::pwd + request.path
		puts filepath

		result = []

		uri = request.query["uri"] || ""

		#Check if request conatined url parameter
		if uri.size > 0
			#set up raakt and run tests
			raakttest = Raakt::Test.new
			raakttest.feedurl(uri)
			result = raakttest.all
		end

		File.open('index.rhtml','r') do |f|
			@template = ERB.new(f.read)
		end

		response.body = @template.result(binding)
		response.status = 200
		response['Content-Type'] = "text/html"

	end
end


#Set up server
HTTPUtils::DefaultMimeTypes.store('js', 'text/javascript')

s = HTTPServer.new(
	:Port            	=> 2000,
	:RequestTimeout 	=> 30,
	:DocumentRoot    	=> Dir::pwd
)

s.mount("/", RaaktServlet)
s.mount("/files", HTTPServlet::FileHandler, Dir::pwd + "/files", true)  #<= allow to show directory index.


# When the server gets a control-C, kill it
trap("INT"){ s.shutdown }

# Start the server
s.start

