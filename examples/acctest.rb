# This is a sample command line script that uses the raakt gem to test a html document. Please install the mechanize gem before running this script.
require 'mechanize'
require File.dirname(__FILE__) + '/../lib/raakt' #or just 'raakt' of you have installed the gem

#Parse command line url argument to get URL
url = ARGV[0] || ""

if url.length == 0
  puts "\nRuby Accessibility Analysis Kit Example\n\n  Usage: ruby acctest.rb <url>\n  Example: ruby acctest.rb http://www.rubylang.org/en\n\nView source for this file for example usage."
  exit
end

#Get html for the url specified (does not follow redirects)
puts "Fetching #{url}...\n"

#Allow for bastard-sized asp.net view state attribute values...
Hpricot.buffer_size = 262144

#Set up mechanize agent
agent = WWW::Mechanize.new
agent.pluggable_parser.default = Hpricot

# Set user_agent string
# See possible values here:
# http://mechanize.rubyforge.org/classes/WWW/Mechanize.html#constants-list
agent.user_agent_alias = 'Mac Safari' 

# Get the page
page = agent.get(url)

# Set up the RAAKT test and pass html and headers
raakttest = Raakt::Test.new(page.body, page.header.to_hash)

#Run all checks and print result to the console
result = raakttest.all

if result.length > 0
  puts "Accessibility problems detected:"
  puts result
else
  puts "No measurable accessibility problems were detected."
end
