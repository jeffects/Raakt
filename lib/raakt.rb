# == The Ruby Accessibility Analysis Kit (RAAKT)
# :title: Ruby Accessibility Analysis Kit (RAAKT)
# Author::    Peter Krantz (http://www.peterkrantz.com/)
# License::   See LICENSE file
#
# RAAKT is a toolkit to find accessibility issues in HTML documents. RAAKT can be used as part of a an automatic test procedure or as a standalone module for mass validation of all pages in a site.
# 
# The ambition has been to provide tests that can be fully automated. Currently, none of the included tests should fail for any web page.
#
# Many of the tests included here map to tests defined in the Unified Web Evaluation Methodology (UWEM[http://www.wabcluster.org/uwem/tests/]). See note for each test to find the corresponding UWEM test.
# 
# == Output
# RAAKT output is in the form of an array of Raakt::ErrorMessage objects.
#
# == Contributions
# Thanks to Derek Perrault for refactoring RAAKT to use Hpricot[http://github.com/hpricot] while at the same time making the code more readable.
#
# == Example usage
# See the RAAKT wiki[http://www.peterkrantz.com/raakt/wiki/] for examples and more documentation.
#
module Raakt
  require 'hpricot'
  require File.dirname(__FILE__) + '/iso_language_codes'
  
  MESSAGES = {
    :missing_title       => "The title element is missing. Provide a descriptive title for your document.",
    :empty_title         => "The title element is empty. Provide a descriptive title for your document.",  
    :missing_alt         => "Missing alt attribute for image (with src '%s').",
    :missing_heading     => "Missing first level heading (h1). Provide at least one first level heading describing document content.",
    :wrong_h_structure   => "Document heading structure is wrong.",
    :first_h_not_h1      => "The first heading is not h1.",
    :has_nested_tables   => "You have one or more nested tables.",
    :missing_semantics   => "You have used %s for visual formatting. Use CSS instead.",
    :has_flicker         => "You have used <blink> and/or <marquee>. These may create accessibility issues and should be avoided.",
    :missing_lang_info   => "Document language information is missing. Use the lang attribute on the html element.",
    :missing_th          => "Missing table headings (th) for table #%s.",
    :ambiguous_link_text => "One or more links have the same link text ('%s'). Make sure each link is unambiguous.",
    :field_missing_label => "A field (with id/name '%s') is missing a corresponding label element. Make sure a label exists for all visible fields.",
    :missing_frame_title => "Missing title attribute for frame with url %s",
    :has_meta_refresh    => "Client side redirect (meta refresh) detected. Use server side redirection instead.",
	:charset_mismatch	 => "The character set specified in the HTTP headers does not match that specified in the markup.",
	:embed_used			 => "You have used the embed element. It does not provide a way to express a text representation.",
	:wrong_lang_code	 => "You have used a language code ('%s') not recognized in the ISO 639 standard.",
	:fieldset_missing_legend => "Missing legend element for fieldset #%s.",
	:missing_input_alt	 => "Missing alt attribute for image button with id/name '%s'.",
	:missing_input_alt_text	 => "Missing alt text for image button with id/name '%s'.",
	:missing_area_alt	 => "Missing alt attribute for area with id/name '%s'.",
	:missing_area_alt_text	 => "Missing alt text for area with id/name '%s'.",
	:difficult_word => "Vocabulary: %s"
  } 
  
  VERSION = "0.5.6"
  
  class ErrorMessage
  
    attr_reader :eid, :text, :note

    def initialize(eid, note=nil)
      @eid = eid
      
      if note
        @text = MESSAGES[@eid].sub(/%s/, note)
      else
        @text = MESSAGES[@eid]
      end
      @note = note
    end

    def to_s
      "#{@eid}: #{@text}"
    end

	# Return single error message as an xml element.
  	def to_xml
  		"<message id=\"#{@eid}\">#{@text}</message>"
  	end
  end



  class Test

    attr_accessor :html, :headers, :ignore_bi, :wordlist

    def initialize(html=nil, headers=nil, wordlist=nil)
      @html = html
	  @headers = headers
	  @wordlist = wordlist
      self.doc = @html if html
	  self.headers = @headers if headers
	  self.wordlist = @wordlist if wordlist
	  @ignore_bi = false 
    end

	# Set the HTML used in the test.
    def doc=(html)
	  Hpricot.buffer_size = 524288 #Allow for asp.net bastard-sized viewstate attributes...
      @doc = Hpricot(html)
    end
    
    # Set HTML headers to be used in the test. Headers are necessary for some tests (e.g. to check encoding).
    def headers=(headers)
		if headers
      		@headers = downcase_hash_keys(headers)
		else
			@headers = nil
		end
    end


	# Call all check methods.
    def all
      messages = []
      
      self.methods.each do |method|
        if method[0..5] == "check_"
          messages += self.send(method)
        end
      end
      
      return messages
    end


	# Verify that all fieldset elements have a legend child element. See UWEM 1.0 Test 12.3_HTML_01.
	def check_fieldset_legend
		messages = []
		fieldsets = (@doc/"fieldset")
		fieldset_instance = 1
		for fieldset in fieldsets 
			if (fieldset/"legend").empty?
				messages << ErrorMessage.new(:fieldset_missing_legend, fieldset_instance.to_s)				
			end
			fieldset_instance += 1
		end
		messages
	end


	# Verify that the embed element isn't used. See UWEM 1.0 Test 1.1_HTML_06.
	def check_embed
		return [ErrorMessage.new(:embed_used)] unless (@doc/'embed').empty?
		[]
	end

  
	# Verify that the charater set specified in HTTP headers match that specidied in the HTML meta element.
	def check_character_set
		messages = []
		header_charset = meta_charset = ""
		if @headers and @headers.length > 0 then
			if @headers.has_key?("content-type")
				header_charset = parse_charset(@headers["content-type"].to_s)
			end

			#get meta element charset
			meta_elements = @doc.search("//meta[@http-equiv]")
			for element in meta_elements do
				if element["http-equiv"].downcase == "content-type" then
					meta_charset = parse_charset(element["content"])
				end
			end

			if header_charset.length > 0 and meta_charset.length > 0
				unless meta_charset == header_charset
					messages << ErrorMessage.new(:charset_mismatch) 
				end
			end
		end

		return messages

	end


	# Verify that all input type=image elements have an alt attribute.
	def check_input_type_img
		#Covers UWEM 1.0 Test 1.1_HTML_01

		messages = []
		image_input_buttons = @doc.search("input").select { |element| element['type'] =~ /image/i }
		image_input_buttons.map { |element| 
			unless element['alt']
				messages << ErrorMessage.new(:missing_input_alt, element['name'] || element['id'] || "") 
			else
				if element['alt'].length == 0
					messages << ErrorMessage.new(:missing_input_alt_text, element['name'] || element['id'] || "")
				end
			end
		}

		messages
	end


	# Verify that all img elements have an alt attribute.
    def check_images
      no_alt_images = (@doc/"img:not([@alt])")
      no_alt_images.map { |img| ErrorMessage.new(:missing_alt, img['src']) }
    end

  
	# Verify that all area elements have a non-empty alt attribute. See UWEM 1.0 Test 1.1_HTML_01 (together with check_images)
    def check_areas
		messages = []
		area_elements = (@doc/"area")
		area_elements.map { |element| 
			unless element['alt']
				messages << ErrorMessage.new(:missing_area_alt, element['name'] || element['id'] || "unknown") 
			else
				if element['alt'].length == 0
					messages << ErrorMessage.new(:missing_area_alt_text, element['name'] || element['id'] || "unknown")
				end
			end
		}

		messages
    end



	# Verify that the document has a non-empty title element.
    def check_title
      title = @doc.at('title')
      return [ErrorMessage.new(:missing_title)] unless title
      return [ErrorMessage.new(:empty_title)] if normalize_text(title.inner_html).empty?
      []			
    end

  
	# Verify that the document has at least one h1 element.
    def check_has_heading
      return [ErrorMessage.new(:missing_heading)] if (@doc/"h1").empty?
      []
    end


	# Verify that heading elements (h1-h6) appear in the correct order (no levels skipped). See UWEM 1.0 Test 3.5_HTML_03.
    def check_document_structure
      messages = []
      currentitem = 0
      
      for heading in headings
        if currentitem == 0
          if level(heading.name) != 1
            messages << ErrorMessage.new(:first_h_not_h1, "h" + heading.name[1,1])
          end
        else
          if level(heading.name) - level(headings[currentitem - 1].name) > 1
            messages << ErrorMessage.new(:wrong_h_structure)
            break
          end  
        end
        
        currentitem += 1
        
      end
      
      messages
    end

    
	# Verify that the document does not have any nested tables. This is indicative of a table-based layout.
    def check_for_nested_tables
      
      messages = []  
      tables = (@doc/"table")
      
      for table in tables
        unless (table/"table").empty?
          return messages << ErrorMessage.new(:has_nested_tables)
        end
      end
      
      messages
    end

    
	# Verify that all tables have at least on table header (th) element.
    def check_tables
      messages = []  
      tables = (@doc/"table")   
      currenttable = 1
      
      for table in tables     
      	hasth = false
        hasth = true unless (table/">tr>th").empty?
        hasth = true unless (table/">thead>tr>th").empty?
        hasth = true unless (table/">tbody>tr>th").empty?
        
        messages << ErrorMessage.new(:missing_th, currenttable.to_s) unless hasth
                
        currenttable += 1
      end
      
      messages
    end
    
    

	# Verify that no formatting elements have been used. See UWEM 1.0 Test 7.2_HTML_01 and Test 7.3_HTML_01.
    def check_for_formatting_elements
      
      	messages = []

	  	formatting_elements = %w(font b i u tt small big strike s)
		formatting_elements = %w(font u tt small big strike s) if @ignore_bi
	  
	    formatting_items = (@doc/formatting_elements.join('|'))
      
      	unless formatting_items.empty?
			found_elements = []
			for element in formatting_items
				found_elements << element.name
			end
        	messages << ErrorMessage.new(:missing_semantics, "#{found_elements.uniq.join(', ')}")  
	    end
	  
	    flicker_elements = %w(blink marquee)
	    flicker_items = (@doc/flicker_elements.uniq.join('|'))
	    
      	unless flicker_items.empty?
        	messages << ErrorMessage.new(:has_flicker)  
      	end

      	messages   
    end
    
    
	# Verify that the root documet html element as a lang attribute.
    def check_for_language_info
      messages = []  
	  unless (@doc/'html[@lang]').empty?
	  	lang_code = (@doc/"html").first["lang"].to_s
	  	if lang_code.length < 2
      		messages << ErrorMessage.new(:missing_lang_info) 
	  	end
	  else
      	messages << ErrorMessage.new(:missing_lang_info) 
	  end
	  messages
    end


	# Verify that the html element has a valid lang code.
	def check_valid_language_code
	  messages = []
	  unless (@doc/"html[@lang]").empty?
		#load list of valid language codes
		#iso_lang_codes = []
		#IO.foreach(File.dirname(__FILE__) + "/iso_language_codes.txt") { |code| iso_lang_codes << code.chomp }

		doc_main_lang_code = (@doc/"html").first["lang"].to_s.downcase
		unless ISO_CODES.include?(doc_main_lang_code[0..1])
			messages << ErrorMessage.new(:wrong_lang_code, doc_main_lang_code)
		end
	  end

	  messages
	end
    
    
	# Verify that no link texts are ambiguous. A typical example is the presence of multiple "Read more" links.
    def check_link_text
      links = get_links
      
      link = links.find do |link|
        links.find { |cmp_link| is_ambiguous_link(link, cmp_link) }
      end
      
      return [] unless link
      [ErrorMessage.new(:ambiguous_link_text, get_link_text(link))]
    end
        
    
	# Verify that all form fields have a corresponding label element. See UWEM 1.0 Test 12.4_HTML_02.
    def check_form
      messages = []
      labels = get_labels
      fields = get_editable_fields
      
      #make sure all fields have associated labels
      label_for_ids = []
      for label in labels
        if label["for"]
          label_for_ids << label["for"]
        end
      end
      
      field_id = nil
      
      for field in fields
        field_id = (field["id"] || "")
        field_identifier = (field["id"] || field["name"] || "unknown")
        if not label_for_ids.include?(field_id)
          messages << ErrorMessage.new(:field_missing_label, field_identifier)
        end
      end   
      
      messages
    end
    
    
	# Verify that all frame elements have a title atribute.
    def check_frames
	  # Covers UWEM Test 12.1_HTML_01
      return [] unless is_frameset
      
      (@doc/"frame").find_all do |frame|
        frame_title = frame['title'] || ''
        normalize_text(frame_title).empty?
      end.map { |frame| ErrorMessage.new(:missing_frame_title, frame['src']) }            
    end
    
    
	# Verify that the document does not use meta-refresh to redirect the user away after a period of time.
    def check_refresh
      meta_elements = (@doc/'meta')
      
      meta_elements.find_all do |element|
        element["http-equiv"] == "refresh"
      end.map { ErrorMessage.new(:has_meta_refresh) }
    end
    

	def check_difficult_words
      messages = []
		if @wordlist

			# get document text (and all title and ait attributes but remove blockquote and q elements)

			# remove q and blockquotes
			@doc.search("blockquote").remove
			@doc.search("q").remove

			doctext = @doc.inner_text

			#add alt texts
			@doc.search("*[@alt]").each { |item|
				doctext += " " + item['alt']
				doctext += ", "
			}

			#add title texts
			@doc.search("*[@title]").each { |item|
				doctext += " " + item['title']
				doctext += ", "
			}

			@wordlist.each { |key, value| 
				re = Regexp.new("\\b" + key.sub(/ /, "\\s+") + "\\b", true)   
				if doctext =~ re
					# loop over all keys in wordlist
					messages << ErrorMessage.new(:difficult_word, value)
				end
			}
			
			
		end
		return messages
	end
    



    # Utility methods    
    def headings
		items = []
	 	@doc.traverse_element("h1", "h2", "h3", "h4", "h5", "h6") { |heading|
			items << heading
	  	}
		return items
    end

    
    def level(heading)
      Integer(heading[1].chr)
    end

    
	def downcase_hash_keys(a_hash)
		downcased_hash = {}
		a_hash.collect {|key,value| downcased_hash[key.downcase] = value}
		return downcased_hash
	end

	def parse_charset(contenttype)
		# get charset identifier from content type string
		if contenttype=~/charset=(.*)\w?/ then
			return $1.downcase.strip
		end

		return ""
	end


    def is_ambiguous_link(link_a, link_b)
      return false if links_point_to_same_resource?(link_a, link_b)
      return true if link_text_identical?(link_a, link_b) &&
                     link_title_identical?(link_a, link_b)
      
      false
    end
    
    def get_links      
      (@doc/'a')
    end

    def langinfo(element)
      langval = ""
      
      if element.class.to_s == 'Tag'      
        if element['lang']
          langval = element['lang']
        end      
      else
        return nil
      end
      
      return langval
    end    
    
    
    def alt_to_text(element)
		if element.kind_of?(Hpricot::Elem) then
      		element.has_attribute?("alt") ? element['alt'] : ""
		else
			""
		end
    end

    def elements_to_text(element)
      str = ''
      element.traverse_all_element do |elem|
        elem.kind_of?(Hpricot::Text) ? str += "#{elem}" : str += alt_to_text(elem)
      end
      
      str
    end
    
    
    def normalize_text(text)
      text ||= ''
      retval = text.gsub(/&nbsp;/, ' ')
      retval = retval.gsub(/&#160;/, ' ')
      retval = retval.gsub(/\n/, '')
      retval = retval.gsub(/\r/, '')
      retval = retval.gsub(/\t/, '')
      while /  /.match(retval) do
        retval = retval.gsub(/  /, ' ')
      end
      
      retval = retval.strip
      
      return retval
    end
    
    
    def get_labels
      @doc/'label'
    end


    def get_editable_fields
      allfields = (@doc/"textarea|select|input")
      fields = []
      field_type = ""
      
      for field in allfields do
        field_type = field["type"] || ""
        unless ["button", "submit", "hidden", "image"].include?(field_type)
          fields << field
        end
        
      end
      
      return fields
    end
        
        
    def is_frameset
      (@doc/"frameset").length > 0
    end    
    
    
    def link_text_identical?(link_a, link_b)
      get_link_text(link_a) == get_link_text(link_b)
    end
    
    def link_title_identical?(link_a, link_b)
      get_link_title(link_a) == get_link_title(link_b)
    end
    
    def links_point_to_same_resource?(link_a, link_b)
      (link_a == link_b) ||
      (get_link_url(link_a) == get_link_url(link_b))
    end
    
    def get_link_text(link)
      text = (elements_to_text(link) || '').strip
      normalize_text(text)
    end
    
    def get_link_url(link)
      link['href']
    end
    
    def get_link_title(link)
      text = (link['title'] || '').strip
      normalize_text(text)
    end

  end

end
