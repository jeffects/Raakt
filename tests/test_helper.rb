require 'test/unit'
require 'rubygems'

class Test::Unit::TestCase
  
  def method_missing(methId)
    methodname = methId.id2name
    
    if(methodname[0..4] == "data_")    
      file_name = $0.sub(/raakt_test.rb/, "") + methodname[5..-1] + ".htm"
      if File.exist?(file_name)
        File.open(file_name) {|file|  
         return file.read
        }
      else
        raise "Missing file " + file_name
      end
    end
  end

end
