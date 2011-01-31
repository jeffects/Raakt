require 'spec'
require 'selenium'
require 'raakt'

context 'Test Google' do
  setup do
    @sel = Selenium::SeleniumDriver.new("localhost", 4444, "*iexplore", "http://www.google.com", 15000)
    @sel.start
  end
		
  specify'assert start page accessibility' do
    @sel.open("http://www.google.com/webhp")
	raakttest = Raakt::Test.new(@sel.get_html_source)
	result = raakttest.all
	result.should be([])
  end
	
  teardown do
    @sel.stop
  end
end
