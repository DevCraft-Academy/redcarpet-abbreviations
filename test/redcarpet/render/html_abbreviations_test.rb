require File.expand_path('../../test_helper', __dir__)

describe Redcarpet::Render::HTMLAbbreviations do
  before do
    @renderer = Class.new do
      include Redcarpet::Render::HTMLAbbreviations
    end
  end

  describe '#preprocess' do
    it 'converts markdown abbrevations to HTML' do
      markdown = <<-MARKDOWN.strip_heredoc
        YOLO

        *[YOLO]: You Only Live Once
      MARKDOWN

      _(@renderer.new.preprocess(markdown)).must_equal <<-MARKDOWN.strip_heredoc.chomp
        <abbr title="You Only Live Once">YOLO</abbr>
      MARKDOWN
    end

    it 'converts hyphenated abbrevations to HTML' do
      markdown = <<-MARKDOWN.strip_heredoc
        JSON-P

        *[JSON-P]: JSON with Padding
      MARKDOWN

      _(@renderer.new.preprocess(markdown)).must_equal <<-MARKDOWN.strip_heredoc.chomp
        <abbr title="JSON with Padding">JSON-P</abbr>
      MARKDOWN
    end

    it 'converts abbrevations with numbers to HTML' do
      markdown = <<-MARKDOWN.strip_heredoc
        ES6

        *[ES6]: ECMAScript 6
      MARKDOWN

      _(@renderer.new.preprocess(markdown)).must_equal <<-MARKDOWN.strip_heredoc.chomp
        <abbr title="ECMAScript 6">ES6</abbr>
      MARKDOWN
    end

    it 'converts abbrevations with unicode, lowercase and spaces to HTML' do
      markdown = <<-MARKDOWN.strip_heredoc
        É.-U. d'A.

        *[É.-U. d'A.]: États-Unis d'Amérique
      MARKDOWN

      _(@renderer.new.preprocess(markdown)).must_equal <<-MARKDOWN.strip_heredoc.chomp
        <abbr title="États-Unis d'Amérique">É.-U. d'A.</abbr>
      MARKDOWN
    end

    it "doesn't convert an abbreviation which is part of a word" do
      markdown = <<-MARKDOWN.strip_heredoc
        This is about the event `DOMContentLoaded`.

        *[DOM]: Document Object Model
      MARKDOWN

      _(@renderer.new.preprocess(markdown)).must_equal <<-MARKDOWN.strip_heredoc.chomp
        This is about the event `DOMContentLoaded`.
      MARKDOWN
    end

    it "doesn't convert an abbreviation within a link URL but within the link text" do
      markdown = <<-MARKDOWN.strip_heredoc
        [DOM](https://developer.mozilla.org/en-US/docs/Web/API/Document_Object_Model)

        *[DOM]: Document Object Model
        *[API]: Application Programming Interface
      MARKDOWN

      _(@renderer.new.preprocess(markdown)).must_equal <<-MARKDOWN.strip_heredoc.chomp
        [<abbr title="Document Object Model">DOM</abbr>](https://developer.mozilla.org/en-US/docs/Web/API/Document_Object_Model)
      MARKDOWN
    end
  end

  describe '#acronym_regexp' do
    it 'matches an acronym at the beginning of a line' do
      _('FOO bar').must_match @renderer.new.acronym_regexp('FOO')
    end

    it 'matches an acronym at the end of a line' do
      _('bar FOO').must_match @renderer.new.acronym_regexp('FOO')
    end

    it 'matches an acronym next to punctuation' do
      _('.FOO.').must_match @renderer.new.acronym_regexp('FOO')
    end

    it 'matches an acronym with hyphens' do
      _('JSON-P').must_match @renderer.new.acronym_regexp('JSON-P')
    end

    it "doesn't match an acronym in the middle of a word" do
      _('YOLOFOOYOLO').wont_match @renderer.new.acronym_regexp('FOO')
    end

    it 'matches numbers' do
      _('ES6').must_match @renderer.new.acronym_regexp('ES6')
    end
  end
end
