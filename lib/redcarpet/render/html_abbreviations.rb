# frozen_string_literal: true

require 'uri'
require 'securerandom'

module Redcarpet
  module Render
    module HTMLAbbreviations
      REGEXP = /^\*\[([^\]]+)\]: (.+)$/

      def preprocess(document)
        without_urls(document) do
          abbreviations = document.scan(REGEXP)
          abbreviations = Hash[*abbreviations.flatten]

          if abbreviations.any?
            document.gsub!(REGEXP, '')
            document.rstrip!

            abbreviations.each do |key, value|
              html = <<-ABBR.strip
                <abbr title="#{value}">#{key}</abbr>
              ABBR

              document.gsub!(acronym_regexp(key), html)
            end
          end
        end

        document
      end

      def acronym_regexp(acronym)
        /\b#{acronym}((?<=\.)|\b)/
      end

      def without_urls(document)
        urls = {}
        document.gsub!(URI::DEFAULT_PARSER.make_regexp) do |url|
          uuid = SecureRandom.uuid
          urls[uuid] = url
          uuid
        end

        yield

        urls.each do |uuid, url|
          document.gsub!(uuid, url)
        end
      end
    end
  end
end
