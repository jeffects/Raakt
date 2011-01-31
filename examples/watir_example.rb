require 'watir'
require 'raakt'
require 'test/unit'

# == Example usage of Raakt in Watir
# Watir is a great test framework. This simple class shows how you can assert basic accessibility in your testing framework and make sure you catch basic accessibility issues early in the development cycle.
class TC_myTest < Test::Unit::TestCase
	attr_accessor :ie

	def setup
		@ie = Watir::IE.start("http://www.peterkrantz.com")
	end

	def teardown
		@ie.close
	end

	# This is a standard watir test case
	def test_startPageContainsAuthorName
		assert(@ie.contains_text("Peter Krantz"))
	end

	def test_startPagePassesSimpleAccessibility
		#set up the accessibility test
		raakttest = Raakt::Test.new(@ie.document.body.parentelement.outerhtml)

		#run all tests on the current page
		result = raakttest.all

		#make sure raakt didn't return any error messages
		assert(result.length == 0, result)
	end
end

