# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{raakt}
  s.version = "0.5.6"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Peter Krantz"]
  s.date = %q{2010-08-29}
  s.description = %q{A toolkit to find basic accessibility issues in HTML documents.}
  s.email = %q{peter.krantzNODAMNSPAM@gmail.com}
  s.extra_rdoc_files = ["CHANGELOG", "LICENSE", "README", "TODO", "lib/iso_language_codes.rb", "lib/raakt.rb"]
  s.files = ["CHANGELOG", "LICENSE", "Manifest", "README", "TODO", "examples/acctest.rb", "examples/crawlandtest.rb", "examples/list_site_urls.rb", "examples/seleniumrc_example.rb", "examples/svarta_listan.rb", "examples/watir_example.rb", "lib/iso_language_codes.rb", "lib/raakt.rb", "raakt.gemspec", "rakefile", "service/files/base.css", "service/files/button-left.png", "service/files/button-right.png", "service/files/grad.png", "service/files/jquery-131.js", "service/files/round-br.png", "service/files/round-tl.png", "service/files/round-tr.png", "service/files/tab-tl.png", "service/files/tab-tr.png", "service/files/test.js", "service/files/textbg.png", "service/files/w3c.png", "service/index.rhtml", "service/server.rb", "tests/areadoc1.htm", "tests/areadoc2.htm", "tests/areadoc3.htm", "tests/bdoc.htm", "tests/charset_nocharset_specified.htm", "tests/charset_utf8.htm", "tests/difficult_words1.htm", "tests/difficult_words2.htm", "tests/difficult_words3.htm", "tests/difficult_words4.htm", "tests/difficult_words5.htm", "tests/difficult_words6.htm", "tests/difficult_words7.htm", "tests/embeddoc1.htm", "tests/empty.htm", "tests/emptytitledoc.htm", "tests/fielddoc1.htm", "tests/fielddoc2.htm", "tests/fielddoc3.htm", "tests/flickerdoc1.htm", "tests/formdoc1.htm", "tests/formdoc2.htm", "tests/formdoc3.htm", "tests/framedoc1.htm", "tests/framedoc2.htm", "tests/full_berg.htm", "tests/full_google.htm", "tests/headingsdoc1.htm", "tests/headingsdoc10.htm", "tests/headingsdoc2.htm", "tests/headingsdoc3.htm", "tests/headingsdoc4.htm", "tests/headingsdoc5.htm", "tests/headingsdoc6.htm", "tests/headingsdoc7.htm", "tests/headingsdoc8.htm", "tests/headingsdoc9.htm", "tests/imagedoc1.htm", "tests/imagedoc2.htm", "tests/imagedoc3.htm", "tests/imagedoc4.htm", "tests/inputimgdoc1.htm", "tests/invalidelements1.htm", "tests/invalidhtmldoc1.htm", "tests/invalidhtmldoc2.htm", "tests/invalidxhtmldoc1.htm", "tests/langinfodoc1.htm", "tests/langinfodoc2.htm", "tests/linkdoc1.htm", "tests/linkdoc2.htm", "tests/linkdoc3.htm", "tests/linkdoc4.htm", "tests/metarefreshdoc1.htm", "tests/metarefreshdoc2.htm", "tests/metarefreshdoc3.htm", "tests/nestedcomment.htm", "tests/nestedtabledoc.htm", "tests/newlinetext.txt", "tests/raakt_test.rb", "tests/scriptdoc1.htm", "tests/scriptdoc2.htm", "tests/tabledoc1.htm", "tests/tabledoc2.htm", "tests/tabledoc3.htm", "tests/tabledoc4.htm", "tests/tabledoc5.htm", "tests/tabledoc6.htm", "tests/tabledoc7.htm", "tests/tablelayoutdoc.htm", "tests/test_helper.rb", "tests/xhtmldoc1.htm", "Rakefile"]
  s.homepage = %q{http://www.peterkrantz.com/raakt/wiki/}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Raakt", "--main", "README"]
  s.require_paths = ["lib"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.8.2")
  s.rubyforge_project = %q{raakt}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{A toolkit to find basic accessibility issues in HTML documents.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<hpricot>, [">= 0.6"])
    else
      s.add_dependency(%q<hpricot>, [">= 0.6"])
    end
  else
    s.add_dependency(%q<hpricot>, [">= 0.6"])
  end
end
