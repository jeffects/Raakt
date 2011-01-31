require 'rubygems'
require 'rake'
require 'echoe'

Echoe.new('raakt') do |s|
  s.name = 'raakt'
  s.summary = 'A toolkit to find basic accessibility issues in HTML documents.'
  s.runtime_dependencies = ["hpricot >=0.6"]
  s.has_rdoc = true
  s.ruby_version = '>= 1.8.2'
  s.files = FileList['lib/*.rb', 'tests/*'].to_a
  s.test_files = Dir.glob('tests/raakt_test.rb')
  s.author = "Peter Krantz"
  s.email = "peter.krantzNODAMNSPAM@gmail.com"
  s.url = "http://www.peterkrantz.com/raakt/wiki/"
  s.ignore_pattern = ["examples", "pkg", "service"]
end

