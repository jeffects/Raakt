require File.dirname(__FILE__) + '/test_helper'
require File.dirname(__FILE__) + '/../lib/raakt'

class RaaktTest < Test::Unit::TestCase
  
  def setup
    @raakt = Raakt::Test.new
  end
  
  def test_all
    @raakt.doc = data_full_google
    assert_equal 7, @raakt.all.length
  end

  def test_check_fieldset_legend
	@raakt.doc = data_formdoc1
	assert_equal 1, @raakt.check_fieldset_legend.length

	@raakt.doc = data_formdoc2
	assert_equal 0, @raakt.check_fieldset_legend.length

	@raakt.doc = data_formdoc3
	assert_equal 2, @raakt.check_fieldset_legend.length
  end

  def test_check_embed
	@raakt.doc = data_embeddoc1
	assert_equal 1, @raakt.check_embed.length

	@raakt.doc = data_empty
	assert_equal 0, @raakt.check_embed.length
  end
  
  def test_check_character_set
	@raakt.doc = data_charset_utf8
	test_headers = {"Content-Type" => "text/html; charset=ISO-8859-1"}
	@raakt.headers = test_headers
	assert_equal 1, @raakt.check_character_set.length

	@raakt.doc = data_charset_utf8
	test_headers = {"Content-Type" => "text/html; charset=utf-8"}
	@raakt.headers = test_headers
	assert_equal 0, @raakt.check_character_set.length

	@raakt.doc = data_charset_nocharset_specified
	@raakt.headers = nil
	assert_equal 0, @raakt.check_character_set.length
  end


  def test_check_input_type_img
	@raakt.doc = data_inputimgdoc1
	assert_equal 2, @raakt.check_input_type_img.length
	assert_equal "1the_name", @raakt.check_input_type_img[0].note
	assert_equal "3the_id", @raakt.check_input_type_img[1].note
  end


  def test_check_areas
    @raakt.doc = data_areadoc1
    assert_equal 1, @raakt.check_areas.length
    assert_equal :missing_area_alt, @raakt.check_areas[0].eid  
	
    @raakt.doc = data_areadoc2
    assert_equal 0, @raakt.check_areas.length

    @raakt.doc = data_areadoc3
    assert_equal 1, @raakt.check_areas.length
    assert_equal :missing_area_alt_text, @raakt.check_areas[0].eid  
  end
  

  def test_check_images
    @raakt.doc = data_imagedoc1
    assert_equal 1, @raakt.check_images.length
    assert_equal :missing_alt, @raakt.check_images[0].eid    
    
    @raakt.doc = data_imagedoc2
    assert_equal 0, @raakt.check_images.length
    
    @raakt.doc = data_imagedoc3
    assert_equal 3, @raakt.check_images.length
    
    @raakt.doc = data_imagedoc4
    assert_equal 1, @raakt.check_images.length
  end
  

  def test_check_images_in_blank_doc
    @raakt.doc = data_empty
    assert_equal 0, @raakt.check_images.length    
  end
  
  
  def test_check_title
    @raakt.doc = data_xhtmldoc1
    assert_equal 0, @raakt.check_title.length
    
    @raakt.doc = data_empty
    assert_equal 1, @raakt.check_title.length
    assert_equal :missing_title, @raakt.check_title[0].eid
    
    @raakt.doc = data_emptytitledoc
    assert_equal 1, @raakt.check_title.length 
    assert_equal :empty_title, @raakt.check_title[0].eid
    
    @raakt.doc = data_invalidhtmldoc1
    assert_equal 0, @raakt.check_title.length 
    
    @raakt.doc = data_invalidhtmldoc2
    assert_equal 0, @raakt.check_title.length 
  end
  
  
  def test_headings
    @raakt.doc = data_headingsdoc1
    assert_equal 3, @raakt.headings.length
    
    @raakt.doc = data_invalidhtmldoc2
    assert_equal 0, @raakt.headings.length
  end
  
  
  def test_level
    assert_equal 1, @raakt.level("h1")
    assert_equal 2, @raakt.level("h2")
    assert_equal 6, @raakt.level("h6")
  end
  
  
  
  def test_check_has_heading
    @raakt.doc = data_empty
    assert_equal 1, @raakt.check_has_heading.length
    assert_equal :missing_heading, @raakt.check_has_heading[0].eid
    
    @raakt.doc = data_headingsdoc1
    assert_equal 0, @raakt.check_has_heading.length
    
    # This now works thanks to hpricot.
    @raakt.doc = data_headingsdoc9
    assert_equal 1, @raakt.check_has_heading.length
    assert_equal :missing_heading, @raakt.check_has_heading[0].eid
     
     
    @raakt.doc = data_invalidhtmldoc2
    assert_equal 1, @raakt.check_has_heading.length
    assert_equal :missing_heading, @raakt.check_has_heading[0].eid
  end
  
  
  def test_check_document_structure
    
    @raakt.doc = data_headingsdoc1
    assert_equal 0, @raakt.check_document_structure.length
    
    @raakt.doc = data_headingsdoc3
    assert_equal 1, @raakt.check_document_structure.length
    assert_equal :first_h_not_h1, @raakt.check_document_structure[0].eid
    
    @raakt.doc = data_headingsdoc4
    assert_equal :wrong_h_structure, @raakt.check_document_structure[0].eid
    
    @raakt.doc = data_headingsdoc5
    assert_equal :first_h_not_h1, @raakt.check_document_structure[0].eid
    assert_equal :wrong_h_structure, @raakt.check_document_structure[1].eid
    
    @raakt.doc = data_headingsdoc6
    assert_equal 0, @raakt.check_document_structure.length
    
    @raakt.doc = data_headingsdoc10
    assert_equal 1, @raakt.check_document_structure.length
    assert_equal :first_h_not_h1, @raakt.check_document_structure[0].eid

    @raakt.doc = data_empty
    assert_equal 0, @raakt.check_document_structure.length
  end
  
  
  def test_check_for_nested_tables
    @raakt.doc = data_tabledoc1
    assert_equal 0, @raakt.check_for_nested_tables.length
    
    @raakt.doc = data_tabledoc2
    assert_equal 0, @raakt.check_for_nested_tables.length
    
    @raakt.doc = data_tabledoc3
    assert_equal 1, @raakt.check_for_nested_tables.length
    assert_equal :has_nested_tables, @raakt.check_for_nested_tables[0].eid

    @raakt.doc = data_tabledoc4
    assert_equal 0, @raakt.check_for_nested_tables.length
    
    @raakt.doc = data_tabledoc5
    assert_equal 1, @raakt.check_for_nested_tables.length

	@raakt.doc = data_nestedtabledoc
	assert_equal 1, @raakt.check_for_nested_tables.length
  end
  
  
  def test_check_tables
    @raakt.doc = data_tabledoc4
    assert_equal 0, @raakt.check_tables.length
    
    @raakt.doc = data_tabledoc1
    assert_equal 0, @raakt.check_tables.length
    
    @raakt.doc = data_tabledoc2
    assert_equal 2, @raakt.check_tables.length
  
    @raakt.doc = data_tabledoc7
    assert_equal 0, @raakt.check_tables.length
  
    # More accurate count here due to hpricot
    @raakt.doc = data_full_berg
    assert_equal 21, @raakt.check_tables.length
  end
  
  def test_check_for_formatting_elements
    @raakt.doc = data_invalidelements1
    invaliderrs = @raakt.check_for_formatting_elements

    assert_equal 2, invaliderrs.length
    assert_equal :missing_semantics, invaliderrs[0].eid
    assert_equal :has_flicker, invaliderrs[1].eid
    
    @raakt.doc = data_xhtmldoc1
    assert_equal 0, @raakt.check_for_formatting_elements.length
  end

  
  
  def test_check_for_language_info
    @raakt.doc = data_xhtmldoc1
    assert_equal 0, @raakt.check_for_language_info.length
    
    @raakt.doc = data_tabledoc2
    assert_equal 1, @raakt.check_for_language_info.length
    
    @raakt.doc = data_tablelayoutdoc
    assert_equal 1, @raakt.check_for_language_info.length   
    
    @raakt.doc = data_langinfodoc1
    assert_equal 0, @raakt.check_for_language_info.length

    @raakt.doc = data_langinfodoc2
    assert_equal 1, @raakt.check_for_language_info.length
  end


  def test_check_valid_language_code
	@raakt.doc = data_langinfodoc1
	assert_equal 0, @raakt.check_valid_language_code.length

	@raakt.doc = data_empty
	assert_equal 0, @raakt.check_valid_language_code.length

	@raakt.doc = data_xhtmldoc1
	assert_equal 0, @raakt.check_valid_language_code.length
  end
  
  
  def test_check_link_text
    @raakt.doc = data_linkdoc1
    assert_equal 1, @raakt.check_link_text.length
    assert_equal :ambiguous_link_text, @raakt.check_link_text[0].eid
    
    @raakt.doc = data_linkdoc3
    assert_equal 0, @raakt.check_link_text.length
    
    @raakt.doc = data_linkdoc2
    assert_equal 0, @raakt.check_link_text.length
    
    @raakt.doc = data_linkdoc4
    assert_equal 1, @raakt.check_link_text.length
  end
  
  
  def test_get_links
    @raakt.doc = data_linkdoc1
    assert_equal 8, @raakt.get_links.length
    
    @raakt.doc = data_linkdoc4
    assert_equal 2, @raakt.get_links.length
    assert_equal "Read more", @raakt.get_link_text(@raakt.get_links[0])
  end
  
  def test_alt_to_text
    element = Hpricot("<img src='123' alt='Read more' />").at('img')
    assert_equal "Read more", @raakt.alt_to_text(element)
  end
  
  def test_elements_to_text
    element = Hpricot("<a href='rrr'>Read <img src='123' alt='more' /> about</a>").at('a')
    assert_equal "Read more about", @raakt.elements_to_text(element)
    element2 = Hpricot("<a href='r'><strong><i>A</i></strong> sample <img src='123' alt='text' /> <b>here</b></a>").at('a')
    assert_equal "A sample text here", @raakt.elements_to_text(element2)
  end
  
  def test_normalize_text
    assert_equal "Read more", @raakt.normalize_text("Read&nbsp;more")
    assert_equal "Read more", @raakt.normalize_text("Read&#160;more") 
    assert_equal "Read more", @raakt.normalize_text("Read  more")
    assert_equal "Read more", @raakt.normalize_text("Read    more")
    assert_equal "Read more", @raakt.normalize_text("Read     more")
    assert_equal "Read more", @raakt.normalize_text("Read\n more")
    assert_equal "Läs mer",   @raakt.normalize_text("Läs\n mer")
    assert_equal "Läs mer",   @raakt.normalize_text("Läs \nmer")
    assert_equal "Read more", @raakt.normalize_text("Read \n\n\nmore")
    assert_equal "Read more", @raakt.normalize_text("Read \tmore") 
    assert_equal "Read more", @raakt.normalize_text("  Read more")   
  end
  
  def test_is_ambiguous_link
    link_a = Hpricot("<a href='/news/1'>Read more</a>").at('a')
    link_b = Hpricot("<a href='/news/2'>Read more</a>").at('a')   
    assert_equal true, @raakt.is_ambiguous_link(link_a, link_b)
    
    link_c = Hpricot("<a href='/news/1' title='More about first news item'>Read more</a>").at('a')
    link_d = Hpricot("<a href='/news/2' title='More about second news item'>Read more</a>").at('a')  
    assert_equal false, @raakt.is_ambiguous_link(link_c, link_d)
    
    link_e = Hpricot("<a href='/news/1'>Read more</a>").at('a')
    link_f = Hpricot("<a href='/news/1'>Read more</a>").at('a')   
    assert_equal false, @raakt.is_ambiguous_link(link_e, link_f)
    
    link_g = Hpricot("<a href='/news/1'>Läs mer</a>").at('a')
    link_h = Hpricot("<a href='/news/2'>Läs\n mer</a>").at('a')   
    assert_equal true, @raakt.is_ambiguous_link(link_g, link_h)
    
    link_i = Hpricot("<a href='/news/1'>Läs mer</a>").at('a')
    link_j = Hpricot("<a href='/news/2'>Läs \nmer</a>").at('a')   
    assert_equal true, @raakt.is_ambiguous_link(link_i, link_j)   
  end
  
  
  def test_get_labels
    @raakt.doc = data_fielddoc1
    assert_equal 1, @raakt.get_labels.length
    
    @raakt.doc = data_fielddoc2
    assert_equal 1, @raakt.get_labels.length
    
    @raakt.doc = data_fielddoc3
    assert_equal 2, @raakt.get_labels.length
  end
  
  
  def test_get_editable_fields
    @raakt.doc = data_fielddoc1
    assert_equal 1, @raakt.get_editable_fields.length
    
    @raakt.doc = data_fielddoc2
    assert_equal 2, @raakt.get_editable_fields.length
    
    @raakt.doc = data_fielddoc3
    assert_equal 3, @raakt.get_editable_fields.length
  end
  
  
  def test_check_form
    @raakt.doc = data_fielddoc1
    assert_equal 0, @raakt.check_form.length
    
    @raakt.doc = data_fielddoc2
    assert_equal 1, @raakt.check_form.length
    assert_equal :field_missing_label, @raakt.check_form[0].eid
    
    @raakt.doc = data_fielddoc3
    assert_equal 1, @raakt.check_form.length
    assert_equal :field_missing_label, @raakt.check_form[0].eid
  end
  
  
  def test_is_frameset
    @raakt.doc = data_framedoc1
    assert @raakt.is_frameset
    
    @raakt.doc = data_framedoc2
    assert @raakt.is_frameset
    
    @raakt.doc = data_xhtmldoc1
    assert !@raakt.is_frameset
  end
  
  
  def test_check_frames
    @raakt.doc = data_framedoc1
    assert_equal 3, @raakt.check_frames.length
    
    @raakt.doc = data_framedoc2
    assert_equal 0, @raakt.check_frames.length
  end
  
  

 

  def test_use_ignore_bi_setting
	@raakt.ignore_bi = true
	@raakt.doc = data_bdoc
	assert_equal 0, @raakt.check_for_formatting_elements.length
	@raakt.ignore_bi = false
	assert_equal 1, @raakt.check_for_formatting_elements.length
  end


  def test_refresh
    @raakt.doc = data_metarefreshdoc1
    assert_equal 1, @raakt.check_refresh.length
    
    @raakt.doc = data_metarefreshdoc2
    assert_equal 1, @raakt.check_refresh.length
    
    @raakt.doc = data_metarefreshdoc3
    assert_equal 1, @raakt.check_refresh.length
    
    @raakt.doc = data_xhtmldoc1
    assert_equal 0, @raakt.check_refresh.length
  end




  def test_difficult_words_combinations
	  #words tat are part of other words should not be flagged
	  @raakt.wordlist = { 
		  "reticent" => "Use a 'did not want to say' instead.",
		  "taciturn" => "Use a different phrase.",
	  }

	  @raakt.doc = data_difficult_words5
	  assert_equal 0, @raakt.check_difficult_words.length
  end


  def test_difficult_words_ignore_case
	  #words tat are part of other words should not be flagged
	  @raakt.wordlist = { 
		  "reticent" => "Use a 'did not want to say' instead.",
	  }

	  @raakt.doc = data_difficult_words7
	  assert_equal 1, @raakt.check_difficult_words.length
  end


  def test_difficult_words_exclude_blockquoted_text
	  #words that are part of a blockquote should not be flagged
	  @raakt.wordlist = { 
		  "reticent" => "Use a 'did not want to say' instead.",
	  }
	  @raakt.doc = data_difficult_words6
	  assert_equal 0, @raakt.check_difficult_words.length
  end


  def test_difficult_words_exclude_text_in_q_elements
	  #words that are part of a q-element should not be flagged
	  @raakt.wordlist = { 
		  "reticent" => "Use a 'did not want to say' instead.",
	  }
	  @raakt.doc = data_difficult_words6
	  assert_equal 0, @raakt.check_difficult_words.length
  end



  def test_difficult_words_accented_chars
	  #Phrases
	  @raakt.wordlist = { 
		  "anhängiggöra" => "Använd 'väcka/inleda' istället",
	  }

	  @raakt.doc = data_difficult_words6
	  assert_equal 1, @raakt.check_difficult_words.length
  end


  def test_difficult_words_phrases
	  #Phrases
	  @raakt.wordlist = { 
		  "a phrase" => "Use something else instead.",
	  }

	  @raakt.doc = data_difficult_words6
	  assert_equal 1, @raakt.check_difficult_words.length
  end
  

  def test_difficult_words
	  @raakt.wordlist = { 
		  "reticent" => "Use a 'did not want to say' instead.",
		  "taciturn" => "Use a different phrase.",
	  }

	  @raakt.doc = data_xhtmldoc1
	  assert_equal 0, @raakt.check_difficult_words.length

	  @raakt.doc = data_difficult_words1
	  assert_equal 2, @raakt.check_difficult_words.length

	  #Make sure text in alt attribute is found
	  @raakt.doc = data_difficult_words2
	  assert_equal 1, @raakt.check_difficult_words.length

	  #Make sure text in title attribute is found
	  @raakt.doc = data_difficult_words3
	  assert_equal 2, @raakt.check_difficult_words.length

	  @raakt.doc = data_difficult_words4
	  assert_equal 2, @raakt.check_difficult_words.length
  end

end
